import json
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import requests
from io import BytesIO
import math

# --- Helper Functions ---

def hex_to_rgba(hex_color, opacity=1.0):
    """Converts hex color to RGBA tuple."""
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 3: # Expand shorthand hex (e.g., #03F to #0033FF)
        hex_color = "".join([c*2 for c in hex_color])
    
    if len(hex_color) == 6: # RGB
        r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        return (r, g, b, int(opacity * 255))
    elif len(hex_color) == 8: # RGBA
        r, g, b, a_hex = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4, 6))
        # Modulate the hex alpha with the style's opacity
        return (r, g, b, int((a_hex / 255.0) * opacity * 255))
    raise ValueError(f"Invalid hex color: {hex_color}")


def apply_box_fit(img, target_width, target_height, box_fit_str):
    """Applies BoxFit logic to an image. Ensures target dimensions are positive."""
    target_width = max(1, int(target_width))
    target_height = max(1, int(target_height))
    
    img_width, img_height = img.size
    if img_width == 0 or img_height == 0: # Cannot process zero-size image
        return Image.new("RGBA", (target_width, target_height), (0,0,0,0))

    target_aspect = target_width / target_height
    img_aspect = img_width / img_height

    if box_fit_str == "BoxFit.fill":
        return img.resize((target_width, target_height), Image.Resampling.LANCZOS)
    elif box_fit_str == "BoxFit.contain":
        if img_aspect > target_aspect: # Image is wider than target
            new_width = target_width
            new_height = int(new_width / img_aspect)
        else: # Image is taller than target or same aspect
            new_height = target_height
            new_width = int(new_height * img_aspect)
        
        new_width = max(1, new_width)
        new_height = max(1, new_height)
        img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        new_img = Image.new("RGBA", (target_width, target_height), (0,0,0,0))
        paste_x = (target_width - new_width) // 2
        paste_y = (target_height - new_height) // 2
        new_img.paste(img, (paste_x, paste_y), img if img.mode == 'RGBA' else None)
        return new_img
    elif box_fit_str == "BoxFit.cover":
        if img_aspect > target_aspect: # Image is wider, scale by height and crop width
            new_height = target_height
            new_width = int(new_height * img_aspect)
            img = img.resize((max(1,new_width), max(1,new_height)), Image.Resampling.LANCZOS)
            crop_x = (new_width - target_width) // 2
            img = img.crop((crop_x, 0, crop_x + target_width, new_height))
        else: # Image is taller or same aspect, scale by width and crop height
            new_width = target_width
            new_height = int(new_width / img_aspect)
            img = img.resize((max(1,new_width), max(1,new_height)), Image.Resampling.LANCZOS)
            crop_y = (new_height - target_height) // 2
            img = img.crop((0, crop_y, new_width, crop_y + target_height))
        return img.resize((target_width, target_height), Image.Resampling.LANCZOS) # Ensure final size
    elif box_fit_str == "BoxFit.fitWidth":
        new_width = target_width
        new_height = int(new_width / img_aspect) if img_aspect > 0 else 0
        return img.resize((max(1,new_width), max(1,new_height)), Image.Resampling.LANCZOS)
    elif box_fit_str == "BoxFit.fitHeight":
        new_height = target_height
        new_width = int(new_height * img_aspect) if target_height > 0 else 0
        return img.resize((max(1,new_width), max(1,new_height)), Image.Resampling.LANCZOS)
    elif box_fit_str == "BoxFit.scaleDown":
        if img_width > target_width or img_height > target_height:
            return apply_box_fit(img, target_width, target_height, "BoxFit.contain")
        else:
            new_img = Image.new("RGBA", (target_width, target_height), (0,0,0,0))
            paste_x = (target_width - img_width) // 2
            paste_y = (target_height - img_height) // 2
            new_img.paste(img, (paste_x, paste_y), img if img.mode == 'RGBA' else None)
            return new_img
    else: # Default (e.g. BoxFit.none or unknown) - center and clip or simple paste
        new_img = Image.new("RGBA", (target_width, target_height), (0,0,0,0))
        paste_x = (target_width - img_width) // 2
        paste_y = (target_height - img_height) // 2
        new_img.paste(img.crop((0,0,target_width-paste_x, target_height-paste_y)), (paste_x, paste_y), img if img.mode == 'RGBA' else None)
        return new_img


def render_template_element(image_canvas, element_data, canvas_width, canvas_height, current_language, default_language_code, font_asset_path):
    """Renders a single TemplateElement onto the image_canvas."""
    box = element_data['box']
    style = element_data['style']
    content = element_data['content']
    el_type = element_data['type']

    el_x = box.get('x_px', (box.get('x_percent', 0) / 100.0) * canvas_width)
    el_y = box.get('y_px', (box.get('y_percent', 0) / 100.0) * canvas_height)
    el_width = box.get('width_px', (box.get('width_percent', 100) / 100.0) * canvas_width)
    el_height = box.get('height_px', (box.get('height_percent', 100) / 100.0) * canvas_height)
    rotation_angle = -box.get('rotation', 0) # Pillow rotates counter-clockwise

    el_x, el_y, el_width, el_height = int(el_x), int(el_y), int(el_width), int(el_height)

    el_layer_width = max(1, el_width)
    el_layer_height = max(1, el_height)
    element_layer = Image.new('RGBA', (el_layer_width, el_layer_height), (0, 0, 0, 0))
    element_draw = ImageDraw.Draw(element_layer)

    opacity = style.get('opacity', 1.0)

    if el_type == 'image':
        img_url = content.get('url')
        if img_url:
            try:
                response = requests.get(img_url, timeout=10)
                response.raise_for_status()
                img_data = BytesIO(response.content)
                el_image = Image.open(img_data).convert("RGBA")
                box_fit = style.get('imageFit', 'BoxFit.contain')
                el_image = apply_box_fit(el_image, el_layer_width, el_layer_height, box_fit)
                element_layer.paste(el_image, (0,0), el_image)
            except Exception as e:
                print(f"Error processing image {img_url}: {e}")

    elif el_type == 'text':
        text_to_render = ""
        if isinstance(content, dict):
            lang_content = content.get(current_language) or content.get(default_language_code) or content.get('fallback')
            if isinstance(lang_content, dict):
                text_to_render = lang_content.get('text', "")
            elif isinstance(lang_content, str):
                 text_to_render = lang_content
            if not text_to_render and 'text' in content :
                text_to_render = content['text']
        
        if text_to_render:
            font_color_hex = style.get('color', '#000000')
            font_color_rgba = hex_to_rgba(font_color_hex, 1.0)
            font_size_vw = style.get('font_size', 4.0)
            initial_font_size_px = max(1, int((font_size_vw / 100.0) * canvas_width))
            font_family = style.get('font_family', 'English')
            # NOTE: Font weight (e.g., style.get('font_weight')) is not directly applied here
            # as Pillow relies on the font file itself (e.g., "English-Bold.ttf") to contain
            # different weights. If the specified .ttf file is a single-weight font,
            # variations like 'FontWeight.w900' won't be rendered differently.
            actual_font_path = f"{font_asset_path}/{font_family}.ttf"

            lines = text_to_render.splitlines()
            
            final_font_size_px = initial_font_size_px
            if lines and el_layer_width > 0:
                try:
                    test_font = ImageFont.truetype(actual_font_path, final_font_size_px)
                    for line_to_test in lines:
                        while element_draw.textlength(line_to_test, font=test_font) > el_layer_width and final_font_size_px > 1:
                            final_font_size_px -= 1
                            test_font = ImageFont.truetype(actual_font_path, final_font_size_px)
                except IOError:
                    pass 

            try:
                font = ImageFont.truetype(actual_font_path, final_font_size_px)
            except IOError:
                print(f"Warning: Font '{actual_font_path}' at size {final_font_size_px} not found. Using Arial.")
                try: 
                    font = ImageFont.truetype("arial.ttf", final_font_size_px)
                except IOError: 
                    font = ImageFont.load_default()

            text_align = style.get('text_align', 'left')
            
            # Calculate total text block height for vertical centering
            total_text_block_height = 0
            line_heights_and_ascents = [] # Store (height, ascent_offset)
            if lines:
                for line_to_measure in lines:
                    current_line_height = 0
                    ascent_offset = 0 # Distance from top of line_to_measure to its baseline
                    if not line_to_measure.strip() and len(lines) > 1:
                        try:
                            # Use metrics of a placeholder character for empty line height
                            _x1, y1_placeholder, _x2, y2_placeholder = font.getbbox("Ay") 
                            current_line_height = y2_placeholder - y1_placeholder
                            ascent_offset = -y1_placeholder # y1 is typically negative
                        except AttributeError:
                            current_line_height = final_font_size_px 
                            ascent_offset = final_font_size_px * 0.8 # Approximate ascent
                    else:
                        try:
                            _x1, y1, _x2, y2 = font.getbbox(line_to_measure)
                            current_line_height = y2 - y1
                            ascent_offset = -y1 # y1 is distance from baseline to top, usually negative
                        except AttributeError: 
                            _w_fallback, h_fallback = font.getsize(line_to_measure) if hasattr(font, 'getsize') else (0, final_font_size_px)
                            current_line_height = h_fallback
                            ascent_offset = h_fallback * 0.8 # Approximate ascent
                    line_heights_and_ascents.append((current_line_height, ascent_offset))
                    total_text_block_height += current_line_height
            
            # Determine starting Y position for the top of the text block
            y_cursor_top = 0
            if el_layer_height > total_text_block_height:
                y_cursor_top = (el_layer_height - total_text_block_height) / 2
            
            for idx, line in enumerate(lines):
                line_width = element_draw.textlength(line, font=font)
                x_text_offset = 0
                if text_align == 'center':
                    x_text_offset = (el_layer_width - line_width) / 2
                elif text_align == 'right':
                    x_text_offset = el_layer_width - line_width
                
                _line_h, line_ascent_val = line_heights_and_ascents[idx]
                # y_cursor_top is the top of the current line. For draw.text, y is the baseline.
                baseline_y_for_draw = y_cursor_top + line_ascent_val
                
                element_draw.text((x_text_offset, baseline_y_for_draw), line, font=font, fill=font_color_rgba)
                y_cursor_top += _line_h # Move to the top of the next line

    elif el_type == 'shape':
        shape_type = content.get('shapeType')
        fill_color_hex = content.get('fillColor', '#00000000')
        stroke_color_hex = content.get('strokeColor', '#00000000')
        stroke_width = int(content.get('strokeWidth', 0))

        fill_color_rgba = hex_to_rgba(fill_color_hex, 1.0) # Opacity is applied to the whole layer later
        outline_color_rgba = hex_to_rgba(stroke_color_hex, 1.0) if stroke_width > 0 else None
        
        bounds = [(0,0), (el_layer_width-1, el_layer_height-1)]

        nested_content_data = element_data.get('nested_content')
        if nested_content_data and nested_content_data.get('content'):
            nested_el_data = nested_content_data['content']
            nested_canvas = Image.new('RGBA', (el_layer_width, el_layer_height), (0,0,0,0))
            # Render nested content into its own canvas, using parent's dimensions as the viewport for the nested element
            render_template_element(nested_canvas, nested_el_data, el_layer_width, el_layer_height, current_language, default_language_code, font_asset_path)
            
            fit_mode = nested_content_data.get('contentFit', 'BoxFit.contain')
            fitted_nested_canvas = apply_box_fit(nested_canvas, el_layer_width, el_layer_height, fit_mode)

            # Create a mask from the parent shape
            mask_layer = Image.new('L', (el_layer_width, el_layer_height), 0) # Grayscale for mask
            mask_draw = ImageDraw.Draw(mask_layer)

            if shape_type == "ShapeType.rectangle" or shape_type is None:
                mask_draw.rectangle(bounds, fill=255) # Opaque white for mask area
            elif shape_type == "ShapeType.circle" or shape_type == "ShapeType.oval":
                mask_draw.ellipse(bounds, fill=255) # Opaque white for mask area
            
            # If the parent shape itself had a fill color, draw it first (respecting its opacity)
            # This acts as a background for the masked nested image if the image has transparency
            # or doesn't fully cover the mask.
            if fill_color_rgba[3] > 0: # If parent shape fill is not fully transparent
                 # Corrected to draw the actual shape type (e.g., ellipse for circle)
                 if shape_type == "ShapeType.rectangle" or shape_type is None:
                    element_draw.rectangle(bounds, fill=fill_color_rgba)
                 elif shape_type == "ShapeType.circle" or shape_type == "ShapeType.oval":
                    element_draw.ellipse(bounds, fill=fill_color_rgba)

            # Paste the fitted nested image onto the element_layer using the shape mask
            element_layer.paste(fitted_nested_canvas, (0,0), mask_layer)

            # If there's an outline for the parent shape, draw it on top
            if outline_color_rgba and stroke_width > 0:
                if shape_type == "ShapeType.rectangle" or shape_type is None:
                    element_draw.rectangle(bounds, fill=None, outline=outline_color_rgba, width=stroke_width)
                elif shape_type == "ShapeType.circle" or shape_type == "ShapeType.oval":
                    element_draw.ellipse(bounds, fill=None, outline=outline_color_rgba, width=stroke_width)
        else:
            # No nested content, just draw the shape as before
            if shape_type == "ShapeType.rectangle" or shape_type is None:
                element_draw.rectangle(bounds, fill=fill_color_rgba, outline=outline_color_rgba, width=stroke_width)
            elif shape_type == "ShapeType.circle" or shape_type == "ShapeType.oval":
                element_draw.ellipse(bounds, fill=fill_color_rgba, outline=outline_color_rgba, width=stroke_width)

    if opacity < 1.0:
        element_layer.putalpha(element_layer.split()[-1].point(lambda p: p * opacity))

    if rotation_angle != 0:
        rotated_layer = element_layer.rotate(rotation_angle, expand=True, resample=Image.Resampling.BICUBIC)
        orig_center_x = el_x + el_width / 2
        orig_center_y = el_y + el_height / 2
        new_paste_x = int(orig_center_x - rotated_layer.width / 2)
        new_paste_y = int(orig_center_y - rotated_layer.height / 2)
        image_canvas.paste(rotated_layer, (new_paste_x, new_paste_y), rotated_layer)
    else:
        image_canvas.paste(element_layer, (el_x, el_y), element_layer)


def create_image_from_json(json_data, output_path="output_image.png", font_asset_path="assets/fonts"):
    canvas_width = json_data['original_width']
    canvas_height = json_data['original_height']
    # Initialize with a transparent background, as the base_image_url will form the actual base
    final_image = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0)) 

    # 1. Render the base_image_url as the first layer
    base_image_url = json_data.get('base_image_url')
    if base_image_url:
        try:
            print(f"Fetching base_image_url: {base_image_url}")
            response = requests.get(base_image_url, timeout=10)
            response.raise_for_status()
            img_data = BytesIO(response.content)
            base_img = Image.open(img_data).convert("RGBA")
            # Resize base image to cover the canvas
            base_img = apply_box_fit(base_img, canvas_width, canvas_height, "BoxFit.cover")
            final_image.paste(base_img, (0,0), base_img) # Paste onto the main canvas
            print("Base image rendered.")
        except Exception as e:
            print(f"Error processing base_image_url {base_image_url}: {e}")
            # Optionally, fill with a default color if base image fails
            # base_draw = ImageDraw.Draw(final_image)
            # base_draw.rectangle([(0,0), (canvas_width, canvas_height)], fill=(255,255,255,255)) # White background

    # 2. Sort and render elements from content_json on top
    content_json = sorted(json_data['content_json'], key=lambda el: el.get('z_index', 0))
    
    lang_settings = json_data.get('language_settings', {})
    current_language = lang_settings.get('current_language', 'en')
    default_lang_code = lang_settings.get('default_language', {}).get('code', 'en')

    for element in content_json:
        print(f"Rendering element type: {element['type']}, tag: {element.get('tag')}, z: {element.get('z_index')}")
        render_template_element(final_image, element, canvas_width, canvas_height, current_language, default_lang_code, font_asset_path)

    final_image.save(output_path)
    print(f"Image saved to {output_path}")

# --- Main ---
if __name__ == '__main__':
    example_json_data = {
    "id": 4,
    "poster": 36,
    "base_image_url": "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/BJP.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250508%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250508T063612Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=a8ac9258af873f25b46e748fa777a6219c10a2ecb14c4cc2fc6a6823be2f7a4f",
    "thumbnail_url": None,
    "original_width": 1080,
    "original_height": 1080,
    "aspect_ratio": 1.0,
    "content_json": [
        {
            "box": {
                "rotation": 0,
                "alignment": "center",
                "x_percent": 0,
                "y_percent": 0,
                "width_percent": 100,
                "height_percent": 100
            },
            "tag": "TemplateElementTag.background",
            "type": "image",
            "group": None,
            "style": {
                "color": "#000000",
                "opacity": 0.25,
                "imageFit": "BoxFit.contain",
                "font_size": 0,
                "is_italic": False,
                "box_shadow": None,
                "text_align": None,
                "decorations": None,
                "font_family": "English",
                "font_weight": "FontWeight.w400",
                "image_shape": None,
                "border_color": None,
                "border_style": None,
                "border_width": None,
                "is_read_only": False,
                "border_radius": None,
                "is_underlined": False
            },
            "content": {
                "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549917602"
            },
            "z_index": 0,
            "nested_content": None
        },
        {
            "box": {
                "x_px": 315,
                "y_px": 151,
                "rotation": 0,
                "width_px": 450,
                "alignment": "center",
                "height_px": 450,
                "x_percent": 26.3388327383154,
                "y_percent": 10.270695493342368,
                "width_percent": 47.83266415505989,
                "height_percent": 46.718507027803554
            },
            "tag": "TemplateElementTag.keyVisual",
            "type": "shape",
            "group": None,
            "style": {
                "color": "#000000",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 0,
                "is_italic": False,
                "box_shadow": None,
                "text_align": None,
                "decorations": None,
                "font_family": "English",
                "font_weight": "FontWeight.w400",
                "image_shape": None,
                "border_color": None,
                "border_style": None,
                "border_width": None,
                "is_read_only": False,
                "border_radius": None,
                "is_underlined": False
            },
            "content": {
                "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549919078",
                "fillColor": "#FFFFFF",
                "shapeType": "ShapeType.circle",
                "strokeColor": "#00000000",
                "strokeWidth": 2,
                "isStrokeDashed": False
            },
            "z_index": 0,
            "nested_content": {
                "content": {
                    "box": {
                        "rotation": 0,
                        "alignment": "center",
                        "x_percent": 0,
                        "y_percent": 0,
                        "width_percent": 100,
                        "height_percent": 100
                    },
                    "tag": "TemplateElementTag.defaulty",
                    "type": "image",
                    "group": None,
                    "style": {
                        "color": "#000000",
                        "opacity": 1,
                        "imageFit": "BoxFit.cover",
                        "font_size": 0,
                        "is_italic": False,
                        "box_shadow": None,
                        "text_align": None,
                        "decorations": None,
                        "font_family": "English",
                        "font_weight": "FontWeight.w400",
                        "image_shape": None,
                        "border_color": None,
                        "border_style": None,
                        "border_width": None,
                        "is_read_only": False,
                        "border_radius": None,
                        "is_underlined": False
                    },
                    "content": {
                        "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549919078"
                    },
                    "z_index": 0,
                    "nested_content": None
                },
                "contentFit": "BoxFit.fill",
                "contentAlignment": "Alignment.center"
            }
        },
        {
            "box": {
                "y_px": 717,
                "rotation": 0,
                "alignment": "center",
                "x_percent": 10.515334894853924,
                "y_percent": 66.08904995590017,
                "width_percent": 80,
                "height_percent": 10
            },
            "tag": "TemplateElementTag.subheading",
            "type": "text",
            "group": None,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 5,
                "is_italic": False,
                "box_shadow": None,
                "text_align": None,
                "decorations": None,
                "font_family": "English",
                "font_weight": "FontWeight.w600",
                "image_shape": None,
                "border_color": None,
                "border_style": None,
                "border_width": None,
                "is_read_only": False,
                "border_radius": None,
                "is_underlined": False
            },
            "content": {
                "bn-IN": {
                    "text": " তাঁর জন্মদিনে শ্রদ্ধাঞ্জলি"
                },
                "en-IN": {
                    "text": " Paying Tribute on His Birth Anniversary"
                },
                "hi-IN": {
                    "text": " उनकी जयंती पर श्रद्धांजलि"
                }
            },
            "z_index": 0,
            "nested_content": None
        },
        {
            "box": {
                "x_px": 165,
                "y_px": 625,
                "rotation": 0,
                "width_px": 750,
                "alignment": "center",
                "height_px": 68,
                "x_percent": 9.778249833123477,
                "y_percent": 59.2935004757599,
                "width_percent": 80,
                "height_percent": 14.444444444444445
            },
            "tag": "TemplateElementTag.heading",
            "type": "text",
            "group": None,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 7,
                "is_italic": False,
                "box_shadow": None,
                "text_align": None,
                "decorations": None,
                "font_family": "English",
                "font_weight": "FontWeight.w900",
                "image_shape": None,
                "border_color": None,
                "border_style": None,
                "border_width": None,
                "is_read_only": False,
                "border_radius": None,
                "is_underlined": False
            },
            "content": {
                "bn-IN": {
                    "text": "কেশব বলিরাম হেডগেওয়ার "
                },
                "en-IN": {
                    "text": "Keshav Baliram Hedgewar "
                },
                "hi-IN": {
                    "text": "केशव बलिराम हेडगेवार "
                }
            },
            "z_index": 0,
            "nested_content": None
        },
        {
            "box": {
                "x_px": 115,
                "y_px": 808,
                "rotation": 0,
                "width_px": 850,
                "alignment": "center",
                "height_px": 120,
                "x_percent": 11.974513457737276,
                "y_percent": 71.92704907538395,
                "width_percent": 80,
                "height_percent": 19.047619047619044
            },
            "tag": "TemplateElementTag.message",
            "type": "text",
            "group": None,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 3,
                "is_italic": False,
                "box_shadow": None,
                "text_align": "center",
                "decorations": None,
                "font_family": "English",
                "font_weight": "FontWeight.w400",
                "image_shape": None,
                "border_color": None,
                "border_style": None,
                "border_width": None,
                "is_read_only": False,
                "border_radius": None,
                "is_underlined": False
            },
            "content": {
                "bn-IN": {
                    "text": "কেশব বলিরাম হেডগেওয়ার ছিলেন ভারতীয় জাতীয়তাবাদের অন্যতম পথপ্রদর্শক। তাঁর নেতৃত্বে রাষ্ট্রীয় স্বয়ংসেবক সংঘ (RSS) গঠিত হয়, যা আজও জাতীয়তাবাদী ভাবনার ভিত্তি রক্ষা করে চলেছে।"
                },
                "en-IN": {
                    "text": "Keshav Baliram Hedgewar was a pioneering nationalist thinker who founded the Rashtriya Swayamsevak Sangh (RSS),\nlaying the foundation for a strong cultural and nationalist movement in India."
                },
                "hi-IN": {
                    "text": "केशव बलिराम हेडगेवार भारतीय राष्ट्रवाद के एक प्रमुख विचारक थे। उनके नेतृत्व में राष्ट्रीय स्वयंसेवक संघ (RSS) की स्थापना हुई, जो आज भी राष्ट्रभक्ति और संस्कृति की रक्षा करता है।"
                }
            },
            "z_index": 2,
            "nested_content": None
        }
    ],
    "language_settings": {
        "current_language": "en-IN",
        "default_language": {
            "code": "en",
            "name": "English",
            "flagEmoji": None,
            "nativeName": "English",
            "textDirection": "TextDirection.ltr"
        },
        "enabled_languages": [
            {
                "code": "en-IN",
                "name": "English",
                "flagEmoji": None,
                "nativeName": "English",
                "textDirection": "TextDirection.ltr"
            },
            {
                "code": "bn-IN",
                "name": "Bengali",
                "flagEmoji": None,
                "nativeName": "Bengali",
                "textDirection": "TextDirection.ltr"
            },
            {
                "code": "hi-IN",
                "name": "Hindi",
                "flagEmoji": None,
                "nativeName": "Hindi",
                "textDirection": "TextDirection.ltr"
            }
        ]
    }
}
    
    font_directory = "assets/fonts" 
    
    create_image_from_json(example_json_data, output_path="generated_image_py.png", font_asset_path=font_directory)
