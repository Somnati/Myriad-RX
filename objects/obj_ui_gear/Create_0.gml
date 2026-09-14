/// obj_ui_gear - THE DOCK (2026-09-13, his ask: "move the battery /
/// credit core / statistics over there as well... positioned to the
/// left of the settings icon, not vertically... daily gifts would have
/// to go there eventually"). It began as the settings gear alone
/// (Myriad DE's spr_quickoption_settings, imported as spr_gear) - a
/// DOOR rather than a menu line, the one destination you reach
/// mid-anything. Now it is a row of doors: the gear, and beside it the
/// credit core, the battery, statistics and the daily gift, each drawn
/// in the gear's own language (21px, the burger's two tones, a hover
/// halo and a quarter-turn's worth of ease) - the core and the battery
/// as their panels' discs with their LIVE fill, statistics as three
/// rising bars, the gift as a box with a ribbon that breathes while one
/// is waiting. Their menu lines came out of menu2_content the day they
/// landed here. An icon exists only once its feature has unfolded.
///
/// TWO HOMES, one object, and they want different corners:
///   in game    the row rides the OPEN drawer's left edge at the BOTTOM,
///              sliding in with it, the gear nearest the drawer and the
///              rest stepping LEFT (landscape) - or UP the edge in
///              portrait, where there is no room to the left. Closed,
///              there is no dock at all - the header keeps the burger
///              alone (his call).
///   title      the gear alone, bottom right, where nothing else lives
///              (the version strings hold the bottom LEFT).
/// Nothing here gates on g.game_started the way obj_ui_menu2 does:
/// having no run yet is precisely when you want display and audio.

depth = instance_exists(obj_ui_header) ? obj_ui_header.depth - 1 : -1001;

tic  = 0;   // press debounce, obj_ui_menu2's
rip  = 0;   // press ripple, 1 -> 0 (the icon pressed)
rip_i = -1;
hot_i = -1; // the icon under the pointer
DOCK_STEP = 26;   // px between icons

// THE ROSTER: key (the unfold key that gates it; "" = the gear, always)
// and spin (its hover ease). Order = distance from the gear. The doors
// themselves are __open's switch - a function literal inside a struct
// literal binds to the STRUCT, and create_obj reads the caller's depth
// (his crash report, 2026-09-13: "struct.depth not set")
drop = 0;   // the title's gear: 0 seated, 1 pulled down off the screen (a panel is up)
icons = [
	{ key : "",           spin : 0, name : "settings" },
	{ key : "ccore",      spin : 0, name : "credit core" },
	{ key : "battery",    spin : 0, name : "battery" },
	{ key : "statistics", spin : 0, name : "statistics" },
	{ key : "gift",       spin : 0, name : "daily gift" },
];
__open = function(_i) {
	switch (icons[_i].key) {
		case "":
			if (in_room(rm_titlescreen)) title_header();   // the title: its header first, so the panel seats under it and its X can close it
			settings_open();
			break;
		case "ccore":      ccore_open();      break;
		case "battery":    battery_open();    break;
		case "statistics": statistics_open(); break;
		case "gift":       gift_open();       break;
	}
};

/// where the gear sits this frame, and how visible the dock is.
/// `a` 0 means it is not there at all - Step and Draw both leave on it,
/// so there is one answer to "is the dock up" rather than two.
__seat = function() {
	// THE TITLE SCREEN has no menu to hang off, so the gear takes the
	// bottom right corner outright (and the dock is the gear alone)
	// ...and pulls DOWN OFF THE SCREEN while a panel is up there (his ask,
	// 2026-09-13), back up when it closes - `drop` eases in the Step
	if (!instance_exists(obj_ui_menu2) || in_room(rm_titlescreen))
		return { x : room_width - 15, y : room_height - 15 + 34 * drop, a : 1, e : 1 };
	// IN GAME it belongs to the drawer, not to the header: it appears
	// when the menu opens and rides the panel's left edge in, which is
	// what makes it read as part of the menu rather than as a second
	// permanent button competing with the burger.
	if (!instance_exists(syst_menu2)) return { x : 0, y : 0, a : 0, e : 0 };
	var _m = syst_menu2;
	// ⚖️ THEY RISE FROM THE BOTTOM (his ask, 2026-09-13), not in from the
	// right with the drawer: x is the row's FINAL seat beside the open
	// drawer's edge, and the Draw lifts each icon from under the room's
	// bottom edge on the drawer's own ease (e), the gear first
	return {
		x : room_width - _m.pw - 16,
		// THE BOTTOM of the drawer (his call, 2026-09-08): level with the
		// pinned time-played band - a few px up from its middle, so a disc
		// (r10, +1 hovered) clears the edge (his report: their bottoms fell off)
		y : room_height - 14,
		a : clamp(_m.am, 0, 1),
		e : _m.__ease(clamp(_m.am, 0, 1)),
	};
};

/// @func __seats()
/// @desc every VISIBLE icon's seat this frame: [{ i, x, y }] - the gear at
///       the base, the rest stepping left (landscape) or up (portrait)
__seats = function() {
	var _s = __seat();
	var _out = [];
	if (_s.a <= .01) return _out;
	// (the title-mode header brings an obj_ui_menu2 with it - the ROOM is the
	// test, or the other four icons rose beside the gear there: his report)
	var _title = in_room(rm_titlescreen) || !instance_exists(obj_ui_menu2);
	var _land  = (room_width > 300);
	var _n = 0;
	for (var _i = 0; _i < array_length(icons); _i++) {
		var _ic = icons[_i];
		if (_i > 0 && _title) break;                       // the title: the gear alone
		if (_ic.key != "" && !unfold_has(_ic.key)) continue;
		// THE RISE: each icon a beat behind the last, from 40 px under its
		// seat (the room's bottom edge) up to it on the drawer's ease
		var _t = clamp((_s.e - _n * .08) / .68, 0, 1);
		var _lift = (1 - _t * _t * (3 - 2 * _t)) * 40;
		array_push(_out, { i : _i,
			x : floor(_land ? (_s.x - _n * DOCK_STEP) : _s.x),
			y : floor((_land ? _s.y : (_s.y - _n * DOCK_STEP)) + _lift),
			t : _t });
		_n += 1;
	}
	return _out;
};

/// @func __disc(x, y, col, fill, a, h)
/// @desc THE GROUND: spr_dock_disc - the gear's own disc, its cog filled in
///       (his idea, 2026-09-13: the same background sprite the gear had) -
///       then the fill rising from the bottom (the core's and the
///       battery's liquid) in the door's colour.
///       The disc is 18 px on a 21 px sprite with the gear's origin at
///       (10,10), so its centre is (x-.5, y-.5): every glyph in this file
///       is seated on THAT point, which is what centres them
__disc = function(_x, _y, _col, _fill, _a, _h) {
	var _sc = 1 + .15 * _h;
	draw_sprite_ext(spr_dock_disc, 0, _x, _y, _sc, _sc, 0, c_white, _a);
	var _cx = _x - .5, _cy = _y - .5, _r = 8 + _h;
	for (var _py = _y - 9; _py <= _y + 8; _py++) {
		var _dy = (_py + .5) - _cy;
		if (abs(_dy) >= _r) continue;
		var _hw = sqrt(sqr(_r) - sqr(_dy));
		var _x0 = round(_cx - _hw), _x1 = round(_cx + _hw);
		if (_x1 <= _x0) continue;
		// the liquid, where the fill has risen to (no wash under it - his
		// report, 2026-09-13: it read as a second, paler disc on the gear's)
		if (_fill > 0 && _dy > _r - 2 * _r * clamp(_fill, 0, 1))
			draw_sprite_ext(spr_pixel_1x1, 0, _x0, _py, _x1 - _x0, 1, 0, _col, .6 * _a);
	}
};

/// @func __label(x, y, txt, a)
/// @desc the small font, centred in a disc
__label = function(_x, _y, _txt, _a) {
	draw_set_font(fnt_outline);   // (his call: the outline keeps it readable over the fill)
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(.95 * _a);
	// ON THE GRID: centred on the disc's centre point (x-.5) and then
	// ROUNDED to a whole column - a sprite font at a half pixel lands on
	// whichever side the sampler picks, never both (his report: uncentred)
	var _w = string_width(_txt);
	draw_text(round(_x - .5 - _w * .5), _y - 4, _txt);
	draw_set_font(fnt);
	draw_set_alpha(1);
};

/// @func __glyph(i, x, y, a, h, hot)
/// @desc one icon's face
__glyph = function(_i, _x, _y, _a, _h, _hot) {
	_x = floor(_x); _y = floor(_y);   // the seat is a pixel; the disc's centre is half a px up-left of it
	var _tone = _hot ? c_white : rgb(190, 200, 225);   // the burger's two tones
	switch (icons[_i].key) {
		case "": {
			// DE's cog, frame 0 (frame 1 is its inverse). The origin sits
			// at its middle, so it turns on the spot: a quarter turn and a
			// little bigger, both off the hover ease
			var _sc = 1 + .15 * _h;
			draw_sprite_ext(spr_gear, 0, _x, _y, _sc, _sc, _h * 90, _tone, (.85 + .15 * _h) * _a);
			break;
		}
		case "ccore": {
			// the well: lavender, its fill the credits in it, the count inside
			var _v = ccore_values();
			var _live = (g.ccore.st == 1 || g.ccore.st == 2);
			var _f = _live ? clamp(g.ccore.xp / max(1, _v.cap), 0, 1) : 0;
			__disc(_x, _y, _hot ? merge_colour(c_feat_ccore, c_white, .3) : c_feat_ccore, _f, _a, _h);
			__label(_x, _y, _live ? string(floor(g.ccore.xp)) : "-", _a);
			break;
		}
		case "battery": {
			// the cell: green, its fill the charge, the percentage inside
			var _f = clamp(g.battery.charge / max(1, battery_cap()), 0, 1);
			__disc(_x, _y, _hot ? merge_colour(c_feat_battery, c_white, .3) : c_feat_battery, _f, _a, _h);
			var _pc = floor(_f * 100);
			__label(_x, _y, (_pc >= 100) ? "100" : (string(_pc) + "%"), _a);   // ("100%" is a glyph too wide for the disc)
			break;
		}
		case "statistics": {
			// three bars rising (DE's icon) on a disc of the gear's tone - the
			// same round ground as the core and the battery (his ask), which is
			// also what keeps the hover glow centred on it
			__disc(_x, _y, _tone, 0, _a, _h);
			// ⚖️ THREE BARS, 3 WIDE WITH 2 BETWEEN = 13 WIDE, from x-7 (his second
			// screenshot, 2026-09-13: still not centred). The disc's centre is
			// the half-pixel point x-.5, so only an ODD width can sit on it: 13
			// columns x-7..x+5 have their middle column at x-1, whose centre is
			// x-.5. The old 16 (4/2/4/2/4) was even and sat half a pixel right.
			// Rows: the tallest spans y-6..y+5, middle row y-1 -> centre y-.5
			var _hs = [6, 9, 12];
			for (var _k = 0; _k < 3; _k++) {
				var _bh = _hs[_k] + _h;
				draw_sprite_ext(spr_pixel_1x1, 0, _x - 7 + _k * 5, _y + 6 - _bh, 3, _bh, 0, _tone, (.85 + .15 * _h) * _a);
			}
			break;
		}
		case "gift": {
			// DE's own box (spr_popbutton_dailygift's face, imported as
			// spr_gift_icon), in the gear's tone, pink and breathing while one
			// is waiting
			var _wait = gift_can_claim();
			var _br = _wait ? (.7 + .3 * abs(dsin(current_time * .3))) : 1;
			var _gc = _wait ? (_hot ? merge_colour(c_feat_gift, c_white, .3) : c_feat_gift) : _tone;
			// on a disc, and drawn from the disc's centre PIXEL (floor): the box
			// is eleven wide with its origin at five, so its middle column lands
			// on the disc's - the glow, the disc and the box share one centre
			// (his report: the hover glow sat off the box)
			__disc(_x, _y, _wait ? _gc : _tone, 0, _a, _h);
			// the box is 11 wide with its origin at 5: drawn at (x-1, y-1) its
			// columns are 4..14 of the sprite about the disc's centre (9.5)
			var _sc = 1 + .15 * _h;
			draw_sprite_ext(spr_gift_icon, 0, _x - 1, _y - 1, _sc, _sc, 0, _gc, (.85 + .15 * _h) * _a * _br);
			break;
		}
	}
	// "NEW" - a gold dot at the icon's shoulder while its feature is fresh
	if (icons[_i].key != "" && unfold_fresh(icons[_i].key)) {
		var _ph = frac(current_time / 2000);
		draw_sprite_ext(spr_pixel_1x1, 0, _x + 6, _y - 10, 3, 3, 0, c_gold, lerp(.3, 1, 1 - abs(_ph * 2 - 1)) * _a);
	}
};
