/// @description ex_planet_draw(e, ea, dim) -> true when the page is drawn (the old exit): THE PLANET PAGE - the orbit view (__draw_orbit), the drawer and its tabs, region mode's box and banner, the hand's cards, the buttons (syst_exped_panel's Draw, q219; self = the panel; e = g.exped, ea / dim the event's ease and colour)
function ex_planet_draw(_e, _ea, _dim) {
	var _d = pl_dest;
	var _b = exped_biomes()[_d.biome];
	var _ocf = starmap_config();
	var _pvr = __pv_r(), _pvc = __pv_c();
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th);
	var _w = _pvr.w, _h = _pvr.h;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_w, _h);
	}
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) {
		if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf);
		sky_fog_surf = surface_create(_w, _h);
	}
	var _lcx = _pvc.x - _pvr.x, _lcy = _pvc.y - _pvr.y;
	var _pr = _ocf.pr * pv_zoom;
	var _nol = __nolanding(_d);   // (a gas giant: no spots, no region mode - q243)
	g.planet_rshow = 1; g.planet_rsel = (pl_focus >= 0) ? pl_focus + 1 : 0;   // THE TERRITORIES on the world (q287): the tint and the borders, the picked one brighter
	var _camd = __cam_snap(_pn, pv_cam, pv_spin, _pr, planet_cell());   // THE POSITION SNAP (q302): the texel grid on the cell grid about the centre - the draw's camera, the state untouched
	var _mats = __draw_orbit(_d, _pvr.x, _pvr.y, _w, _h, _lcx, _lcy, _pr, _camd, pv_spin, _nol ? -1 : ((pv_mode == "region") ? pl_focus : -2), pl_focus, pv_cfade);
	g.planet_rshow = 0;
	pv_mat_m = _mats.m; pv_mat_r = _mats.r;
	ui_fade_set(_ea);
	// the facts over the sky (the world's name lives in the strip now - his
	// ask, 2026-09-15; the tier and the flight time are gone)
	if (is_struct(pv_sky)) {
		var _sm = starmap_get(), _hm = galaxy_world_sys(pl_dest);   // (the world's own star, 2026-09-16)
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(land ? 14 : 4, list_y + 6, "the " + star_name(_hm.star) + " system  -  " + _sm.regions[_sm.stars[_hm.star].props.region].name + "  -  " + string(array_length(_hm.sys.planets)) + " worlds" + ((_hm.star == galaxy_home().star && _hm.planet == galaxy_home().planet) ? "" : ("  -  tier " + string(pl_dest.tier))));
	}
	// THE WORLD BOX (2026-09-15): what the world is - out of the way as the region box comes in
	if (rg_in < .99) __draw_world_box(_d);
	// the hint, bottom middle
	draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(room_width * .5, room_height - 8 - 12, (pv_mode == "region" || _nol) ? "drag to orbit  -  wheel to zoom" : "drag to orbit  -  wheel to zoom  -  tap a region");
	draw_set_halign(fa_left);
	// the left column: [galaxy] at the foot, [star system] over it ([map] is in the strip; the geosync toggle went - his call, 2026-09-16)
	var _gl = __galaxy_r();
	draw_ui_button(_gl.x, _gl.y, _gl.w, _gl.h, "galaxy", c_steelblue, true, false);
	var _syr = __system_r();
	draw_ui_button(_syr.x, _syr.y, _syr.w, _syr.h, "star system", c_steelblue, true, false);   // (the demo's system view, 2026-09-16)
	if (pv_mode == "planet") { var _bsr = __best_r(); draw_ui_button(_bsr.x, _bsr.y, _bsr.w, _bsr.h, "bestiary", c_steelblue, true, false); }   // (the hub's button, rehomed - 2026-09-16)
	if (pv_mode == "region") {
		// REGION MODE: THE INFO BOX left (his shape, 2026-09-15: the name, then
		// "level 1 - peaceful / temperature - warm / weather - calm / time -
		// dusk / flora - bountiful / fauna - passive / civilization -
		// farmlands", the word coloured by its threat - region_info), [region
		// map] in the left column, [quests] over [explore] bottom right
		var _rg = region_get(_d, rg_sel);
		__draw_info_box(_d, _rg, __rg_banner_r());
		var _esr = __rg_banner_r(); __draw_event_strip(_d, _rg, _esr.x, _esr.y + rg_box_h + 4, max(rg_box_w, land ? 210 : 150));   // (the events header - q285)
		var _qb = __quests_r();
		draw_ui_button(_qb.x, _qb.y, _qb.w, _qb.h, "quests", c_gold, true, true);
		var _xb = __explore_r();
		draw_ui_button(_xb.x, _xb.y, _xb.w, _xb.h, "explore", c_horange, true, false);
		var _ifb = __infl_r();
		draw_ui_button(_ifb.x, _ifb.y, _ifb.w, _ifb.h, "influence", c_seagreen, true, rg_infl);   // (the region's ledger - q270)
		// THE INFLUENCE VIEW (q270 / q286): the region's ledger over the view, IN TABS - a strip of pills up top, the tab's
		// explainer, its rows with a bar where a number wants one and a dim sub-line under each saying what moves it and
		// what reads it; the wheel scrolls; a tab's tap switches, any other tap closes
		if (rg_infl) {
			draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, .86);
			var _lx = (land ? 14 : 4) + 6, _lyy = list_y + 6, _lw = room_width - _lx * 2;
			draw_set_font(fnt); draw_set_halign(fa_left);
			draw_set_color(c_gold); draw_set_alpha(.95);
			draw_text(_lx, _lyy, _rg.name + "  -  what the crews did here, and what the region is doing about it");
			_lyy += 13;
			var _tabs = region_ledger_tabs(), _tx = _lx;
			rg_infl_tabs = [];
			for (var _tbi = 0; _tbi < array_length(_tabs); _tbi++) {
				var _tw = string_width(_tabs[_tbi]) + 12, _ton = (_tabs[_tbi] == rg_infl_tab);
				draw_sprite_ext(spr_pixel_1x1, 0, _tx, _lyy, _tw, 13, 0, _ton ? c_gold : c_black, _ton ? .9 : .7);
				draw_px_rect(_tx, _lyy, _tw, 13, c_gold, _ton ? .9 : .45);
				draw_set_color(_ton ? c_black : c_gold); draw_set_alpha(.95);
				draw_text(_tx + 6, _lyy + 2, _tabs[_tbi]);
				array_push(rg_infl_tabs, { x : _tx, y : _lyy, w : _tw, h : 13, name : _tabs[_tbi] });
				_tx += _tw + 4;
			}
			_lyy += 17;
			var _top = _lyy, _bot = room_height - 8 - 14, _ly2 = _top - rg_infl_scroll, _tot = 0;
			var _lgr = region_ledger(_d, rg_sel, rg_infl_tab);
			for (var _li = 0; _li < array_length(_lgr); _li++) {
				var _lr = _lgr[_li], _kw = (_lr.k == "") ? 0 : 58, _rh = 0;
				var _vw = _lw - _kw - ((!is_undefined(_lr[$ "bar"])) ? 68 : 0);
				var _vh = string_height_ext(_lr.v, 9, _vw), _sh = (is_string(_lr[$ "sub"]) && _lr.sub != "") ? string_height_ext(_lr.sub, 9, _lw - _kw) : 0;
				_rh = max(11, _vh) + ((_sh > 0) ? _sh + 1 : 0) + 3;
				if (_ly2 + _rh > _top && _ly2 < _bot) {
					var _vis = (_ly2 >= _top - 1);   // (a row cut by the top edge is skipped whole - no text over the tabs)
					if (_vis) {
						if (_lr.k != "") { draw_set_color(sett_ink); draw_set_alpha(.8); draw_text(_lx, _ly2, _lr.k); }
						var _vx = _lx + _kw;
						if (!is_undefined(_lr[$ "bar"])) {
							var _bx = _vx, _bw = 60, _bv = clamp(_lr.bar, -1, 1);
							draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ly2 + 2, _bw, 6, 0, c_black, .8);
							draw_sprite_ext(spr_pixel_1x1, 0, _bx + _bw * .5, _ly2 + 1, 1, 8, 0, sett_ink, .5);
							if (_bv != 0) draw_sprite_ext(spr_pixel_1x1, 0, (_bv > 0) ? (_bx + _bw * .5) : (_bx + _bw * .5 + _bv * _bw * .5), _ly2 + 2, abs(_bv) * _bw * .5, 6, 0, _lr.col, .9);
							_vx += _bw + 8;
						}
						draw_set_color(_lr.col); draw_set_alpha(.95); draw_text_ext(_vx, _ly2, _lr.v, 9, _vw);
						if (_sh > 0) { draw_set_color(_dim); draw_set_alpha(.75); draw_text_ext(_lx + _kw, _ly2 + max(11, _vh) + 1, _lr.sub, 9, _lw - _kw); }
					}
				}
				_ly2 += _rh; _tot += _rh;
			}
			rg_infl_hmax = max(0, _tot - (_bot - _top));
			// (the strip's cover, so a scrolled row never rides over the tabs)
			draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, _top - list_y, 0, c_black, .86);
			draw_set_color(c_gold); draw_set_alpha(.95); draw_text(_lx, list_y + 6, _rg.name + "  -  what the crews did here, and what the region is doing about it");
			for (var _tbi = 0; _tbi < array_length(rg_infl_tabs); _tbi++) {
				var _tbr = rg_infl_tabs[_tbi], _ton = (_tbr.name == rg_infl_tab);
				draw_sprite_ext(spr_pixel_1x1, 0, _tbr.x, _tbr.y, _tbr.w, _tbr.h, 0, _ton ? c_gold : c_black, _ton ? .9 : .7);
				draw_px_rect(_tbr.x, _tbr.y, _tbr.w, _tbr.h, c_gold, _ton ? .9 : .45);
				draw_set_color(_ton ? c_black : c_gold); draw_set_alpha(.95); draw_text(_tbr.x + 6, _tbr.y + 2, _tbr.name);
			}
			draw_sprite_ext(spr_pixel_1x1, 0, 0, _bot, room_width, room_height - _bot, 0, c_black, .86);
			draw_set_color(_dim); draw_set_alpha(.6); draw_text(_lx, room_height - 8 - 12, (rg_infl_hmax > 0) ? "wheel to scroll  -  tap a tab  -  tap elsewhere to close" : "tap a tab  -  tap elsewhere to close");
		}
		// THE HAND'S VEIL (the cards themselves are obj_card instances over the panel)
		if (hand_a > .001) {
			draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, .85 * hand_a);   // (darker - his ask)
			draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.7 * hand_a);
			draw_text(room_width * .5, list_y + 24, (hand == "quests") ? "quests on offer  -  tap one; off the cards to close" : "explore  -  tap a card; off the cards to close");
			// THE CLOCK under each card (his ask): grey, reddening as the slot
			// nears its re-deal (the last half hour); a taken one says so
			for (var _hc = 0; _hc < array_length(hand_ids); _hc++) {
				var _cd = hand_ids[_hc];
				if (!instance_exists(_cd) || !_cd.visible || !_cd.settled) continue;
				var _csl = _cd.face[$ "slot"];
				if (!is_struct(_csl)) continue;
				if (_csl.taken != 0) { draw_set_color(c_steelblue); draw_set_alpha(.8 * hand_a); draw_text(_cd.x, _cd.y + _cd.card_h * .5 + 4, "taken"); }
				else {
					var _urg = 1 - clamp(_csl.left / EXPED_QUEST_LIFE_LO, 0, 1);
					draw_set_color(merge_colour(c_gray, c_hred, _urg)); draw_set_alpha((.7 + .3 * _urg) * hand_a);
					draw_text(_cd.x, _cd.y + _cd.card_h * .5 + 4, "gone in " + crunch_time_long(_csl.left / max(1, g.exped.spd)));
				}
			}
			draw_set_halign(fa_left);
		}
	} else if (_nol) {
		draw_set_halign(fa_right); draw_set_color(c_horange); draw_set_alpha(.7);
		draw_text(room_width - (land ? 14 : 4), room_height - 8 - 12, "no landing  -  a gas giant has no ground");
		draw_set_halign(fa_left);
	} else if (pl_focus >= 0) {
		var _vr = __view_rg_r();
		draw_ui_button(_vr.x, _vr.y, _vr.w, _vr.h, "view region", c_gold, true, true);
	} else {
		draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.5);
		draw_text(room_width - (land ? 14 : 4), room_height - 8 - 12, "pick a region to view it");
		draw_set_halign(fa_left);
	}
	// THE DRAWER: the tab on the right edge, the regions when open (planet mode only)
	var _dwx = __pv_dw_x();
	if (pv_mode == "region") { __draw_back(); ui_fade_set(1); return true; }
	if (pv_dwa > .01) { var _pbx = __pv_box_r(); draw_sprite_ext(spr_pixel_1x1, 0, _pbx.x, _pbx.y, _pbx.w, _pbx.h, 0, c_black, .82 * pv_dwa); draw_px_rect(_pbx.x, _pbx.y, _pbx.w, _pbx.h, c_steelblue, .55 * pv_dwa); }   // (ends above the button row; outlined - his ask 2026-09-16)
	var _tb = __pv_tab_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _tb.x, _tb.y, _tb.w, _tb.h, 0, c_black, .85);
	draw_px_rect(_tb.x, _tb.y, _tb.w, _tb.h, c_steelblue, .6);
	draw_set_color(c_steelblue); draw_set_alpha(.9);
	draw_text(_tb.x + 2, _tb.y + _tb.h * .5 - 4, pv_dw ? ">" : "<");
	if (pv_dwa > .3) {
		// THE TABS (his ask, 2026-09-16): [regions] and [active / expeditions] - the second on two lines
		for (var _ti = 0; _ti < 2; _ti++) {
			var _tr2 = __pv_dtab_r(_ti), _ton = (pv_dtab == _ti);
			draw_sprite_ext(spr_pixel_1x1, 0, _tr2.x, _tr2.y, _tr2.w, _tr2.h, 0, _ton ? merge_colour(c_steelblue, c_black, .75) : c_black, .85 * pv_dwa);
			draw_px_rect(_tr2.x, _tr2.y, _tr2.w, _tr2.h, _ton ? c_gold : c_steelblue, (_ton ? .9 : .45) * pv_dwa);
			draw_set_halign(fa_center); draw_set_color(_ton ? c_white : _dim); draw_set_alpha((_ton ? .95 : .7) * pv_dwa);
			if (_ti == 0) draw_text(_tr2.x + _tr2.w * .5, _tr2.y + 7, "regions");
			else { draw_text(_tr2.x + _tr2.w * .5, _tr2.y + 2, "active"); draw_text(_tr2.x + _tr2.w * .5, _tr2.y + 11, __sheet_cut("expeditions", _tr2.w - 4)); }
			draw_set_halign(fa_left);
		}
		var _kk = region_kinds();
		if (pv_dtab == 0 && _nol) { var _nr0 = __pv_row_r(0); draw_set_color(c_horange); draw_set_alpha(.75 * pv_dwa); draw_text(_nr0.x + 4, _nr0.y + 6, "no landing"); draw_set_color(_dim); draw_set_alpha(.6 * pv_dwa); draw_text(_nr0.x + 4, _nr0.y + 18, "a gas giant has no ground"); draw_set_alpha(1); }
		var _rlist = __pv_row_list(_d), _rshown = 0, _rfit = __pv_rows_fit();   // (the rows: the picked, the crews', the gate, the rest - scrolled by the wheel; q287 / q295)
		pv_rsc = clamp(pv_rsc, 0, max(0, array_length(_rlist) - _rfit));
		if (pv_dtab == 0 && !_nol) for (var _ik = pv_rsc; _ik < array_length(_rlist); _ik++) {
			var _i = _rlist[_ik];
			var _rg = region_get(_d, _i);
			var _rr = __pv_row_r(_ik - pv_rsc);
			if (_rr.y + _rr.h > room_height - 32) break;
			_rshown++;
			var _nciv = 0, _ndun = 0, _ncmp = 0, _nlnd = 0;
			for (var _j = 0; _j < array_length(_rg.nodes); _j++) {
				var _kd = _kk[$ _rg.nodes[_j].kind];
				if (is_undefined(_kd)) continue;
				if (_kd.civ) _nciv++;
				if (_rg.nodes[_j].kind == "dungeon") _ndun++;
				if (_rg.nodes[_j].kind == "camp") _ncmp++;
				if (_rg.nodes[_j].kind == "landing") _nlnd++;
			}
			var _on = (pl_focus == _i), _rcl = region_col(_d, _i);   // (the region's own colour - the outline's on the world; q296)
			draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_black, .7);
			draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, _rcl, _on ? .95 : .45);
			draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, 2, _rr.h, 0, _rcl, _on ? .95 : .6);
			draw_set_color(c_white); draw_set_alpha(.95);
			draw_text(_rr.x + 5, _rr.y + 3, string_copy(_rg.name, 1, land ? 18 : 14));
			draw_set_halign(fa_right);
			var _lvd = _rg.lv - exped_world_lv(_d);   // (the rung from the gate: green near, gold, red far - q287)
			draw_set_color((_lvd <= 1) ? c_sgreen : ((_lvd <= 4) ? c_gold : c_hred)); draw_set_alpha(.9);
			draw_text(_rr.x + _rr.w - 5, _rr.y + 3, "lv " + string(_rg.lv));
			draw_set_halign(fa_left);
			draw_set_color(_dim); draw_set_alpha(.7);
			var _rinf = region_info(_d, _rg), _rbio = "";
			for (var _ri2 = 0; _ri2 < array_length(_rinf); _ri2++) if (_rinf[_ri2].k == "biome") _rbio = _rinf[_ri2].v;
			draw_text(_rr.x + 5, _rr.y + 13, (_rg[$ "mood"] ?? "quiet") + "  -  " + _rbio);   // (the mood and the biome, the info box's words)
			var _out = 0;
			for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed && (_e.trips[_t][$ "rgi"] ?? 0) == _i) _out++;
			if (_out > 0) { draw_set_halign(fa_right); draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_rr.x + _rr.w - 5, _rr.y + 13, string(_out) + " out"); draw_set_halign(fa_left); }
		}
		if (pv_dtab == 0 && !_nol) {
			draw_set_color(_dim); draw_set_alpha(.5 * pv_dwa);
			draw_text(_dwx + 13, list_y + 48 + _rshown * 26 + 2, (array_length(_rlist) > _rfit) ? (string(array_length(_rlist)) + " regions - wheel to scroll, or tap the world") : "tap a row: the world turns to it");
			// THE SCROLL'S BAR (q295): a thin track down the drawer's right edge, the thumb where the rows stand in the list
			if (array_length(_rlist) > _rfit) {
				var _sbx = room_width - 4, _sby = list_y + 48, _sbh = _rfit * 26 - 2;
				draw_sprite_ext(spr_pixel_1x1, 0, _sbx, _sby, 2, _sbh, 0, c_black, .6 * pv_dwa);
				var _thh = max(6, _sbh * _rfit / array_length(_rlist)), _thy = _sby + (_sbh - _thh) * (pv_rsc / max(1, array_length(_rlist) - _rfit));
				draw_sprite_ext(spr_pixel_1x1, 0, _sbx, _thy, 2, _thh, 0, c_gold, .8 * pv_dwa);
			}
		}
		// THE EXPEDITIONS (the hub's list, moved into the drawer - his call, 2026-09-16; its own tab since): hauls home first, then the trips out; a row each, tap for its page
		var _nl = (pv_dtab == 1) ? (array_length(_e.hauls) + array_length(_e.trips)) : 0;
		for (var _k = 0; _k < _nl; _k++) {
			var _pr1 = __pv_trip_r(_k);
			if (_pr1.y + _pr1.h > room_height - 32) break;
			var _ish = (_k < array_length(_e.hauls));
			var _rec = _ish ? _e.hauls[_k] : _e.trips[_k - array_length(_e.hauls)];
			draw_sprite_ext(spr_pixel_1x1, 0, _pr1.x, _pr1.y, _pr1.w, _pr1.h, 0, c_black, .7 * pv_dwa);
			draw_px_rect(_pr1.x, _pr1.y, _pr1.w, _pr1.h, _ish ? c_gold : _rec.cols[0], .6 * pv_dwa);
			__dot(_pr1.x + 6, _pr1.y + 6, 2, _rec.cols[0], .95 * pv_dwa);
			draw_set_color(_ish ? c_gold : c_white); draw_set_alpha(.95 * pv_dwa);
			draw_text(_pr1.x + 12, _pr1.y + 2, __sheet_cut(exped_crew_txt(_rec.names) + (_ish ? " - home, collect" : (" - " + exped_where(_rec))), _pr1.w - 16));
		}
		if (pv_dtab == 1 && _nl == 0) { draw_set_color(_dim); draw_set_alpha(.45 * pv_dwa); draw_text(_dwx + 13, list_y + 52, "no expeditions out"); }
	}
	__draw_back();
	ui_fade_set(1);
	return true;
}
