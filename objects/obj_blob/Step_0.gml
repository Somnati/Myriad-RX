if (s == undefined) { instance_destroy(); exit; }
if (!in_room(rm_clicker)) { instance_destroy(); exit; }
// away on an expedition: the body is not in the room (the card and
// the bubble go with it - __draw_over checks visible)
// THE TILE CREW (sprite_room): a fab or merge sprite lives in the tile
// panel - its body shows only while the panel is up, over the board
// (-512: above the board at -510, under the menu's blur at -515),
// and its taps charge the fabricator there. Hidden, sprites_tick
// works it headless
tile_room = (sprite_room(s[$ "job"] ?? "tap") == "tiles");
var _panel = instance_exists(syst_tiles) && syst_tiles.oa > .5 && !syst_tiles.closing;
visible = !(s[$ "trip"] ?? false) && (!tile_room || _panel);
depth = tile_room ? -512 : -60;   // over the board (-510), UNDER the menu's second blur (-515) and the drawer (-520) - his report: they stayed sharp
if (!visible) exit;

var _pl = sprite_personalities();
var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];

// ---- the clocks ----
sq    = max(0, sq - .09 * delta);
hop   = max(0, hop - .35 * delta);
happy = max(0, happy - delta);
bub_t = max(0, bub_t - delta);
// the line it would say drifts on its own clock (see the Create)
bub_next -= delta;
if (bub_next <= 0) {
	bub_next = random_range(240, 720);
	bub_cur = _p.lines[irandom(array_length(_p.lines) - 1)];
}
// the card fades toward its state; a press anywhere NOT on this sprite
// closes it (his report: they lingered)
card_a = trickle(card_a, card_open ? 1 : 0, 4, 0);
if (card_open && mouse_check_button_pressed(mb_left) && !__hit(mouse_x, mouse_y)) card_open = false;
bob  += 2.2 * delta;
blink = max(0, blink - delta);
blink_t -= delta;
if (blink_t <= 0) { blink = 6; blink_t = random_range(90, 260); }
// the pupils follow the pointer, a px either way
look_x = lerp(look_x, clamp((mouse_x - x) / 40, -1, 1), .15 * delta);
look_y = lerp(look_y, clamp((mouse_y - (y - r)) / 40, -1, 1), .15 * delta);

// ---- the poke, before the state: a press on it is its own ----
// (the tile crew lives under the panel's overlay rung - his report: not
// clickable there - so it asks at that rung; the room's crew at the floor)
if (input_free(tile_room ? ui_layer_overlay : 0) && (!variable_global_exists("click_owner") || g.click_owner == noone))
if (mouse_check_button_pressed(mb_left) && __hit(mouse_x, mouse_y)) __poke();

// A YOUNG ONE trails its keeper (2026-09-16): its body small, its wander target beside the keeper's blob when that is in the room
var _yng = s[$ "young"];
r = is_struct(_yng) ? 3.4 : 5;
if (is_struct(_yng) && !s.asleep) {
	var _kb = noone;
	with (obj_blob) if (sid == other.s.young.parent) _kb = id;
	if (_kb != noone) { st = 1; st_t = max(st_t, 30); tx = _kb.x + follow_dx; ty = _kb.y + follow_dy; }
}
// ---- the loop ----
if (s.asleep) { st = 3; }
else {
	if (st == 3) { st = 0; st_t = 30; }
	st_t -= delta;
	if (st == 1) {
		// walk to the target, then stand there until the slot ends
		var _d = point_distance(x, y, tx, ty);
		if (_d >= 1.5) {
			var _spd = .35 * _p.pace * delta;
			x += (tx - x) / _d * _spd;
			y += (ty - y) / _d * _spd;
		}
		if (st_t <= 0) __next_state();
	} else if (st == 2) {
		// working: a tap on its cadence, a hop with each. The cadence is
		// sprite_rate's pace TERM FOR TERM - personality pace x the rarity
		// pace - or the room's sprite and the headless one disagree, and
		// watching it changes what it earns (the sprites twin's one law;
		// 2026-09-12: the rarity factor was missing here, an ultimate
		// tapped x1.84 slower on screen than off it)
		tap_t -= delta * _p.pace * (1 + SPRITE_RAR_PACE * (s[$ "rar"] ?? 0));
		if (tap_t <= 0) {
			tap_t = SPRITE_TAP_T * 60;
			sq = .8; hop = 3;
			var _job = s[$ "job"] ?? "tap";
			if (_job == "tap") {
				tap_fire(1, x, y - r, true, true, false);
				sprite_voice(s, "tap");
				s.taps += 1;
			}
			// the tile crew: the hop and the squeak are the same, and the tap
			// CHARGES its bar by its bonus (his ask, 2026-09-13 - DE's merge
			// charge): SPRITE_FAB_TAP x (1 + rarity) of a full bar
			else if (_job == "fab" || _job == "merge") {
				var _fr = sprite_fab_frac(s);
				if (_job == "fab") tiles_fab_charge(_fr); else tiles_merge_charge(_fr);
				sprite_voice(s, "tap");
				// the tap's own particles (his ask): the effect at the sprite, and
				// motes flying to the bar it charged - the fill's leading edge
				if (instance_exists(syst_tiles)) {
					var _bx = room_width * clamp(g.tiles.fab / max(1, g.tiles.fab_t), 0, 1);
					var _by = syst_tiles.bar_y + ((_job == "fab") ? 1 : 4);
					bezier_bits(x, y - r, 3, s.col, _bx, _by, 0, 0, -1, 1, "tile", -545);
					tapfx_fire(x, y - r, false, 1);
				}
				s.taps += 1;
			}
			// (the dials' and the autotapper's staff hop for show - their work is a rate)
		}
		if (st_t <= 0) __next_state();
	} else {
		if (st_t <= 0) __next_state();
	}
}

// stay in its patch, and remember where it stands
var _b = __bounds();
x = clamp(x, _b.x1, _b.x2);
y = clamp(y, _b.y1, _b.y2);
if (tx > _b.x2 || tx < _b.x1) __wander_to();   // a target the patch no longer holds (the drawer came out over it)
// OFF THE TABLE (his ask): a body that finds itself on the board - it
// arrived there from the money room's seat, or the board grew under it
// - is walked straight off to the nearest edge, and its wander target
// re-rolled off it too
if (tile_room && instance_exists(syst_tiles)) {
	var _rows = ceil(g.tiles.slots / g.tiles.cols);
	var _kx1 = syst_tiles.bx - 10, _ky1 = syst_tiles.by - 10;
	var _kx2 = syst_tiles.bx + g.tiles.cols * syst_tiles.pw + 6, _ky2 = syst_tiles.by + _rows * syst_tiles.ph + 6;
	if (point_in_rectangle(x, y, _kx1, _ky1, _kx2, _ky2)) {
		var _dl = x - _kx1, _dr = _kx2 - x, _dt = y - _ky1, _db = _ky2 - y;
		var _m = min(_dl, _dr, _dt, _db);
		var _spd = 1.2 * delta;
		if (_m == _dl) x -= _spd; else if (_m == _dr) x += _spd; else if (_m == _dt) y -= _spd; else y += _spd;
		if (point_in_rectangle(tx, ty, _kx1, _ky1, _kx2, _ky2)) __wander_to();
	}
}
s.fx = x / room_width;
s.fy = y / room_height;
