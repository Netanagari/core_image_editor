import 'package:core_image_editor/scripts/bulk_poster_processor.dart';
import 'package:core_image_editor/widgets/image_from_json_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final exampleJson = {
  "id": 1020,
  "poster": 464,
  "base_image_url":
      "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/005_05_ekJfL91.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250529%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250529T121702Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=4d17f67309f7517ad5cf677d61feaa03db5f26a6933c5a30b59fcef4dbbddc28",
  "thumbnail_url":
      "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/464/content/1748520904325?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250529%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250529T121702Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=0d76c1f6f76cc1693ea0c89de54bc0988b1cba32069bc9ec893216fdee426c36",
  "original_width": 1080,
  "original_height": 1080,
  "aspect_ratio": 1.0,
  "content_json": [
    {
      "box": {
        "x_px": 0,
        "y_px": 0,
        "rotation": 359.9474386836921,
        "width_px": 1080,
        "alignment": "center",
        "height_px": 1080,
        "x_percent": 0,
        "y_percent": 0,
        "width_percent": 100,
        "height_percent": 100
      },
      "tag": "TemplateElementTag.background",
      "type": "image",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 0.52,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747564974074"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 315,
        "y_px": 139,
        "rotation": 0,
        "width_px": 450,
        "alignment": "center",
        "height_px": 450,
        "x_percent": 29.166666666666668,
        "y_percent": 12.87037037037037,
        "width_percent": 47.83266415505989,
        "height_percent": 46.718507027803554
      },
      "tag": "TemplateElementTag.keyVisual",
      "type": "shape",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": {
          "color": "#ffffff",
          "offsetX": 0,
          "offsetY": 0,
          "blurRadius": 0,
          "spreadRadius": 2
        },
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549919078",
        "fillColor": "#FFFFFF",
        "shapeType": "ShapeType.circle",
        "strokeColor": "#00000000",
        "strokeWidth": 2,
        "isStrokeDashed": false
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
          "group": null,
          "style": {
            "color": "#000000",
            "opacity": 1,
            "imageFit": "BoxFit.cover",
            "font_size": 0,
            "is_italic": false,
            "box_shadow": null,
            "text_align": null,
            "decorations": null,
            "font_family": "English",
            "font_weight": "FontWeight.w400",
            "image_shape": null,
            "line_height": 1.2,
            "text_shadow": null,
            "border_color": null,
            "border_style": null,
            "border_width": null,
            "is_read_only": false,
            "border_radius": null,
            "is_underlined": false,
            "text_vertical_align": "center"
          },
          "content": {
            "url":
                "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1746767706649"
          },
          "z_index": 0,
          "nested_content": null
        },
        "contentFit": "BoxFit.fill",
        "contentAlignment": "Alignment.center"
      }
    },
    {
      "box": {
        "x_px": 61,
        "y_px": 709.9447370132697,
        "rotation": 0,
        "width_px": 958,
        "alignment": "center",
        "height_px": 109,
        "x_percent": 5.648148148148148,
        "y_percent": 65.73562379752497,
        "width_percent": 76.41828994953238,
        "height_percent": 17.48466203109454
      },
      "tag": "TemplateElementTag.subheading",
      "type": "text",
      "group": null,
      "style": {
        "color": "#ffffff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 4.070981210855951,
        "is_italic": false,
        "box_shadow": null,
        "text_align": "center",
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w600",
        "image_shape": null,
        "line_height": 1.0499999999999998,
        "text_shadow": {
          "color": "#000000",
          "offsetX": 0,
          "offsetY": 2,
          "blurRadius": 4
        },
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "top"
      },
      "content": {
        "bn-IN": {"text": "বাংলার মানুষের আস্থা বাংলার মানুষের আস্থা বাংলার "},
        "fallback": ""
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 15,
        "y_px": 583,
        "rotation": 0,
        "width_px": 1050.2453326127277,
        "alignment": "center",
        "height_px": 121.41103884422634,
        "x_percent": 1.3888888888888888,
        "y_percent": 53.98148148148149,
        "width_percent": 95.39308635303033,
        "height_percent": 22.54601156641138
      },
      "tag": "TemplateElementTag.heading",
      "type": "text",
      "group": null,
      "style": {
        "color": "#ffffff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 4.7652200759385455,
        "is_italic": false,
        "box_shadow": null,
        "text_align": "center",
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w900",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": {
          "color": "#000000",
          "offsetX": 0,
          "offsetY": 2,
          "blurRadius": 4
        },
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "bottom"
      },
      "content": {
        "bn-IN": {"text": " বাংলার মানুষের মমতা আস্থা "},
        "fallback": ""
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 131.10427759387312,
        "y_px": 789,
        "rotation": 0,
        "width_px": 818,
        "alignment": "center",
        "height_px": 140,
        "x_percent": 12.13928496239566,
        "y_percent": 73.05555555555556,
        "width_percent": 75.76919638478812,
        "height_percent": 30.36809721190104
      },
      "tag": "TemplateElementTag.messaging",
      "type": "text",
      "group": null,
      "style": {
        "color": "#ffffff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 3.177244494359996,
        "is_italic": false,
        "box_shadow": null,
        "text_align": "center",
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": {
          "color": "#000000",
          "offsetX": 0,
          "offsetY": 2,
          "blurRadius": 4
        },
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "bn-IN": {
          "text":
              "অরুণা আসাফ আলি ছিলেন ভারতের স্বাধীনতা সংগ্রামের একজন সাহসী  স্বাধীনতা  সংগ, যিনি ব্রিটিশ শাসনের বিরুদ্ধে নির্ভীকভাবে সংগ্রাম করেছিলেন। তাঁর অবদান জাতীয় ইতিহাসে চিরকাল স্মরণীয় থাকবে।123"
        },
        "fallback": ""
      },
      "z_index": 8,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "height_px": 190,
        "x_percent": 0,
        "y_percent": 80.95888414061254,
        "width_percent": 100,
        "height_percent": 17.711214877795392
      },
      "tag": "TemplateElementTag.partyStrip",
      "type": "image",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747565113141"
      },
      "z_index": 1,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 883,
        "y_px": 845,
        "rotation": 0,
        "width_px": 187,
        "alignment": "center",
        "height_px": 211,
        "x_percent": 81.75925925925925,
        "y_percent": 78.24074074074075,
        "width_percent": 17.356771387930607,
        "height_percent": 19.582849292952517
      },
      "tag": "TemplateElementTag.userPicture",
      "type": "image",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": "rectangle",
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747687627390"
      },
      "z_index": 10,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 201.05701716820616,
        "y_px": 961.4534835969088,
        "rotation": 0,
        "width_px": 456.1819414366651,
        "alignment": "right",
        "height_px": 59.01528370751135,
        "x_percent": 18.616390478537607,
        "y_percent": 89.02347070341747,
        "width_percent": 40.85017976265418,
        "height_percent": 14.72392592092172
      },
      "tag": "TemplateElementTag.userName",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#03a3ff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 10.19987351555278,
        "is_italic": false,
        "box_shadow": null,
        "text_align": "right",
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w600",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "bn-IN": {"text": "Name |"},
        "fallback": "New text"
      },
      "z_index": 5,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 181.59023927631935,
        "y_px": 1048.527675744814,
        "rotation": 0,
        "width_px": 698.6718203813474,
        "alignment": "center",
        "height_px": 27.055298130673524,
        "x_percent": 16.813911044103644,
        "y_percent": 97.08589590229758,
        "width_percent": 64.69183522049514,
        "height_percent": 2.5051201972845853
      },
      "tag": "TemplateElementTag.facebookHandle",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#ffffff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 2.187684383874693,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "bn-IN": {
          "text": "Other details (like Social Media Username or Phone Number)"
        },
        "fallback": "New text"
      },
      "z_index": 4,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 20,
        "y_px": 20,
        "rotation": 0,
        "width_px": 1040,
        "alignment": "left",
        "height_px": 80,
        "x_percent": 1.8518518518518516,
        "y_percent": 1.8518518518518516,
        "width_percent": 87.42331405598104,
        "height_percent": 2.8929879440617627
      },
      "tag": "TemplateElementTag.leaderStrip",
      "type": "leader_strip",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": "none",
        "border_width": 0,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "leaders": [
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.cover",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "text_align": null,
              "decorations": null,
              "font_family": "English",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "line_height": 1.2,
              "text_shadow": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747686495159"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.cover",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "text_align": null,
              "decorations": null,
              "font_family": "English",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "line_height": 1.2,
              "text_shadow": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747686456151"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.cover",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "text_align": null,
              "decorations": null,
              "font_family": "English",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "line_height": 1.2,
              "text_shadow": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747686468588"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.cover",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "text_align": null,
              "decorations": null,
              "font_family": "English",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "line_height": 1.2,
              "text_shadow": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747686480849"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.cover",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "text_align": null,
              "decorations": null,
              "font_family": "English",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "line_height": 1.2,
              "text_shadow": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1747686488596"
            },
            "z_index": 0,
            "nested_content": null
          }
        ],
        "spacing": 5,
        "stripSize": "medium",
        "justifyContent": "start",
        "verticalSpacing": 5
      },
      "z_index": 6,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 659.8246631476392,
        "y_px": 969.7681573423836,
        "rotation": 0,
        "width_px": 218.3989152594607,
        "alignment": "left",
        "height_px": 25.816063688801375,
        "x_percent": 61.094876217373994,
        "y_percent": 89.79334790207255,
        "width_percent": 20.2221217832834,
        "height_percent": 2.3903762674816087
      },
      "tag": "TemplateElementTag.userDesignation",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#039dff",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 9.15755464089176,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w600",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "bn-IN": {"text": "Designation/Post"},
        "fallback": "New text"
      },
      "z_index": 9,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 660,
        "y_px": 992.2163073344718,
        "rotation": 0,
        "width_px": 240,
        "alignment": "left",
        "height_px": 28,
        "x_percent": 61.111111111111114,
        "y_percent": 91.8718803087474,
        "width_percent": 15.830106113837031,
        "height_percent": 2.3063412144365265
      },
      "tag": "TemplateElementTag.userAddress",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#0996ef",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 8.364957496398727,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "bn-IN": {"text": "District/Area"},
        "fallback": "New text"
      },
      "z_index": 10,
      "nested_content": null
    },
    {
      "box": {
        "x_px": 24,
        "y_px": 894,
        "rotation": 0,
        "width_px": 174.8996329292451,
        "alignment": "center",
        "height_px": 174.82705596688746,
        "x_percent": 2.2222222222222223,
        "y_percent": 82.77777777777777,
        "width_percent": 16.74996601196714,
        "height_percent": 15.724727404341431
      },
      "tag": "TemplateElementTag.partySymbol",
      "type": "shape",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "text_align": null,
        "decorations": null,
        "font_family": "English",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "line_height": 1.2,
        "text_shadow": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false,
        "text_vertical_align": "center"
      },
      "content": {
        "points": null,
        "curvature": null,
        "fillColor": "#FFFFFF",
        "shapeType": "ShapeType.circle",
        "strokeColor": "#ffffff",
        "strokeWidth": 2,
        "isStrokeDashed": false
      },
      "z_index": 11,
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
          "group": null,
          "style": {
            "color": "#000000",
            "opacity": 1,
            "imageFit": "BoxFit.cover",
            "font_size": 0,
            "is_italic": false,
            "box_shadow": null,
            "text_align": null,
            "decorations": null,
            "font_family": "English",
            "font_weight": "FontWeight.w400",
            "image_shape": null,
            "line_height": 1.2,
            "text_shadow": null,
            "border_color": null,
            "border_style": null,
            "border_width": null,
            "is_read_only": false,
            "border_radius": null,
            "is_underlined": false,
            "text_vertical_align": "center"
          },
          "content": {
            "url":
                "https://netanagri-bucket.s3.amazonaws.com/poster/464/content/1748164511278"
          },
          "z_index": 0,
          "nested_content": null
        },
        "contentFit": "BoxFit.contain",
        "contentAlignment": "Alignment.center"
      }
    }
  ],
  "language_settings": {
    "current_language": "bn-IN",
    "default_language": {
      "code": "en",
      "name": "English",
      "flagEmoji": "🇬🇧",
      "fontFamily": "English",
      "nativeName": "English",
      "textDirection": "TextDirection.ltr"
    },
    "enabled_languages": [
      {
        "code": "en-IN",
        "name": "English",
        "flagEmoji": null,
        "fontFamily": "English",
        "nativeName": "English",
        "textDirection": "TextDirection.ltr"
      },
      {
        "code": "bn-IN",
        "name": "Bengali",
        "flagEmoji": null,
        "fontFamily": "BengaliOptimized",
        "nativeName": "Bengali",
        "textDirection": "TextDirection.ltr"
      },
      {
        "code": "hi-IN",
        "name": "Hindi",
        "flagEmoji": null,
        "fontFamily": "Lohit-Devanagri",
        "nativeName": "Hindi",
        "textDirection": "TextDirection.ltr"
      }
    ]
  }
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BulkPosterProcessorWidget(
          // contentJson: exampleJson,
          posterIds: [
            1352,
            1354,
            1353,
            1355,
            1356,
            1357,
            1358,
            1359,
            1360,
            1361,
            1362,
            1363,
            1364,
            1367,
            1365,
            1366,
            1368,
            1370,
            1369,
            1371,
            1372,
            1373,
            1374,
            1375,
            1376,
            1377,
            1378,
            1379,
            1380,
            1381,
            1382,
            1383,
            1384,
            1385,
            1386,
            1387
          ],
          apiBaseUrl: "https://netanagri-backend.onrender.com/api",
        ),
      ),
    );
  }
}
