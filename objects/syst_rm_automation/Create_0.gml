/// syst_rm_automation - THE AUTOMATION ROOM. rm_automation is only a
/// view: every preference lives in g.autom (autom_init) and the runner
/// is autom_tick on syst_production's heartbeat, so automation works
/// whether or not this screen is open.
///
/// A LEFT RAIL OF TABS, the settings / saves shape - because three
/// sections that each want a full page is exactly the problem that rail
/// was built for, and a fourth invented layout is a fourth thing to
/// learn. [dials] [rebirth] [upgrades].
///
/// DRAW-ONLY PLUS REGION HITS, all off the geometry declared here. The
/// sliders are drawn tracks with a drag handled in the Step rather than
/// the settings screen's bound widget instances: those exist to keep a
/// LIST of heterogeneous rows in sync, and this screen has three fixed
/// pages where the geometry is known at build time.

autom_init();

bby     = obj_ui_header.sprite_height;
list_y  = bby + 16;
rail_w  = 72;
cont_x  = rail_w + 6;
cont_w  = room_width - cont_x - 8;

tab   = 0;
tabs  = ["dials", "rebirth", "upgrades"];
tcol  = [c_sblue, c_hred, c_lavender];

row_h = 14;
row_p = 16;
top_y = list_y + 8;

// the drag in progress: which control, so a slider keeps the pointer
// even when it slides off its own track (the settings screen's rule -
// a knob you can lose by moving too fast is a knob that fights you)
drag_row = -1;     // -1 = nothing being dragged
drag_tab = 0;
drag_lo  = 0;
drag_hi  = 100;

__tab_rect = function(_i) {
	return { x : 2, y : list_y + 3 + _i * 20, w : rail_w - 6, h : 17 };
};
__back_rect = function() {
	return { x1 : room_width - 62, y1 : bby + 6, x2 : room_width - 6, y2 : bby + 22 };
};

// ---- one row's furniture, shared by Draw and Step ----
// A row is: label, a toggle pill, a slider track, a readout. Not every
// row uses all of it; the ones that do all put it in the same place,
// which is the only reason a page of them is readable.
tog_x = 0; tog_w = 30;
trk_x = 0; trk_w = 150;
__seat = function() {
	tog_x = cont_x + 96;
	trk_x = cont_x + 134;
	// 96 rather than 60: a dial row shows BOTH a percentage readout and
	// a verdict pill, and they were being right-aligned to the same
	// pixel - the pill drew straight over the number
	trk_w = cont_w - 134 - 96;
};
__seat();

__row_y  = function(_i) { return top_y + _i * row_p; };
__tog_r  = function(_i) { return { x : tog_x, y : __row_y(_i) + 2, w : tog_w, h : 11 }; };
__trk_r  = function(_i) { return { x : trk_x, y : __row_y(_i) + 5, w : trk_w, h : 5 }; };

// a slider's value from the pointer, snapped to whole units
__slide = function(_i, _lo, _hi) {
	var _t = __trk_r(_i);
	return round(lerp(_lo, _hi, clamp((mouse_x - _t.x) / max(1, _t.w), 0, 1)));
};

// ==================================================================
// THE PAGES, declared once and read by both the Step and the Draw.
// Region law: one description of what a page contains, so a hit test
// can never disagree with what was painted.
//   kind 0 = toggle only, 1 = slider only, 2 = both
// ==================================================================
__page_rows = function() {
	var _o = [];
	var _a = g.autom;

	if (tab == 0) {
		// THE RESERVE sits at the top of this page (his ask), because it
		// is the counterweight to everything under it: autobuy spends
		// profit, and this is the share autobuy may not touch.
		array_push(_o, {
			kind : 1, lo : 0, hi : 90,
			name : "reserve",
			on   : (_a.lock_pct > 0),
			val  : _a.lock_pct,
			sfx  : "% locked",
			st   : -1,
			col  : c_gold,
			help : "this share of every earning is kept out of spending",
		});
		if (!variable_global_exists("dial")) return _o;
		var _n = min(g.dial_total, array_length(_a.dial));
		for (var _i = 0; _i < _n; _i++) {
			var _p = _a.dial[_i];
			array_push(_o, {
				kind : 2, lo : 1, hi : 100,
				name : "dial " + dial_config(_i).name,
				on   : _p.on,
				val  : _p.pct,
				sfx  : "%",
				st   : _p.st,
				col  : dial_color(_i),
				help : "buys while the bill fits this share of spendable profit",
			});
		}
	}

	if (tab == 1) {
		var _r = _a.reb;
		array_push(_o, { kind : 2, lo : 1, hi : 240, name : "run length",
			on : _r.t_on, val : _r.t_min, sfx : "m", st : -1, col : c_hred,
			help : "at least this long into the run" });
		array_push(_o, { kind : 2, lo : 1, hi : 500, name : "units gained",
			on : _r.u_on, val : _r.u_min, sfx : "", st : -1, col : c_hred,
			help : "the press would award at least this many" });
		array_push(_o, { kind : 2, lo : 1, hi : 200, name : "gain vs held",
			on : _r.g_on, val : _r.g_pct, sfx : "%", st : -1, col : c_hred,
			help : "the award is at least this much of what you hold" });
		array_push(_o, { kind : 2, lo : 1, hi : 60, name : "profit reach",
			on : _r.p_on, val : _r.p_oom, sfx : " ooms", st : -1, col : c_hred,
			help : "profit has passed 10^this" });
		array_push(_o, { kind : 0, name : "no timeclamp",
			on : _r.c_on, val : 0, sfx : "", st : -1, col : c_hred,
			help : "wait until the early-run penalty has expired" });
	}

	if (tab == 2) {
		var _u = _a.upg;
		array_push(_o, { kind : 0, name : "auto roll",
			on : _u.roll, val : 0, sfx : "", st : -1, col : c_sblue,
			help : "fill every empty slot" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto buy",
			on : _u.buy, val : _u.pct, sfx : "% of credits", st : -1,
			col : c_sgreen, help : "buy tiers while the bill fits the budget" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto sell",
			on : _u.sell, val : _u.keep, sfx : "% kept", st : -1,
			col : c_lavender,
			help : "sell offers outside the best " + string(_u.keep) + "%" });
	}
	return _o;
};

// the toggle, per page and row
__flip = function(_t, _i) {
	var _a = g.autom;
	// row 0 of the dials page is the reserve, which has no toggle - so
	// a dial's row index is one further down than its dial index
	if (_t == 0) {
		if (_i < 1) return;
		var _d = _a.dial[_i - 1];
		_d.on = !_d.on;
		if (!_d.on) _d.st = 0;
		return;
	}
	if (_t == 1) {
		var _r = _a.reb;
		switch (_i) {
			case 0: _r.t_on = !_r.t_on; break;
			case 1: _r.u_on = !_r.u_on; break;
			case 2: _r.g_on = !_r.g_on; break;
			case 3: _r.p_on = !_r.p_on; break;
			case 4: _r.c_on = !_r.c_on; break;
		}
		return;
	}
	var _u = _a.upg;
	switch (_i) {
		case 0: _u.roll = !_u.roll; break;
		case 1: _u.buy  = !_u.buy;  break;
		case 2: _u.sell = !_u.sell; break;
	}
};

// the slider, per page and row
__set_slider = function(_t, _i, _v) {
	var _a = g.autom;
	if (_t == 0) {
		if (_i == 0) _a.lock_pct = clamp(_v, 0, 90);
		else         _a.dial[_i - 1].pct = _v;
		return;
	}
	if (_t == 1) {
		var _r = _a.reb;
		switch (_i) {
			case 0: _r.t_min = _v; break;
			case 1: _r.u_min = _v; break;
			case 2: _r.g_pct = _v; break;
			case 3: _r.p_oom = _v; break;
		}
		return;
	}
	var _u = _a.upg;
	switch (_i) {
		case 1: _u.pct  = _v; break;
		case 2: _u.keep = _v; break;
	}
};
