/// the drawer, from the same __layout the hit tests use. draws:
/// left shadow -> panel bg -> list rows -> pinned header/foot bands OVER
/// them (scrolled rows slide underneath).
///
/// ⚖️ THE OVERHAUL (2026-09-08), in two passes. The first kept every
/// dimension and changed only what was drawn inside them. The second is
/// his correction to the premise: this drawer is a PC control, so it did
/// not need a phone's width at all. The panel derives from the rows now
/// (__layout) instead of the rows fitting a hand-picked 148px, and 60-odd
/// pixels of dead teal went with it. ROW HEIGHT is still untouched at
/// 14px - about 56 real px on a 1080p phone, over the touch minimum -
/// so the day this does want a phone, only the width is the question.
///
/// What changed inside the boxes:
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
// ...IN THE CHOSEN STYLE (settings > visuals > menu style, 2026-09-13):
// default = the teal plate; black = plain black; glass = this frame's
// pixelated shot of what is under the panel, then the teal at a dim the
// words still read through (the plate stands in on a frame without one)
var _style = variable_global_exists("menu_style") ? g.menu_style : "default";
if (_style == "glass" && snap_ok) {
	draw_pixel_region(panel_x, 0, pw, room_height, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, room_height, 0, c_hsv(169, 186, 7), .62);
} else if (_style == "black") {
	draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, room_height, 0, c_black, 1);
} else {
	draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, room_height, 0,
		c_hsv(169, 186, 7), .97);
}
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
	var _hv = hov[_o.idx];   // eased in the Step
	// method destinations are never "here" (comparing a method to a
	// room id can throw - guard first)
	var _here = !is_method(_b.rm) && in_room(_b.rm);
	var _w = _o.x2 - _o.x1;
	var _h = _o.y2 - _o.y1;

	// SOLID BLACK GROUND (his ask). Every row is its own black plate, so
	// the column reads as a stack of discrete buttons against the panel
	// rather than as text floating on a tint - and it gives the label a
	// known ground whatever the blurred room behind happens to be doing.
	draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _w, _h, 0, c_black, 1);

	// ⚖️ THE HIGHLIGHT IS A WIPE, NOT A SWAP (his report: "i dont want it
	// to instantly change colors"). The hue enters from the LEFT and
	// fades into black across the row, and the lit part GROWS with the
	// hover ease - so pointing at a row is something that happens over a
	// few frames in a direction, rather than a colour that is suddenly
	// there. It leaves the same way, at the same rate.
	if (_hv > .01) {
		var _gc = merge_colour(_b.col, c_black, .55);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_o.x1, _o.y1, _w * _hv, _h, 0,
			_gc, c_black, c_black, _gc, .92);
	}
	// the room you are in keeps a steady ground under all of that
	if (_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _w, _h, 0,
			merge_colour(_b.col, c_black, .82), .9);

	// THE PIP is the whole colour story now: 2px at rest, 3 when
	// pointed at, and gold-capped on the room you are in - one mark
	// carrying identity, hover and location between them.
	var _pw2 = (_hv > .5) ? 3 : 2;
	if (_here) _pw2 = 3;
	draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1, _pw2, _h, 0,
		merge_colour(_b.col, c_white, .2), 1);
	if (_here)
		draw_sprite_ext(spr_pixel_1x1, 0, _o.x1, _o.y1 + 3, _pw2, _h - 6, 0,
			c_gold, .95);

	draw_set_halign(fa_left);
	var _tc = merge_colour(_b.col, c_white, .6 + .2 * _hv);
	if (_here) _tc = c_white;
	draw_set_color(_tc);
	draw_set_alpha(_here ? 1 : .92);
	draw_text(_o.x1 + 9, _o.y1 + ((_h - 7) div 2), _o.name);
	// "NEW" - DE's ability-slot pulse, term for term (obj_ability_slot:
	// gold, the outline font, alpha a triangle wave between .2 and 1 over
	// two seconds, each row a fifteenth of a cycle behind the last) - on
	// a line whose feature has unfolded and not been visited (unfold_fresh)
	if ((_b[$ "key"] ?? "") != "" && unfold_fresh(_b.key)) {
		var _ph = frac(current_time / 2000 + _i / 15);
		var _na = lerp(.2, 1, 1 - abs(_ph * 2 - 1));
		draw_set_font(fnt_outline);
		draw_set_color(c_gold);
		draw_set_alpha(_na);
		draw_text(_o.x1 + 9 + string_width(_o.name) + 5, _o.y1 + ((_h - 7) div 2), "new");
		draw_set_font(fnt);
	}
}

// ---- pinned header band ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, pw, hdr_h, 0,
	c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, 0, 1, hdr_h, 0, _slate, .28);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, hdr_h - 1, pw - 8, 1, 0,
	_slate, .22);
var _px2 = panel_x + 4;
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

// ---- pinned foot band: time played, and nothing else ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, pw,
	foot_h, 0, c_hsv(169, 186, 7), 1);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x, room_height - foot_h, 1, foot_h, 0, _slate, .28);
draw_sprite_ext(spr_pixel_1x1, 0, panel_x + 4, room_height - foot_h, pw - 8,
	1, 0, _slate, .22);
// THE PROFIT LINE IS GONE (his call). It sat here because the drawer
// was wide enough to hold two columns; the header shows profit in every
// room anyway, so it was the same number twice and the narrow panel has
// no space to spend on saying things twice. The clock stays, because
// nothing else anywhere reports it.
//
// Anchored on the PANEL's left edge, not the room's - the "time text
// doesn't move with the drawer" fix, now that the panel is narrow
// enough that a right-aligned clock would sit on the rows' edge.
draw_set_halign(fa_left);
draw_set_color(_slate);
draw_set_alpha(.4 * am);
draw_text(panel_x + 4, room_height - foot_h + 3, "time played");
draw_set_color(_ink);
draw_set_alpha(.85 * am);
// the precise ACTIVE clock, then the away time as a compact tail:
// "00d 02h 14m 03s +5h" reads as what you played plus what accrued
// while you were gone, and their sum is the save's whole life. Below a
// minute of absence the tail is left off rather than showing "+0s".
var _tp = __playtime_str();
var _off = variable_global_exists("time_played_offline") ? g.time_played_offline : 0;
if (_off >= 60) _tp += " +" + crunch_time(_off * 60);
draw_text(panel_x + 4, room_height - foot_h + 11, _tp);
draw_set_halign(fa_left);

// (the scrollbar is a real obj_scrollbar now - lane scrl_menu2, spawned
// in the Create and seated on the sliding edge each Step. The 2px
// whisper that used to be drawn here could show a position but never a
// PROPORTION, and it could not be grabbed or thrown.)

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
