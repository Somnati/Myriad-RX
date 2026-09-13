// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
// THE TILE TOWER rides the header menu up the left edge (his ask,
// 2026-09-13; obj_tile_tower): made when the drawer comes out here,
// landscape only; it leaves on its own when either goes
if (room_width > 300 && instance_exists(syst_menu2) && !instance_exists(obj_tile_tower) && !closing)
	create_obj(0, 0, obj_tile_tower);
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }   // the proxies die with their owner
if (__in() && keyboard_check_pressed(vk_escape)) { tiles_close(); exit; }

/// pure presentation + input: the sim itself (fabricator, automerge,
/// failsafe, gps total) runs globally in syst_tiletimer via
/// tiles_tick(). this drains the engine's events into glow/sounds,
/// handles the drag, and refreshes caches when the board revs.

var _t = g.tiles;
__grow();   // a slot bought since last frame (see the Create)

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
	// ⚖️ snd_tierup IS THE +2 SOUND AND NOTHING ELSE (his report: "i can
	// hear a little ding noise when i merge and that sound is supposed
	// to only play when a tier up+2 triggers"). DE settles it -
	// merge_mods.gml plays snd_merge on every merge and snd_tierup only
	// `if _uptier = true`. RX had it on the bonus correctly but ALSO on
	// the deadlock failsafe and on an upgrade purchase, so the ding had
	// stopped meaning anything by the time a real +2 landed.
	if (_e.k == "merge") {
		// the combo's pitch (see __merge_pitch): DE's .8..1.2 roll, lifted
		// a semitone per consecutive climb
		var _mp = __merge_pitch(_t.tier[_e.i]);
		play_sound_ext(snd_merge, .8 * _mp, 1.2 * _mp, .3, 1);
		// a few shards off EVERY merge (his trial, 2026-09-10: the tier-up
		// throws six; he wants to see the plain ones throw too)
		if (_e.i >= 0 && _e.i < _t.slots)
			spark_burst(__slot_x(_e.i) + tw * .5, __slot_y(_e.i) + th * .5, 3,
				tile_color(_t.tier[_e.i]));
		if (_e.b) {
			play_sound_ext(snd_tierup, .8, 1.1, .5, 1);
			__tierup_fx(_e.i);
		}
	}
	// the failsafe tiers the lowest tile to break a deadlock - a merge
	// the BOARD made, not you. Same sound family, pitched well under the
	// player's own merges so it reads as the table shifting by itself.
	if (_e.k == "fail") play_sound_ext(snd_merge, .55, .65, .35, 1);
	// a DUPLICATE dropped out of the fabricator (the duplication row):
	// the spawn sound again, a shade higher - two of the same cue, for
	// two of the same tile. No slot to glow: it is in the hopper.
	if (_e.k == "dup") play_sound_ext(snd_apply, 1.15, 1.3, .3, 1);
	// a sprite's charge: the meter grows to it (bar_adj) and flashes
	if (_e.k == "charge")  { bar_adj = 30; bar_glow = 1; }
	if (_e.k == "mcharge") { am_glow = 1; }
}

arm_rb = max(0, arm_rb - delta);   // the rebirth confirm's window
arm_rs = max(0, arm_rs - delta);   // the board reset's
arm_ru = max(0, arm_ru - delta);   // the upgrade reset's

// ---- input (region pattern: fully arbitrated) ----
// ---- THE DRAWER: a swipe LEFT opens it, a swipe RIGHT closes it ----
// Two things decide whether a gesture is the drawer's: WHERE THE PRESS
// LANDED (below) and WHETHER IT WAS A FLICK (DE's gate, further down).
// The old rule judged travel on release, and a tile dragged two
// columns travels 68px - so merging closed the drawer (his report).
dr_open += (dr_want - dr_open) * min(1, .22 * delta);
if (abs(dr_want - dr_open) < .004) dr_open = dr_want;
dbg_open += (dbg_want - dbg_open) * min(1, .22 * delta);
if (abs(dbg_want - dbg_open) < .004) dbg_open = dbg_want;
__reseat();   // a board-size upgrade re-centres the table at once

if (__in() && (!variable_global_exists("click_owner") || g.click_owner == noone)) {
	// ⚖️ WHERE THE PRESS LANDED ARMS THE SWIPE, OR REFUSES IT.
	//   on an occupied slot    never - that press is a tile's, and the
	//                          gate below refuses the whole press while
	//                          a tile is held (his rule, 2026-09-10:
	//                          "if im holding a tile at all cancel the
	//                          swipe until my finger releases")
	//   in the right edge band the OPEN swipe, drawer closed
	//   anywhere, drawer open  the CLOSE swipe - his ask to bring it
	//                          back from anywhere; empty slots and
	//                          gutters included, since those presses
	//                          hold nothing
	// Mirrored with the drawer (his ask): it comes from the right, so
	// a swipe LEFT pulls it out and a swipe RIGHT pushes it back.
	if (mouse_check_button_pressed(mb_left)) {
		sw_x = -1;
		var _s0 = __slot_at(mouse_x, mouse_y);
		var _on_tile = (_s0 != -1 && _t.tier[_s0] != 0);
		if (!_on_tile) {
			if (dr_want == 0 && mouse_x >= room_width - sw_edge) { sw_x = mouse_x; sw_y = mouse_y; }
			// (swipe protection, settings > input: the close swipe starts
			// on the drawer's own side or not at all)
			if (dr_want >  0 && (!(variable_global_exists("swipe_protect") && g.swipe_protect)
			                     || mouse_x >= __dr_face() - 24))    { sw_x = mouse_x; sw_y = mouse_y; }
		}
	}
	// A HELD TILE CANCELS THE PRESS AS A SWIPE, for the rest of the
	// press - not merely "this frame does not fire": once the hand has
	// a tile, nothing it does until it lets go is a gesture at the
	// drawer, so the arm is dropped and only a new press can re-arm
	if (grab_i != -1) sw_x = -1;
	// nor a window that just moved or resized under the pointer
	// (syst_touchscreen's hold - the fullscreen swap)
	if (touch_jump > 0) sw_x = -1;
	// ⚖️ DE's GATE, the dial drawer's port (his list: speed limits,
	// touch bounds, a hold limit that cancels the swipe). Fires WHILE
	// HELD the moment the gesture qualifies; sw_tic keeps one gesture
	// from re-firing. A held TILE can never be a swipe, whatever the
	// press did - the second lock on the same door.
	//   touch_dragdist > SW_DIST_MIN          a twitch is not a swipe
	//   touch_dragdist < touch_dragdist_min   a long haul is not either
	//   touch_time     < touch_time_min       held too long: cancelled
	//   touch_dragspd  > touch_dragspd_min    slow is not a swipe
	//   direction cone +/-45 of the axis      a diagonal is not one
	sw_tic = max(0, sw_tic - delta);
	if (sw_x >= 0 && grab_i == -1 && sw_tic <= 0)
	if (touching_screen || mouse_check_button_released(mb_left))
	if (touch_dragdist > SW_DIST_MIN)
	if (touch_dragdist < touch_dragdist_min)
	if (touch_time    < touch_time_min)
	if (touch_dragspd > touch_dragspd_min) {
		var _d = touch_dir;
		if (dr_want == 0 && _d >= 135 && _d <= 225) {   // LEFT: pull it out
			dr_want = 1; sw_tic = SW_COOL; sw_x = -1;
			play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		}
		else if (dr_want > 0 && (_d <= 45 || _d >= 315)) {   // RIGHT: push it shut
			dr_want = 0; sw_tic = SW_COOL; sw_x = -1;
			dp_x = -1;   // the press became a swipe - it is not a tap any more
			play_sound_ext(snd_softclick, .9, 1, .4, 1);
		}
	}
	if (mouse_check_button_released(mb_left)) sw_x = -1;
	// and the edge tab is a plain tap, for anyone who would rather not
	// swipe at all
	if (mouse_check_button_pressed(mb_left))
	if (dr_want == 0)
	if (point_in_rectangle(mouse_x, mouse_y, __dr_tab_r().x - 1,
		__dr_tab_r().y, room_width, __dr_tab_r().y + __dr_tab_r().h)) {
		dr_want = 1;
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
	}
}

// the buy-amount button's pressed face, while the finger is on it (the
// dial drawer's bb_down) - a look, not an input; the tap lands on release
var _bbr = __bb_r();
bb_down = (dr_open > .5) && mouse_check_button(mb_left)
	&& point_in_rectangle(mouse_x, mouse_y, _bbr.x, _bbr.y, _bbr.x + _bbr.w, _bbr.y + _bbr.h);

// ---- the upgrade quotes, on the slow tick ----
qtic -= delta;
if (qtic <= 0) {
	qtic = 15;
	var _rw2 = __rows();
	uq = [];
	for (var _k = 0; _k < array_length(_rw2); _k++) {
		// a flux row: one level, priced in flux (tile_fupg)
		if (_rw2[_k].cur == "flux") {
			var _fq = tile_fupg(_rw2[_k].cfg.id, false);
			array_push(uq, { ok : _fq.ok, cost : _fq.cost, lv : _fq.lv, max : _fq.max, n : 1,
				txt : _fq.max ? "maxed" : (string(_fq.cost) + " flux") });
			continue;
		}
		// the bulk quote: cost is the TOTAL for however many the buy
		// mode would take right now, and n says how many that is
		var _q2 = tile_upg_bulk(_rw2[_k].cfg.id, false);
		var _mx2 = _q2[$ "max"] ?? false;
		var _txt2 = "maxed";
		if (!_mx2) {
			_txt2 = crunch_arb(_q2.cost);
			// a mode above x1 says how many the price is for - the whole
			// bundle, affordable or not (tile_upg_bulk: the dial
			// drawer's contract). "max" says how many it found.
			if (g.tile_buy_lv != 1) _txt2 = "x" + string(_q2.n) + "  " + _txt2;
		}
		array_push(uq, { ok : _q2.ok, cost : _q2.cost, lv : _q2.lv,
			max : _mx2, n : _q2.n, txt : _txt2 });
	}
}

// ---- the upgrade buttons. BEFORE the board's own input, because a
// press on the panel must never also be a press on a tile ----
// ⚖️ ON RELEASE, UNDER DR_BUDGET (his report: swiping the drawer shut
// bought upgrades). The press only REMEMBERS where it landed - and
// swallows itself so the board never sees it; the tap happens when the
// finger comes up within a few px of that spot, tested at the PRESS
// point (where they aimed), and only if the swipe gate did not take
// the press first. See the Create.
if (__in())
if (dr_open > .5)
if (!variable_global_exists("click_owner") || g.click_owner == noone) {
	if (mouse_check_button_pressed(mb_left) && mouse_x > __dr_face()) {
		dp_x = mouse_x; dp_y = mouse_y;
		exit;   // the press is the drawer's - the board underneath never receives it
	}
}
// (a separate block, not an early exit: the frames with no release
// must fall through to the board, the quote tick and the recache)
if (__in())
if (dr_open > .5)
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_released(mb_left) && dp_x >= 0) {
	var _tpx = dp_x, _tpy = dp_y;
	dp_x = -1;
	if (point_distance(_tpx, _tpy, mouse_x, mouse_y) > DR_BUDGET) exit;

	// the close chip, first of all: a plain tap shuts the drawer, for
	// anyone who would rather not swipe near a board (his report)
	var _cx2 = __cx_r();
	if (point_in_rectangle(_tpx, _tpy, _cx2.x, _cx2.y,
		_cx2.x + _cx2.w, _cx2.y + _cx2.h)) {
		dr_want = 0;
		sw_x = -1;
		play_sound_ext(snd_softclick, .9, 1, .4, 1);
		exit;
	}
	// the tabs: shards / flux
	for (var _tk = 0; _tk < 2; _tk++) {
		var _tr2 = __tab_r(_tk);
		if (point_in_rectangle(_tpx, _tpy, _tr2.x, _tr2.y, _tr2.x + _tr2.w, _tr2.y + _tr2.h)) {
			__tab_set(_tk);
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			exit;
		}
	}
	// the buy-amount button - it sits above the rows and a tap on it
	// must never also land on one (the shard tab's alone)
	var _bb2 = __bb_r();
	if (upg_tab == 0 && point_in_rectangle(_tpx, _tpy, _bb2.x, _bb2.y,
		_bb2.x + _bb2.w, _bb2.y + _bb2.h)) {
		__bb_cycle();
		qtic = 0;   // requote at the new amount at once
		play_sound_ext(snd_matclick, .95, 1.05, .35, 1);
		exit;
	}

	var _rw3 = __rows();
	for (var _k = 0; _k < array_length(_rw3); _k++) {
		// the COST BAR is the target, not the row (his ask) - see
		// __upg_btn_r; the float still rises off the row. A folded row
		// (a whisper) sells nothing
		if (!__upg_live(_k)) continue;
		var _ur2 = __upg_r(_k);
		var _ub2 = __upg_btn_r(_k);
		if (!point_in_rectangle(_tpx, _tpy, _ub2.x, _ub2.y,
			_ub2.x + _ub2.w, _ub2.y + _ub2.h)) continue;
		var _uc3 = [];
		for (var _q3 = 0; _q3 < array_length(_rw3); _q3++) array_push(_uc3, _rw3[_q3].cfg);
		var _r2 = (_rw3[_k].cur == "flux") ? tile_fupg(_rw3[_k].cfg.id, true) : tile_upg_bulk(_rw3[_k].cfg.id, true);
		if (_r2.ok) {
			qtic = 0;
			// the house purchase sound (upgrade_buy's), not the tier-up
			// ding - see the event drain at the top of this file
			play_sound_ext(snd_diamond, .95, 1.05, .5, 2);
			// THE BUY LANDS IN THE ROW (his report, 2026-09-11: "not
			// satisfying"): the row flashes its colour, the level pops,
			// sparks leave the bar in the row's colour, and the float
			// says what it bought
			var _rc2 = (_rw3[_k].cur == "flux") ? merge_colour(c_hred, c_white, .25) : __upg_col(_uc3[_k].id);
			while (array_length(uflash) <= _k) array_push(uflash, 0);
			while (array_length(upop)   <= _k) array_push(upop, 1);
			uflash[_k] = 14;
			upop[_k]   = 1.45;
			spark_burst(_ub2.x + _ub2.w * .5, _ub2.y + _ub2.h * .5, 8, _rc2);
			float_text(_ur2.x + _ur2.w * .5, _ur2.y - 6,
				_uc3[_k].name + (((_r2[$ "n"] ?? 1) > 1) ? (" +" + string(_r2.n)) : " up"),
				_rc2, fnt_outline);
		} else play_sound_ext(snd_matclick2, .7, .8, .35, 1);
		exit;
	}
	// ---- the table's own rebirth ----
	// ⚖️ TWO PRESSES, and it is the only control in this drawer that
	// asks for one. Everything else here is a purchase you can make
	// again next minute; this one throws the board away. arm_rb holds
	// the confirm for a couple of seconds and the button says so, which
	// is DE's own two-tap scrap pattern rather than a modal nobody
	// reads.
	var _rr3 = __rb_r();
	if (point_in_rectangle(_tpx, _tpy, _rr3.x, _rr3.y,
		_rr3.x + _rr3.w, _rr3.y + _rr3.h)) {
		var _rc3 = tile_rebirth_calc();
		if (!_rc3.can) {
			play_sound_ext(snd_matclick2, .7, .8, .35, 1);
		} else if (arm_rb > 0) {
			arm_rb = 0;
			var _got = tile_rebirth_do();
			if (_got > 0) {
				qtic = 0;   // the levels are gone - requote before the next draw
				play_sound_ext(snd_rebirthcollect, .9, 1.1, .7, 2);
				float_text(float_x, float_y, "+" + crunch_arb(arb(_got)) + " flux",
					c_hred, fnt_outline);
			}
		} else {
			arm_rb = 120;   // two seconds to mean it
			play_sound_ext(snd_tierup, .8, .9, .5, 1);
		}
		exit;
	}

	// (anywhere else on the drawer: a tap on nothing)
}

if (__in())
if (!variable_global_exists("click_owner") || g.click_owner == noone) {

	if (mouse_check_button_pressed(mb_left)) {
		// the welcome-back report dismisses on any tap
		if (!is_undefined(_t.report)) _t.report = undefined;

		// (no back hit test: the button is gone - the header's burger is
		// how every other room in the game is left)

		// ---- THE DEBUG DRAWER: the chip opens and closes it ----
		var _dc = __dbg_chip();
		if (point_in_rectangle(mouse_x, mouse_y, _dc.x, _dc.y, _dc.x + _dc.w, _dc.y + _dc.h)) {
			dbg_want = 1 - dbg_want;
			play_sound_ext(snd_softclick, dbg_want ? 1 : .9, dbg_want ? 1.1 : 1, .4, 1);
			exit;
		}
		// its rows, only while it is out; a press anywhere on the panel
		// is the panel's (the board behind it never sees it)
		var _dhit = -1;
		if (dbg_open > .5) {
			for (var _k = 0; _k < array_length(dbg_rows); _k++) {
				var _dr = __dbg_r(_k);
				if (point_in_rectangle(mouse_x, mouse_y, _dr.x, _dr.y, _dr.x + _dr.w, _dr.y + _dr.h)) _dhit = _k;
			}
		}
		if (_dhit == 0) {   // auto merge
			_t.automerge = !_t.automerge;
			save_mark_dirty(); // save-on-mutation law (it persists)
			play_sound_ext(snd_matclick2, 1.0, 1.1, .5, 1);
		}
		if (_dhit == 1) {   // sort
			tiles_sort();
			play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		}
		if (_dhit == 2) {   // aim anchor (round 2): mouse point vs held-tile centre
			g.tiles.aim_center = !g.tiles.aim_center;
			save_mark_dirty();
			play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		}
		// THE RED ONE: the whole table back to nothing - board, hopper,
		// SHARDS, UPGRADES, FLUX, the lot (his report, 2026-09-10: it
		// used to clear the tiles and leave 136m shards and thirteen
		// levels standing; then "flux needs reset too"). tiles_wipe is
		// the one list, shared with the rebirth; this button passes
		// fresh = true and pays nothing. Two presses two seconds apart,
		// the rebirth's rule, because it throws away everything the
		// table has ever paid.
		if (_dhit == 3) {
			if (arm_rs > 0) {
				arm_rs = 0;
				tiles_wipe(true);    // FRESH: flux and the rebirth count too
				_t.tier[0] = 1;      // DE's fresh board: two starters
				_t.tier[1] = 1;
				_t.dirty = true;
				for (var _i = 0; _i < _t.slots; _i++) glow[_i] = 0;
				grab_i = -1;
				qtic = 0;            // the levels are gone - requote at once
				save_mark_dirty();   // the wipe is saved state too
				play_sound_ext(snd_matclick2, .5, .6, .6, 1);
			} else {
				arm_rs = 120;        // two seconds to mean it
				play_sound_ext(snd_tierup, .8, .9, .5, 1);
			}
		}
		// THE SECOND RESET (his ask, same day): the upgrade levels alone,
		// no refund, board and shards and flux untouched - for running a
		// cost ladder again against a board that already exists. Asked
		// twice like its neighbour.
		if (_dhit == 4) {
			if (arm_ru > 0) {
				arm_ru = 0;
				tile_upg_reset();
				qtic = 0;            // the levels are gone - requote at once
				save_mark_dirty();
				play_sound_ext(snd_matclick2, .5, .6, .6, 1);
			} else {
				arm_ru = 120;
				play_sound_ext(snd_tierup, .8, .9, .5, 1);
			}
		}
		// a press on the open panel is spent, whatever it landed on
		if (dbg_open > .5 && mouse_x < __dbg_x() + dbg_w && mouse_y >= dr_top) exit;
		// the sort button (DE's, under the info box)
		var _sr = __sort_r();
		if (point_in_rectangle(mouse_x, mouse_y, _sr.x, _sr.y, _sr.x + _sr.w, _sr.y + _sr.h)) {
			tiles_sort();
			sort_glow = .6;
			play_sound_ext(snd_apply, .9, 1.1, .5, 1);
			exit;
		}
		// grab a tile
		var _s = __slot_at(mouse_x, mouse_y);
		if (_s != -1 && _t.tier[_s] != 0 && grab_i == -1) {
			grab_i = _s;
			_t.grab = _s; // the engine keeps its hands off this slot
			gx = __slot_x(_s);
			gy = __slot_y(_s);
			// caught mid-glide: the hand takes it from where it is
			if (_s == ret_i) { gx = ret_x; gy = ret_y; ret_i = -1; }
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
	// ⚖️ THE LIFT IS WHAT SITS IT ABOVE THE CURSOR, and it belongs to
	// ONE mode (his report: "both options have it sitting in the same
	// spot which is slightly above the mouse"). z trickles to 3, so
	// `- z * 2` was raising the tile 6px in BOTH modes - which made the
	// toggle invisible AND made "aim: mouse" lie, because the pointer
	// was the drop point while the tile floated somewhere else.
	//
	//   aim: mouse   - dead centre on the cursor. The tile IS the
	//                  pointer, so what you see is where it lands.
	//   aim: tile    - keeps the 6px lift. Here the TILE's centre is
	//                  the drop point, so raising it off the cursor is
	//                  honest: it shows you the aim point is not where
	//                  you are pointing.
	//
	// The two modes now look different at rest, which is the least a
	// toggle can do. The shadow (Draw, gy + 4 + z) reads as the height
	// either way.
	var _lift = g.tiles.aim_center ? z * 2 : 0;
	gx = trickle(gx, mouse_x - tw * .5, 5);
	gy = trickle(gy, (mouse_y - th * .5) - _lift, 5);

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
			var _tms = _t.skin[_dst];
			_t.skin[_dst] = _t.skin[grab_i];
			_t.skin[grab_i] = _tms;
			_t.dirty = true;
			save_mark_dirty(); // save-on-mutation law
			_res = 1; // reads as a move
		}
		if (_res == 0) play_sound_ext(snd_softclick, .9, 1.1, .3, 1); // snaps home
		if (_res == 1) play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		if (_res >= 2) {
			glow[_dst] = 1;
			var _mp2 = __merge_pitch(_t.tier[_dst]);
			play_sound_ext(snd_merge, .8 * _mp2, 1.2 * _mp2, .4, 1);
			// (the plain merge's shards - see the event handler above)
			spark_burst(__slot_x(_dst) + tw * .5, __slot_y(_dst) + th * .5, 3,
				tile_color(_t.tier[_dst]));
		}
		if (_res == 3) { play_sound_ext(snd_tierup, .8, 1.1, .6, 1); __tierup_fx(_dst); }
		// a bounce or a move: the ghost glides to the slot it belongs
		// to now (see ret_i in the Create); a merge just lands
		if (_res == 0 || _res == 1) {
			ret_i = (_res == 0) ? grab_i : _dst;
			ret_x = gx; ret_y = gy;
			ret_x0 = gx; ret_y0 = gy;
			// ⚖️ ON A CLOCK, NOT A TRICKLE (his report, 2026-09-10: a tile
			// released far off the table kept its held look too long).
			// trickle approaches its target asymptotically, so a long
			// glide spent its last frames creeping the final pixel with
			// the ghost's brighter shade and shadow still on - it read
			// as still held. The glide runs for ret_n frames, a little
			// longer for a longer trip, and LANDS on the last one.
			ret_t = 0;
			ret_n = clamp(8 + point_distance(gx, gy, __slot_x(ret_i), __slot_y(ret_i)) / 14, 10, 20);
			_t.grab = ret_i;   // still the hand's until it lands
		} else _t.grab = -1;
		// the put-down tile is not "hovered" just because the pointer is
		// still over it (see hov_mute)
		hov_mute = (_res == 0) ? grab_i : ((_res == 1) ? _dst : -1);
		grab_i = -1;
	}
}

// the hover mute lifts once the pointer has left that slot
if (hov_mute != -1 && __slot_at(mouse_x, mouse_y) != hov_mute) hov_mute = -1;

// ---- the glide home (see ret_i in the Create) ----
if (ret_i != -1) {
	if (ret_i >= _t.slots || _t.tier[ret_i] == 0) { ret_i = -1; if (grab_i == -1) _t.grab = -1; }
	else {
		var _hx = __slot_x(ret_i), _hy = __slot_y(ret_i);
		ret_t = min(1, ret_t + delta / ret_n);
		var _q = 1 - ret_t;
		var _e = 1 - _q * _q * _q;                  // ease out: quick off the hand, soft landing
		ret_x = lerp(ret_x0, _hx, _e);
		ret_y = lerp(ret_y0, _hy, _e);
		if (ret_t >= 1) {
			ret_i = -1;
			if (grab_i == -1) _t.grab = -1;
		}
	}
}

// display caches follow the engine's revision counter
if (last_rev != _t.rev) {
	__recache();
	last_rev = _t.rev;
}
