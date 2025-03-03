/*
  Trayfinity Workbench: infinite possibilities in generating gridfinity assortment trays.
  
  This file contains constant definitions used throughout the code. The end user 
  can use these for convenience if so desired. 
  
  Constant names with 'GF_' prefix follow from Zack's gridfinity standard, the 
  others are for the Trayfinity Workbench code.
*/

// Horizontal pitch of a gridfinity unit
GF_PITCH_H = 42;
// Vertical pitch of a gridfinity unit
GF_PITCH_V = 7;
// Nominal radius of the outer corner of a gridfinity object.
GF_OUTER_RADIUS = 4;
// Undersizing of outer dimensions to not make stacking of gridfinity objects too tight
GF_CLEARANCE = 0.25;
// The true real-world outer radius of a gridfinity object.
GF_EFFECTIVE_OUTER_RADIUS = GF_OUTER_RADIUS - GF_CLEARANCE;
/* If you would consequently create the top interface, using the 7 mm vertical 
   grid units, it would have a sharp edge on top. Like this:
    /|  \ 
   / |   } Top chamfer 
  /  |  /

   However, the specs specify a flat top rim. In essence this is a chamfer. 
    /|  \ 
   / |   } Top chamfer 
  /__|  /
 /   |
*/
GF_TOP_CHAMFER = 1;

// Nominal height of the interface for vertical stacking gridfinity objects on
// top of each other or on top of a base
GF_INTERFACE_HEIGHT = 5;
// Chamfer at the bottom of the interface. Is the same for top and bottom
// (= outer resp. inner) interface
GF_INTERFACE_CHAMFER = 0.8;
// Height of the rim (= vertical section) of the interface. Is the same for
// top and bottom.
GF_INTERFACE_RIM_HEIGHT = 2.6;

// The corner radius of the rim (vertical section) of the interface
GF_BOTTOM_INTERFACE_RIM_RADIUS = 1.6;
// Slightly larger inner interface for ease of stacking
GF_TOP_INTERFACE_RIM_RADIUS = GF_BOTTOM_INTERFACE_RIM_RADIUS + GF_CLEARANCE;
// Distance from the top of the tray (after subtraction of GF_TOP_CHAMFER) to
// the top of the interface rim.  
GF_TOP_INTERFACE_RIM_FROM_TOP = 1.2;

// Chamfer between interface rim and lip, supposed to fit the bottom interface
// chamfer.
GF_TOP_INTERFACE_CHAMFER = GF_INTERFACE_CHAMFER - 0.1;
// The bottom interface is lower than the nominal interface height by the 
// standard gridfinity clearance. This works out to 4.75 mm.
GF_BOTTOM_INTERFACE_HEIGHT = GF_INTERFACE_HEIGHT - GF_CLEARANCE;

// The inner corner radius of the lip.
GF_STANDARD_LIP_RADIUS = GF_TOP_INTERFACE_RIM_RADIUS - GF_TOP_INTERFACE_CHAMFER;
// Height of the lip
GF_LIP_HEIGHT = 1.3;
// Height of the top of the lip from the top of the tray,
GF_LIP_TOP_DIST = GF_INTERFACE_HEIGHT - GF_LIP_HEIGHT;
// Height of the 45 degree chamfer on the underside of the lip.
GF_LIP_BOTTOM_CHAMFER_HEIGHT = 1.6;

// Standard magnet height as specified by Zack.
GF_MAGNET_HEIGHT = 2.4;
// Standard screw hole diameter as specified by Zack.
GF_SCREW_DIAMETER = 3;
// Distance from the center of the magnet/screw holes to the center of the
// rounded corners. 
GF_ATTACHMENT_INSET = 4; 

// Angle of the slanted underside of the label, lower values are more horizontal
LABEL_UNDERSIDE_ANGLE = 30;
// Radius of the rounded edges of the label
LABEL_FILLET_RADIUS = 0.6;
// For 3d printing fiendly tweak to the attachment hole in case both screws and 
// magnets are specified. The depth of this tweak should be roughly the same as
// the layer height.
OVERHANG_REMEDY_DEPTH = 0.3;

DUMMY_CELL = [ 0, 1 ];

// Indices for tray_definition
WIDTH_UNITS = 0;
DEPTH_UNITS = 1;
HEIGHT_UNITS = 2;
GRIDDED_LAYOUT = 3;
TRAY_PROPERTIES = 4;

// Indices for cell definition
COLSPAN = 0;
ROWSPAN = 1;
PROPERTIES = 2;
GENERATE = 3;
REF = 4;
USER_DEFINED = 5;
BOUNDING_BOX = 6;
METADATA = 7;

// Indices for bounding box definition
POSITION = 0;
SIZE = 1;
X = 0;
Y = 1;
Z = 2;

// Indices for metadata
IS_FIRST_COLUMN = 0;
IS_LAST_COLUMN = 1;
IS_LAST_ROW = 2;

// Indices for cell + tray properties
FINGERSLIDE_RADIUS = 0;
FLOOR_THICKNESS = 1;
FILLET_RADIUS = 2;
LABEL_PLACEMENT = 3;
LABEL_ALIGN = 4;
LABEL_WIDTH = 5;
LABEL_DEPTH = 6;
LABEL_TEXT = 7;
FONT = 8;
FONT_SIZE = 9;
TEXT_COLOR = 10;
TEXT_HEIGHT = 11;
TEXT_DEPTH = 12;
TEXT_MARGIN_H = 13;
TEXT_MARGIN_V = 14;

// Indices for extra tray properties
WALL_THICKNESS = 15;
DIVIDER_THICKNESS = 16;
LIP_SIZE = 17;
MAGNET_DIAMETER = 18;
SCREW_DEPTH = 19;
CORNER_ATTACHMENTS_ONLY = 20;
ATTACHMENT_OVERHANG_REMEDY = 21;
BOTTOM_INTERFACE_DIVIDE = 22;
BRIM_WIDTH = 23;
BRIM_HEIGHT = 24;
BRIM_SEPARATION_GAP = 25;

