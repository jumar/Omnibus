// -*- mode: c -*-
/* All distances are in mm. */

/* set output quality */
$fn = 10;

/* Distance between key centers. */
IN_COLUMN_SPACING   = 19;
IN_ROW_SPACING      = IN_COLUMN_SPACING;

/* This number should exceed ROW_SPACING and COLUMN_SPACING. The
    default gives a 1mm = (20mm - 19mm) gap between keycaps and cuts in
    the top plate.*/
KEY_HOLE_SIZE = 20;

/* Rotation ange; the angle between the halves is twice this
   number */
ANGLE = 20;

/* The radius of screw holes. Holes will be slightly bigger due
   to the cut width. */
SCREW_HOLE_RADIUS = 1.5;

/* Each screw hole is a hole in a "washer". How big these "washers"
   should be depends on the material used: this parameter and the
   `SWITCH_HOLE_SIZE` determine the spacer wall thickness. */
WASHER_HOLE_RADIUS     = 4 * SCREW_HOLE_RADIUS;

/* This constant allows tweaking the location of the screw holes near
   the USB cable. Only useful with small `angle` values. Try the value
   of 10 with angle=0. */
BACK_SCREW_HOLE_OFFSET = 0;

/* Distance between halves. */
HAND_SEPARATION        = 5;

/* The approximate size of switch holes. Used to determine how
   thick walls can be, i.e. how much room around each switch hole to
   leave. See spacer(). */
SWITCH_HOLE_SIZE = 14;

/* Sets whether the case should use notched switch holes. As far as I can
   tell these notches are not all that useful... */
USE_NOTCHED_HOLES = false;

/* Number of rows and columns in the matrix. You need to update
   STAGGERING_OFFSETS and COL_KEY_COUNTS if you change NB_COLS. */
NB_COLS = 7;
COL_KEY_COUNTS = [3, 5, 4, 4, 4, 4, 4]; // Number of keys per columns
MAX_NB_ROWS = 5; // Highest value in COL_KEY_COUNTS

/* Vertical column staggering offsets. The 1st element should
   be zero (innermost column) */
STAGGERING_OFFSETS = [0, 5, 10, 16, 13, 6, 5];

/* The width of the USB cable hole in the spacer. */
CABLE_HOLE_WIDTH = 12;

/* Default z height value for various holes */
HOLE_HEIGHT = 50;

/***************************************************/
/* Rotate children of `angle` degrees around `center`. */
module rotate_children(angle, center=undef) {
    translate(center) {
    rotate(angle) {
        translate(-center) {
            for (i=[0:$children-1])
            children(i);
      }
    }
  }
}

/* Compute coordinates of a point obtained by rotating the point p of angle
   degrees around center. Used to compute locations of screw holes near the
   USB cable hole. */
function rotate_func(p, angle, center) = [cos(angle) * (p[0] - center[0]) - sin(angle) * (p[1] - center[1]) + center[0],
                                        sin(angle) * (p[0] - center[0]) + cos(angle) * (p[1] - center[1]) + center[1]];

/* Cherry MX switch hole centered at `position`. Sizes come
   from the ErgoDox design. */
module create_switch_hole(position, notches=USE_NOTCHED_HOLES) {
    hole_size    = 13.97;
    notch_width  = 3.5001;
    notch_offset = 4.2545;
    notch_depth  = 0.8128;
    translate(position) {
        union() {
            translate([0,0,-1])
            cube([hole_size, hole_size, HOLE_HEIGHT], center=true);
            if (notches == true) {
                translate([0, notch_offset,-1]) {
                    cube([hole_size+2*notch_depth, notch_width, HOLE_HEIGHT], center=true);
                }
                translate([0, -notch_offset,-1]) {
                    cube([hole_size+2*notch_depth, notch_width, HOLE_HEIGHT], center=true);
                }
            }
        }
    }
};

/* Create a hole for a key. */
module create_key_hole(position, size) {
    translate(position) {
        cube([size, size, HOLE_HEIGHT], center=true);
    }
}
TYPE_SWITCH_HOLES   = "switch_holes";
TYPE_KEY_HOLES      = "key_holes";
TYPE_TEXTURE        = "texture";
NONE                = "none";
TOP                 = "top";
BOTTOM              = "bottom";
TOP_BOTTOM          = "top_bottom";
TOP_HALF            = "top_half";
TOP_DOUBLE          = "top_double";
BOTTOM_HALF         = "bottom_half";
TEXTURE_TYPE        = [TOP_HALF, TOP, TOP_DOUBLE, TOP_BOTTOM, NONE, NONE, NONE];

module create_spike(texture_type=NONE, row_count) {
    echo(texture_type);
    if (texture_type == TOP || texture_type == TOP_BOTTOM) {
        for(i = [0:4]) {
            for(j = [0:5]) {  
                translate([-6+3*i, -10+row_count*KEY_HOLE_SIZE+3*j, 1]) cylinder(h=2, r1=0.1, r2=1, center=false);
            }
        }
    }
    if (texture_type == TOP_DOUBLE) {
        for(i = [0:4]) {
            for(j = [0:9]) {  
                translate([-6+3*i, -10+row_count*KEY_HOLE_SIZE+3*j, 1]) cylinder(h=2, r1=0.1, r2=1, center=false);
            }
        }
    }
    if (texture_type == TOP_HALF) {
        for(i = [0:4]) {
            for(j = [-i:0]) {  
                translate([-6+3*i, -9+row_count*KEY_HOLE_SIZE-3*j, 1]) cylinder(h=2, r1=0.1, r2=1, center=false);
            }
        }
    }
    if(texture_type == BOTTOM || texture_type == TOP_BOTTOM) {
        for(i = [0:4]) {
            for(j = [0:5]) {
                translate([-6+3*i, -13-3*j, 1]) cylinder(h=2, r1=0.1, r2=1, center=false);
            }
        }
    }
    if(texture_type == BOTTOM_HALF) {
        for(i = [0:4]) {
            for(j = [0:i]) {
                translate([-6+3*i, -13-3*j, 1]) cylinder(h=2, r1=0.1, r2=1, center=false);
            }
        }
    }
}

/* Create a column of keys. if create_switch_holes is true, creates switch holes
   otherwise creates key holes. */
module create_column(bottom_position, type, key_size=KEY_HOLE_SIZE, row_count, texture_type=NONE) {
    translate(bottom_position) {
        for (row = [0:(row_count-1)]) {
            if (type == TYPE_SWITCH_HOLES) {
                create_switch_hole([0, row*IN_COLUMN_SPACING, -1]);
            } else if (type == TYPE_KEY_HOLES) {
                create_key_hole([0, row*IN_COLUMN_SPACING, -1], key_size);
            }  
        }
        if (type == TYPE_TEXTURE) {
            create_spike(texture_type, row_count);
        }
    }
}

/* Rotate the right half of the keys around the top left corner of
   the innermost column. */
module rotate_half() {
    rotation_center_x = HAND_SEPARATION;
    rotation_center_y = COL_KEY_COUNTS[0] * IN_COLUMN_SPACING;
    for (i=[0:$children-1]) {
        rotate_children(ANGLE, [rotation_center_x, rotation_center_y]) {
        children(i);
    }
  }
}

/* Shift everything right to get desired hand separation. */
module add_hand_separation() {
    for (i=[0:$children-1]) {
        // We use half of the hand separation value to reach desired separation because of mirroring
        translate([0.5*HAND_SEPARATION, 0]) {
            children(i);
        }
    }
}

/* Create switch holes (create_switch_holes=true) or key holes (create_switch_holes=false)
   for the right half of the keyboard. Different key_sizes are used in top_plate() and
   spacer(). */
module create_right_half_features(type, key_size=KEY_HOLE_SIZE) {
    x_offset = 0.5 * IN_ROW_SPACING;
    y_offset = 0.5 * IN_COLUMN_SPACING;
    thumb_key_offset = y_offset + 0.5 * IN_COLUMN_SPACING;
    rotate_half() {
        add_hand_separation() {
            for (col=[0:(NB_COLS-1)]) {
                pos = [x_offset + col*IN_ROW_SPACING, y_offset + STAGGERING_OFFSETS[col]];
                create_column(pos, type, key_size, COL_KEY_COUNTS[col],TEXTURE_TYPE[col]);
            }
        }
    }
}

module create_left_half_features(type, key_size=KEY_HOLE_SIZE) {
  mirror ([1,0,0]) { create_right_half_features(type, key_size); }
}

 /* Create a screw hole of radius `radius` at a location
    `offset_radius` from `position`, (diagonally), in the direction
    `direction`. Oh, what a mess this is.
    `direction` is the 2-element vector specifying to which side of
     position to move to, [-1, -1] for bottom left, etc. */
module create_screw_hole(radius, offset_radius, position, direction) {
    /* radius_offset is the offset in the x (or y) direction so that
        we're offset from position */
    radius_offset = offset_radius / sqrt(2);
    /* key_hole_offset if the difference between key spacing and key
        hole edge */
    key_hole_offset = 0.5*(IN_ROW_SPACING - KEY_HOLE_SIZE);
    x = position[0] + (radius_offset - key_hole_offset) * direction[0];
    y = position[1] + (radius_offset - key_hole_offset) * direction[1];
    translate([x,y,0]) {
        cylinder(r1=radius,r2=radius,h=3);
    }
}

module create_right_screw_holes(hole_radius) {
    /* coordinates of the back right screw hole before rotation... */
    back_right = [(NB_COLS)*IN_ROW_SPACING, STAGGERING_OFFSETS[NB_COLS-1] + COL_KEY_COUNTS[NB_COLS-1] * IN_COLUMN_SPACING];
    /* and after */
    tmp = rotate_func(back_right, ANGLE, [0, 2.25*IN_COLUMN_SPACING]);

    nudge = 0.75;

    rotate_half() {
        add_hand_separation() {
        // bottom center 
        create_screw_hole(hole_radius, WASHER_HOLE_RADIUS, [0, 0], [-nudge, -nudge]);
        // bottom right
        create_screw_hole(hole_radius, WASHER_HOLE_RADIUS, [(NB_COLS)*IN_ROW_SPACING, STAGGERING_OFFSETS[NB_COLS-1]], [nudge, -nudge]);
        // top right
        create_screw_hole(hole_radius, WASHER_HOLE_RADIUS, back_right, [nudge, nudge]);
        }
    }
    /* add the screw hole near the cable hole */
    translate([WASHER_HOLE_RADIUS - tmp[0], BACK_SCREW_HOLE_OFFSET]) {
        rotate_half() {
            add_hand_separation() {
                create_screw_hole(hole_radius, WASHER_HOLE_RADIUS, back_right, [nudge, nudge]);
            }
        }
    }
}

/* Create all the screw holes. */
module create_screw_holes(hole_radius) {
    create_right_screw_holes(hole_radius);
    mirror ([1,0,0]) { 
        create_right_screw_holes(hole_radius);
    }
}

/* bottom layer of the case */
module create_bottom_plate() {
    difference() {
        hull() { color("pink") create_screw_holes(WASHER_HOLE_RADIUS); }
        color("red") create_screw_holes(SCREW_HOLE_RADIUS);
    }
}

/* top layer of the case */
module create_top_plate() {
    difference() {
        create_bottom_plate();
        create_right_half_features(TYPE_KEY_HOLES);
        create_left_half_features(TYPE_KEY_HOLES);
        //create_right_half_features(TYPE_TEXTURE);
        //create_left_half_features(TYPE_TEXTURE);
    }
}

/* the switch plate */
module create_switch_plate() {
    difference() {
        create_bottom_plate();
        create_right_half_features(TYPE_SWITCH_HOLES);
        create_left_half_features(TYPE_SWITCH_HOLES);
    }
}

/* Create a spacer. */
module create_spacer() {
    difference() {
        union() {
            difference() {
                create_bottom_plate();
                hull() {
                    create_right_half_features(TYPE_KEY_HOLES, SWITCH_HOLE_SIZE + 3);
                    create_left_half_features(TYPE_KEY_HOLES, SWITCH_HOLE_SIZE + 3);
                }
                /* add the USB cable hole: */
                translate([-0.5*CABLE_HOLE_WIDTH, 2*IN_COLUMN_SPACING,0]) {
                    cube([CABLE_HOLE_WIDTH, (2*MAX_NB_ROWS) * IN_COLUMN_SPACING,HOLE_HEIGHT]);
                }
            }
            create_screw_holes(WASHER_HOLE_RADIUS);
        }
        create_screw_holes(SCREW_HOLE_RADIUS);
    }
}

/* Now create all four layers. */

translate([0, 0, 9]) {
    //create_top_plate();
    //create_right_half_features(TYPE_TEXTURE);
    //create_left_half_features(TYPE_TEXTURE);
}

color("black") translate([0, 0, 6]) create_switch_plate(); 
//translate([0, 0, -3]) create_bottom_plate();
translate([0, 0, 3]) create_spacer();
translate([0, 0, 0]) create_spacer();
translate([0, 0, -3]) create_spacer();

