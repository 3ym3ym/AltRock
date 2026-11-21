// =====================================================================
//  Altoids-tin insert / PCB holder for the AF7KR DCRX v26.10 board
// =====================================================================
//  Tin inner cavity : 92 x 58 mm, corner radius 14 mm
//  PCB              : 85 x 55 mm, rounded R10, four 2.7 mm (M2.5)
//                     mounting holes. Hole positions taken from
//                     DCRX_v_26_10.kicad_pcb, relative to the board's
//                     min corner (KiCad 38.1, 38.1).
//
//  Shape: a 1.5 mm thick X-shaped base plate. Two wide diagonal arms
//  join four full-circle corner pads. Each pad is concentric with one
//  rounded corner of the tin (radius tin_r - fit), so its arc nests
//  into that corner with uniform clearance and the insert is located
//  by all four corners and cannot slide. A pin for each PCB hole
//  stands on every corner pad.
//
//  Print flat, pins up, no supports.
//  NOTE: the base is only 1.5 mm tall - check that nothing tall on the
//  PCB's underside crosses the arms / corner pads.
//
//  Orientation: the pin pattern matches the PCB as drawn in KiCad
//  (component side up, board's KiCad-origin corner at the insert's
//  front-left), offset pin_dx = 1.5 mm to the right, i.e. the seated
//  board sits 1.5 mm right of insert centre. The hole pattern is
//  0.13 mm asymmetric, so rotating the board 180 deg still fits, but
//  it is a noticeably tighter push.
// =====================================================================

/* [Tin cavity (inner)] */
// inner width (X)
tin_w = 92;
// inner depth (Y)
tin_d = 58;
// inner corner radius
tin_r = 14;
// clearance per side (0.3 mm total)
fit = 0.15;

/* [Insert base] */
// plate thickness
base_t = 1.5;
// width of the X arms
arm_w = 14;
// lead-in chamfer around the bottom edge (hides first-layer squish)
bottom_ch = 0.5;

/* [Board pins] */
// pin diameter - PCB holes are 2.7; raise this if the fit is too loose
pin_d = 2.5;
// pin height above the base top (PCB + thin M2.5 nut need ~3 mm)
pin_h = 4.0;
// lead-in chamfer on the pin tip
pin_ch = 0.6;
// X offset of the whole pin pattern (shifts the seated PCB to the right)
pin_dx = 1.5;

/* [PCB] */
pcb_w = 85;
pcb_d = 55;
// hole positions relative to the PCB's min corner (KiCad coords in brackets)
holes = [
    [ 9.779,  3.048],  // front-left  (47.879, 41.148)
    [75.057,  3.048],  // front-right (113.157, 41.148)
    [ 9.779, 51.943],  // back-left   (47.879, 90.043)
    [74.930, 51.943],  // back-right  (113.030, 90.043)
];

/* [Hidden] */
$fn = 96;

// ---------------------------------------------------------------------
// Derived values
// ---------------------------------------------------------------------
W = tin_w - 2 * fit;                        // insert width
D = tin_d - 2 * fit;                        // insert depth
R = tin_r - fit;                            // insert corner radius
                                            // (concentric with the tin's)
pcb_off = [(W - pcb_w) / 2, (D - pcb_d) / 2];   // PCB centred on insert
cc = [[R, R], [W - R, R], [R, D - R], [W - R, D - R]];  // corner arc centres
arm_ang = atan2(cc[3][1] - cc[0][1], cc[3][0] - cc[0][0]);

// ---------------------------------------------------------------------
// 2D footprint
// ---------------------------------------------------------------------
// full-circle corner pad, concentric with the tin's corner arc
// (radius tin_r - fit) so it nests into the corner with uniform
// clearance; the circle is tangent to both inner walls
module corner_pads() {
    for (c = cc)
        translate(c) circle(R);
}

module arm(p, q) {
    hull() {
        translate(p) circle(d = arm_w);
        translate(q) circle(d = arm_w);
    }
}

module insert_2d() {
    union() {
        corner_pads();
        arm(cc[0], cc[3]);   // front-left  -> back-right
        arm(cc[1], cc[2]);   // front-right -> back-left
    }
}

// ---------------------------------------------------------------------
// 3D
// ---------------------------------------------------------------------
module base() {
    // lower slab shrunk by the chamfer amount acts as an insertion
    // lead-in and hides elephant-foot from the first layers
    linear_extrude(bottom_ch) offset(delta = -bottom_ch) insert_2d();
    translate([0, 0, bottom_ch])
        linear_extrude(base_t - bottom_ch) insert_2d();
}

module pins() {
    for (h = holes) {
        p = pcb_off + h + [pin_dx, 0];
        translate([p[0], p[1], base_t]) {
            cylinder(d = pin_d, h = pin_h);
            translate([0, 0, pin_h])
                cylinder(d1 = pin_d, d2 = pin_d - 0.6, h = pin_ch);
        }
    }
}

union() {
    base();
    pins();
}

// ---------------------------------------------------------------------
// Sanity-check echoes (see console)
// ---------------------------------------------------------------------
echo("insert footprint", W, "x", D, "corner R", R);
echo("pin pitch X", holes[1][0] - holes[0][0], "Y", holes[2][1] - holes[0][1],
     "offset X", pin_dx);
echo("total height", base_t + pin_h + pin_ch);
