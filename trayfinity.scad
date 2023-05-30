/*
  Trayfinity Workbench: infinite possibilities in generating gridfinity assortment trays.
  
  Inspired by the gridfinity OpenSCAD model by user "Jamie": https://www.printables.com/model/174346-gridfinity-openscad-model
  
  ****************************************************************
  *                        WARNING                               *
  *                                                              *
  * Always used named args when calling modules and functions.   *
  * The order of parameters is not guaranteed and can change     *
  * in future versions.                                          *
  ****************************************************************
*/

include <trayfinity-constants.scad>
use <trayfinity-modules.scad>

/* [ Dimensions and layout ] */
// X dimension in grid units
width_units = 5.0; // .5
// Y dimension in grid units
depth_units = 3.0; // .5
// Z dimension (multiples of 7mm)
height_units = 3; // 
// Regular column subdivisions
num_columns = 2;
// Regular row subdivisions
num_rows = 3;
// Relative column widths
column_widths = [ 1, 1, 1, 1, 1 ];
// Relative row depths
row_depths = [ 1, 1, 1, 1, 1 ];
// Generate a layout based on the rows and columns specified above. Otherwise, you'll have to provide one in code.
use_generated_layout = true;

/* [ Tray features ] */
// Outer wall thickness
wall_thickness = 0.95;  // .05
// Thickness of internal subdividers
divider_thickness = 0.9; // .05
// Size of the lip
lip_size = "standard";  // [ "standard", "reduced", "none" ]
// Diameter of the cutouts for the magnets. The design default is 6.5,  the depth of the hole will be 2.4 mm to fit a 6 x 2 mm cylindrical magnet. Set to 0 to disable.
magnet_diameter = 6.5;  // .1
// Depth of the cutouts for the screws. The design default is 4.75. The diameter of the hole will be 3 mm. Set to 0 to disable. 
screw_depth = 4.75;  // .25
// Only add attachments (magnets and screw) to box corners (prints faster).
corner_attachments_only = false;
// Subdivide bottom pads. 
bottom_interface_divide = 1; // [ 1, 2 ]

/* [ Cell features ] */
// Include larger corner fillet at the front side of each cell. Set to 0 to disable. Can be specified per cell
fingerslide_radius = 11;
// Fillet radius of the inside of a cell. Set to 0 to default to 3.75 - wall_thickness. On the corners of the tray the default is the minimum to guarantee a minimum wall thickness.
fillet_radius = 0; // .25
// Minimum thickness above bottom interface. Determines the height of the bottom of a cell.
floor_thickness = 0.8; // .1

/* [ Labels ] */
// Include overhang for labeling. Can be specified per cell. 
label_placement = "all"; // [ "single", "column", "row", "all", "none" ]
// Alignment of the label. Can be specified per cell.
label_align = "left"; // [ "left", "right", "center", "full" ]
// Width of the label in mm.
label_width = 30;  // 1
// Depth of the label in mm.
label_depth = 10;  // .5
// Font name. See the OpenSCAD documentation of the text() function for options (eg. bold).
font = "Liberation Sans";
// Font size (roughly vertical size of text in mm)
font_size = 4; // .1
// Color of the text. This does not matter for the shape, its use is for separate exports of differently colored labels
// You can enter a color name or a hex value
text_color = "black";

text_height = 0.0; // 0.05
// How far the text is embedded into the label.
text_depth = 0.3; // 0.05
// Margin on the left for label text (or the right if label_align == "right")
text_margin_h = 1.0;  // .5
// Margin at the bottom for label text
text_margin_v = 0.0;  // .5

/* [ Output options ] */
// What to render
generate = "all"; // [ "all", "tray", "label texts" ]
// Which color labels to render
color_selection = "all";
// Add extra feature in attachement holes to use bridges for the hole ceiling. Will be done when both screws and magnets are enabled.
attachment_overhang_remedy = true;

// How detailed the model will be rendered. A circle will have at most 360/fa segments
fa_final = 2;
// How detailed the model will be rendered. Maximum size of a circle segment fs. 
fs_final = 0.2;

// Same settings, but for preview
fa_preview = 18;
fs_preview = 0.5;

$fa = $preview ? fa_preview : fa_final;
$fs = $preview ? fs_preview : fs_final;

module customizer_end() {}

layout = 
  use_generated_layout
  ? generate_layout(num_columns = num_columns, num_rows = num_rows)
  : [
      row(
        [ 
          cell(1, 1, label_text = "M3x12", label_align = "full", ref="m3x12"),
          cell(1, 1, label_text = "M3x16"),
          cell(1, 1, label_text = "M3x20", ref="m3x20"),
          cell(1, 1, label_text = "M3x25"),
          cell(1, 2, label_placement = "none", fingerslide_radius = 0, floor_thickness = 10, ref="toolholder")
        ]
      ),
      row(
        [
          cell(2, 1, label_text = "M3x40", ref = "m3x40"),
          cell(1, 1, label_text = "nuts"),
          cell(1, 1, label_text = "washers", font_size = 3.0, ref = "washers")
        ]
      )
    ];
 
tray_definition = build_tray_definition(
  width_units = width_units,
  depth_units = depth_units,
  height_units = height_units,
  layout = layout,
  column_widths = column_widths,
  row_depths = row_depths, 
  fingerslide_radius = fingerslide_radius, 
  floor_thickness = floor_thickness, 
  fillet_radius = fillet_radius,
  label_placement = label_placement,
  label_align = label_align, 
  label_width = label_width, 
  label_depth = label_depth, 
  font = font,
  font_size = font_size,
  text_color = text_color,
  text_height = text_height,
  text_depth = text_depth,
  text_margin_h = text_margin_h,
  text_margin_v = text_margin_v,
  wall_thickness = wall_thickness,
  divider_thickness = divider_thickness, 
  lip_size = lip_size,
  magnet_diameter = magnet_diameter, 
  screw_depth = screw_depth, 
  corner_attachments_only = corner_attachments_only,
  attachment_overhang_remedy = attachment_overhang_remedy,
  bottom_interface_divide = bottom_interface_divide
);    

union() {
  if (generate == "label texts" || generate == "all") { 
    tray_label_texts(
      tray_definition = tray_definition,
      color_selection = color_selection
    );
  }

  if (generate == "tray" || generate == "all") { 
    difference() {  
      trayfinity_tray(
        tray_definition = tray_definition
      );
      tray_label_texts(
        tray_definition = tray_definition,
        color_selection = color_selection
      );
    }
  }
}
