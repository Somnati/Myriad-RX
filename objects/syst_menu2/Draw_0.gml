/// the drawer, from the same __layout the hit tests use. draws:
/// left shadow -> panel bg -> list rows -> pinned header/foot bands OVER
/// them (scrolled rows slide underneath).
///
/// ⚖️ THE OVERHAUL (2026-09-08, his ask: overhaul it but keep the size
/// so it still ports to mobile). Nothing here is bigger or smaller than
/// it was - a 14px row is ~56 real px on a 1080p phone, over the touch
/// minimum, and that was never the problem. What changed is what is
/// drawn inside those boxes:
///
///   THE ROWS ARE FLAT. Every row used to be a filled gradient bar
///   running black -> its own hue at the right edge. Fourteen of those
///   is a rainbow ladder, and the gradient ran the wrong way: dark on
///   the LEFT where the text is, so the label fought a black ground
///   while the colour sat out at the right doing decoration. Colour is
///   now one 2px identity pip and nothing else; hover fills the row in
///   its own hue instead.
///
///   HERE IS ONE STATE, NOT TWO. The room you are in had a solid fill
///   AND a gold pip on the far side. It is the left pip now: full
///   height, gold-tipped, white text.
///
///   ONE SOFT SHADOW replaces the 1px slate line. It is the cheapest
///   cue there is for "this floats above the room" and it costs eight
///   1px strips.
///
/// TOUCH NOTE, and it is the one that governs any future change here:
/// every affordance must survive having NO hover. On a phone hover
/// never fires, so whatever the resting row looks like is the entire
/// interface. A flat text row with a colour pip reads as tappable at
/// rest; a row that only looks interactive when pointed at does not.

if (am <= 0) exit;

var _it = __layout();
var _slate = rgb(170, 190, 230);
var _ink   = rgb(195, 205, 235);
draw_set_font(fnt);

// ---- the left shadow ----
// falls onto the ROOM, not the panel, so it rides the slide and reads
// as depth rather than as a border drawn on an edge
for (var _k = 0; _k < 8; _k++) {
	draw_sprite_ext(spr_pixel_1x1, 0, panel_x - 1 - _k, 0, 1, room_height, 0,
		c_black, .30 * (1 - _k / 8) * am);
}

// ---- panel base ----
// widths are the CONSTANT panel width (pw), never room_width-panel_x:
// the drawer is a rigid unit that slides off the room edge, it does
// not shrink against it (close-anim fix 2026-07-12)
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, room_height, 0,
	c_hsv(169, 186, 7), .97);
// one hairline of light on the panel's own edge - the shadow gives the
// depth, this gives the edge somewhere to stop
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, 1, room_height, 0, _slate, .28);

// ---- list rows + section labels ----
for (var _i = 0; _i < array_length(_it); _i++) {
	var _o = _it[_i];
	var _hov = point_in_rectangle(mousex, mousey, _o.x1, _o.y1, _o.x2, _o.y2);

	// SECTION HEADING: drawn at the bottom of its band so the extra
	// height lands ABOVE it, where the grouping happens. No rule - the
	// space is the separator, and a line would only put the weight back.
	if (_o.kind == 2) {
		draw_set_halign(fa_left);
		draw_set_color(_slate);
		draw_set_alpha(.42);
		draw_text(_o.x1 + 1, _o.y2 - 8, _o.name);
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

	// the ground: nothing at rest. Hover tints the row in its own hue,
	// which is where the colour identity earns its place instead of
	// being painted across every row at all times.
	if (_hov && !_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _w, _h, 0,
			merge_colour(_b.col, c_black, .74), .9);
	if (_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _w, _h, 0,
			merge_colour(_b.col, c_black, .84), .9);

	// THE PIP is the whole colour story now: 2px at rest, 3 when
	// pointed at, and gold-capped on the room you are in - one mark
	// carrying identity, hover and location between them.
	var _pw2 = _hov ? 3 : 2;
	if (_here) _pw2 = 3;
	draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _pw2, _h, 0,
		merge_colour(_b.col, c_white, .2), 1);
	if (_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1 + 3, _pw2, _h - 6, 0,
			c_gold, .95);

	draw_set_halign(fa_left);
	var _tc = merge_colour(_b.col, c_white, _hov ? .8 : .6);
	if (_here) _tc = c_white;
	draw_set_color(_tc);
	draw_set_alpha(_here ? 1 : .92);
	draw_text(_o.x1 + 9, _o.y1 + ((_h - 7) div 2), _o.name);
}

// ---- pinned header band ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, hdr_h, 0,
	c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, 1, hdr_h, 0, _slate, .28);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, hdr_h - 1, pw - 8, 1, 0,
	_slate, .22);
var _px2 = panel_x + 9;
draw_set_halign(fa_left);
// WHERE YOU ARE leads, because that is what you opened a menu to change
// - the profile is context under it rather than the headline
draw_set_color(_ink);
draw_set_alpha(.9 * am);
draw_text(_px2, 8, __here_name());
if (variable_global_exists("profile_name")) {
	draw_set_color(g.profile_color[g.profile]);
	draw_set_alpha(.5 * am);
	draw_text(_px2, 20, g.profile_name[g.profile]);
}

// ---- pinned foot band: profit (left, gold) + time played (right,
// right-aligned) - his layout, 2026-07-10 ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, pw,
	foot_h, 0, c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, 1, foot_h, 0, _slate, .28);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, room_height - foot_h, pw - 8,
	1, 0, _slate, .22);
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
