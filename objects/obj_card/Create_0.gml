/// a 2.5D card. draw anything you want on either face.
/// rotate it with rot_x / rot_y / rot_z, it handles the rest.

// card dimensions. this is both the surface resolution
// and the on-screen base size
card_w = 168/2;
card_h = 240/2;

// rotation in degrees
rot_x = 0;   // pitch. tips the top edge toward or away from you
rot_y = 0;   // yaw. the classic flip
rot_z = 0;   // roll. the twist

// perspective strength. lower = more dramatic foreshortening.
// 600 feels like a card held at arm's length
focal = 600;

// mesh subdivision. the card is drawn as a grid of quads
// because a single textured quad warps badly under perspective.
// 8 is invisible-seams territory. raise it if you push focal low
grid = 8;

// content surfaces, one per face, rendered at card size x ss.
// ss = 1 (2026-07-12, his call): HARD PIXELS - faces render at native
// card resolution and the mesh samples NEAREST (the draw's filter
// state follows ss > 1 automatically), matching the house crisp-pixel
// look. tilting makes pixels crawl like classic rotated pixel art -
// that's the intended read. if a consumer ever needs small text to
// survive STEEP perspective, ss = 2 restores the old supersampled +
// filtered (soft) mode per-instance; invalidate faces after changing.
ss = 1;
surf_front  = -1;
surf_back   = -1;
front_dirty = true;
back_dirty  = true;

// premium FINISH, tcg style. fx is a BITMASK - finishes combine:
//   1  foil         a sheen band swept by the card's tilt
//   2  rainbow      a hue wash sliding with tilt and time
//   4  glitter      SPECULAR pixel sparks - tiny projected glints
//                   that catch and release as the card tilts
//   8  pearlescent  soft pastel mother-of-pearl shift, tilt-driven
//  16  chromatic    a sheen that splits into r/g/b prismatic streaks
//  32  void         swallows light: a slow dark wash breathing
//                   across the face (subtractive)
// glitter BINDS to a co-present finish: rainbow-glitter sparkles in
// the wash's hue, chromatic splits sparks into r/g/b, pearl goes
// pastel, void goes violet. e.g. fx = 2 | 4. fx_alpha scales the lot
fx = 0;
fx_alpha = .55;

// darkens the card slightly as it turns edge-on. cheap depth cue
use_shading = true;

// ---------------------------------------------------------
// your art goes here. draw in local card space, (0,0) is
// the top left of the card, card_w x card_h is the canvas
// ---------------------------------------------------------
draw_front_content = function() {
    draw_clear(#F0EBDC);
    draw_set_color(#222222);
    draw_rectangle(6, 6, card_w - 7, card_h - 7, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(card_w * 0.5, card_h * 0.5, "FRONT");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
};

draw_back_content = function() {
    draw_clear(#3A2E52);
    draw_set_color(#C9B8E8);
    draw_rectangle(6, 6, card_w - 7, card_h - 7, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(card_w * 0.5, card_h * 0.5, "BACK");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
};

// call these whenever your card art changes.
// content is cached on surfaces, so it only redraws when told to
invalidate_front = function() { front_dirty = true; };
invalidate_back  = function() { back_dirty  = true; };

// rotates a local point: yaw (Y) first, then pitch (X), then roll (Z).
// returns [x, y, z] with z positive = away from the camera
rotate_point = function(px, py, pz, _cx, _sx, _cy, _sy, _cz, _sz) {
    // yaw
    var x1 =  px * _cy + pz * _sy;
    var z1 = -px * _sy + pz * _cy;
    // pitch
    var y2 =  py * _cx - z1 * _sx;
    var z2 =  py * _sx + z1 * _cx;
    // roll
    var x3 =  x1 * _cz - y2 * _sz;
    var y3 =  x1 * _sz + y2 * _cz;
    return [x3, y3, z2];
};

// demo flip control, replace with whatever drives your game
flip_target = 0;

// autopilot: true = the demo Step drives the card (click to flip,
// idle drift). an OWNER that wants to drive rot_x/y/z itself sets
// this false and the card becomes a pure display
auto = true;

