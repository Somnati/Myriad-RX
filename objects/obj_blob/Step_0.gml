if (s == undefined) { instance_destroy(); exit; }
if (!in_room(rm_clicker)) { instance_destroy(); exit; }
// away on an expedition: the body is not in the room (the card and
// the bubble go with it - __draw_over checks visible)
// THE TILE CREW (sprite_room): a fab or merge sprite lives in the tile
// panel - its body shows only while the panel is up, over the board
// (-530: above the board at -510, under the panel's drawer at -560),
// and its taps charge the fabricator there. Hidden, sprites_tick
// works it headless
tile_room = (sprite_room(s[$ "job"] ?? "tap") == "tiles");
var _panel = instance_exists(syst_tiles) && syst_tiles.oa > .5 && !syst_tiles.closing;
visible = !(s[$ "trip"] ?? false) && (!tile_room || _panel);
depth = tile_room ? -530 : -60;
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
if (input_free() && (!variable_global_exists("click_owner") || g.click_owner == noone))
if (mouse_check_button_pressed(mb_left) && __hit(mouse_x, mouse_y)) __poke();

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
				var _fr = SPRITE_FAB_TAP * (1 + (s[$ "rar"] ?? 0));
				if (_job == "fab") tiles_fab_charge(_fr); else tiles_merge_charge(_fr);
				sprite_voice(s, "tap");
				spark_burst(x, y - r, 2, s.col);
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
s.fx = x / room_width;
s.fy = y / room_height;
