draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
// the strip
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(sett_ink); draw_set_alpha(.85);
draw_text(6, bby + 4, "the arena" + ((page == "fight") ? "  -  a practice fight (nothing is kept)" : ((page == "result") ? "  -  the result" : "  -  pick a crew and an opponent")));
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);

if (page == "setup") {
	// THE CREW: the customs first, then every sprite; the picked ones lit
	draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(6, bby + 22, "crew  " + string(array_length(picked)) + " / " + string(exped_party_max()));
	var _cl = __crew_list();
	for (var _i = 0; _i < array_length(_cl); _i++) {
		var _cr = __crew_r(_i);
		if (_cr.y < bby + 34 || _cr.y > room_height - 40) continue;
		var _sp = _cl[_i], _on = false;
		for (var _k = 0; _k < array_length(picked); _k++) if (picked[_k] == _sp.id) _on = true;
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, _on ? merge_colour(_sp.col, c_black, .55) : c_hsv(168, 140, 15), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, 2, _cr.h, 0, _sp.col, .9);
		draw_set_color(_on ? c_white : sett_ink); draw_set_alpha(_on ? .95 : .7);
		var _sh = sprite_sheet(_sp);
		draw_text(_cr.x + 6, _cr.y + 2, _sp.name + "  lv " + string(_sh.lv) + "  " + sprite_classes()[_sh.cls].name + ((_sp[$ "trip"] ?? false) ? "  (out)" : ((_sp[$ "custom"] ?? false) ? "  (custom)" : "")));
	}
	// THE TABS (q257): opponent / place / custom
	var _tabs = ["opponent", "place", "custom"], _tcol = [c_hred, c_sgreen, c_hpurple];
	for (var _t = 0; _t < 3; _t++) { var _tr = __tab_r(_t); draw_ui_button(_tr.x, _tr.y, _tr.w, _tr.h, _tabs[_t], _tcol[_t], true, tab == _tabs[_t]); }
	if (tab == "opponent") {
		var _p0 = __opp_pill_r(0), _p1 = __opp_pill_r(1);
		draw_ui_button(_p0.x, _p0.y, _p0.w, _p0.h, "dummy", c_gold, true, opp == "dummy");
		draw_ui_button(_p1.x, _p1.y, _p1.w, _p1.h, "creature", c_hred, true, opp == "creature");
		if (opp == "dummy") {
			var _lbls = ["hit points  x" + string(d_hp), "armour  " + ["none", "leather", "mail", "plate"][d_arm], "behaviour  " + (d_hits ? "hits back" : "stands still")];
			for (var _r = 0; _r < 3; _r++) {
				var _l0 = __dum_r(_r, 0); draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_l0.x, _l0.y + 2, _lbls[_r]);
				if (_r < 2) { var _l1 = __dum_r(_r, 1), _l2 = __dum_r(_r, 2); draw_ui_button(_l1.x, _l1.y, _l1.w, _l1.h, "-", c_gold, true, false); draw_ui_button(_l2.x, _l2.y, _l2.w, _l2.h, "+", c_gold, true, false); }
				else { var _l3 = __dum_r(_r, 1); draw_ui_button(_l3.x, _l3.y, 34, _l3.h, "flip", c_gold, true, false); }
			}
			draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(170, bby + 112, "the dummy takes the first pick's level");
		} else {
			var _ros = foe_roster(), _nat = foe_kinds_at(p_land, p_season);
			var _c0 = __clv_r(0), _c1 = __clv_r(1), _c2 = __clv_r(2); draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_c0.x, _c0.y + 2, "level  " + string(c_lv));
			draw_ui_button(_c1.x, _c1.y, _c1.w, _c1.h, "-", c_gold, true, false); draw_ui_button(_c2.x, _c2.y, _c2.w, _c2.h, "+", c_gold, true, false);
			var _n0 = __cn_r(0), _n1 = __cn_r(1), _n2 = __cn_r(2); draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_n0.x, _n0.y + 2, "pack  " + string(c_n));
			draw_ui_button(_n1.x, _n1.y, _n1.w, _n1.h, "-", c_gold, true, false); draw_ui_button(_n2.x, _n2.y, _n2.w, _n2.h, "+", c_gold, true, false);
			for (var _i = 0; _i < array_length(_ros); _i++) {
				var _kr = __kind_r(_i); _kr.y -= kind_scroll * 13;   // (the grid scrolls on the wheel - q257)
				if (_kr.y < bby + 74 || _kr.y + _kr.h > room_height - 30) continue;
				var _kon = (_i == c_kind);
				draw_sprite_ext(spr_pixel_1x1, 0, _kr.x, _kr.y, _kr.w, _kr.h, 0, _kon ? merge_colour(_ros[_i].col, c_black, .5) : c_hsv(168, 140, 15), 1);
				var _ff = foe_sprite_frame(_ros[_i].name);
				if (_ff >= 0) draw_sprite_ext(spr_foe, _ff, _kr.x + 7, _kr.y + 6, .5, .5, 0, _ros[_i].col, .95);
				draw_set_color(_kon ? c_white : sett_ink); draw_set_alpha(_kon ? .95 : .7); draw_text(_kr.x + 16, _kr.y + 2, _ros[_i].name);
				if (array_contains(_nat, _ros[_i].name)) draw_sprite_ext(spr_pixel_1x1, 0, _kr.x + _kr.w - 4, _kr.y + 5, 2, 2, 0, c_sgreen, .9);   // (a native of the place - q257)
			}
			draw_set_color(sett_ink); draw_set_alpha(.45); draw_text(170, room_height - 28, "wheel: more kinds   .  green dot: native to the place");
		}
	} else if (tab == "place") {
		// THE LAND and THE SEASON, then what they mean: the hazard (the trip's own law) and the natives
		for (var _i = 0; _i < array_length(p_lands); _i++) { var _lr = __land_r(_i); draw_ui_button(_lr.x, _lr.y, _lr.w, _lr.h, p_lands[_i], c_sgreen, true, p_land == p_lands[_i]); }
		for (var _k = 0; _k < 5; _k++) { var _sr = __seas_r(_k); draw_ui_button(_sr.x, _sr.y, _sr.w, _sr.h, p_seasons[_k], c_gold, true, p_season == _k - 1); }
		var _hz = __place_hz();
		if (is_struct(_hz)) {
			draw_set_color(_hz.col); draw_set_alpha(.95); draw_text(170, bby + 110, _hz.name + "  -  a bare member's " + _hz.lane + " x" + string(_hz.f));
			draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(170, bby + 122, "held off by " + _hz.hold);
		} else { draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(170, bby + 110, "no hazard here"); }
		var _nat = foe_kinds_at(p_land, p_season), _ros = foe_roster();
		draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(170, bby + 138, "natives (tap one to fight it)");
		for (var _i = 0; _i < array_length(_nat); _i++) {
			var _nr = __nat_r(_i); if (_nr.y + _nr.h > room_height - 50) break;
			var _rc = c_white; for (var _r = 0; _r < array_length(_ros); _r++) if (_ros[_r].name == _nat[_i]) _rc = _ros[_r].col;
			var _non = (opp == "creature" && _ros[c_kind].name == _nat[_i]);
			draw_sprite_ext(spr_pixel_1x1, 0, _nr.x, _nr.y, _nr.w, _nr.h, 0, _non ? merge_colour(_rc, c_black, .5) : c_hsv(168, 140, 15), 1);
			draw_set_color(_non ? c_white : sett_ink); draw_set_alpha(_non ? .95 : .7); draw_text(_nr.x + 4, _nr.y + 2, _nat[_i]);
		}
		draw_set_color(sett_ink); draw_set_alpha(.45); draw_text(170, room_height - 28, "weather and night have no hand in a fight (the diary's) - a place is its land and season");
	} else {
		// THE CUSTOM SPRITE: the knobs, the preview, [reroll] [add to crew] [remove last]
		var _cls = sprite_classes();
		for (var _k = 0; _k < array_length(_cls); _k++) { var _kr2 = __ccls_r(_k); draw_ui_button(_kr2.x, _kr2.y, _kr2.w, _kr2.h, _cls[_k].name, _cls[_k].col, true, cu_cls == _k); }
		var _lbl = ["level  " + string(cu_lv), "gear  " + cu_rars[cu_rar + 1], "skills learned  " + string(cu_skills), "potions  " + string(cu_pots)];
		for (var _r = 0; _r < 4; _r++) {
			var _r0 = __cu_r(_r, 0), _r1 = __cu_r(_r, 1), _r2 = __cu_r(_r, 2);
			draw_set_color(sett_ink); draw_set_alpha(.85); draw_text(_r0.x, _r0.y + 2, _lbl[_r]);
			draw_ui_button(_r1.x, _r1.y, _r1.w, _r1.h, "-", c_gold, true, false); draw_ui_button(_r2.x, _r2.y, _r2.w, _r2.h, "+", c_gold, true, false);
		}
		if (is_struct(cu_preview)) {
			var _st = sprite_stats(cu_preview), _p = _st.pts, _b = cbt_balance();
			var _y = bby + 116;
			draw_set_color(cu_preview.col); draw_set_alpha(.95);
			draw_text(170, _y, cu_preview.name + "  -  " + _cls[cu_cls].name + " lv " + string(cu_lv) + "  hp " + string(floor(_p.hp * _b.hp_per_point + _b.hp_flat_add)));
			draw_set_color(sett_ink); draw_set_alpha(.8);
			draw_text(170, _y + 11, "atk " + string(round(_p.atk)) + "  def " + string(round(_p.def)) + "  int " + string(round(_p.mag)) + "  res " + string(round(_p.mdef)) + "  spd " + string(round(_p.spd)) + "  hit " + string(round(_p.hit)));
			var _ln = 0;
			for (var _w = 0; _w < array_length(_st.worn) && _ln < 4; _w++) { draw_set_color(_st.worn[_w].col); draw_set_alpha(.9); draw_text(170, _y + 24 + _ln * 10, _st.worn[_w].name); _ln++; }
			var _sks = sprite_skills(cu_preview), _skt = "";
			for (var _s = 0; _s < array_length(_sks); _s++) _skt += ((_s > 0) ? ", " : "") + _sks[_s].name;
			draw_set_color(c_lavender); draw_set_alpha(.85); draw_text(170, _y + 24 + _ln * 10, "skills: " + _skt);
		}
		var _b0 = __cubtn_r(0), _b1 = __cubtn_r(1), _b2 = __cubtn_r(2);
		draw_ui_button(_b0.x, _b0.y, _b0.w, _b0.h, "reroll", c_gold, true, false);
		draw_ui_button(_b1.x, _b1.y, _b1.w, _b1.h, "add to crew", c_sgreen, true, true);
		draw_ui_button(_b2.x, _b2.y, _b2.w, _b2.h, "remove last", c_hred, array_length(customs) > 0, false);
	}
	var _fr = __fight_r(); draw_ui_button(_fr.x, _fr.y, _fr.w, _fr.h, "fight", c_sgreen, array_length(picked) > 0, true);
	draw_set_color(sett_ink); draw_set_alpha(.45); draw_text(6, room_height - 12, "a practice fight: the crew as it is, copies of its potions - no hp, xp or items are kept");
}

if ((page == "fight" || page == "result") && is_struct(f)) {
	// THE TURN ORDER STRIP: every living pawn's fill toward the threshold (the ATB made visible)
	var _sx = 8, _sy = bby + 22;
	draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(_sx, _sy, "turn");
	var _tx0 = _sx + 30;
	for (var _i = 0; _i < array_length(f.all); _i++) {
		var _p = f.all[_i];
		if (_p.hp <= 0) continue;
		var _fill = clamp(_p.tic / max(.001, f.thr), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx0, _sy + 1, 40, 8, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx0, _sy + 1, 40 * _fill, 8, 0, (f.actor == _p) ? c_white : _p.col, .9);
		draw_px_rect(_tx0, _sy + 1, 40, 8, (_p.team == 0) ? c_steelblue : c_hred, .6);
		draw_set_color(c_white); draw_set_alpha(.85); draw_text(_tx0 + 2, _sy + 1, string_copy(_p.name, 1, 6));
		_tx0 += 46;
	}
	// THE PARTY (left) and THE FOES (right): a row a pawn - the face, the name, hp and mp bars, the statuses
	for (var _i = 0; _i < array_length(f.party); _i++) {
		var _p = f.party[_i], _pr = __party_r(_i), _isact = (f.actor == _p);
		draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, _isact ? merge_colour(_p.col, c_black, .6) : c_hsv(168, 140, 15), 1);
		draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, _isact ? c_white : merge_colour(_p.col, c_black, .3), _isact ? .9 : .5);
		var _sps = exped_sprite(_p[$ "sid"] ?? -1);
		if (!is_undefined(_sps) && _p.hp > 0) sprite_portrait(_sps, _pr.x + 18, _pr.y + 18, 2);
		else if (_p.hp <= 0) { draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(_pr.x + 8, _pr.y + 13, "down"); }
		draw_set_color(_p.hp > 0 ? c_white : sett_ink); draw_set_alpha(.95); draw_text(_pr.x + 40, _pr.y + 3, _p.name + "  lv " + string(_p.lv));
		draw_sprite_ext(spr_pixel_1x1, 0, _pr.x + 40, _pr.y + 15, 140, 5, 0, c_black, .8);
		draw_sprite_ext(spr_pixel_1x1, 0, _pr.x + 40, _pr.y + 15, 140 * clamp(_p.hp / max(1, _p.maxhp), 0, 1), 5, 0, c_sgreen, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _pr.x + 40, _pr.y + 22, 140, 3, 0, c_black, .8);
		if (_p.maxmp > 0) draw_sprite_ext(spr_pixel_1x1, 0, _pr.x + 40, _pr.y + 22, 140 * clamp(_p.mp / max(1, _p.maxmp), 0, 1), 3, 0, c_sblue, .95);
		draw_set_color(sett_ink); draw_set_alpha(.75);
		var _st = string(round(_p.hp)) + " / " + string(round(_p.maxhp)) + "   mp " + string(round(_p.mp));
		if ((_p[$ "guard"] ?? 0) > 0) _st += "   guarding";
		if (is_struct(_p[$ "ail"])) { if (_p.ail.poison > 0) _st += "   poisoned"; if (_p.ail.slow > 0) _st += "   slowed"; }
		draw_text_transformed(_pr.x + 40, _pr.y + 27, _st, .85, .85, 0);
	}
	for (var _i = 0; _i < array_length(f.foes); _i++) {
		var _p = f.foes[_i], _fr2 = __foe_r(_i), _isact = (f.actor == _p);
		draw_sprite_ext(spr_pixel_1x1, 0, _fr2.x, _fr2.y, _fr2.w, _fr2.h, 0, _isact ? merge_colour(_p.col, c_black, .6) : c_hsv(168, 140, 15), 1);
		draw_px_rect(_fr2.x, _fr2.y, _fr2.w, _fr2.h, _isact ? c_white : merge_colour(_p.col, c_black, .3), _isact ? .9 : .5);
		var _ff = foe_sprite_frame(_p[$ "kind"] ?? "");
		if (_p.hp > 0 && _ff >= 0) draw_sprite_ext(spr_foe, _ff, _fr2.x + 18, _fr2.y + 18, 1, 1, 0, _p.col, .95);
		else if (_p.hp > 0) { draw_sprite_ext(spr_pixel_1x1, 0, _fr2.x + 12, _fr2.y + 12, 12, 12, 45, merge_colour(_p.col, c_black, .35), .95); draw_sprite_ext(spr_pixel_1x1, 0, _fr2.x + 14, _fr2.y + 14, 8, 8, 45, _p.col, .95); }
		else { draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(_fr2.x + 8, _fr2.y + 13, "down"); }
		draw_set_color(_p.hp > 0 ? c_white : sett_ink); draw_set_alpha(.95); draw_text(_fr2.x + 40, _fr2.y + 3, _p.name + "  lv " + string(_p.lv));
		draw_sprite_ext(spr_pixel_1x1, 0, _fr2.x + 40, _fr2.y + 15, 100, 5, 0, c_black, .8);
		draw_sprite_ext(spr_pixel_1x1, 0, _fr2.x + 40, _fr2.y + 15, 100 * clamp(_p.hp / max(1, _p.maxhp), 0, 1), 5, 0, c_hred, .95);
		draw_set_color(sett_ink); draw_set_alpha(.75);
		var _st2 = string(round(_p.hp)) + " / " + string(round(_p.maxhp));
		if (is_struct(_p[$ "ail"])) { if (_p.ail.poison > 0) _st2 += "   poisoned"; if (_p.ail.slow > 0) _st2 += "   slowed"; }
		draw_text_transformed(_fr2.x + 40, _fr2.y + 23, _st2, .85, .85, 0);
	}
	// THE LOG: the last lines, the newest lit
	var _lg = __log_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _lg.x, _lg.y, _lg.w, _lg.h, 0, c_black, .6);
	draw_px_rect(_lg.x, _lg.y, _lg.w, _lg.h, sett_ink, .25);
	var _nl = min(6, array_length(f.log));
	for (var _i = 0; _i < _nl; _i++) {
		var _ln = f.log[array_length(f.log) - _nl + _i];
		draw_set_color((_i == _nl - 1) ? c_white : sett_ink); draw_set_alpha((_i == _nl - 1) ? .95 : .55);
		draw_text_transformed(_lg.x + 3, _lg.y + 2 + _i * 9, string_copy(_ln, 1, 46), .85, .85, 0);
	}
	if (page == "fight") {
		// the controls: the speed pills, [auto], [quit]
		var _s0 = __spd_r(0), _s1 = __spd_r(1), _s2 = __spd_r(2), _au = __auto_r(), _qu = __quit_r();
		draw_ui_button(_s0.x, _s0.y, _s0.w, _s0.h, "x1", c_gold, true, spd == 1);
		draw_ui_button(_s1.x, _s1.y, _s1.w, _s1.h, "x4", c_gold, true, spd == 4);
		draw_ui_button(_s2.x, _s2.y, _s2.w, _s2.h, "max", c_gold, true, spd == 0);
		draw_ui_button(_au.x, _au.y, _au.w, _au.h, auto ? "auto: on" : "auto", c_steelblue, true, auto);
		draw_ui_button(_qu.x, _qu.y, _qu.w, _qu.h, "quit", c_hred, true, false);
		// THE MENU on your pawn's turn
		if (mn.open && !is_undefined(f.actor)) {
			var _ac = f.actor;
			draw_set_color(c_white); draw_set_alpha(.9); draw_text(8, room_height - 8 - 14 * 6 - 2, _ac.name + "'s turn");
			var _names = ["attack", "skill", "item", "guard", "flee"];
			for (var _i = 0; _i < 5; _i++) { var _mr = __menu_r(_i); var _en = (_i != 2) || (is_array(_ac[$ "items"]) && array_length(_ac.items) > 0); draw_ui_button(_mr.x, _mr.y, _mr.w, _mr.h, _names[_i], (_i == 4) ? c_hred : c_gold, _en, (mn.stage == "root")); }
			if (mn.stage != "root") {
				draw_set_color(sett_ink); draw_set_alpha(.7); draw_text(124, room_height - 8 - 14 * 6 - 2, (mn.stage == "skill") ? "which skill" : ((mn.stage == "item") ? "which item" : "on whom"));
				for (var _i = 0; _i < min(6, array_length(mn.list)); _i++) {
					var _lr = __list_r(_i), _row = mn.list[_i], _lbl = "";
					if (mn.stage == "skill") _lbl = _row.skill.name + "  (" + string(cbt_skill_cost(_ac, _row.skill)) + " mp)";
					else if (mn.stage == "item") _lbl = _row.name;
					else _lbl = _row.name + "  " + string(round(_row.hp)) + " / " + string(round(_row.maxhp));
					draw_ui_button(_lr.x, _lr.y, _lr.w, _lr.h, _lbl, (mn.stage == "target") ? ((_row.team == 0) ? c_steelblue : c_hred) : c_gold, true, true);
				}
				if (array_length(mn.list) == 0) { draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(124, room_height - 8 - 14 * 5, "nothing here"); }
			}
		} else if (!is_undefined(f.actor) || beat > 0) { draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(8, room_height - 8 - 13, is_undefined(f.actor) ? "..." : (f.actor.name + " acts")); }
		// the last line, big for a moment
		if (last_t > 0 && last_line != "") { draw_set_halign(fa_center); draw_set_color(c_white); draw_set_alpha(clamp(last_t / 20, 0, 1) * .95); draw_text(room_width * .5, bby + 34, string_copy(last_line, 1, 60)); draw_set_halign(fa_left); }
	}
}

if (page == "result" && is_struct(res)) {
	var _bx = room_width * .5 - 130, _by = room_height * .5 - 40, _bw = 260, _bh = 96;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, _bw, _bh, 0, c_black, .92);
	draw_px_rect(_bx, _by, _bw, _bh, res.won ? c_sgreen : (res.withdrew ? c_gold : c_hred), .9);
	draw_set_halign(fa_center); draw_set_color(res.won ? c_sgreen : (res.withdrew ? c_gold : c_hred)); draw_set_alpha(.95);
	draw_text(_bx + _bw * .5, _by + 8, res.won ? "won" : (res.withdrew ? "withdrew" : "routed"));
	draw_set_color(sett_ink); draw_set_alpha(.8);
	draw_text(_bx + _bw * .5, _by + 22, string(res.turns) + " actions  -  nothing is kept");
	draw_set_halign(fa_left);
	var _ry = _by + 38;
	for (var _i = 0; _i < min(6, array_length(res.rows)); _i++) {
		var _rw = res.rows[_i];
		draw_set_color((_rw.team == 0) ? c_steelblue : c_hred); draw_set_alpha(.9);
		draw_text_transformed(_bx + 8, _ry, string_copy(_rw.name, 1, 16), .85, .85, 0);
		draw_set_color(sett_ink); draw_set_alpha(.75);
		draw_text_transformed(_bx + 110, _ry, "dealt " + string(_rw.dd) + "   taken " + string(_rw.dt) + "   " + string(_rw.hp) + " / " + string(_rw.maxhp) + " left", .85, .85, 0);
		_ry += 9;
	}
	var _ag = __again_r(), _su = __setup_r();
	draw_ui_button(_ag.x, _ag.y, _ag.w, _ag.h, "again", c_sgreen, true, true);
	draw_ui_button(_su.x, _su.y, _su.w, _su.h, "setup", c_gold, true, false);
}
draw_set_halign(fa_left); draw_set_color(c_white); draw_set_alpha(1);
