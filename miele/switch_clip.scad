/*
Control panel bracket for Miele PUR 88 W range hood
https://www.mieleusa.com/e/30-inch-wall-mounted-ventilation-hood-pur-88-w-stainless-steel-10743170-p

May work with other models, but I haven't tested them.

These clips go at either end of the buttons to hold them in the panel.
They have broken repeatedly, so I put this together so I can replace
them as needed rather than trying to get spares from Miele.

All units in mm.

Jeremy Fitzhardinge <jeremy@goop.org> 2022
*/

// Version id imprinted in output - 1 char
version = "a";

cap_len = 25.79;
cap_width = 7.73;
cap_face_middle = 1.93;
cap_face_edge = 1.5;

base_plinth_len = 7.48;
base_plinth_thick = 5.04;

wing_len = 20.92;
wing_extend = 9.48;
wing_below = 1.36+base_plinth_thick;

$fn = 50;

function circle_by_three_points(A, B, C) =
let (
  yD_b = C.y - B.y,  xD_b = C.x - B.x,  yD_a = B.y - A.y,
  xD_a = B.x - A.x,  aS = yD_a / xD_a,  bS = yD_b / xD_b,
  cex = (aS * bS * (A.y - C.y) + 
  bS * (A.x + B.x) -    aS * (B.x + C.x)) / (2 * (bS - aS)),
  cey = -1 * (cex - (A.x + B.x) / 2) / aS + (A.y + B.y) / 2
)
[cex, cey];

function len3(v) = sqrt(pow(v.x, 2) + pow(v.y, 2));

module chord(width, height) {
a = [0,0];
    b = [width/2,height];
    c = [width,height];
    
    center = circle_by_three_points([0,0],[width/2, height], [width,0]);
    radius = len3([width,0] - center);
    
    intersection() {
        square([width,height]);
        translate(center) circle(radius, $fn=100);
    }
}

// Front-facing outer body
module cap() {
    /*
    
        cap_len
     +---------------+
     |               | cap_width
     +---------------+
    
    cap_face_middle
     /-\ (curve)
    |   | cap_face_edge
    */
    
    center = circle_by_three_points(
        [0, cap_face_edge],
        [cap_width/2, cap_face_middle],
        [cap_width, cap_face_edge]
    );
    radius = len3([cap_width,cap_face_edge]-center);
    
    rotate([90,0,90])
    linear_extrude(height = cap_len)
        union () {
            translate([0,cap_face_edge])
                chord(cap_width, cap_face_middle - cap_face_edge);
            square([cap_width,cap_face_edge]);
        }
}

module tongue(width, length) {
    union() {
        translate([0, -width/2])
            square([length - width/2, width]);
        translate([length - width/2, 0])
            circle(d = width);
    }
}

module cap_flange() {
    /*
    flange_len
    ---------\
             |
    ---------/
    
    ---------.  | flange_lip
           |    | flange_thick
    -------------. cap
                 |
    
    */
    flange_len = cap_len - 2.26 - base_plinth_len;
    flange_thick = 1.25;
    flange_lip = 2.35 - flange_thick;
    flange_under = 4.02; // width of narrow under

    translate([0,cap_width/2])
    scale([1,1,-1]) // look from below
    translate([base_plinth_len, 0, 0])
    union () {
        translate([0,0,flange_thick])
            linear_extrude(height = flange_lip)
                tongue(cap_width, flange_len);
        linear_extrude(height = flange_thick)
            tongue(flange_under, flange_len - (cap_width - flange_under));
    } 
}

module version () {
    ver_depth = .3;

    scale([-1,1,1])
    translate([0,0,-ver_depth])
    linear_extrude(height = ver_depth*2)
    rotate([0,0,90])
    text(text = version, size = 6, halign = "center", valign = "center");
}

module base_plinth() {
    
    scale([1,1,-1])
    difference () {
        cube([base_plinth_len, cap_width, base_plinth_thick]);
        translate([base_plinth_len / 2, cap_width / 2, base_plinth_thick])
            version();
    }
}

/*    
    End profile:
         x1          x2  
  y2     +-----------+
         |  +--w--+  |  y4
         |  | chan|  |    x3
  y1+----+  h nel |  +----+
    |       |     |       |
    |     +-+     +-------+y3
    |     | x5    x4
  y0+-----+
    x0    x6
*/
channelw = 1.6;
channelh = 1.50;

wx0 = 0;
wx1 = wx0 + 2.74;
wx2 = wx1 + 3.53;
wx3 = wx2 + 1.25;


ch_wall = ((wx2 - wx1) - channelw) / 2;

wx4 = wx2 - ch_wall;
wx5 = wx1 + ch_wall;

wx6 = wx0 + 1.40;

wy0 = 0 ;
wy1 = wy0 + 3.53;
wy2 = wy1 + 1.50;
wy3 = wy1 - 2.09;
wy4 = wy3 + channelh;

module wing_body() {

    difference() {
        rotate([90,0,90])
            linear_extrude(height = wing_len)
                polygon([
                    [wx0, wy0], [wx0, wy1], [wx1, wy1], [wx1, wy2], [wx2, wy2], [wx2, wy1], [wx3, wy1],
                    [wx3, wy3], [wx4, wy3], [wx4, wy4], [wx5, wy4], [wx5, wy3], [wx6, wy3], [wx6, wy0]
                ]);
        translate([(6.8+4)/2,wx1-.8,wy1])
            cylinder(d = 3, h = 5);
    }
}

lump_len = 8.75;

module wing_lump() {
    lump_len = 8.75;
    lump_height = 5.55;
    lump_width = 3.9;
    lump_out = 1.15;
    
    translate([wing_len - lump_len, -lump_out, 0])
    cube([lump_len, lump_width, lump_height]);
}

module wing_bridge() {
    translate([wing_extend, wx3, wy3])
        cube([lump_len, .5, abs(wy1-wy3)]);
}

module wing() {
    difference () {
        union () {
            wing_body();
            wing_lump();
            wing_bridge();
        }
        translate([wing_len-4.25, 5.15, 0])
        cube([5, 4.23, 10]);
    }    
}

module middle() {
    union () {
        cap();
        cap_flange();
        base_plinth();
    }
}


union() {
    middle();
    translate([-wing_extend,-cap_width,-wing_below])
        wing();
    translate([-wing_extend, cap_width*2, -wing_below])
        scale([1,-1,1])
            wing();
}