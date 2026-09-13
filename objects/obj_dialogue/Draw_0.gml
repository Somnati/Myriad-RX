/// ============================================================
/// STEP 2 :: obj_dialogue DRAW EVENT  (was Draw GUI - see the Create's depth note)
/// ============================================================

if (!dialogue_active) exit;

// harden the draw state before anything renders. something
// upstream leaves alpha dirty, and text would inherit it
draw_set_alpha(1);
draw_set_color(c_white);

// position follows the live GUI size, so resolution changes,
// fullscreen toggles, and your display system's snapping
// can never strand the box
box_x = (room_width  - box_w) * 0.5;
box_y =  room_height - box_h - box_margin;
if (passive) { box_x = passive_x; box_y = passive_y; } // barks sit
	// where their spawner parked them (bean boss: the center column)

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- main box: pixel fill, double pixel border ----
__px(box_x, box_y, box_w, box_h, box_col_fill, box_alpha_fill);
__px_frame(box_x,     box_y,     box_w,     box_h,     1, box_col_border);
__px_frame(box_x + 1, box_y + 1, box_w - 2, box_h - 2, 1, box_col_border);

// ---- name plate, only when a speaker was given ----
if (cur_speaker != "") {
    var _nw = string_width(cur_speaker) + pad * 2;
    var _ny = box_y - name_h - 2;
__px(box_x, _ny, _nw, name_h, box_col_fill, box_alpha_fill);
__px_frame(box_x, _ny, _nw, name_h, 1, box_col_border);
    draw_text(box_x + pad, _ny + 3, cur_speaker);
}

// ---- portrait slot ----
if (use_portrait) {
    var _px2 = box_x + pad;
    var _py2 = box_y + (box_h - portrait_size) * 0.5;
__px_frame(_px2, _py2, portrait_size, portrait_size, 1, box_col_border);
    if (portrait_sprite != -1) {
        draw_sprite_stretched(portrait_sprite, 0, _px2 + 1, _py2 + 1,
                              portrait_size - 2, portrait_size - 2);
    }
}

// ---- work out how many text rows the menu will claim ----
// when a choice menu is up, it owns the bottom N rows of the box.
// any kept text line that would fall into that territory is hidden
var _n_opts = array_length(choice_options);
var _text_line_cap = 9999;   // "draw every line" unless choosing
if (state == DSTATE.CHOOSING) {
    var _rows_total = floor((box_h - pad * 2) / line_h);
    _text_line_cap = _rows_total - _n_opts - 1;   // last text line allowed
}

// ---- text, per character so each can carry its own style ----
var _tx = box_x + pad + (use_portrait ? portrait_size + pad : 0);
var _ty = box_y + pad;
var _vis = floor(reveal);

for (var i = 0; i < _vis; i++) {
    var _c = chars[i];
    if (_c.line > _text_line_cap) continue;   // row belongs to the menu
    if (_c.ch == "\n" || _c.ch == " ") continue;

    var _ox = 0, _oy = 0;
    if (_c.wave)  _oy += dsin(current_time * wave_speed + i * wave_phase) * wave_amp;
    if (_c.shake) { _ox += random_range(-shake_amp, shake_amp);
                    _oy += random_range(-shake_amp, shake_amp); }

    draw_set_color(_c.col);
    draw_text(_tx + _c.x + _ox, _ty + _c.line * line_h + _oy, _c.ch);
}
draw_set_color(c_white);

// ---- "line finished" indicator: pixel arrow, blinking ----
if (state == DSTATE.WAITING && (current_time div 400) % 2 == 0) {
    var _ax = box_x + box_w - 13;
    var _ay = box_y + box_h - 9;
    __px(_ax, _ay, 7, 1, box_col_accent);
    __px(_ax + 1, _ay + 1, 5, 1, box_col_accent);
    __px(_ax + 2, _ay + 2, 3, 1, box_col_accent);
    __px(_ax + 3, _ay + 3, 1, 1, box_col_accent);
}

// ---- choice menu: anchored to the bottom of the box, ----
// ---- stacking upward, per-char so labels carry style  ----
if (state == DSTATE.CHOOSING) {
    var _oy_base = box_y + box_h - pad - _n_opts * line_h;
    _oy_base = max(_oy_base, _ty);

    for (var i = 0; i < _n_opts; i++) {
        var _oy2 = _oy_base + i * line_h;
        var _ox2 = _tx + 12;

        if (i == choice_index) {
            // pixel cursor square, soul-adjacent
            __px(_tx + 2, _oy2 + 1, 5, 5, box_col_accent);
        }

        var _lc = choice_options[i].parsed;
        for (var k = 0; k < array_length(_lc); k++) {
            var _c2 = _lc[k];
            if (_c2.ch == " ") continue;

            var _ox3 = 0, _oy3 = 0;
            if (_c2.wave)  _oy3 += dsin(current_time * wave_speed + k * wave_phase) * wave_amp;
            if (_c2.shake) { _ox3 += random_range(-shake_amp, shake_amp);
                             _oy3 += random_range(-shake_amp, shake_amp); }

            draw_set_color(_c2.col);
            draw_text(_ox2 + _c2.x + _ox3, _oy2 + _oy3, _c2.ch);
        }
    }
    draw_set_color(c_white);
}

draw_set_color(c_white);
draw_set_alpha(1);
