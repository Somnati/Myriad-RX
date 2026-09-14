/// obj_tickets - THE SCRATCH TICKETS (his ask 2026-09-13: "what about
/// lottery tickets" / "build it"). The pile on the desk in the tap room
/// and the card you pull from it. THE SCRATCH IS THE FIDGET: a foil of
/// 2px cells over a 3x3 of symbols, your drag clears it, flakes fly,
/// it rasps; at 85% the last of it peels itself (nobody grinds
/// corners), the grid reads, a match of three pays on the spot with
/// that wallet's own ceremony. Tickets are EARNED, never bought
/// (ticket_grant) - the odds are printed on the face and the grid never
/// lies (ticket_roll).
///
/// THE PILE sits left of the tap surface above the milestone scale:
/// up to four faces fanned, the next one on top, the count beside.
/// Tap it and the top ticket grows out of the pile to the room's
/// centre. Closing (the x, escape) puts it back with its scratch
/// kept; the pile hides while the menu, a panel or the veil is up.
///
/// INPUT: a syst_input family member whose mask IS the live rect (the
/// pile when closed, the card when open), spr_pixel_1x1 scaled - the
/// puck's pattern - so the tapper under it stays quiet exactly where
/// the card is. Depth 10 closed (with the scales, over the visualizer's
/// fx layers); -30 open (over the dial column).
depth = 10;
sprite_index = spr_pixel_1x1;
mask_index   = spr_pixel_1x1;
image_alpha  = 0;
x = -1000; y = -1000;

// LARGER (his report, 2026-09-13): the card 82 x 94, the grid 60 (three 18s
// and two 3s), the foil 30 x 30 cells of 2 px, the faces 24 x 16
CW = 82; CH = 94;       // the card
PW = 24; PH = 16;       // a face on the pile
GN = 30; CS = 2;        // the foil: GN x GN cells of CS px over the 60 x 60 grid
CELL = 18; GAP = 3;     // the symbol cells
GW = 60;                // the grid's side (3 x CELL + 2 x GAP = GN x CS)
SY = 1.5;               // the symbols' size against the old 12 px cell

open  = false;
oa    = 0;              // the card's ease, pile -> centre
cur   = undefined;      // the ticket up (g.tickets.pile[0])
roll  = undefined;      // its grid (ticket_roll)
held  = false;          // the pointer is scratching
lmx = 0; lmy = 0;
peel  = -1;             // the self-peel, 0..1 (-1 = not yet)
done  = false;          // revealed; waiting to leave
done_t = 0;
prize = undefined;      // what it paid (undefined = a loser)
snd_t = 0;              // frames of grace before the scratch loop lets go
// THE SCRATCH LOOP's handle (2026-09-14: his "Writing (6)", cut to its
// two steadiest strokes and looped - snd_scratch is a LOOP now, fixed
// pitch). Mirrored in g.scratch_snd so the persistent system can stop
// it if this instance dies mid-scratch (a room restart under the hand)
snd_h = -1;
g.scratch_snd = -1;
flakes = [];
t = 0;
hot = false;

/// where the pile sits: left edge, above the milestone scale's labels
__pile = function() {
	var _sy = instance_exists(obj_scale_rx) ? obj_scale_rx.seat : room_height - 15;
	return { x : 6, y : _sy - 48 };
};

/// the card's rect this frame - grows out of the pile on oa
__card = function() {
	var _p = __pile();
	var _e = oa * oa * (3 - 2 * oa);
	var _w = round(lerp(PW, CW, _e)), _h = round(lerp(PH, CH, _e));
	var _cx = lerp(_p.x + PW * .5, room_width * .5, _e);
	var _cy = lerp(_p.y + PH * .5, room_height * .5 - 4, _e);
	return { x : round(_cx - _w * .5), y : round(_cy - _h * .5), w : _w, h : _h };
};

/// the symbol grid's top-left inside a card rect
__grid = function(_r) {
	return { x : _r.x + ((_r.w - GW) div 2), y : _r.y + 13 };
};

/// the card's close x (top right of the header)
__xrect = function(_r) {
	return { x : _r.x + _r.w - 10, y : _r.y + 1, w : 9, h : 9 };
};

/// @func __open()
__open = function() {
	ticket_init();
	if (array_length(g.tickets.pile) == 0) return;
	cur = g.tickets.pile[0];
	if (cur.cells == undefined) { cur.cells = array_create(GN * GN, 1); cur.cleared = 0; }
	roll = ticket_roll(cur);
	open = true; held = false; peel = -1; done = false; prize = undefined;
	flakes = [];
	// the pull: the deck's rarity voice
	var _snd = [snd_ability_common, snd_ability_uncommon, snd_ability_rare, snd_ability_epic, snd_ability_legendary];
	play_sound_ext(_snd[clamp(cur.rar, 0, 4)], .95, 1.05, .5, 1);
};

/// @func __close()
/// @desc put it back (the scratch stays on the ticket)
__close = function() {
	if (!open) return;
	open = false; held = false;
	__snd_stop();
	if (done) __finish();
};

/// @func __snd_stop()
/// @desc the scratch loop lets go now (a close, a lift held too long)
__snd_stop = function() {
	if (snd_h >= 0 && audio_is_playing(snd_h)) audio_stop_sound(snd_h);
	snd_h = -1; g.scratch_snd = -1; snd_t = 0;
};

/// @func __finish()
/// @desc the scratched ticket leaves the pile
__finish = function() {
	if (cur != undefined && array_length(g.tickets.pile) > 0 && g.tickets.pile[0] == cur)
		array_delete(g.tickets.pile, 0, 1);
	cur = undefined; roll = undefined; done = false; prize = undefined;
	open = false; held = false;
	save_mark_dirty();
};

/// @func __clear(c, r)
/// @desc one foil cell goes (a flake with it, sometimes)
__clear = function(_c, _r, _gx, _gy) {
	if (_c < 0 || _r < 0 || _c >= GN || _r >= GN) return false;
	var _i = _r * GN + _c;
	if (cur.cells[_i] == 0) return false;
	cur.cells[_i] = 0;
	cur.cleared += 1;
	if (random(1) < .45 && array_length(flakes) < 90) {
		array_push(flakes, { x : _gx + _c * CS + random(CS), y : _gy + _r * CS + random(CS),
			vx : random_range(-.8, .8), vy : random_range(-1.6, -.4), life : 1,
			col : ticket_config().rars[cur.rar].foil });
	}
	return true;
};

/// @func __scratch(x0, y0, x1, y1)
/// @desc the pointer's stroke clears the foil under it (radius 3.2)
__scratch = function(_x0, _y0, _x1, _y1) {
	var _r = __card();
	var _g = __grid(_r);
	var _n = 0;
	var _len = point_distance(_x0, _y0, _x1, _y1);
	var _steps = max(1, ceil(_len / 1.5));
	for (var _s = 0; _s <= _steps; _s++) {
		var _px = lerp(_x0, _x1, _s / _steps), _py = lerp(_y0, _y1, _s / _steps);
		if (_px < _g.x - 5 || _py < _g.y - 5 || _px > _g.x + GW + 5 || _py > _g.y + GW + 5) continue;
		var _c0 = floor((_px - _g.x - 4.5) / CS), _c1 = floor((_px - _g.x + 4.5) / CS);
		var _r0 = floor((_py - _g.y - 4.5) / CS), _r1 = floor((_py - _g.y + 4.5) / CS);
		for (var _rr = _r0; _rr <= _r1; _rr++)
		for (var _cc = _c0; _cc <= _c1; _cc++) {
			var _cx = _g.x + _cc * CS + CS * .5, _cy = _g.y + _rr * CS + CS * .5;
			if (point_distance(_px, _py, _cx, _cy) > 4.5) continue;
			if (__clear(_cc, _rr, _g.x, _g.y)) _n++;
		}
	}
	return _n;
};

/// @func __reveal()
__reveal = function() {
	var _r = __card();
	prize = ticket_pay(cur, roll, _r.x + _r.w * .5, _r.y + 43);
	done = true; done_t = 1.9;
	if (roll.win) play_sound_ext(snd_diamond, .95, 1.1, .6, 1);
	else          play_sound_ext(snd_softclick, .8, .9, .5, 1);
};

/// the odds, as the ticket prints them
__odds = function(_win) {
	switch (_win) {
		case 25: return "1 in 4";
		case 33: return "1 in 3";
		case 50: return "1 in 2";
		case 75: return "3 in 4";
		case 100: return "sure thing";
	}
	return string(_win) + "%";
};

/// @func __symbol(k, x, y, a)
/// @desc a grid symbol, centred: profit disc / credit diamond / flux
///       spark / shard chip / the ticket's own gift box
__symbol = function(_k, _x, _y, _a) {
	switch (_k) {
		case 0:
			draw_set_color(g.profit_color); draw_set_alpha(_a);
			draw_circle(_x, _y, 3 * SY, false);
			break;
		case 1:
			draw_set_color(c_lavender); draw_set_alpha(_a);
			draw_triangle(_x, _y - 4 * SY, _x + 4 * SY, _y, _x, _y + 4 * SY, false);
			draw_triangle(_x, _y - 4 * SY, _x - 4 * SY, _y, _x, _y + 4 * SY, false);
			break;
		case 2:
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 6, _y, 13, 1, 0, c_aqua, _a);
			draw_sprite_ext(spr_pixel_1x1, 0, _x, _y - 6, 1, 13, 0, c_aqua, _a);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y - 3, 7, 1, 0, c_aqua, _a * .6);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 3, _y + 3, 7, 1, 0, c_aqua, _a * .6);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y - 1, 3, 3, 0, c_white, _a);
			break;
		case 3:
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 5, _y - 5, 11, 11, 0, c_horange, _a);
			draw_sprite_ext(spr_pixel_1x1, 0, _x - 2, _y - 2, 5, 5, 0, c_white, _a * .8);
			break;
		default:
			draw_sprite_ext(spr_gift_icon, 0, _x, _y, SY, SY, 0, c_gold, _a);
			break;
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
};
