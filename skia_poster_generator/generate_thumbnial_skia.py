import skia
import requests
from io import BytesIO
import math
import os
import argparse
import json

# --- Skia Helper Functions ---

def hex_to_skia_color(hex_color_str, opacity=1.0):
    """Converts hex color string (e.g., #RRGGBB or #AARRGGBB) to skia.Color."""
    if not hex_color_str:
        return skia.Color(0, 0, 0, 0) # Transparent black for invalid/missing color
    hex_color = hex_color_str.lstrip('#')
    if len(hex_color) == 3: # Expand shorthand hex (e.g., #03F to #0033FF)
        hex_color = "".join([c*2 for c in hex_color])

    if len(hex_color) == 6: # RGB
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        a = int(opacity * 255)
        return skia.Color(r, g, b, a)
    elif len(hex_color) == 8: # ARGB (from hex) or RGBA (if alpha is at end)
        # Assuming standard web RGBA hex if 8 chars, then modulate with opacity
        # If it were AARRGGBB, Skia would parse it directly with skia.ColorSetARGBFromString
        try: # Try parsing as AARRGGBB first
            return skia.ColorSetARGBFromString(f"#{hex_color}") # Skia expects #AARRGGBB
        except: # Fallback to RGBA parsing
            r = int(hex_color[0:2], 16)
            g = int(hex_color[2:4], 16)
            b = int(hex_color[4:6], 16)
            a_hex = int(hex_color[6:8], 16)
            # Modulate the hex alpha with the style's opacity
            final_alpha = int((a_hex / 255.0) * opacity * 255)
            return skia.Color(r, g, b, final_alpha)
    print(f"Warning: Invalid hex color format: {hex_color_str}. Defaulting to transparent.")
    return skia.Color(0,0,0,0)


def get_skia_font_weight(font_weight_str):
    """Maps Flutter FontWeight string to Skia FontStyle.Weight."""
    weights = {
        "FontWeight.w100": skia.FontStyle.kThin_Weight,
        "FontWeight.w200": skia.FontStyle.kExtraLight_Weight,
        "FontWeight.w300": skia.FontStyle.kLight_Weight,
        "FontWeight.w400": skia.FontStyle.kNormal_Weight,
        "FontWeight.w500": skia.FontStyle.kMedium_Weight,
        "FontWeight.w600": skia.FontStyle.kSemiBold_Weight,
        "FontWeight.w700": skia.FontStyle.kBold_Weight,
        "FontWeight.w800": skia.FontStyle.kExtraBold_Weight,
        "FontWeight.w900": skia.FontStyle.kBlack_Weight,
    }
    return weights.get(font_weight_str, skia.FontStyle.kNormal_Weight)

def get_skia_text_align(text_align_str):
    if text_align_str == "center":
        return skia.TextBlobBuilder.kCenter_Align
    elif text_align_str == "right":
        return skia.TextBlobBuilder.kRight_Align
    return skia.TextBlobBuilder.kLeft_Align # Default for null or "left"

def calculate_box_fit_rects(img_width, img_height, target_width, target_height, box_fit_str):
    """Calculates source and destination skia.Rects for BoxFit logic."""
    src_rect = skia.Rect.MakeWH(img_width, img_height)
    dst_rect = skia.Rect.MakeWH(target_width, target_height)

    if img_width <= 0 or img_height <= 0 or target_width <= 0 or target_height <= 0:
        return src_rect, dst_rect # Cannot compute, return full rects

    target_aspect = target_width / target_height
    img_aspect = img_width / img_height

    if box_fit_str == "BoxFit.fill":
        return src_rect, dst_rect # Source full, dest full

    elif box_fit_str == "BoxFit.contain":
        if img_aspect > target_aspect: # Image wider than target, fit width
            scale = target_width / img_width
            final_h = img_height * scale
            y_offset = (target_height - final_h) / 2
            return src_rect, skia.Rect.MakeXYWH(0, y_offset, target_width, final_h)
        else: # Image taller or same aspect, fit height
            scale = target_height / img_height
            final_w = img_width * scale
            x_offset = (target_width - final_w) / 2
            return src_rect, skia.Rect.MakeXYWH(x_offset, 0, final_w, target_height)

    elif box_fit_str == "BoxFit.cover":
        if img_aspect > target_aspect: # Image wider, scale by height and crop width
            scale = target_height / img_height
            scaled_w = img_width * scale
            crop_w = (img_width - target_width / scale) / 2 # Crop from source
            return skia.Rect.MakeXYWH(crop_w, 0, img_width - 2 * crop_w, img_height), dst_rect
        else: # Image taller, scale by width and crop height
            scale = target_width / img_width
            scaled_h = img_height * scale
            crop_h = (img_height - target_height / scale) / 2 # Crop from source
            return skia.Rect.MakeXYWH(0, crop_h, img_width, img_height - 2 * crop_h), dst_rect
    
    # BoxFit.fitWidth, BoxFit.fitHeight, BoxFit.scaleDown, BoxFit.none are more complex
    # For simplicity, defaulting to contain for these in this example
    # print(f"Warning: BoxFit mode '{box_fit_str}' not fully implemented, defaulting to contain-like behavior.")
    if img_aspect > target_aspect:
        scale = target_width / img_width
        final_h = img_height * scale
        y_offset = (target_height - final_h) / 2
        return src_rect, skia.Rect.MakeXYWH(0, y_offset, target_width, final_h)
    else:
        scale = target_height / img_height
        final_w = img_width * scale
        x_offset = (target_width - final_w) / 2
        return src_rect, skia.Rect.MakeXYWH(x_offset, 0, final_w, target_height)


def get_language_font_family(lang_settings, lang_code):
    enabled = lang_settings.get('enabled_languages', [])
    for lang in enabled:
        if lang.get('code') == lang_code:
            return lang.get('fontFamily', 'English')
    return 'English'


def render_template_element_skia(canvas, element_data, parent_canvas_width, parent_canvas_height, current_language, default_language_code, font_asset_path, lang_settings=None):
    """Renders a single TemplateElement onto the Skia canvas."""
    box = element_data['box']
    style = element_data.get('style', {})
    content = element_data.get('content', {})
    el_type = element_data['type']

    # Calculate element dimensions and position
    el_x = box.get('x_px', (box.get('x_percent', 0) / 100.0) * parent_canvas_width)
    el_y = box.get('y_px', (box.get('y_percent', 0) / 100.0) * parent_canvas_height)
    el_width = box.get('width_px', (box.get('width_percent', 100) / 100.0) * parent_canvas_width)
    el_height = box.get('height_px', (box.get('height_percent', 100) / 100.0) * parent_canvas_height)
    rotation_angle = box.get('rotation', 0)

    # Debug log for element position and size
    print(f"[DEBUG] Element type: {el_type}, tag: {element_data.get('tag')}, x: {el_x}, y: {el_y}, width: {el_width}, height: {el_height}, rotation: {rotation_angle}")

    # Ensure non-zero dimensions for drawing
    el_width = max(1, el_width)
    el_height = max(1, el_height)

    canvas.save()
    canvas.translate(el_x, el_y)
    if rotation_angle != 0:
        canvas.translate(el_width / 2, el_height / 2) # Rotate around center
        canvas.rotate(rotation_angle)
        canvas.translate(-el_width / 2, -el_height / 2)

    paint = skia.Paint(AntiAlias=True)
    opacity = style.get('opacity', 1.0)
    # General opacity for the layer will be applied at the end using saveLayer if needed

    element_rect = skia.Rect.MakeWH(el_width, el_height)

    if el_type == 'image':
        img_url = content.get('url')
        if img_url:
            try:
                print(f"Attempting to load image for element: {element_data.get('tag', 'N/A')}, URL: {img_url}")
                response = requests.get(img_url, timeout=10)
                response.raise_for_status() # Will raise an HTTPError for bad responses (4xx or 5xx)
                image_data = skia.Data(response.content)
                skia_image = skia.Image.MakeFromEncoded(image_data)
                if skia_image:
                    print(f"Successfully loaded image: {img_url} (w:{skia_image.width()}, h:{skia_image.height()})")
                    box_fit_str = style.get('imageFit', 'BoxFit.contain')
                    src_rect, dst_rect_fitted = calculate_box_fit_rects(
                        skia_image.width(), skia_image.height(),
                        el_width, el_height, box_fit_str
                    )
                    print(f"[DEBUG] BoxFit: {box_fit_str}, src_rect: {src_rect}, dst_rect: {dst_rect_fitted}")
                    paint = skia.Paint(AntiAlias=True)
                    paint.setAlphaf(opacity)
                    canvas.drawImageRect(skia_image, src_rect, dst_rect_fitted, paint)
                else:
                    print(f"Failed to decode Skia image from URL: {img_url}")
            except requests.exceptions.RequestException as e:
                print(f"HTTP Request Exception for image {img_url}: {e}")
            except Exception as e:
                print(f"Generic Exception loading/processing image {img_url}: {e}")

    elif el_type == 'shape':
        shape_type = content.get('shapeType')
        fill_color_str = content.get('fillColor', '#00000000')
        stroke_color_str = content.get('strokeColor', '#00000000')
        stroke_width = float(content.get('strokeWidth', 0))

        print(f"[DEBUG] Shape type: {shape_type}, fill: {fill_color_str}, stroke: {stroke_color_str}, stroke_width: {stroke_width}")

        # Prepare paint for fill
        fill_paint = skia.Paint(AntiAlias=True, Style=skia.Paint.kFill_Style)
        fill_paint.setColor(hex_to_skia_color(fill_color_str, 1.0)) # Opacity applied to layer

        # Prepare paint for stroke
        stroke_paint = None
        if stroke_width > 0:
            stroke_paint = skia.Paint(AntiAlias=True, Style=skia.Paint.kStroke_Style, StrokeWidth=stroke_width)
            stroke_paint.setColor(hex_to_skia_color(stroke_color_str, 1.0)) # Opacity applied to layer

        # Path for the shape
        path = skia.Path()
        if shape_type == "ShapeType.rectangle" or shape_type is None:
            path.addRect(element_rect)
        elif shape_type == "ShapeType.circle" or shape_type == "ShapeType.oval":
            path.addOval(element_rect)
        
        # Handle nested content (masking)
        nested_content_data = element_data.get('nested_content')
        if nested_content_data and nested_content_data.get('content'):
            # Apply overall element opacity using a layer
            layer_paint = skia.Paint(Alphaf=opacity)
            canvas.saveLayer(element_rect, layer_paint)

            # 1. Draw parent shape's fill color (e.g., white circle background)
            if fill_paint.getAlphaf() > 0: # Check if fill is not transparent
                 canvas.drawPath(path, fill_paint)

            # 2. Render nested content, clipped by the parent shape
            canvas.save()
            canvas.clipPath(path, doAntiAlias=True)
            
            nested_el_data = nested_content_data['content']
            # The nested element is rendered relative to the parent's 0,0
            # Its dimensions are determined by contentFit within parent's el_width, el_height
            
            # For nested content, its 'canvas' is effectively the parent's element_rect
            # BoxFit for nested content needs to be handled carefully.
            # Here, we assume the nested element (if image) will be drawn to fill the clipped path
            # according to its own BoxFit, then the clip applies.
            # This simplified version passes el_width, el_height as parent dimensions for nested.
            render_template_element_skia(canvas, nested_el_data, el_width, el_height, current_language, default_language_code, font_asset_path, lang_settings)
            
            canvas.restore() # Restore from clip

            # 3. Draw parent shape's stroke on top (if any)
            if stroke_paint:
                canvas.drawPath(path, stroke_paint)
            
            canvas.restore() # Restore from saveLayer
        else:
            # No nested content, just draw the shape with its own opacity
            fill_paint.setAlphaf(fill_paint.getAlphaf() * opacity)
            if fill_paint.getAlphaf() > 0:
                canvas.drawPath(path, fill_paint)
            if stroke_paint:
                stroke_paint.setAlphaf(stroke_paint.getAlphaf() * opacity)
                canvas.drawPath(path, stroke_paint)

    elif el_type == 'text':
        text_to_render = ""
        lang_content_map = content # content is the map of languages
        if isinstance(lang_content_map, dict):
            lang_specific_content = lang_content_map.get(current_language) or lang_content_map.get(default_language_code) or lang_content_map.get('fallback')
            if isinstance(lang_specific_content, dict):
                text_to_render = lang_specific_content.get('text', "")
            elif isinstance(lang_specific_content, str): # Direct fallback string
                 text_to_render = lang_specific_content
            if not text_to_render and 'text' in lang_content_map : # for cases where content is just {"text": "..."}
                text_to_render = lang_content_map['text']
        
        if text_to_render:
            font_color_str = style.get('color', '#000000')
            font_size_vw = style.get('font_size', 4.0) # Default to 4vw
            # Use font_family from style if present, else from language settings
            font_family_name = get_language_font_family(lang_settings, current_language)
            font_weight_str = style.get('font_weight', 'FontWeight.w400')
            is_italic = style.get('is_italic', False)
            is_underlined = style.get('is_underlined', False)
            text_align_style = style.get('text_align') # Can be None

            initial_font_size_px = max(1.0, (font_size_vw / 100.0) * parent_canvas_width)
            skia_font_weight = get_skia_font_weight(font_weight_str)
            skia_font_slant = skia.FontStyle.kItalic_Slant if is_italic else skia.FontStyle.kUpright_Slant
            skia_font_style = skia.FontStyle(skia_font_weight, skia.FontStyle.kNormal_Width, skia_font_slant)

            # Try to load italic font variant if needed
            font_file = f"{font_family_name}{'-Italic' if is_italic else ''}.ttf"
            actual_font_path = os.path.join(font_asset_path, font_file)
            if not os.path.exists(actual_font_path):
                actual_font_path = os.path.join(font_asset_path, f"{font_family_name}.ttf")
            print(f"[DEBUG] Text element: '{text_to_render}', font: {actual_font_path}, font_size_vw: {font_size_vw}, initial_font_size_px: {initial_font_size_px}, color: {font_color_str}, align: {text_align_style}")
            try:
                typeface = skia.Typeface.MakeFromFile(actual_font_path, 0) or skia.Typeface.MakeDefault()
            except Exception as e:
                print(f"Warning: Could not load font '{actual_font_path}': {e}. Using default.")
                typeface = skia.Typeface.MakeDefault()

            # --- Word wrapping ---
            def wrap_text(text, font, max_width):
                words = text.split()
                lines = []
                current_line = ''
                for word in words:
                    test_line = current_line + (' ' if current_line else '') + word
                    if font.measureText(test_line) <= max_width:
                        current_line = test_line
                    else:
                        if current_line:
                            lines.append(current_line)
                        current_line = word
                if current_line:
                    lines.append(current_line)
                return lines

            # Start with initial font size, wrap, then reduce if needed
            current_font_size_px = initial_font_size_px
            max_height = el_height
            max_width = el_width
            final_lines = []
            while current_font_size_px > 1:
                temp_font = skia.Font(typeface, current_font_size_px)
                temp_font.setEdging(skia.Font.Edging.kAntiAlias)
                temp_font.setSubpixel(True)
                wrapped_lines = []
                for para in text_to_render.split('\n'):
                    wrapped_lines.extend(wrap_text(para, temp_font, max_width))
                # Calculate total height
                font_metrics = temp_font.getMetrics()
                line_height = font_metrics.fDescent - font_metrics.fAscent + font_metrics.fLeading
                total_height = line_height * len(wrapped_lines)
                if total_height <= max_height:
                    final_lines = wrapped_lines
                    break
                current_font_size_px -= 1
            else:
                # If nothing fits, use at least one line
                temp_font = skia.Font(typeface, 1)
                temp_font.setEdging(skia.Font.Edging.kAntiAlias)
                temp_font.setSubpixel(True)
                final_lines = wrap_text(text_to_render, temp_font, max_width)
                line_height = temp_font.getMetrics().fDescent - temp_font.getMetrics().fAscent + temp_font.getMetrics().fLeading

            final_font = skia.Font(typeface, current_font_size_px)
            final_font.setEdging(skia.Font.Edging.kAntiAlias)
            final_font.setSubpixel(True)
            text_paint = skia.Paint(AntiAlias=True, Color=hex_to_skia_color(font_color_str, opacity))

            # Calculate total text block height for vertical centering
            font_metrics = final_font.getMetrics()
            line_height = font_metrics.fDescent - font_metrics.fAscent + font_metrics.fLeading
            total_text_height = line_height * len(final_lines)
            y_cursor = (el_height - total_text_height) / 2 - font_metrics.fAscent

            print(f"[DEBUG] Final font size px: {current_font_size_px}, lines: {len(final_lines)}, line_height: {line_height}, total_text_height: {total_text_height}")

            for line_text in final_lines:
                line_width = final_font.measureText(line_text)
                x_text_offset = 0
                if text_align_style == 'center':
                    x_text_offset = (el_width - line_width) / 2
                elif text_align_style == 'right':
                    x_text_offset = el_width - line_width
                # Default is left
                print(f"[DEBUG] Drawing text line: '{line_text}', x: {x_text_offset}, y: {y_cursor}, width: {line_width}")
                canvas.drawString(line_text, x_text_offset, y_cursor, final_font, text_paint)
                # Underline
                if is_underlined:
                    underline_y = y_cursor + font_metrics.fDescent * 0.8
                    canvas.drawLine(x_text_offset, underline_y, x_text_offset + line_width, underline_y, text_paint)
                y_cursor += line_height

    canvas.restore()


def create_image_from_json_skia(json_data, output_path="output_image_skia.png", font_asset_path="assets/fonts", canvas_width=None, canvas_height=None, base_image_url=None):
    if canvas_width is None or canvas_height is None:
        canvas_width = json_data['original_width']
        canvas_height = json_data['original_height']

    surface = skia.Surface(canvas_width, canvas_height)
    canvas = surface.getCanvas()
    canvas.clear(skia.ColorTRANSPARENT) # Start with a transparent background

    # 1. Render base_image_url
    if base_image_url is None:
        base_image_url = json_data.get('base_image_url')

    if base_image_url:
        try:
            print(f"Fetching base_image_url: {base_image_url}")
            response = requests.get(base_image_url, timeout=10)
            response.raise_for_status() # Will raise an HTTPError for bad responses (4xx or 5xx)
            # Corrected: Use skia.Data(bytes_object) constructor
            base_image_data = skia.Data(response.content)
            skia_base_image = skia.Image.MakeFromEncoded(base_image_data)
            if skia_base_image:
                print(f"Successfully loaded base image: {base_image_url} (w:{skia_base_image.width()}, h:{skia_base_image.height()})")
                src_rect, dst_rect_fitted = calculate_box_fit_rects(
                    skia_base_image.width(), skia_base_image.height(),
                    canvas_width, canvas_height, "BoxFit.cover" # Base image covers canvas
                )
                canvas.drawImageRect(skia_base_image, src_rect, dst_rect_fitted, skia.Paint(AntiAlias=True))
                print("Base image rendered with Skia.")
            else:
                print(f"Failed to decode Skia base image from URL: {base_image_url}. Drawing white fallback.")
                canvas.drawColor(skia.ColorWHITE) # Fallback to white background
        except requests.exceptions.RequestException as e:
            print(f"HTTP Request Exception for base_image_url {base_image_url}: {e}. Drawing white fallback.")
            canvas.drawColor(skia.ColorWHITE)
        except Exception as e:
            print(f"Generic Exception processing base_image_url {base_image_url}: {e}. Drawing white fallback.")
            canvas.drawColor(skia.ColorWHITE)
    else:
        print("No base_image_url provided. Canvas will be white if not otherwise painted.")
        canvas.drawColor(skia.ColorWHITE) # Default to white if no base image at all

    # 2. Render elements from content_json
    # Elements with same z_index are drawn in array order.
    # The Dart exampleJson has all z_index: 0 for content_json elements.
    # No explicit sorting by z_index needed here if we process in given order.
    
    lang_settings = json_data.get('language_settings', {})
    current_language = lang_settings.get('current_language', 'en-IN') # Match Dart example
    default_lang_code = lang_settings.get('default_language', {}).get('code', 'en-IN') # Corrected

    elements = json_data.get('content_json', []) # Corrected: content_json is a list

    if elements:
        for element in elements:
            print(f"Rendering element (Skia) type: {element['type']}, tag: {element.get('tag')}") # Moved log here
            render_template_element_skia(canvas, element, canvas_width, canvas_height, current_language, default_lang_code, font_asset_path, lang_settings=lang_settings)
        print("All elements rendered with Skia.")
    else:
        print("No elements found in content_json or content_json was empty.")
    
    # 3. Save the final image
    print("Attempting to save Skia image...")
    image_snapshot = None
    encoded_data = None
    try:
        image_snapshot = surface.makeImageSnapshot()
        if image_snapshot:
            print("Image snapshot created successfully.")
            # Corrected call to encodeToData with format and quality
            encoded_data = image_snapshot.encodeToData(skia.EncodedImageFormat.kPNG, 100)
            if encoded_data:
                print("Image data encoded successfully.")
                # Use a with statement for safer file handling
                with open(output_path, "wb") as f:
                    f.write(encoded_data.bytes())
                print(f"Image saved to {output_path}")
            else:
                print("Error: Failed to encode image snapshot to PNG data.")
        else:
            print("Error: Failed to create image snapshot from surface.")
    except Exception as e:
        print(f"Error during image saving process: {e}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate a poster image from a JSON template using Skia.")
    parser.add_argument('--json', required=True, help='Path to the JSON file containing poster data')
    parser.add_argument('--lang', required=True, help='Language key to use for text rendering (e.g., en-IN, hi-IN)')
    parser.add_argument('--output', default='generated_image_skia.png', help='Output image file path')
    parser.add_argument('--fonts', default='./assets/fonts', help='Path to font assets directory (default: ./assets/fonts)')
    parser.add_argument('--base_image_url', default=None, help='URL of the base image to use (overrides JSON)')
    args = parser.parse_args()

    print(f">>> PYTHON SCRIPT EXECUTION STARTED (generate_thumbnail.py) <<<")
    # Load JSON data
    try:
        with open(args.json, 'r', encoding='utf-8') as f:
            json_data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        exit(1)

    # Set language in the data
    if 'language_settings' not in json_data:
        json_data['language_settings'] = {}
    json_data['language_settings']['current_language'] = args.lang
    if 'default_language' not in json_data['language_settings']:
        json_data['language_settings']['default_language'] = {'code': args.lang}

    # Handle base_image_url override and set canvas size from image if provided
    if args.base_image_url:
        try:
            print(f"Fetching base image from URL: {args.base_image_url} to determine dimensions...")
            response = requests.get(args.base_image_url, timeout=10)
            response.raise_for_status()
            base_image_data = skia.Data(response.content)
            skia_base_image = skia.Image.MakeFromEncoded(base_image_data)
            if skia_base_image:
                canvas_width = skia_base_image.width()
                canvas_height = skia_base_image.height()
                base_image_url = args.base_image_url
                print(f"Base image dimensions: width={canvas_width}, height={canvas_height}")
            else:
                print(f"Failed to decode Skia base image from URL: {args.base_image_url}. Using JSON dimensions.")
                canvas_width = json_data['original_width']
                canvas_height = json_data['original_height']
                base_image_url = json_data.get('base_image_url')
        except Exception as e:
            print(f"Error fetching or decoding base image from URL: {e}. Using JSON dimensions.")
            canvas_width = json_data['original_width']
            canvas_height = json_data['original_height']
            base_image_url = json_data.get('base_image_url')
    else:
        canvas_width = json_data['original_width']
        canvas_height = json_data['original_height']
        base_image_url = json_data.get('base_image_url')

    # Font directory
    if args.fonts:
        font_dir = args.fonts
    else:
        current_script_dir = os.path.dirname(os.path.abspath(__file__))
        font_dir = os.path.join(current_script_dir, "assets", "fonts")
    print(f"Font directory set to: {font_dir}")

    # Call the rendering function with local canvas size and base image url
    create_image_from_json_skia(json_data, output_path=args.output, font_asset_path=font_dir, canvas_width=canvas_width, canvas_height=canvas_height, base_image_url=base_image_url)
    print(f"Image generated at: {args.output}")
    print(">>> PYTHON SCRIPT EXECUTION FINISHED (generate_thumbnail.py) <<<")
