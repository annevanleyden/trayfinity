/*
  Trayfinity Workbench: infinite possibilities in generating gridfinity assortment trays.
  
  This file contains the internals, not intended to be called by the user. They
  WILL change or disappear in future versions. Use at your own risk.
*/


include <trayfinity-constants.scad>

/*
  Generate a tray with a solid useable inner space. This form the basis from which
  the cells are carved out.
*/
module _blank_tray(
  width,
  depth,
  height,
  wall_thickness,
  lip_size,
  magnet_diameter,
  screw_depth, 
  corner_attachments_only,
  attachment_overhang_remedy,
  bottom_interface_divide  
) {
  straight_length_x = width * GF_PITCH_H - GF_OUTER_RADIUS * 2;
  straight_length_y = depth * GF_PITCH_H - GF_OUTER_RADIUS * 2;
  corner_center_distance = GF_PITCH_H / bottom_interface_divide - GF_OUTER_RADIUS * 2;
  translate([GF_EFFECTIVE_OUTER_RADIUS, GF_EFFECTIVE_OUTER_RADIUS, 0])
  difference() {
    union() {
      _tray_top(
        straight_length_x = straight_length_x,
        straight_length_y = straight_length_y,
        height = height,
        wall_thickness = wall_thickness,
        lip_size = lip_size
      );

      translate([0, 0, GF_BOTTOM_INTERFACE_HEIGHT])
      _rounded_box(
        size_x = width * GF_PITCH_H - GF_CLEARANCE * 2,
        size_y = depth * GF_PITCH_H - GF_CLEARANCE * 2,
        // - 0.001 to not let the top of the cell cutters coincide with the top plane of this solid
        // infill of the tray. This can produce artifacts.
        size_z = tray_inside_top_z(height) - GF_BOTTOM_INTERFACE_HEIGHT - 0.001,
        radius = GF_EFFECTIVE_OUTER_RADIUS
      );

      for (x = [0 : width * bottom_interface_divide - 1])
        for (y  = [0 : depth  * bottom_interface_divide - 1])
          translate([GF_PITCH_H * x / bottom_interface_divide, GF_PITCH_H * y / bottom_interface_divide, 0])
            union() {
              _rounded_shape(
                straight_length_x = corner_center_distance, 
                straight_length_y = corner_center_distance
              ) _bottom_interface_profile();
              cube([corner_center_distance, corner_center_distance, GF_BOTTOM_INTERFACE_HEIGHT]);
            }
    }
        
    if (corner_attachments_only) {
      _attachment_cutouts(
        dist_x = straight_length_x,
        dist_y = straight_length_y,
        magnet_diameter = magnet_diameter,
        screw_depth = screw_depth,
        attachment_overhang_remedy = attachment_overhang_remedy
      ); 
    } else {    
      for (x = [0 : width * bottom_interface_divide - 1])
        for (y  = [0 : depth  * bottom_interface_divide - 1])
          translate([GF_PITCH_H * x / bottom_interface_divide, GF_PITCH_H * y / bottom_interface_divide, 0])
            _attachment_cutouts(
              dist_x = corner_center_distance,
              dist_y = corner_center_distance,
              magnet_diameter = magnet_diameter,
              screw_depth = screw_depth,
              attachment_overhang_remedy = attachment_overhang_remedy
            );
    }
  }
}

/*
  Generate a shape representing the maximum usable space inside a tray. 
*/
module _usable_space(
  width,
  depth,
  height,
  wall_thickness,
  floor_thickness,
  lip_size 
) {
  translate([GF_EFFECTIVE_OUTER_RADIUS, GF_EFFECTIVE_OUTER_RADIUS, 0])
  difference() {
    translate([0, 0, GF_BOTTOM_INTERFACE_HEIGHT + floor_thickness])
    _rounded_box(
      size_x = GF_PITCH_H * width - (GF_CLEARANCE + wall_thickness) * 2,
      size_y = GF_PITCH_H * depth - (GF_CLEARANCE + wall_thickness) * 2,
      size_z = tray_inside_top_z(height) - GF_BOTTOM_INTERFACE_HEIGHT ,
      radius = GF_EFFECTIVE_OUTER_RADIUS - wall_thickness
    );
    _tray_top(
      straight_length_x = width * GF_PITCH_H - GF_OUTER_RADIUS * 2,
      straight_length_y = depth * GF_PITCH_H - GF_OUTER_RADIUS * 2,
      height = height,
      wall_thickness = wall_thickness,
      lip_size = lip_size
    );
  }
}

/*
  Generate the top section of the tray. Everything from the chamfer beneath 
  the lip and up. 
*/
module _tray_top(
  straight_length_x,
  straight_length_y,
  height,
  wall_thickness,
  lip_size
) {
    _rounded_shape(
      straight_length_x = straight_length_x,
      straight_length_y = straight_length_y
    ) {
      _tray_top_profile(
        height = height,
        wall_thickness = wall_thickness,
        lip_size = lip_size
      );
    }
}

/*
  Generate the 2D profile for the top rim.
*/
module _tray_top_profile(
  height,
  wall_thickness,
  lip_size
) {
  top_z = tray_top_z(height); 
  wall_inner_radius = GF_EFFECTIVE_OUTER_RADIUS - wall_thickness;

  top_interface_radius = 
    lip_size == "none"
      ? wall_inner_radius
      : GF_TOP_INTERFACE_RIM_RADIUS;
  
  lip_radius = lip_radius(lip_size, wall_thickness);
//    lip_size == "reduced" ? GF_TOP_INTERFACE_RIM_RADIUS :
//    lip_size == "none"    ? wall_inner_radius
//                           : GF_STANDARD_LIP_RADIUS;

  top_rim_inner_radius = GF_TOP_INTERFACE_RIM_RADIUS + GF_TOP_INTERFACE_RIM_FROM_TOP; 

  top_interface_rim_from_top =
    lip_size == "none" 
      ? max(top_rim_inner_radius - wall_inner_radius, 0)
      : GF_TOP_INTERFACE_RIM_FROM_TOP;
  
  interface_rim_height_net = GF_INTERFACE_RIM_HEIGHT - GF_INTERFACE_CHAMFER;
  top_interface_rim_top_z = top_z - top_interface_rim_from_top;
  top_interface_rim_bottom_z = top_interface_rim_top_z - interface_rim_height_net;
  lip_top_z =     
    lip_size == "standard" 
      ? top_interface_rim_bottom_z - (GF_TOP_INTERFACE_RIM_RADIUS - GF_STANDARD_LIP_RADIUS)
      : top_interface_rim_bottom_z;
      
  lip_bottom_z = 
    lip_size == "standard"
      ? lip_top_z - GF_LIP_HEIGHT
      : lip_top_z;
      
  lip_bottom_chamfer_z = lip_bottom_z - max(wall_inner_radius - lip_radius, 1);
    
  polygon(
    [
      [ wall_inner_radius, top_z - GF_INTERFACE_HEIGHT ],
      [ GF_EFFECTIVE_OUTER_RADIUS, top_z - GF_INTERFACE_HEIGHT ],
      [ GF_EFFECTIVE_OUTER_RADIUS, top_z ],             
      [ top_rim_inner_radius, top_z ], 
      [ top_interface_radius, top_interface_rim_top_z ], 
      [ top_interface_radius, top_interface_rim_bottom_z ], 
      [ lip_radius, lip_top_z ], 
      [ lip_radius, lip_bottom_z ], 
      [ wall_inner_radius, lip_bottom_chamfer_z ],
      [ wall_inner_radius, top_z - GF_INTERFACE_HEIGHT ]
    ]
  );
}

/*
  Generate a box with a flat top and bottom and rounded corners. The box will be 
  positioned with the center of a corner at [0, 0] and the bottom at z 0. It will
  extend into the positive x and y directions.
*/
module _rounded_box(
  size_x,
  size_y,
  size_z,
  radius
 ) {
  hull() {
    _rectangle_pattern(
      dist_x = size_x - radius * 2,
      dist_y = size_y - radius * 2
    )
      // - 0.001 to not let the top of the cell cutters coincide with the top plane of this solid
      // infill of the tray. This can produce artifacts.
      cylinder(r = radius, h = size_z );        
  }
}

/* 
  The 2d profile describing the bottom (outer) interface
*/
module _bottom_interface_profile() {
  polygon(
    [
      [ 0, 0 ],
      [ GF_INTERFACE_CHAMFER, 0 ],
      [ GF_INTERFACE_CHAMFER * 2, GF_INTERFACE_CHAMFER ],             
      [ GF_INTERFACE_CHAMFER * 2, GF_INTERFACE_RIM_HEIGHT ], 
      [ GF_EFFECTIVE_OUTER_RADIUS, GF_BOTTOM_INTERFACE_HEIGHT ], 
      [ 0, GF_BOTTOM_INTERFACE_HEIGHT ], 
    ]
  );  
}

/*
  Carve out the cells from a blank tray. 
*/
module _cell_cutouts(
  gridded_layout,
  tray_properties
) { 

  union() {
    for (row=[0 : len(gridded_layout) - 1]) {
      for (cell = gridded_layout[row]) {
        if (cell[GENERATE] && cell != undef && cell[COLSPAN] > 0 && cell[ROWSPAN] > 0) {

          difference() {
            _cell_cutter(
              cell = cell,
              tray_properties = tray_properties
            ); 
            
            _label_cutter(
              cell = cell,
              tray_properties = tray_properties
            );
          }
        }
      }
    }
  }
}

/*
  Carve out a single cell from a blank tray.
*/
module _cell_cutter(
  cell, 
  tray_properties
) {
  fillet_radius = get_property(
    FILLET_RADIUS, 
    cell[PROPERTIES], 
    tray_properties, 
    GF_EFFECTIVE_OUTER_RADIUS - tray_properties[WALL_THICKNESS]
  );
      
  cell_x = cell[BOUNDING_BOX][SIZE][X];
  cell_y = cell[BOUNDING_BOX][SIZE][Y];
  
  finger_slide_radius = max(get_property(FINGERSLIDE_RADIUS, cell[PROPERTIES], tray_properties), fillet_radius);
  corner_x = [0 + fillet_radius, cell_x - fillet_radius];
  corner_y = [0 + fillet_radius, cell_y - fillet_radius];
  translate(cell[BOUNDING_BOX][POSITION]) {
    hull() {
      for (x=[0:1]) {
        for (y=[0:1]) {
          translate([corner_x[x], corner_y[y], cell[BOUNDING_BOX][SIZE][Z] - 1])
          cylinder(h = 1.2, r = fillet_radius);        
        }
        
        // We only need a quarter torus for the hull(), extruding a
        // quarter circle over 90 degrees speeds up rendering noticeably
        translate([corner_x[x], finger_slide_radius, finger_slide_radius])
        rotate([-90, 90 * (1 - x), 90 + 180 * x])
        rotate_extrude(angle = 90)
        translate([finger_slide_radius - fillet_radius, 0, 0])
        intersection() {
          square(finger_slide_radius);
          circle(r = fillet_radius);
        }
        
        translate([corner_x[x], corner_y[1], fillet_radius])
        sphere(r = fillet_radius);
      }
    }
    %translate([cell_x / 2, cell_y / 2, 0.01 ]) 
    color("black")
    linear_extrude(height = 0.1) { 
      translate([0, 6.5])
      text(text = cell[REF], size = 2.5, halign = "center", valign = "center");
      translate([0, 3.25])
      text(text = str(cell_x), size = 2.5, halign = "center", valign = "center");
      translate([0, 0.75])
      text(text = " x ", size = 2, halign = "center", valign = "center");
      translate([0, -1.75])
      text(text = str(cell_y), size = 2.5, halign = "center", valign = "center");
    }
  }
}

/*
  Cut the label from a cell cut out if the design specifies that this cell must 
  have a label. 
  
  Because negative x negative = positive, this renders a positive shape.
  
  The label will be positioned at [0, 0, 0], extending into the negative y and z 
  directions. It will extend into the positive x direction when label_align is 
  "left" or "full" and in the negative x direction if label_align = "right".
  If label_align = "center" the x direction will be centered on 0.
*/
module _label_cutter(
  cell,
  tray_properties
) {
  label_placement = get_property(LABEL_PLACEMENT, cell[PROPERTIES], tray_properties);
  is_first_column = cell[METADATA][IS_FIRST_COLUMN];
  is_last_column = cell[METADATA][IS_LAST_COLUMN];
  is_last_row = cell[METADATA][IS_LAST_ROW];

  if (label_placement != "none" &&
      (   (is_last_row || label_placement == "row") && 
          (is_first_column || label_placement == "column") ||
          label_placement == "all"
      )
  ) {
    cell_start_x = cell[BOUNDING_BOX][POSITION][X];
    cell_size_x  = cell[BOUNDING_BOX][SIZE][X];
    cell_end_y = cell[BOUNDING_BOX][POSITION][Y] + cell[BOUNDING_BOX][SIZE][Y];
    cell_end_z = cell[BOUNDING_BOX][POSITION][Z] + cell[BOUNDING_BOX][SIZE][Z];

    label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties);
    label_width = get_property(LABEL_WIDTH, cell[PROPERTIES], tray_properties);
    label_depth = get_property(LABEL_DEPTH, cell[PROPERTIES], tray_properties);
    text_height = get_property(TEXT_HEIGHT, cell[PROPERTIES], tray_properties);
    text_depth  = get_property(TEXT_DEPTH,  cell[PROPERTIES], tray_properties);
    
    lip_size = tray_properties[LIP_SIZE];
    wall_thickness = tray_properties[WALL_THICKNESS];

    label_pos_x = label_pos_x(cell, tray_properties);

    difference() {
      translate([cell_start_x + label_pos_x, cell_end_y, cell_end_z - text_height])
      translate([-0.002, -0.002, -text_height])
      _label_shape(
        cell = cell, 
        tray_properties = tray_properties
      );
    }
  }
}


/* 
  Render the basic shape of a label.
*/
module _label_shape(
  cell, 
  tray_properties
) {
  size_x = label_size_x(cell, tray_properties); 
  size_y = get_property(LABEL_DEPTH, cell[PROPERTIES], tray_properties) + 
    label_size_correction(cell[METADATA][IS_LAST_ROW], tray_properties);
    
  label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties);
  label_corner_x = 
    label_align == "right"  ? [-size_x + LABEL_FILLET_RADIUS, -LABEL_FILLET_RADIUS] :
    label_align == "center" ? [-size_x / 2 + LABEL_FILLET_RADIUS, size_x / 2 - LABEL_FILLET_RADIUS]
                      // "left", "full" and other (unsupported) values 
                      : [LABEL_FILLET_RADIUS, size_x - LABEL_FILLET_RADIUS];

  label_corner_y = [0, -size_y + LABEL_FILLET_RADIUS, 0];
  label_corner_z = [-LABEL_FILLET_RADIUS, -LABEL_FILLET_RADIUS, LABEL_FILLET_RADIUS];

  hull() {
    for (x = [0:1]) {
      for (yz = [0:2]) {
        translate([label_corner_x[x], label_corner_y[yz], label_corner_z[yz]])
        if (yz == 0) {
          translate([0, -LABEL_FILLET_RADIUS, 0])
          if (needs_rounded_label_edge(x, label_align)) {
            rotate([90, 0, 0])
            cylinder(h = LABEL_FILLET_RADIUS * 2, r = LABEL_FILLET_RADIUS,center = true);
          } else {
            cube(LABEL_FILLET_RADIUS * 2, center = true);
          }
        } else if (yz == 1) {
          if (needs_rounded_label_edge(x, label_align)) {
            sphere(r = LABEL_FILLET_RADIUS);
          } else {
            rotate([0, 90, 0])
            cylinder(h = LABEL_FILLET_RADIUS * 2, r = LABEL_FILLET_RADIUS, center = true);
          }
        } else {
          translate([0, -size_y + LABEL_FILLET_RADIUS, 0])
          rotate([-LABEL_UNDERSIDE_ANGLE, 0, 0])
          translate([0, size_y - LABEL_FILLET_RADIUS, 0]) {
            if (needs_rounded_label_edge(x, label_align)) {
              translate([0, 23, 0])
              rotate([90, 0, 0])
              cylinder(h = 50, r = LABEL_FILLET_RADIUS, center = true);
            } else {
              translate([0, 23, 0])
              cube([LABEL_FILLET_RADIUS * 2, 50, LABEL_FILLET_RADIUS * 2], center = true);
            }
          }
        }
      }
    }
  }
}  

/* 
  Render the text for a label.
*/
module _label_text(
  cell, 
  tray_properties
) {
  label_text = get_property(LABEL_TEXT, cell[PROPERTIES]);
  is_first_column = cell[METADATA][IS_FIRST_COLUMN];
  is_last_column = cell[METADATA][IS_LAST_COLUMN];
  is_last_row = cell[METADATA][IS_LAST_ROW];

  nominal_label_size_y = get_property(LABEL_DEPTH, cell[PROPERTIES], tray_properties);
  text_margin_h = get_property(TEXT_MARGIN_H, cell[PROPERTIES], tray_properties);
  text_margin_v = get_property(TEXT_MARGIN_V, cell[PROPERTIES], tray_properties);
  font = get_property(FONT, cell[PROPERTIES], tray_properties);
  font_size = get_property(FONT_SIZE, cell[PROPERTIES], tray_properties);
  text_height = get_property(TEXT_HEIGHT, cell[PROPERTIES], tray_properties);
  text_depth = get_property(TEXT_DEPTH, cell[PROPERTIES], tray_properties);
  text_color = get_property(TEXT_COLOR, cell[PROPERTIES], tray_properties);
  label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties);
  
  label_pos_x = label_pos_x(cell, tray_properties);

  corrections_direction = (label_align == "right" ? -1 : 1);

  translate(cell[BOUNDING_BOX][POSITION])
  translate([
    label_pos_x + (text_margin_h + label_size_x_correction(cell, tray_properties)) * corrections_direction, 
    cell[BOUNDING_BOX][SIZE][Y] - nominal_label_size_y / 2 - label_size_correction(is_last_row, tray_properties) + text_margin_v, 
    cell[BOUNDING_BOX][SIZE][Z] - (text_height + text_depth)
  ])
  color(text_color)
  linear_extrude(height = text_height + text_depth)
    text(
      text = label_text, 
      size = font_size, 
      font = font, 
      halign = label_align == "full" ? "left" : label_align, 
      valign = "center");
}

/*
  Generate one set (4) of cutouts for magnets and/or screws 
*/
module _attachment_cutouts(
  dist_x, 
  dist_y,
  magnet_diameter,
  screw_depth, 
  attachment_overhang_remedy
) {
  translate([GF_ATTACHMENT_INSET, GF_ATTACHMENT_INSET, 0])
    _rectangle_pattern(
      dist_x = dist_x - GF_ATTACHMENT_INSET * 2,
      dist_y = dist_y - GF_ATTACHMENT_INSET * 2
    )
      _attachment_cutter(
        magnet_diameter = magnet_diameter,
        screw_depth = screw_depth,
        attachment_overhang_remedy = attachment_overhang_remedy
      ); 
}

/*
  Render a single cutout for a magnet/screw 
*/
module _attachment_cutter(
  magnet_diameter,
  screw_depth, 
  attachment_overhang_remedy
) {
  render()  // prevent openSCAD from blowing up when previewing
  translate([0, 0, -0.01])
  union() {
    if (magnet_diameter > 0) cylinder(h = GF_MAGNET_HEIGHT, d = magnet_diameter);
    if (screw_depth > 0)     cylinder(h = screw_depth, d = GF_SCREW_DIAMETER);
    if (attachment_overhang_remedy && magnet_diameter > 0 && screw_depth > 0) {
      intersection() {
        cylinder(h = GF_MAGNET_HEIGHT + OVERHANG_REMEDY_DEPTH + 0.001, d = magnet_diameter);
        cube([magnet_diameter, GF_SCREW_DIAMETER, 50], center = true);
      }
    }
  }  
}

/*
  Make a rectangular shape with rounded edges from the given 2d profile. The 
  profile will be rotated along its y-axis. 
  
  This module should have a single 2d profile as child.
*/
module _rounded_shape(straight_length_x, straight_length_y) {
  union() {  
    for (x = [0:1]) 
      for (y = [0:1]) 
        translate([straight_length_x * x, straight_length_y * y, 0])
        rotate([0, 0, 180 + 90 * x - 90 * y + 180 * x * y]) {
          _straight_with_rounded_corner(length = x == y ? straight_length_y : straight_length_x)
            children();
        }
  }
}

/* 
  Make four copies of the given shape and place them in a rectangular pattern.
*/
module _rectangle_pattern(dist_x, dist_y) {
  union() {  
    for (x = [0, dist_x]) 
      for (y = [0, dist_y]) 
        translate([x, y, 0])
        children();
  }
}

/*
  Create a straight shape with a 90% bend at one end from a 2d profile.
*/
module _straight_with_rounded_corner(length) {
  rotate_extrude(angle = 90)
  children();
  rotate([90, 0, 0])
  linear_extrude(height = length)
  children();
}  
  
/*
  Build an enriched layout according to the given layout spec. 
  
    width_units         Number of horizontal gridfinity units (42 mm) in
                        left-right direction.
    depth_units         Number of horizontal gridfinity units (42 mm) in 
                        front-back direction.
    height_units        Number of vertical gridfinity units (7 mm) above bottom
                        interface
    layout              An array of rows (as created with the row() function), each 
                        containing an array of cells (as created with the cell()
                        function). For more information on defining your own custom 
                        layout, see README.md.
    column_widths       Relative widths of each column. You can use any unit you can 
                        think of. Any unspecified column width will default to 1.
    row_depths          Relative depths of each row. You can use any unit you can
                        think of. Any unspecified row depth will default to 1.  
*/  
function build_gridded_layout(
  width_units,
  depth_units,
  height_units,
  layout,
  tray_properties,
  column_widths,
  row_depths, 
  divider_thickness,
  screw_depth
) =
  let(rowspan_inserts = 
    [
      for (col = [0:num_cols(layout) - 1])
      [
        for (row = [0:num_rows(layout) - 1])
          let(rowspan = layout[row][col][1])
          if (rowspan != undef && rowspan > 1) 
            for (spanned_row = [1:rowspan - 1])
              row + spanned_row
      ]  
    ]
  )
  let(gridded_layout =  
    [  
      for (row = [0:num_rows(layout) - 1])
        [
          for (
            src_col = 0,
            dest_col = 0,
            num_cols = len(layout[row]),
            src_col_skip = 0;

            dest_col < num_cols;
           
            src_col_skip = search(row, rowspan_inserts[dest_col]) ? 0 : 1,
            dest_col = dest_col + 1, 
            src_col = src_col + src_col_skip,
            num_cols = num_cols + 1 - src_col_skip
          )
            search(row, rowspan_inserts[dest_col])
              ? DUMMY_CELL
              : layout[row][src_col]            
        ]
    ]
  )
  /* We could have a jagged layout if not all cells were defined. Fill out all rows
     with empty cells so we have a nice regular grid with equal number of cells in
     each rowith an unequalfill out all the rows with empty cells.
  */
  let(num_cols = num_cols(gridded_layout))
  let(regular_gridded_layout =
    [  
      for (grid_row = gridded_layout)
        complete(grid_row, num_cols, DUMMY_CELL)
    ]
  )  

  add_cell_positions_and_sizes(
    gridded_layout = regular_gridded_layout,
    width_units = width_units,
    depth_units = depth_units,
    height_units = height_units,
    tray_properties = tray_properties,
    column_widths = complete(column_widths, num_cols, 1),
    row_depths = complete(row_depths, num_rows(gridded_layout), 1)
  );

/* 
  Augment the gridded_layout with the positions and sizes of each cell.
*/
function add_cell_positions_and_sizes(
  gridded_layout,
  width_units,
  depth_units,
  height_units,
  tray_properties,
  column_widths,
  row_depths 
) =
  let(wall_thickness = get_property(WALL_THICKNESS, tray_properties))
  let(divider_thickness = get_property(DIVIDER_THICKNESS, tray_properties))
  let(screw_depth = get_property(SCREW_DEPTH, tray_properties))

  let(grid_size_pos_x = get_grid_positions_and_sizes(
    relative_dimensions = column_widths,
    num = width_units,
    start_wall_thickness = wall_thickness,
    end_wall_thickness = wall_thickness,
    divider_thickness = divider_thickness
  ))

  let (grid_size_pos_y = get_grid_positions_and_sizes(
    relative_dimensions = row_depths,
    num = depth_units,
    start_wall_thickness = front_wall_thickness(tray_properties),
    end_wall_thickness = wall_thickness,
    divider_thickness = divider_thickness
  ))

  [
    for (row=[0:len(grid_size_pos_y) - 1]) 
    [
      for (col=[0:len(grid_size_pos_x) - 1])
        let(cell = gridded_layout[row][col])
        
        (cell != undef && cell[COLSPAN] > 0 && cell[ROWSPAN] > 0)
          ? join(
              cell,
              [
                cell_bounding_box(
                  row = row,
                  col = col,
                  cell = cell,
                  width_units = width_units,
                  depth_units = depth_units,
                  height_units = height_units,
                  tray_properties = tray_properties,
                  grid_size_pos_x = grid_size_pos_x,
                  grid_size_pos_y = grid_size_pos_y,
                  screw_depth = screw_depth
                ),
                cell_metadata(row, col, gridded_layout)
              ]
            )
          : cell
    ]
  ];

/* 
  For a single direction, and the given relative dimensions, calculate the start 
  position of a cell and its size. This fuction is used for doing this in both x 
  and y direction.
*/
function get_grid_positions_and_sizes(
  relative_dimensions, 
  num, 
  start_wall_thickness, 
  end_wall_thickness,
  divider_thickness
 ) =
  let(available_space = GF_PITCH_H * num - 2 * GF_CLEARANCE - start_wall_thickness - end_wall_thickness - (len(relative_dimensions) - 1) * divider_thickness)
  let(factor = available_space / sum(relative_dimensions))
  len(relative_dimensions) > 0
    ? [ for (i = 0, position = start_wall_thickness; 
          i < len(relative_dimensions); 
          position = position + relative_dimensions[i] * factor + divider_thickness, 
          i = i + 1
        ) 
          [ position, relative_dimensions[i] * factor ] 
      ] 
    : [];   

/*
  Calulate a bounding box for a single cell.
*/
function cell_bounding_box(
  row,
  col,
  cell,
  width_units,
  depth_units,
  height_units,
  tray_properties,
  grid_size_pos_x,
  grid_size_pos_y,
  screw_depth 
) =
  let(wall_thickness = get_property(WALL_THICKNESS, tray_properties))
  let(cell_size_x = get_cell_size(col, grid_size_pos_x, cell[COLSPAN]))
  let(cell_size_y = get_cell_size(row, grid_size_pos_y, cell[ROWSPAN]))
  let(floor_thickness = get_property(FLOOR_THICKNESS, cell[PROPERTIES], tray_properties))
  let(cell_bottom_z = floor_height(screw_depth, floor_thickness))
  let(cell_top_z = tray_inside_top_z(height_units))
  // If this cell overrides the fingerslide, we must slightly correct the bounding box to account for the size difference
  let(fingerslide_wall_thickness_correction = front_wall_thickness(tray_properties, cell[PROPERTIES]) - front_wall_thickness(tray_properties))
  [
    [ grid_size_pos_x[col][0], grid_size_pos_y[row][0] + fingerslide_wall_thickness_correction, cell_bottom_z ],
    [ cell_size_x, cell_size_y - fingerslide_wall_thickness_correction, cell_top_z - cell_bottom_z ]
  ];

/*
  Calculate some metadata of a cell
*/
function cell_metadata(row, col, gridded_layout) =
  let(cell = gridded_layout[row][col])
  [
    col == 0,
    col + cell[COLSPAN] == len(gridded_layout[row]),
    row + cell[ROWSPAN] == len(gridded_layout)
  ];

function num_cols(layout) =
  max([for (grid_row = layout) len(grid_row)]);
  
function num_rows(layout) =
  max([for (row = [0:len(layout) - 1]) for (col = [0:len(layout[row]) - 1]) row + get_rowspan(layout[row], col) ]);

/*
  Get the rowspan of a cell, default to 1 if not specified.
*/  
function get_rowspan(row, col) =
  let (cell = row[col])
  cell != undef 
    ? cell[1]
    : 1;
  
function _find_cells(ref, gridded_layout, row, col) =
  let (cell = gridded_layout[row][col])
  join(
    cell[REF] == ref ? [ cell ] : [],
    col < len(gridded_layout[row]) - 1 ? _find_cells(ref, gridded_layout, row, col + 1) :
    row < len(gridded_layout) - 1      ? _find_cells(ref, gridded_layout, row + 1, 0)
                                       : []
  );
    
/* 
  Calculate the absolute z coordinate of the top of the tray.
*/
function tray_top_z(height) =
  height * GF_PITCH_V + GF_BOTTOM_INTERFACE_HEIGHT - GF_TOP_CHAMFER;

/* 
  Calculate the absolute z coordinate of the available inner space
  of the tray.
*/
function tray_inside_top_z(height) = 
  tray_top_z(height) - GF_LIP_TOP_DIST;

/*
  Calculate the absolute z coordinate of the floor of a cell.
*/
function floor_height(screw_depth, floor_thickness) =  
  max(screw_depth, GF_BOTTOM_INTERFACE_HEIGHT) + floor_thickness;
 
function lip_radius(lip_size, wall_thickness) =
  lip_size == "reduced" ? GF_TOP_INTERFACE_RIM_RADIUS :
  lip_size == "none"    ? GF_EFFECTIVE_OUTER_RADIUS - wall_thickness
                         : GF_STANDARD_LIP_RADIUS;
 
/*
  Used in rendering the label shape to determine if this side needs filleted edges. If the 
  edge will touch a wall, it must be sharp. If the edges ends in air, it must be rounded.
*/
function needs_rounded_label_edge(x, align) =
  (x == 0 && align[0] == "r") || (x == 1 && align[0] == "l" ) || align[0] == "c";

/*
  Calculate the x position for a label. 
*/
function label_pos_x(cell, tray_properties) =
  let(label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties))
  let(cell_size_x = cell[BOUNDING_BOX][SIZE][X])
  (label_align == "center") ? cell_size_x / 2 :
  (label_align == "right")  ? cell_size_x 
                            : 0;  
/*
  Calculate the x size for a label.
*/  
function label_size_x(cell, tray_properties) = 
  let(label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties))
  let(label_width = get_property(LABEL_WIDTH, cell[PROPERTIES], tray_properties))
  let(cell_size_x = cell[BOUNDING_BOX][SIZE][X])
  (label_width > cell_size_x || label_align == "full" 
    ? cell_size_x 
    : label_width)
  + label_size_x_correction(cell, tray_properties);

function label_size_x_correction(cell, tray_properties) =
  let(label_align = get_property(LABEL_ALIGN, cell[PROPERTIES], tray_properties))
  let(is_applicable = 
    label_align == "left" || label_align == "full"  ? cell[METADATA][IS_FIRST_COLUMN]:
    label_align == "right"                          ? cell[METADATA][IS_LAST_COLUMN]
                                                    : false
  )
  label_size_correction(is_applicable, tray_properties);

/* If label is on the left column (or right column when right-aligned labels are 
   specified) or the last row, we must make it a bit wider or deeper to account for 
   the lip and the usable label size is the same as the others.
*/
function label_size_correction(is_applicable, tray_properties) =
  let(lip_size = tray_properties[LIP_SIZE])
  let(wall_thickness = tray_properties[WALL_THICKNESS])
  !is_applicable      ? 0 :
  GF_EFFECTIVE_OUTER_RADIUS - wall_thickness - lip_radius(lip_size, wall_thickness);
    
/*
  If fingerslide is enabled, front wall of first row must move sligthly inward so it
  is flush with the lip. This function will determine the thickness of the front 
  wall based on lip style and fingerslide settings.
*/
function front_wall_thickness(
  tray_properties,
  cell_properties = []
) =   
  let(lip_size = get_property(LIP_SIZE, tray_properties))
  let(fingerslide = get_property(FINGERSLIDE_RADIUS, cell_properties, tray_properties) > get_property(FILLET_RADIUS, cell_properties, tray_properties))
  fingerslide && lip_size == "standard" ? GF_EFFECTIVE_OUTER_RADIUS - GF_STANDARD_LIP_RADIUS :
  fingerslide && lip_size == "reduced"  ? GF_EFFECTIVE_OUTER_RADIUS - GF_TOP_INTERFACE_RIM_RADIUS
                                         : get_property(WALL_THICKNESS, tray_properties);
    
/* 
  Calculate the size of a cell in a single direction. This function is used for 
  both x and y direction.
*/
function get_cell_size(
  grid_cell_no,
  relative_dimensions,
  span
) =
  let(end_cell_no = grid_cell_no + span - 1)
  span > 0
    ? relative_dimensions[end_cell_no][0]  + relative_dimensions[end_cell_no][1] - relative_dimensions[grid_cell_no][0]
    : relative_dimensions[grid_cell_no][1];
            
/* 
  Since OpenSCAD does not support objects, I used arrays to store properties. This 
  function will look in the primary array (usually containing the cell properties) 
  and if a value is not present, take the value from the fallback_properties.
  If that one isn't present either, return the specified default value.
  
  The indices for all properties are defined in trayfinity-constants.scad.
*/
function get_property(
  property_index, 
  primary_properties, 
  fallback_properties,
  default_if_absent
) =
  let(property_value = primary_properties[property_index])
  property_value != undef
    ? property_value
    : fallback_properties[property_index] != undef
        ? fallback_properties[property_index]
        : default_if_absent;  

/*
  Calculate the total for all numbers in an array.
*/
function sum(numbers, start = 0) =
  numbers == undef || len(numbers) == 0  ? 0 :
  start == len(numbers) - 1              ? numbers[start]
                                         : numbers[start] + sum(numbers, start + 1);  

/*
  Join two arrays
*/
function join(array1, array2) =
  [
    if (array1 != undef) for (element = array1) element, 
    if (array2 != undef) for (element = array2) element
  ];
 
// Utility function to fill an array to a certain size using the given element
function complete(array, size, element) =
  size > 0 
    ? [ for (i = [0 : size - 1])
          i < len(array) ? array[i] : element
      ]
    : array; 