// -- keep surfaces alive (they can vanish on alt-tab, resize, etc.)
// faces render at card size x ss (ss 1 = native/hard pixels, the
// default; ss > 1 = the old supersampled soft mode, see Create)
if (!surface_exists(surf_front)) { surf_front = surface_create(card_w * ss, card_h * ss); front_dirty = true; }
if (!surface_exists(surf_back))  { surf_back  = surface_create(card_w * ss, card_h * ss); back_dirty  = true; }

if (front_dirty) {
    surface_set_target(surf_front);
    // painters keep working in card_w x card_h logical space - the
    // world matrix scales them onto the bigger canvas
    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, ss, ss, 1));
    draw_front_content();
    matrix_set(matrix_world, matrix_build_identity());
    surface_reset_target();
    front_dirty = false;
}
if (back_dirty) {
    surface_set_target(surf_back);
    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, ss, ss, 1));
    draw_back_content();
    matrix_set(matrix_world, matrix_build_identity());
    surface_reset_target();
    back_dirty = false;
}

// -- rotation terms, computed once
var _cx = dcos(rot_x), _sx = dsin(rot_x);
var _cy = dcos(rot_y), _sy = dsin(rot_y);
var _cz = dcos(rot_z), _sz = dsin(rot_z);

// which face is looking at the camera?
// rotate the front face's normal (0, 0, -1) and check where it points
var n = rotate_point(0, 0, -1, _cx, _sx, _cy, _sy, _cz, _sz);
var front_visible = (n[2] < 0);

var tex = surface_get_texture(front_visible ? surf_front : surf_back);

// -- rotate and project the grid
// simple perspective divide: things closer to the camera get bigger
var vcount = (grid + 1) * (grid + 1);
var vx = array_create(vcount);
var vy = array_create(vcount);

for (var j = 0; j <= grid; j++) {
    for (var i = 0; i <= grid; i++) {
        var lx = (i / grid - 0.5) * card_w;
        var ly = (j / grid - 0.5) * card_h;
        var p  = rotate_point(lx, ly, 0, _cx, _sx, _cy, _sy, _cz, _sz);
        var s  = focal / (focal + p[2]);
        var idx = j * (grid + 1) + i;
        vx[idx] = x + p[0] * s;
        vy[idx] = y + p[1] * s;
    }
}

// -- shading. |n.z| is 1 face-on, 0 edge-on
var col = c_white;
if (use_shading) {
    var lit = 0.55 + 0.45 * abs(n[2]);
    col = make_color_rgb(255 * lit, 255 * lit, 255 * lit);
}

// -- draw the card as one triangle strip per grid row.
// when the back is showing, U is mirrored so back-face art
// reads correctly instead of appearing reversed.
// sampling follows ss: native faces (ss 1) sample NEAREST - one exact
// texel per pixel, hard edges, the house rule (never averaged);
// supersampled faces (ss > 1) keep the old filtered minification
gpu_set_tex_filter(ss > 1);
for (var j = 0; j < grid; j++) {
    draw_primitive_begin_texture(pr_trianglestrip, tex);
    for (var i = 0; i <= grid; i++) {
        var u  = front_visible ? (i / grid) : (1 - i / grid);
        var i0 = j       * (grid + 1) + i;
        var i1 = (j + 1) * (grid + 1) + i;
        draw_vertex_texture_color(vx[i0], vy[i0], u, j / grid,       col, 1);
        draw_vertex_texture_color(vx[i1], vy[i1], u, (j + 1) / grid, col, 1);
    }
    draw_primitive_end();
}
gpu_set_tex_filter(false);

// -- premium FINISH pass, riding the same projected mesh. fx is a
// bitmask, so effects ACCUMULATE. what sells each one is responding
// to the card's TILT, like light playing on a real foil
if (fx > 0 && front_visible) {
    gpu_set_blendmode(bm_add);

    // vertex-blended finishes (smooth washes and sheens)
    if (fx & (1 | 2 | 8 | 16)) {
        for (var j = 0; j < grid; j++) {
            draw_primitive_begin(pr_trianglestrip);
            for (var i = 0; i <= grid; i++) {
                for (var k = 0; k <= 1; k++) {
                    var jj = j + k;
                    var u2 = i / grid;
                    var v2 = jj / grid;
                    var idx2 = jj * (grid + 1) + i;
                    var _r = 0, _g = 0, _b = 0;

                    if (fx & 1) {
                        // foil: a diagonal sheen band swept by the tilt
                        var _ph = frac(u2 * .6 + v2 * .4 + rot_y / 90 + rot_x / 140 + .5);
                        var _f = power(max(0, 1 - abs(_ph * 2 - 1) * 2.6), 2) * fx_alpha * 255;
                        _r += _f; _g += _f; _b += _f;
                    }
                    if (fx & 2) {
                        // rainbow: a hue wash sliding with tilt and time
                        var _hu = (u2 * 220 + v2 * 60 + rot_y * 2.5 + current_time * .02) mod 256;
                        var _c6 = make_colour_hsv(_hu, 255, 255);
                        var _a6 = .3 * fx_alpha * (.6 + .4 * abs(n[2]));
                        _r += colour_get_red(_c6) * _a6;
                        _g += colour_get_green(_c6) * _a6;
                        _b += colour_get_blue(_c6) * _a6;
                    }
                    if (fx & 8) {
                        // pearlescent: soft desaturated mother-of-pearl,
                        // the hue rides the TILT more than the surface
                        var _hp = (rot_y * 4 + rot_x * 3 + u2 * 90 + v2 * 50 + 1024) mod 256;
                        var _cp = make_colour_hsv(_hp, 95, 255);
                        var _ap2 = (.10 + .08 * dsin(u2 * 180 + v2 * 120 + rot_y * 2)) * fx_alpha;
                        _r += colour_get_red(_cp) * _ap2;
                        _g += colour_get_green(_cp) * _ap2;
                        _b += colour_get_blue(_cp) * _ap2;
                    }
                    if (fx & 16) {
                        // chromatic: one sheen refracted into r/g/b
                        // streaks (three phase-offset bands, one per
                        // channel - light splitting through a prism)
                        var _cb = u2 * .8 + v2 * .2 + rot_y / 70 + rot_x / 110;
                        var _p0 = frac(_cb + .5);
                        var _p1 = frac(_cb + .535);
                        var _p2 = frac(_cb + .57);
                        _r += power(max(0, 1 - abs(_p0 * 2 - 1) * 3), 2) * fx_alpha * 230;
                        _g += power(max(0, 1 - abs(_p1 * 2 - 1) * 3), 2) * fx_alpha * 230;
                        _b += power(max(0, 1 - abs(_p2 * 2 - 1) * 3), 2) * fx_alpha * 230;
                    }

                    draw_vertex_colour(vx[idx2], vy[idx2],
                        make_colour_rgb(min(_r, 255), min(_g, 255), min(_b, 255)), 1);
                }
            }
            draw_primitive_end();
        }
    }

    // glitter: SPECULAR pixel sparks. not vertex-blended (the mesh
    // interpolated them into huge blobs) - each spark is a hashed
    // point on the face, projected through the same rotation, glinting
    // hard as the tilt sweeps its phase. tilting the card makes light
    // catch and release across the field, like real glitter stock
    if (fx & 4) {
        for (var _s2 = 0; _s2 < 70; _s2++) {
            // abs() matters: GML frac keeps sign and sin goes negative,
            // which scattered half the sparks a card-width off the face
            var _hu3 = abs(frac(sin(_s2 * 12.9898) * 43758.55));
            var _hv3 = abs(frac(sin(_s2 * 78.2330) * 12543.71));
            var _hp3 = abs(frac(sin(_s2 * 39.3468) * 26715.93));
            var _spec = power(max(0, dsin(_hp3 * 1440 + rot_y * 10 + rot_x * 8 + current_time * .02)), 24);
            if (_spec < .06) continue;
            var _pp = rotate_point((_hu3 - .5) * card_w, (_hv3 - .5) * card_h, 0,
                _cx, _sx, _cy, _sy, _cz, _sz);
            var _ps = focal / (focal + _pp[2]);
            var _gw = (_hp3 > .8 && _spec > .7) ? 2 : 1; // a few pop bigger

            // the sparks BIND to whichever full-card finish rides with
            // them: rainbow glitter sparkles in the wash's own hue at
            // that spot, chromatic splits into pure r/g/b splinters,
            // pearl goes pastel, void goes violet. solo = near-white
            var _gc = merge_colour(c_white, make_colour_hsv(_hu3 * 255, 200, 255), .25);
            if (fx & 2) {
                var _ghu = (_hu3 * 220 + _hv3 * 60 + rot_y * 2.5 + current_time * .02) mod 256;
                _gc = make_colour_hsv(_ghu, 255, 255);
            } else if (fx & 16) {
                var _gp = floor(_hp3 * 3);
                if (_gp == 0) _gc = make_colour_rgb(255, 60, 60);
                if (_gp == 1) _gc = make_colour_rgb(60, 255, 60);
                if (_gp >= 2) _gc = make_colour_rgb(80, 80, 255);
            } else if (fx & 8) {
                var _ghp = (rot_y * 4 + rot_x * 3 + _hu3 * 90 + _hv3 * 50 + 1024) mod 256;
                _gc = make_colour_hsv(_ghp, 120, 255);
            } else if (fx & 32) {
                _gc = merge_colour(make_colour_rgb(150, 60, 255), c_white, .3);
            }

            draw_sprite_ext(spr_pixel_1x1, 0,
                x + _pp[0] * _ps - _gw * .5, y + _pp[1] * _ps - _gw * .5, _gw, _gw, 0,
                _gc, _spec * fx_alpha * 1.6);
        }
    }

    gpu_set_blendmode(bm_normal);

    // void: the finish that TAKES light. a slow dark wash breathes
    // across the whole face (subtractive - it eats more green than
    // red or blue, so what survives reads violet)
    if (fx & 32) {
        gpu_set_blendmode(bm_subtract);
        for (var j = 0; j < grid; j++) {
            draw_primitive_begin(pr_trianglestrip);
            for (var i = 0; i <= grid; i++) {
                for (var k = 0; k <= 1; k++) {
                    var jj = j + k;
                    var u2 = i / grid;
                    var v2 = jj / grid;
                    var idx2 = jj * (grid + 1) + i;
                    var _vd = (.22 + .16 * dsin(u2 * 220 + v2 * 170 + rot_y * 2 + current_time * .04))
                        * fx_alpha * 255;
                    draw_vertex_colour(vx[idx2], vy[idx2],
                        make_colour_rgb(_vd * .5, _vd, _vd * .35), 1);
                }
            }
            draw_primitive_end();
        }
        gpu_set_blendmode(bm_normal);
    }
}
