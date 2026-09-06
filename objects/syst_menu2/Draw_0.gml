/// the drawer, from the same __layout the hit tests use. draws:
/// panel bg -> list rows -> pinned header/foot bands OVER them
/// (scrolled rows slide underneath).
/// rows you are NOT in fade to black right-to-left (color lives at
/// the right edge, sinks into the panel); the room you ARE in keeps
/// its solid fill, marked only by the gold pip and white text.

if (am <= 0) exit;

var _it = __layout();
var _slate = rgb(170, 190, 230);
var _ink   = rgb(195, 205, 235);
draw_set_font(fnt);

// ---- panel base ----
// widths are the CONSTANT panel width (pw), never room_width-panel_x:
// the drawer is a rigid unit that slides off the room edge, it does
// not shrink against it (close-anim fix 2026-07-12)
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, room_height, 0,
	c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, 1, room_height, 0, _slate, .5);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 1, 0, 1, room_height, 0, c_black, .5);

// ---- list rows + section labels ----
for (var _i = 0; _i < array_length(_it); _i++) {
	var _o = _it[_i];
	var _hov = point_in_rectangle(mousex, mousey, _o.x1, _o.y1, _o.x2, _o.y2);

	if (_o.kind == 2) {
		draw_set_halign(fa_left);
		draw_set_color(_slate);
		draw_set_alpha(.5);
		draw_text(_o.x1 + 1, _o.y1 + 1, _o.name);
		var _lw = string_width(_o.name);
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1 + _lw + 5, _o.y1 + 4,
			_o.x2 - _o.x1 - _lw - 5, 1, 0, _slate, .18);
		continue;
	}

	// info label (menu2_label): dim ink line, no chrome, no action
	if (_o.kind == 3) {
		draw_set_halign(fa_left);
		draw_set_color(_ink);
		draw_set_alpha(.55);
		draw_text(_o.x1 + 1, _o.y1 + 1, _o.name);
		continue;
	}

	var _b = btns[_o.idx];
	// method destinations are never "here" (comparing a method to a
	// room id can throw - guard first)
	var _here = !is_method(_b.rm) && in_room(_b.rm);
	var _w = _o.x2 - _o.x1;
	var _h = _o.y2 - _o.y1;
	if (_here) {
		// you are here: solid fill, no outline, gold pip
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _w, _h, 0,
			merge_colour(_b.col, c_black, .6), .92);
	}
	else {
		// elsewhere: color at the right edge, sinking to black leftward
		var _cr = merge_colour(_b.col, c_black, _hov ? .35 : .55);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _o.x1, _o.y1, _w, _h, 0,
			c_black, _cr, _cr, c_black, .88);
	}
	// color identity pip at the left
	draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _hov ? 4 : 2, _h, 0,
		merge_colour(_b.col, c_white, .2), 1);

	draw_set_halign(fa_left);
	draw_set_color(_here ? c_white : merge_colour(_b.col, c_white, _hov ? .75 : .55));
	draw_set_alpha(.95);
	draw_text(_o.x1 + 9, _o.y1 + ((_h - 7) div 2), _o.name);

	// "you are here" pip
	if (_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x2 - 7, _o.y1 + (_h div 2) - 1,
			3, 3, 0, c_gold, .95);
}

// ---- pinned header band ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, hdr_h, 0,
	c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, 1, hdr_h, 0, _slate, .5);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, hdr_h - 1, pw - 8, 1, 0,
	_slate, .3);
var _px2 = panel_x + 9;
draw_set_halign(fa_left);
if (variable_global_exists("profile_name")) {
	draw_set_color(g.profile_color[g.profile]);
	draw_set_alpha(.95 * am);
	draw_text(_px2, 8, g.profile_name[g.profile]);
}
// (the profit line moved to the FOOT band, 2026-07-10 his ask - the
// band keeps its 44px height, just breathes more now)
draw_set_color(_ink);
draw_set_alpha(.45 * am);
draw_text(_px2, 20, "@ " + __here_name());

// ---- pinned foot band: profit (left, gold) + time played (right,
// right-aligned) - his layout, 2026-07-10 ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, pw,
	foot_h, 0, c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, 1, foot_h, 0, _slate, .5);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, room_height - foot_h, pw - 8,
	1, 0, _slate, .3);
draw_set_halign(fa_left);
draw_set_color(_slate);
draw_set_alpha(.45 * am);
draw_text(panel_x + 9, room_height - foot_h + 4, "profit");
draw_set_color(c_gold);
draw_set_alpha(.9 * am);
draw_text(panel_x + 9, room_height - foot_h + 14,
	variable_global_exists("profit") ? crunch_arb(g.profit) : "0");
// right-aligned on the PANEL's right edge (panel_x + pw), not the
// room's - this is the "time text doesn't move with the drawer" fix
draw_set_halign(fa_right);
draw_set_color(_slate);
draw_set_alpha(.45 * am);
draw_text(panel_x + pw - 6, room_height - foot_h + 4, "time played");
draw_set_color(_ink);
draw_set_alpha(.9 * am);
// the precise ACTIVE clock, then the away time as a compact tail:
// "00d 02h 14m 03s +5h" reads as what you played plus what accrued
// while you were gone, and their sum is the save's whole life. Below a
// minute of absence the tail is left off rather than showing "+0s".
var _tp = __playtime_str();
var _off = variable_global_exists("time_played_offline") ? g.time_played_offline : 0;
if (_off >= 60) _tp += " +" + crunch_time(_off * 60);
draw_text(panel_x + pw - 6, room_height - foot_h + 14, _tp);
draw_set_halign(fa_left);

// scrollbar whisper (rides the panel edge too)
if (scr_max > 0) {
	var _bandh = room_height - hdr_h - foot_h - 4;
	var _sbh = max(14, _bandh * _bandh / (_bandh + scr_max));
	var _sby = hdr_h + 2 + (scr / scr_max) * (_bandh - _sbh);
	draw_sprite_ext(spr_pixel_1x1, 0, panel_x + pw - 3, _sby, 2, _sbh, 0, _slate, .4);
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
