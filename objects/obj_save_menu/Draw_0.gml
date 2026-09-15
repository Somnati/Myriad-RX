/// The saves screen, drawn in statistics_v2's and settings' exact
/// language so the three read as one family: a title strip under the
/// header, a colour-coded rail down the left, opaque content rows with
/// gradient edge seams and a 2px identity band, and the house button
/// chrome for anything you can press.
///
/// Everything here is drawn in ONE pass at this instance's depth. The
/// other two screens need a draw proxy because their rows scroll under
/// a strip and their widgets live at depth-1; this screen has neither -
/// five rows always fit, and nothing on it is a live instance.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);   // "nothing here" gray
var _steel = rgb(170, 190, 230); // the house secondary text

// ===================== the title strip =====================
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, _steel, .25);

draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 8, ng_mode ? "new game > pick a profile" : "saves");
draw_set_alpha(1);

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ===================== the profile rail =====================
// menu2's colour language, exactly as statistics uses it: identity pip
// at the left edge, the active tab a solid fill, the rest sinking
// toward black. A profile signs its tab in the colour stored IN its
// savefile, so the rail is four different colours and you learn which
// run is which by hue before you read a word.
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, rail_w - 1, list_y, 1, room_height - list_y, 0,
	c_black, .5);

var _tb = __tabs();
for (var _i = 0; _i < 4; _i++) {
	var _t   = _tb[_i];
	var _c   = __pcol(_i);
	var _has = __phas(_i);
	var _on  = (_i == sel_prof);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2);
	var _tw  = _t.x2 - _t.x1;
	var _th  = _t.y2 - _t.y1;

	draw_set_alpha(1);
	if (_on)
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _tw, _th, 0,
			merge_colour(_c, c_black, .6), .92);
	else
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _t.x1, _t.y1, _tw, _th, 0,
			c_black, merge_colour(_c, c_black, _hov ? .5 : .75),
			merge_colour(_c, c_black, _hov ? .5 : .75), c_black, .85);
	draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _hov || _on ? 3 : 2, _th, 0,
		merge_colour(_c, c_white, .2), 1);

	// the ACTIVE profile - the one the run is actually in - wears a
	// gold hairline, which is a different statement from "selected"
	if (variable_global_exists("profile") && _i == g.profile && _has)
		draw_px_rect(_t.x1, _t.y1, _tw, _th, c_gold, .45);

	draw_set_halign(fa_left);
	draw_set_alpha(.95);
	if (_has) {
		draw_set_color(_on ? c_white : merge_colour(_c, c_white, _hov ? .7 : .45));
		draw_text(_t.x1 + 7, _t.y1 + 5, g.profile_name[_i]);
		draw_set_color(merge_colour(c_gold, c_black, _on ? .1 : .45));
		draw_text(_t.x1 + 7, _t.y1 + 16, crunch_arb(prof_info[_i].profit));
	} else {
		draw_set_color(merge_colour(_dim, c_black, _on ? 0 : .35));
		draw_text(_t.x1 + 7, _t.y1 + 10, "empty");
	}
}

// ===================== the content band =====================

// ---- the header line: who this profile is, in one line ----
// difficulty, rebirth count and credits all lived on disk unread until
// now; this is where the profile-level facts belong, so the rows below
// can stay about the FILES.
var _pc  = __pcol(sel_prof);
var _has = __phas(sel_prof);
draw_set_halign(fa_left);
draw_set_alpha(.9);
draw_set_color(_has ? _pc : _dim);
draw_text(content_x, hdr_y, _has ? g.profile_name[sel_prof] : "empty profile");
if (_has) {
	var _hx = content_x + string_width(g.profile_name[sel_prof]) + 6;
	var _pi = prof_info[sel_prof];
	if (_pi.difficulty >= 0 && _pi.difficulty <= 4) {
		draw_set_color(ng_col[_pi.difficulty]);
		draw_set_alpha(.8);
		draw_text(_hx, hdr_y, ng_label[_pi.difficulty]);
		_hx += string_width(ng_label[_pi.difficulty]) + 6;
	}
	draw_set_color(_dim);
	draw_set_alpha(.85);
	var _rb = _pi.rebirths;
	if (_rb > 0) {
		draw_text(_hx, hdr_y, string(_rb) + (_rb == 1 ? " rebirth" : " rebirths"));
		_hx += string_width(string(_rb) + " rebirths") + 6;
	}
	if (_pi.credits > 0)
		draw_text(_hx, hdr_y, crunch_arb(_pi.credits) + " credits");
}
draw_set_alpha(1);

// ---- page 0: the five slot rows ----
for (var _i = 0; _i < 5; _i++) {
	var _ry   = __row_y(_i);
	var _slot = slot_of_row[_i];
	var _inf  = info[_i];
	var _ok   = !is_undefined(_inf) && _inf.valid;

	// the row's identity colour: main gold, autosaves steel, the
	// rebirth backup purple - the same three the popups speak in
	var _fc = _steel;
	if (_slot == 0) _fc = c_gold;
	if (_slot == 4) _fc = c_hpurple;

	__panel(_ry, row_h, _fc, _ok ? 1 : .45);

	// hover wash, settings' exact weight (an empty autosave slot still
	// answers a tap - it explains itself - so every row gets one)
	if (input_free())
	if (g.click_owner == noone)
	if (point_in_rectangle(mouse_x, mouse_y, rail_w, _ry, room_width, _ry + row_h - 1))
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, cw, row_h, 0, c_white, .04);
	// THE SELECTED ROW (his ask: rows select, the buttons act): a wash and a
	// rim in the row's own colour
	if (sel_row == _i && !ng_mode) {
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, cw, row_h, 0, _fc, .10);
		draw_px_rect(rail_w, _ry, cw - 1, row_h - 1, _fc, .55);
	}

	draw_set_halign(fa_left);
	draw_set_alpha(_ok ? .95 : .6);
	draw_set_color(_ok ? c_white : _dim);
	// the rebirth backup names the rebirth it precedes. rebirth_do
	// copies the file BEFORE it increments the total, so the stored
	// count is the number of rebirths behind that run - the one it was
	// about to become is that plus one.
	var _lbl = slot_label[_i];
	if (_slot == 4 && _ok) _lbl = "before rebirth " + string(_inf.rebirths + 1);
	draw_text(content_x, _ry + 5, _lbl);

	// THE STAMP, right-aligned on line one. This is the whole point of
	// the rebuild: without it three rotating autosaves are unreadable.
	if (_ok) {
		draw_set_halign(fa_right);
		draw_set_color(_steel);
		draw_set_alpha(.8);
		draw_text(room_width - 8, _ry + 5, crunch_time_ago(_inf.datetime));
	}

	// line two: what is IN the file
	draw_set_halign(fa_left);
	if (_ok) {
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text(content_x, _ry + 17, crunch_arb(_inf.profit));

		// playtime, right-aligned under the stamp. BOTH clocks when
		// there is an away one to show (his split, two rounds back):
		// active time, then what accrued while the game was closed.
		draw_set_halign(fa_right);
		draw_set_color(_steel);
		draw_set_alpha(.7);
		var _pt = crunch_time_long(_inf.playtime * 60);
		if (_pt == "") _pt = "0s";
		if (_inf.playtime_off > 0)
			_pt += " (+" + crunch_time_long(_inf.playtime_off * 60) + " away)";
		draw_text(room_width - 8, _ry + 17, _pt);
	} else {
		draw_set_color(_dim);
		draw_set_alpha(.7);
		if (_slot == 0)      draw_text(content_x, _ry + 17, "no save here yet");
		else if (_slot == 4) draw_text(content_x, _ry + 17, "written before every rebirth");
		else                 draw_text(content_x, _ry + 17, "empty");
	}
}

// ---- the action band: what you do to the PROFILE, not to a file ----
// (rows are the files, this row is the profile - which is why "delete
// profile" moved out of the main save's popup and down here)
draw_set_halign(fa_left);
draw_set_valign(fa_top);
if (ng_mode) {
	var _nb = __ngbtn();
	draw_ui_button(_nb.x, _nb.y, _nb.w, _nb.h,
		_has ? "overwrite with a new game" : "start a new game here",
		_has ? c_hred : c_sgreen, true, true);
} else {
	var _bd = __band();
	for (var _i = 0; _i < 3; _i++) {
		var _b = _bd[_i];
		var _en = true;
		var _lb = "";
		var _bc = _steel;
		switch (_b.id) {
			case "export": _lb = "export";         _en = _has; break;
			case "import": _lb = "import";                     break;
			case "wipe":   _lb = "delete profile"; _en = _has;
				_bc = c_hred; break;
		}
		draw_ui_button(_b.x, _b.y, _b.w, _b.h, _lb, _bc, _en, false);
	}
}

// ---- THE BIG BUTTONS, bottom right (his ask, 2026-09-13) ----
if (!ng_mode) {
	var _bb = __bigbtns();
	var _sok = (sel_row >= 0) && !is_undefined(info[sel_row]) && info[sel_row].valid;
	for (var _i = 0; _i < array_length(_bb); _i++) {
		var _b = _bb[_i];
		if (_b.id == "save") draw_ui_button(_b.x, _b.y, _b.w, _b.h, "save", c_gold, true, true);
		else                 draw_ui_button(_b.x, _b.y, _b.w, _b.h, "load", c_sblue, _sok, true);
	}
}

// ---- THE CONFIRM POPUP (his ask: a box in the middle, not the dialogue) ----
if (conf_a > .01) {
	var _r = __conf_rect();
	var _e = conf_a * conf_a * (3 - 2 * conf_a);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .55 * _e);
	var _pc = g.profile_color[sel_prof];
	var _ry0 = _r.y + (1 - _e) * 8;
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x + 2, _ry0 + 3, _r.w, _r.h, 0, c_black, .5 * _e);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _ry0, _r.w, _r.h, 0, c_hsv(169, 186, 9), _e);
	draw_px_rect(_r.x, _ry0, _r.w, _r.h, _pc, .8 * _e);
	draw_set_font(fnt);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(.95 * _e);
	var _nm = g.profile_name[sel_prof];
	var _q = "";
	if (confirm == "save") _q = __phas(sel_prof) ? ("are you sure you want to overwrite\n" + _nm + "'s save?") : ("save the run here, as " + _nm + "?");
	else if (confirm == "load") _q = (sel_row > 0) ? ("are you sure you want to load this backup?\nit replaces " + _nm + "'s main save.") : ("are you sure you want to load\n" + _nm + "'s save?");
	else if (confirm == "newgame") _q = "are you sure you want to overwrite\n" + _nm + "'s save with a new game?";
	draw_text(_r.x + _r.w * .5, _ry0 + 12, _q);
	var _cb = __conf_btns();
	var _lbl = (confirm == "save") ? "save game" : ((confirm == "newgame") ? "overwrite" : "load game");
	var _col = (confirm == "save") ? c_gold : ((confirm == "newgame") ? c_hred : c_sblue);
	ui_fade_set(_e);
	draw_ui_button(_cb[0].x, _cb[0].y - _r.y + _ry0, _cb[0].w, _cb[0].h, _lbl, _col, true, true);
	draw_ui_button(_cb[1].x, _cb[1].y - _r.y + _ry0, _cb[1].w, _cb[1].h, "cancel", rgb(170, 190, 230), true, false);
	ui_fade_set(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
