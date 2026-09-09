/// pure presentation + input: the sim itself (fabricator, automerge,
/// failsafe, gps total) runs globally in syst_tiletimer via
/// tiles_tick(). this drains the engine's events into glow/sounds,
/// handles the drag, and refreshes caches when the board revs.

var _t = g.tiles;

// presentation decay
for (var _i = 0; _i < _t.slots; _i++)
	glow[_i] = max(0, glow[_i] - .04 * delta);

// ---- engine events -> presentation. sounds live HERE on purpose:
// the table stays silent while you're in other rooms ----
while (array_length(_t.ev) > 0) {
	var _e = _t.ev[0];
	array_delete(_t.ev, 0, 1);
	if (_e.i >= 0 && _e.i < _t.slots) glow[_e.i] = (_e.k == "spawn") ? .7 : 1;
	if (_e.k == "spawn") play_sound_ext(snd_apply, .9, 1.1, .25, 1);
	if (_e.k == "merge") {
		play_sound_ext(snd_merge, .8, 1.2, .3, 1);
		if (_e.b) play_sound_ext(snd_tierup, .8, 1.1, .5, 1);
	}
	if (_e.k == "fail") play_sound_ext(snd_tierup, .7, .9, .4, 1);
}

// ---- input (region pattern: fully arbitrated) ----
// ---- THE DRAWER: a swipe RIGHT opens it, a swipe LEFT closes it ----
// The gesture is judged on RELEASE by total travel, which is what keeps
// a drag of a TILE from being read as a swipe: a tile drag ends on a
// slot and travels little, a swipe crosses the room.
dr_open += (dr_want - dr_open) * min(1, .22 * delta);
if (abs(dr_want - dr_open) < .004) dr_open = dr_want;
__reseat();   // a board-size upgrade re-centres the table at once

if (input_free() && (!variable_global_exists("click_owner") || g.click_owner == noone)) {
	// the press only ARMS a swipe if it landed in the RIGHT edge band -
	// or anywhere at all while the drawer is already open, so it can
	// always be pushed back shut. Mirrored with the drawer (his ask):
	// it comes from the right now, so a swipe LEFT pulls it out.
	if (mouse_check_button_pressed(mb_left)) {
		if (mouse_x >= room_width - sw_edge || dr_want > 0) {
			sw_x = mouse_x; sw_y = mouse_y;
		}
		else sw_x = -1;
	}
	if (mouse_check_button_released(mb_left) && sw_x >= 0) {
		var _dx = mouse_x - sw_x;
		var _dy = mouse_y - sw_y;
		if (abs(_dx) >= 40 && abs(_dx) > abs(_dy)) dr_want = (_dx < 0) ? 1 : 0;
		sw_x = -1;
	}
	// and the edge tab is a plain tap, for anyone who would rather not
	// swipe at all
	if (mouse_check_button_pressed(mb_left))
	if (dr_want == 0)
	if (point_in_rectangle(mouse_x, mouse_y, room_width - dr_tab - 2,
		strip_y + strip_h + 24, room_width, strip_y + strip_h + 84)) {
		dr_want = 1;
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
	}
}

// ---- the upgrade quotes, on the slow tick ----
qtic -= delta;
if (qtic <= 0) {
	qtic = 15;
	var _uc2 = tile_upg_config();
	uq = [];
	for (var _k = 0; _k < array_length(_uc2); _k++) {
		var _q2 = tile_upg(_uc2[_k].id, false);
		array_push(uq, { ok : _q2.ok, cost : _q2.cost, lv : _q2.lv,
			txt : crunch_arb(_q2.cost) });
	}
}

// ---- the upgrade buttons. BEFORE the board's own input, because a
// press on the panel must never also be a press on a tile ----
if (input_free())
if (dr_open > .5)
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {
	var _uc3 = tile_upg_config();
	for (var _k = 0; _k < array_length(_uc3); _k++) {
		var _ur2 = __upg_r(_k);
		if (!point_in_rectangle(mouse_x, mouse_y, _ur2.x, _ur2.y,
			_ur2.x + _ur2.w, _ur2.y + _ur2.h)) continue;
		var _r2 = tile_upg(_uc3[_k].id, true);
		if (_r2.ok) {
			qtic = 0;
			play_sound_ext(snd_tierup, .9, 1.1, .5, 1);
			float_text(_ur2.x + _ur2.w * .5, _ur2.y - 6,
				_uc3[_k].name + " up", c_aqua, fnt_outline);
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 1);
		exit;
	}
	// anywhere else on an open drawer swallows the press, so the board
	// underneath never receives it (the drawer is the RIGHT side now)
	if (mouse_x > __dr_face()) exit;
}

if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone) {

	if (mouse_check_button_pressed(mb_left)) {
		// the welcome-back report dismisses on any tap
		if (!is_undefined(_t.report)) _t.report = undefined;

		// back, top right
		if (point_in_rectangle(mouse_x, mouse_y, room_width - 62, 30, room_width - 6, 46)) {
			play_sound_ext(snd_matclick2, .8, .9, .5, 1);
			back_room();
			exit;
		}
		// bottom-left controls: auto merge toggle + sort
		if (point_in_rectangle(mouse_x, mouse_y, 6, 246, 106, 260)) {
			_t.automerge = !_t.automerge;
			save_mark_dirty(); // save-on-mutation law (it persists)
			play_sound_ext(snd_matclick2, 1.0, 1.1, .5, 1);
		}
		if (point_in_rectangle(mouse_x, mouse_y, 112, 246, 172, 260)) {
			tiles_sort();
			play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		}
		// the red one: wipe the table back to a fresh board (timers,
		// bank, stats - everything but the automerge preference)
		// aim anchor toggle (round 2): mouse point vs held-tile center
		if (point_in_rectangle(mouse_x, mouse_y, 244, 246, 334, 260)) {
			g.tiles.aim_center = !g.tiles.aim_center;
			save_mark_dirty();
			play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		}
		if (point_in_rectangle(mouse_x, mouse_y, 178, 246, 238, 260)) {
			for (var _i = 0; _i < _t.slots; _i++) { _t.tier[_i] = 0; glow[_i] = 0; }
			_t.tier[0] = 1;
			_t.tier[1] = 1;
			_t.fab     = 0;
			_t.am_tic  = 0;
			_t.stored  = 0;
			_t.merges  = 0;
			_t.highest = 1;
			_t.report  = undefined;
			_t.ev      = [];
			_t.dirty   = true;
			grab_i  = -1;
			_t.grab = -1;
			save_mark_dirty(); // the wipe is saved state too
			play_sound_ext(snd_matclick2, .5, .6, .6, 1);
		}
		// grab a tile
		var _s = __slot_at(mouse_x, mouse_y);
		if (_s != -1 && _t.tier[_s] != 0 && grab_i == -1) {
			grab_i = _s;
			_t.grab = _s; // the engine keeps its hands off this slot
			gx = __slot_x(_s);
			gy = __slot_y(_s);
			z = 0;
			play_sound_ext(snd_pickupmod, .8, 1.2, .5, 1);
		}
	}

	// debug: middle-click tiers a tile up (kept from Myriad - handy
	// for walking the color/gps ladders without an hour of merging)
	if (mouse_check_button_pressed(mb_middle)) {
		var _s2 = __slot_at(mouse_x, mouse_y);
		if (_s2 != -1 && _t.tier[_s2] != 0) {
			_t.tier[_s2] += 1;
			if (_t.tier[_s2] > _t.highest) _t.highest = _t.tier[_s2];
			_t.dirty = true;
			save_mark_dirty(); // debug or not, it lands in the save
			glow[_s2] = .7;
		}
	}
}

// ---- the ghost rides the mouse; release resolves wherever it lands.
// release is NOT arbitrated on purpose: a held tile must always come
// down, even if a popup opened mid-drag ----
if (grab_i != -1) {
	z  = trickle(z, 3, 5);
	// ⚖️ CENTRED ON THE CURSOR IN BOTH MODES (his correction). I had the
	// "aim: mouse" mode hang the tile off the pointer so the pointer
	// stayed visible as the aim point - which reads exactly as he
	// described it, a tile dangling by its top-left corner.
	//
	// The offset was solving a problem that no longer exists: obj_cursor
	// draws the pointer at depth -20000, above everything including a
	// held tile, so the aim point is visible whatever is under it.
	//
	// And the toggle still MEANS something with both modes centred,
	// because the tile LAGS - it trickles toward the cursor rather than
	// snapping to it. During a fast drag those two points are genuinely
	// apart: "mouse" drops where the pointer is NOW, "tile center" drops
	// where the tile has actually got to. That was the original design
	// and the lag is what makes it real.
	gx = trickle(gx, mouse_x - tw * .5, 5);
	gy = trickle(gy, (mouse_y - th * .5) - z * 2, 5);

	if (!mouse_check_button(mb_left)) {
		var _am = __aim(); // mouse or tile-center, the room's toggle
		var _dst = __slot_at(_am[0], _am[1]);
		var _res = (_dst == -1) ? 0 : tiles_merge(grab_i, _dst);
		// Hot Swap (ability deck, LIVE rule-bender): a mismatched drop
		// SWAPS the two tiles instead of bouncing home. guarded so the
		// tile framework stays independent of the deck
		if (_res == 0 && _dst != -1 && _dst != grab_i && _t.tier[_dst] != 0)
		if (variable_global_exists("ad_hotswap") && g.ad_hotswap == 1) {
			var _tmp = _t.tier[_dst];
			_t.tier[_dst] = _t.tier[grab_i];
			_t.tier[grab_i] = _tmp;
			_t.dirty = true;
			save_mark_dirty(); // save-on-mutation law
			_res = 1; // reads as a move
		}
		if (_res == 0) play_sound_ext(snd_softclick, .9, 1.1, .3, 1); // snaps home
		if (_res == 1) play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		if (_res >= 2) { glow[_dst] = 1; play_sound_ext(snd_merge, .8, 1.2, .4, 1); }
		if (_res == 3) play_sound_ext(snd_tierup, .8, 1.1, .6, 1);
		grab_i = -1;
		_t.grab = -1;
	}
}

// display caches follow the engine's revision counter
if (last_rev != _t.rev) {
	__recache();
	last_rev = _t.rev;
}
