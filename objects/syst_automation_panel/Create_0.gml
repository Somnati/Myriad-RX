/// syst_automation_panel - THE AUTOMATION SCREEN, as a panel over
/// whatever room you are standing in (2026-09-10, his ask: standalone
/// like settings and statistics; rm_automation and syst_rm_automation
/// retired). Every preference lives in g.autom (autom_init) and the
/// runner is autom_tick on syst_production's heartbeat, so automation
/// works whether or not this screen is open. On the overlay contract:
/// automation_open is the one door, the burger's X and escape close it
/// (automation_close), syst_input holds the room quiet, ui_blur_tick
/// softens it behind; no back button.
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
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by automation_close; the Step destroys at zero

bby     = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar
list_y  = bby + 16;
rail_w  = 72;
cont_x  = rail_w + 6;
cont_w  = room_width - cont_x - 8;

tab   = 0;
tabs  = ["dials", "rebirth", "upgrades", "filter"];
tcol  = [c_sblue, c_hred, c_lavender, c_horange];
NTAB  = 4;

// THE RARITY CHIPS on the filter page: eight of them across one row,
// seated off the content band so they fit whatever the ladder grows to.
chip_x0 = 0; chip_w = 0; chip_gap = 3;
__chip_seat = function() {
	var _n = max(1, UPG_RARITY_N);
	chip_x0 = cont_x + 56;
	chip_w  = floor((cont_x + cont_w - chip_x0 - (_n - 1) * chip_gap) / _n);
};
__chip_r = function(_k, _ry) {
	return { x : chip_x0 + _k * (chip_w + chip_gap), y : _ry + 2,
	         w : chip_w, h : row_h - 4 };
};

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
__chip_seat();

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
			// ⚖️ "% held", not "% of profit" (his report: "the slider feels
			// backwards"). The behaviour was right - more slider, more
			// reserve - but the readout never said WHICH side the number
			// was. Every other percentage on this page is a spending CAP
			// where bigger means spends more, so an unlabelled 90 sitting
			// directly above a row of them reads as the same kind of
			// number pointing the other way.
			sfx  : "% held",
			st   : -1,
			col  : c_gold,
			help : "held out of spending: this share of the HIGHEST pile "
			     + "you have held this run. turn it down to release it",
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
				// "max 50%" rather than "50%" (his report: the slider did
				// not say what it did). The number alone could be a rate,
				// a chance or a target; the word says it is a ceiling.
				sfx  : "% cap",
				st   : _p.st,
				col  : dial_color(_i),
				help : "the most one buy may cost, as a share of spendable profit",
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
			help : "fills every empty slot, once a second" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto buy",
			on : _u.buy, val : _u.pct, sfx : "% cap", st : -1,
			col : c_sgreen,
			help : "buys a tier while its price fits that share of credits" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto sell",
			on : _u.sell, val : _u.keep, sfx : "% quick-set", st : -1,
			col : c_lavender,
			help : "sells what the filter page rejects - drag to set the "
			     + "rarity flags from the live odds" });
	}

	// ---- THE FILTER PAGE ----
	// One row of rarity chips, then one row per roster entry. Both are
	// explicit keep/sell flags rather than a threshold, because "I am
	// done with credit luck" is not a statement about rarity and no
	// single number can express it.
	if (tab == 3) {
		var _u = _a.upg;
		array_push(_o, { kind : 3, name : "rarity", on : true, val : 0,
			sfx : "", st : -1, col : c_horange,
			help : "chips lit are kept - the dark ones get sold" });
		var _cfg = upgrade_config();
		for (var _i = 0; _i < array_length(_cfg); _i++) {
			var _e = _cfg[_i];
			array_push(_o, { kind : 4, name : _e.name,
				on : (_u.kind[$ _e.id] ?? true), val : 0, sfx : "",
				st : -1, col : _e.col, id : _e.id,
				help : _e.help });
		}
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
	if (_t == 2) {
		var _u = _a.upg;
		switch (_i) {
			case 0: _u.roll = !_u.roll; break;
			case 1: _u.buy  = !_u.buy;  break;
			case 2: _u.sell = !_u.sell; break;
		}
		return;
	}

	// the filter page: row 0 is the chip strip (handled by __flip_chip),
	// every row under it is one roster entry, addressed BY ID
	var _cfg = upgrade_config();
	var _k = _i - 1;
	if (_k < 0 || _k >= array_length(_cfg)) return;
	var _id = _cfg[_k].id;
	g.autom.upg.kind[$ _id] = !(g.autom.upg.kind[$ _id] ?? true);
};

// one rarity chip
__flip_chip = function(_k) {
	var _r = g.autom.upg.rar;
	if (_k < 0 || _k >= array_length(_r)) return;
	_r[_k] = !_r[_k];
};

// THE QUICK-SET. Dragging the auto-sell slider writes the rarity flags
// from upgrade_keep_rarity, which reads the LIVE odds - so the
// self-adjusting logic survives as a way to configure the flags in one
// drag, while the flags themselves stay the thing the runner reads. A
// standing percentage would have quietly stopped matching anything the
// day the distribution moved; a percentage you APPLY cannot.
__quickset = function() {
	var _fl = upgrade_keep_rarity();
	for (var _k = 0; _k < UPG_RARITY_N; _k++) g.autom.upg.rar[_k] = (_k >= _fl);
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
		case 2: _u.keep = _v; __quickset(); break;
	}
};
