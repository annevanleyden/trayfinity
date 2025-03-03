/*
  Trayfinity Workbench: infinite possibilities in generating gridfinity assortment trays.
  
  Inspired by the gridfinity OpenSCAD model by user "Jamie": https://www.printables.com/model/174346-gridfinity-openscad-model
  
  This file contains the public modules and functions, intended to be called by the user.
  
  ****************************************************************
  *                        WARNING                               *
  *                                                              *
  * Always used named args when calling modules and functions.   *
  * The order of parameters is not guaranteed and can change     *
  * in future versions.                                          *
  ****************************************************************
*/

include <trayfinity-constants.scad>
use <trayfinity-internal.scad>


// X dimension in grid units (multiples of 42 mm)
default_width_units = 3; // .5
// Y dimension in grid units (multiples of 42 mm)
default_depth_units = 2; // .5

default_height_units = 4; // 
// Layout specification similar to html table
default_layout = [
  row( 
    [
      cell(1, 1),
      cell(1, 1),
      cell(1, 2)
    ]
  ),
  row( 
    [
      cell(2, 1)
    ]
  )
];


// Thickness of the outer walls
default_wall_thickness = 0.95;  // .05
// Width of internal subdividers
default_divider_thickness = 0.9; // .05
// Size of the lip
default_lip_size = "standard";  // [ "standard", "reduced", "none" ]
// Diameter of the cutouts for the magnets. The design default is 6.5. The depth of the hole will be 2.4 mm. Set to 0 to disable.
default_magnet_diameter = 6.5;  // .1
// Depth of the cutouts for the screws. The design default is 4.75. The diameter of the hole will be 3 mm. Set to 0 to disable.
default_screw_depth = 4.75;
// Only add attachments (magnets and/or screw) to box corners.
default_corner_attachments_only = false;
// Add extra feature in attachement holes to use bridges for the hole ceiling. Will be done when both screws and magnets are enabled.
default_attachment_overhang_remedy = true;
// Subdivide bottom pads, max 4
default_bottom_interface_divide = 1;
// Include larger fillet at the front side of each cell. Set to a value below fillet_radius  to disable.
default_fingerslide_radius = 11;
// Fillet radius of the inside of a cell. Set to 0 to default to 3.75 - wall_thickness. On the corners of the tray the default is the minimum to guarantee a minimum wall thickness.
default_fillet_radius = 0;
// Minimum thickness above cutouts in base (Zack's design is effectively 1.2)
default_floor_thickness = 0.8; // .1
// Include overhang for labeling 
default_label_placement = "all"; // [ "all", "column", "row", "single", "none" ]
// Alignment of the label
default_label_align = "left"; // [ "left", "right", "center", "full" ]
// Width of the label in mm
default_label_width = 30;  // 1
// Depth of the label in mm
default_label_depth = 10;  // .5
// See OpenSCAD documentation for font specification
default_font = "Liberation Sans";
// Font size (roughly vertical size of text in mm)
default_font_size = 5;
// Text color is mainly used for exporting labels of a certain color for multicolor printing
default_text_color = "black";
// Default is text is flush with label
default_text_height = 0.0;
// Default is text embedded by 0.3 mm into label surface
default_text_depth = 0.3;
// Margin on the left for label text (or the right if label_align == "right")
default_text_margin_h = 1.0;  // .5
// Margin at the bottom for label text
default_text_margin_v = 1.0;  // .5
// Width of generated brim. min 2, 0 = off 
default_brim_width = 4.0;
// Height of generated brim. max = 2.6
default_brim_height = 2.0;
// distance between brim and tray
default_brim_separation_gap = 0.1;

module _defaults_end() {}

trayfinity_tray();
  
/*  
  Main module to generate a tray with cells.
  
  Parameters:
    tray_definition  The output of the 'build_tray_definition' function. See
                     README.md for the design of custom layouts. 
                     This will will always be the first parameter and can
                     be used positionally.
   
*/
module trayfinity_tray(tray_definition = build_tray_definition()) {

  tray_properties = tray_definition[TRAY_PROPERTIES];
  width_units = tray_definition[WIDTH_UNITS];
  depth_units = tray_definition[DEPTH_UNITS];
  height_units = tray_definition[HEIGHT_UNITS];
  wall_thickness = tray_properties[WALL_THICKNESS];
  floor_thickness = tray_properties[FLOOR_THICKNESS];
  lip_size = tray_properties[LIP_SIZE];
  magnet_diameter = tray_properties[MAGNET_DIAMETER];
  screw_depth = tray_properties[SCREW_DEPTH];
  corner_attachments_only = tray_properties[CORNER_ATTACHMENTS_ONLY];
  attachment_overhang_remedy = tray_properties[ATTACHMENT_OVERHANG_REMEDY];
  bottom_interface_divide = tray_properties[BOTTOM_INTERFACE_DIVIDE];
  freestyle_tray(
    width_units = width_units,
    depth_units = depth_units,
    height_units = height_units,
    wall_thickness = wall_thickness,
    floor_thickness = floor_thickness,
    lip_size = lip_size,
    magnet_diameter = magnet_diameter, 
    screw_depth = screw_depth,
    corner_attachments_only = corner_attachments_only,
    attachment_overhang_remedy = attachment_overhang_remedy, 
    bottom_interface_divide = bottom_interface_divide
  )
    union() {
      _cell_cutouts(
        gridded_layout = tray_definition[GRIDDED_LAYOUT],
        tray_properties = tray_properties
      );
      children();
    }
}

/* 
  Convenience module to create a tray of your own design. Specify the cutout(s)
  as children of the module. These cutouts will be bounded by the available space
  inside the tray with respect to wall thickness, floor thickness and lip style.
  
  Parameters:
    width_units                 Number of horizontal gridfinity units (42 mm) in
                                left-right direction.
    depth_units                 Number of horizontal gridfinity units (42 mm) in 
                                front-back direction.
    height_units                Number of vertical gridfinity units (7 mm) above bottom
                                interface
    wall_thickness              Thickness of the outer walls.
    floor_thickness             Thickness of the floor above the bottom interface or (if
                                that value is higher) screw_depth.
    lip_size                   Size of inner lip: "standard", "reduced" or "none".
    magnet_diameter             Diameter of the cutout for a magnet. Set to 0 to have no
                                holes. Default value according to gridfinity specs is 6.5.
                                Depth of the magnet hole will be 2.4 mm as per the specs.
    screw_depth                 Depth of the holes for screws. Default value according
                                to gridfinity specs is 4.75. Hole diameter is 3 mm as
                                per the specs.
    corner_attachments_only     Instead of making cutouts for magnets/screws on the 
                                corners of each interface pad, only make them at the 
                                corners of the tray.
    attachment_overhang_remedy  When both magnet and screw holes are specified, 
                                optimize the cutout for a better 3d printing experience.
    bottom_interface_divide     Subdivide bottom interface pads to allow half offsets.
                                You can go up to 4, provided that no magnet and screw
                                cutouts are specified.
*/
module freestyle_tray(
  width_units = default_width_units,
  depth_units = default_depth_units,
  height_units = default_height_units,
  wall_thickness = default_wall_thickness, 
  floor_thickness = default_floor_thickness,
  lip_size = default_lip_size,
  magnet_diameter = default_magnet_diameter, 
  screw_depth = default_screw_depth,
  corner_attachments_only = default_corner_attachments_only,
  attachment_overhang_remedy = default_attachment_overhang_remedy, 
  bottom_interface_divide = default_bottom_interface_divide
) {
  difference() {
    _blank_tray(
      width = width_units,
      depth = depth_units,
      height = height_units,
      wall_thickness = wall_thickness,
      lip_size = lip_size,
      magnet_diameter = magnet_diameter, 
      screw_depth = screw_depth,
      corner_attachments_only = corner_attachments_only,
      attachment_overhang_remedy = attachment_overhang_remedy, 
      bottom_interface_divide = bottom_interface_divide
    );    
   
    intersection() {
      _usable_space(
        width = width_units,
        depth = depth_units,
        height = height_units,
        wall_thickness = wall_thickness,
        floor_thickness = floor_thickness,
        lip_size = lip_size
      );
      union() children();
    }
  }
}

/*
  Generate the label texts as separate objects for multicolor printing.

  Parameters: 
    tray_definition    The output of the 'build_tray_definition' function. See
                       README.md.
                       This will will always be the first parameter and can
                       be used positionally.
    color_selection    Only generate the labels with this text color. If left 
                       empty or value = "all", all label texts will be rendered.
                       
                       
                       
*/
module tray_label_texts(
  tray_definition,
  color_selection
) { 
  tray_properties = tray_definition[TRAY_PROPERTIES];

  union() {
    for (grid_row = tray_definition[GRIDDED_LAYOUT]) {
      for (cell = grid_row) {
        text_color = get_property(TEXT_COLOR, cell[PROPERTIES], tray_properties);
        if (cell[GENERATE] && cell != undef && cell[COLSPAN] > 0 && cell[ROWSPAN] > 0 && (text_color == color_selection || color_selection == undef || color_selection == "all")) {
          _label_text(
            cell = cell,
            tray_properties = tray_properties
          );
        }
      }
    }
  }
}

module tray_brim(
  tray_definition,
) {
  tray_properties = tray_definition[TRAY_PROPERTIES];
  _brim(
    width_units = tray_definition[WIDTH_UNITS],
    depth_units = tray_definition[DEPTH_UNITS],
    brim_width = tray_properties[BRIM_WIDTH],
    brim_height = tray_properties[BRIM_HEIGHT],
    brim_separation_gap = tray_properties[BRIM_SEPARATION_GAP]
  );  
}

/*
  Generate a custom cell in place of the standard cell. For this to work, the standard
  cell must have a 'ref' and be defined with 'generate = false'. Then you can put this
  module inside the trayfinity_tray module to be rendered in the correct position.

  Parameters: 
    tray_definition    The output of the 'build_tray_definition' function. See
                       README.md.
                       This will will always be the first parameter and can
                       be used positionally. 
    ref                ref of the cell for the feature to be rendered. Should 
                       resolve to a single cell. Either this parameter or the
                       cell should be specified.
    cell               The cell to render. The cell can be obtained by using 
                       the find_cells() function or iterating a gridded_layout.
*/
module custom_cell(tray_definition, ref, cell) {
  cells = 
    cell == undef 
      ? find_cells(ref, tray_definition)
      : [ cell ];
  
  if (len(cells) > 1) 
    echo(str("WARNING: multiple cells found for ref ", ref, ". Using the first one."));
  if (len(cells) == 0)
    echo(str("WARNING: no cells found for ref ", ref));
  cell_to_render = cells[0];
    
  if (cell_to_render != undef) {
    translate(cell_to_render[BOUNDING_BOX][POSITION])
    intersection() {
      cube(cell_to_render[BOUNDING_BOX][SIZE]);
      union() children();
    }
  }
}
        
/*
  Generate a brim that is thicker than the single layer one generated by the slicer. 
  This resists peeling a lot better than the single layer brim.
        
  Parameters:
    width_units                 Number of horizontal gridfinity units (42 mm) in
                                left-right direction.
    depth_units                 Number of horizontal gridfinity units (42 mm) in 
                                front-back direction.
    brim_width                  Width of the brim in mm. 
    brim_height                 Height of the brim in mm.
    brim_separation_gap         Gap between the first layer of the tray and the first 
                                layer of the brim. Higher layers of the brim have a fixed
                                distance of 0.4 mm.
*/       
module _brim(
  width_units = default_width_units,
  depth_units = default_depth_units,
  brim_width = default_brim_width,
  brim_height = default_brim_height,
  brim_separation_gap = default_brim_separation_gap  
) { 
  translate([GF_EFFECTIVE_OUTER_RADIUS, GF_EFFECTIVE_OUTER_RADIUS, 0]) {
  _rounded_shape(
    straight_length_x = width_units * GF_PITCH_H - 2 * GF_OUTER_RADIUS, 
    straight_length_y = depth_units * GF_PITCH_H - 2 * GF_OUTER_RADIUS
  ) {
    translate([GF_BOTTOM_INTERFACE_RIM_RADIUS - GF_INTERFACE_CHAMFER + brim_separation_gap, 0, 0]) {
      polygon(
        [
          [0, 0],
          [max(brim_width, 2) - 0.4, 0],
          [0.4 + GF_INTERFACE_CHAMFER, brim_height],
          [0.4 + GF_INTERFACE_CHAMFER, GF_INTERFACE_CHAMFER],
          [0.4, 0.2],
          [0.2, 0.2]       
        ]
      );
    }
  }
  }
}

/*
   Build an enriched definition of a tray to be passed to either the
   trayfinity_tray() or tray_text_label() module.
   
   See defaults above for description of parameters
*/
function build_tray_definition(
  // layout of the tray
  width_units = default_width_units,
  depth_units = default_depth_units,
  height_units = default_height_units,
  layout = default_layout,
  column_widths = [],
  row_depths = [],
  // these properties are shared with cell properties
  fingerslide_radius = default_fingerslide_radius, 
  floor_thickness = default_floor_thickness,
  fillet_radius = default_fillet_radius,
  label_placement = default_label_placement,
  label_align = default_label_align, 
  label_width = default_label_width, 
  label_depth = default_label_depth, 
  font = default_font,
  font_size = default_font_size,
  text_color = default_text_color,
  text_height = default_text_height,
  text_depth = default_text_depth,
  text_margin_h = default_text_margin_h,
  text_margin_v = default_text_margin_v,
  // these properties only makes sense at the tray level
  wall_thickness = default_wall_thickness,
  divider_thickness = default_divider_thickness,
  lip_size = default_lip_size,
  magnet_diameter = default_magnet_diameter, 
  screw_depth = default_screw_depth,
  corner_attachments_only = default_corner_attachments_only,
  attachment_overhang_remedy = default_attachment_overhang_remedy, 
  bottom_interface_divide = default_bottom_interface_divide,
  brim_width = default_brim_width,
  brim_height = default_brim_height,
  brim_separation_gap = default_brim_separation_gap
) =
  let(tray_properties =
    [
      fingerslide_radius, 
      floor_thickness,
      fillet_radius == 0 ? GF_EFFECTIVE_OUTER_RADIUS - wall_thickness : fillet_radius,
      label_placement,
      label_align,
      label_width,
      label_depth,
      undef,  // placeholder for label_text, doesn't make sense at the tray level
      font,
      font_size,
      text_color,
      text_height,
      text_depth,
      text_margin_h,
      text_margin_v,
      wall_thickness,
      divider_thickness,
      lip_size,
      magnet_diameter, 
      screw_depth,
      corner_attachments_only,
      attachment_overhang_remedy,
      bottom_interface_divide,
      brim_width,
      brim_height,
      brim_separation_gap
    ]
  )
  [
    width_units,
    depth_units,
    height_units,
    build_gridded_layout(
      width_units = width_units,
      depth_units = depth_units,
      height_units = height_units,
      layout = layout,
      tray_properties = tray_properties,
      column_widths = complete(column_widths, num_cols(layout), 1),
      row_depths = complete(row_depths, num_rows(layout), 1),
      divider_thickness = default_divider_thickness,
      screw_depth = default_screw_depth
    ),
    tray_properties
  ];


/*
  Define a row 
  
  Parameters:
    cells         The cells in the row, as generated by the cell() function.
*/
function row(cells) =
  [ 
    for (i = [0:len(cells) - 1]) 
      for (j = [0 : len(cells[i]) - 1]) 
        cells[i][j]
  ];

/*
  Define a cell
  Parameters:
    colspan      Span cell over this many columns. This will always be 
                 the first parameter, safe to use positionally.  
    rowspan      Span cell over this many rows.  This will always be 
                 the second parameter, safe to use positionally.  
    generate     If false, the cell will not be generated and result in a 
                 blank space instead where custom features can be created.
    ref          Reference for a cell. For making custom cut-outs. See 
                 README on more details.
  
  Other parameters: see description of defaults at the top of this file 
  or README.md.
      
*/  
function cell(
  colspan = 1, 
  rowspan = 1,
  fingerslide_radius, 
  floor_thickness,
  fillet_radius,
  label_text,
  label_placement,
  label_align,
  label_width,
  label_depth,
  font,
  font_size,
  text_color,
  text_height,
  text_depth,
  text_margin_h,
  text_margin_v,
  generate = true,
  ref,
  user_defined
) =
  [ 
    [ 
      colspan, 
      rowspan, 
      [
        fingerslide_radius, 
        floor_thickness,
        fillet_radius,
        label_placement, 
        label_align,
        label_width,
        label_depth,
        label_text,
        font,
        font_size,
        text_color,
        text_height,
        text_depth,
        text_margin_h,
        text_margin_v
      ],
      generate,
      ref,
      user_defined 
    ],
    if (colspan > 1) for (col = [2:colspan]) [ 0, rowspan, [] ]
  ];

/*
  Find a cell by its reference. If more than one cell matches, the first will
  be returned. The search is case sensitive.
  
  Mostly used to query the available space for a custom feature.
  
  To get a vector with the size in x, y and z direction:
    cell = find_cells(tray_definition, "toolholder");
    size_v3 = cell[BOUNDING_BOX][SIZE];
    
    tray_definition    The output of the 'build_tray_definition' function. See
                       README.md.
                       This will will always be the first parameter and can
                       be used positionally. 
    ref                The ref property of the cells to find.
      
*/
function find_cells(tray_definition, ref) = 
  _find_cells(ref, tray_definition[GRIDDED_LAYOUT], 0, 0); 
  
function generate_layout(num_columns = 2, num_rows = 1) =
[
  for (row = [1:num_rows]) 
    row(
      [
        for (col = [1:num_columns]) cell() 
      ]
    )
];

