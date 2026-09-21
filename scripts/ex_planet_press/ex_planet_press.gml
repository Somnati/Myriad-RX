/// @description ex_planet_press(e) -> true when the press is taken (the old exit): THE PLANET PAGE's presses - the drawer's tab and rows, the region's buttons, the hand's cards, a tap on the world, [galaxy] / [star system] / [bestiary] (syst_exped_panel's Step, after its press gate, q219; self = the panel; e = g.exped)
function ex_planet_press(_e) {
	if (view != "planet") return false;
	if (rg_leave) return true;   // (region mode is swinging out: nothing to press until it has)
	// [galaxy]: the star map
	var _gl = __galaxy_r();
	if (point_in_rectangle(mouse_x, mouse_y, _gl.x, _gl.y, _gl.x + _gl.w, _gl.y + _gl.h)) {
		gx_from = "planet"; __page_go("galaxy");
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		return true;
	}
	// [star system] (2026-09-16): the demo's view of this world's system
	var _syr = __system_r();
	if (point_in_rectangle(mouse_x, mouse_y, _syr.x, _syr.y, _syr.x + _syr.w, _syr.y + _syr.h)) {
		__sy_enter(galaxy_world_sys(pl_dest).star); sy_from = "planet"; __page_go("system");
		play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
		return true;
	}
	// REGION MODE (his ask: no separate window - the camera pulls in, the
	// info box left): [quests] / [explore] bottom right deal THE HAND (the
	// cards pick the departure); [map] is in the strip (2026-09-16)
	if (pv_mode == "region") {
		// THE INFLUENCE VIEW (q270): open, a tap anywhere closes it; the button toggles it
		if (rg_infl) {
			// A TAB'S TAP switches (q286); any other closes
			for (var _tbi = 0; _tbi < array_length(rg_infl_tabs); _tbi++) {
				var _tbr = rg_infl_tabs[_tbi];
				if (point_in_rectangle(mouse_x, mouse_y, _tbr.x, _tbr.y, _tbr.x + _tbr.w, _tbr.y + _tbr.h)) { rg_infl_tab = _tbr.name; rg_infl_scroll = 0; play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1); return true; }
			}
			rg_infl = false; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true;
		}
		var _ifb = __infl_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ifb.x, _ifb.y, _ifb.x + _ifb.w, _ifb.y + _ifb.h)) { rg_infl = true; rg_infl_scroll = 0; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; }
		var _ibr = __rg_banner_r();
		if (point_in_rectangle(mouse_x, mouse_y, _ibr.x, _ibr.y, _ibr.x + _ibr.w, _ibr.y + _ibr.h)) { rg_box_open = !rg_box_open; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }   // (the fold, 2026-09-16)
		var _qb = __quests_r();
		if (point_in_rectangle(mouse_x, mouse_y, _qb.x, _qb.y, _qb.x + _qb.w, _qb.y + _qb.h)) { __hand_open("quests"); return true; }
		var _xb = __explore_r();
		if (point_in_rectangle(mouse_x, mouse_y, _xb.x, _xb.y, _xb.x + _xb.w, _xb.y + _xb.h)) { __hand_open("explore"); return true; }
		return true;
	}
	// [view region]: the pull-in (region mode) on the picked one
	if (pl_focus >= 0 && !__nolanding(pl_dest)) {
		var _vr = __view_rg_r();
		if (point_in_rectangle(mouse_x, mouse_y, _vr.x, _vr.y, _vr.x + _vr.w, _vr.y + _vr.h)) {
			__rg_enter();
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	// the drawer's tab: open / close
	var _tb = __pv_tab_r();
	if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
		pv_dw = !pv_dw;
		play_sound_ext(snd_softclick, .95, 1.05, .4, 1);
		return true;
	}
	// a region row (the drawer open): the camera turns to it
	if (pv_dwa > .5) {
		// the tabs (2026-09-16)
		for (var _ti = 0; _ti < 2; _ti++) { var _tr2 = __pv_dtab_r(_ti); if (point_in_rectangle(mouse_x, mouse_y, _tr2.x, _tr2.y, _tr2.x + _tr2.w, _tr2.y + _tr2.h)) { if (pv_dtab != _ti) { pv_dtab = _ti; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); } return true; } }
		var _rlist = __pv_row_list(pl_dest);
		if (pv_dtab == 0 && !__nolanding(pl_dest)) for (var _ik = pv_rsc; _ik < array_length(_rlist); _ik++) {   // (no rows on a gas giant - q243; the rows in the list's order, scrolled - q287 / q295)
			var _i = _rlist[_ik];
			var _pr0 = __pv_row_r(_ik - pv_rsc);
			if (_pr0.y + _pr0.h > room_height - 32) break;
			if (!point_in_rectangle(mouse_x, mouse_y, _pr0.x, _pr0.y, _pr0.x + _pr0.w, _pr0.y + _pr0.h)) continue;
			if (pl_focus == _i && pv_face < 0) { pv_face = _i; play_sound_ext(snd_softclick, .95, 1.05, .3, 1); return true; }
			__pv_pick(_i); pv_rsc = 0;   // (the picked row leads the list: the list starts over at the top)
			return true;
		}
		// THE EXPEDITIONS in the drawer (2026-09-16): a haul's row opens the haul, a trip's the trip
		var _nl = (pv_dtab == 1) ? (array_length(_e.hauls) + array_length(_e.trips)) : 0;
		for (var _k = 0; _k < _nl; _k++) {
			var _pr1 = __pv_trip_r(_k);
			if (_pr1.y + _pr1.h > room_height - 32) break;
			if (!point_in_rectangle(mouse_x, mouse_y, _pr1.x, _pr1.y, _pr1.x + _pr1.w, _pr1.y + _pr1.h)) continue;
			if (_k < array_length(_e.hauls)) { view_id = _e.hauls[_k].id; __page_go("haul"); }
			else { view_id = _e.trips[_k - array_length(_e.hauls)].id; __page_go("trip"); }
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	// [bestiary] in the left column (planet mode)
	if (pv_mode == "planet") {
		var _bsr = __best_r();
		if (point_in_rectangle(mouse_x, mouse_y, _bsr.x, _bsr.y, _bsr.x + _bsr.w, _bsr.y + _bsr.h)) {
			bs_from = "planet"; __page_go("bestiary");
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	return true;
}
