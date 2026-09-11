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
/// A LEFT RAIL OF TABS, the settings / saves shape - because sections
/// that each want a full page is exactly the problem that rail was
/// built for, and another invented layout is another thing to learn.
/// [overview] [dials] [rebirth] [upgrades] [tiles]. Pages are split
/// into SECTIONS (a labelled band, kind 8): "process automation" - the
/// machine that runs the thing - and "autobuy" - the spending. A page
/// taller than the room scrolls on the wheel (his dials page is
/// seventeen rows).
///
/// ⚖️ RAM (his design, 2026-09-11 - read ram_cost / ram_used /
/// ram_throttle). Every automation costs sticks and the budget shows
/// in a band under the title on EVERY tab; hovering a row shows what
/// it costs as red sticks pulsing on the meter. Over budget nothing
/// stops - every clock slows by cap/used, and the band says so. Each
/// autobuy has its own timer (1s..30s, 30s the default; faster costs
/// more), the three machines - the dials' cycling, the fabricator, the
/// automerger - have speed sliders (5..100%, a stick per 20%), the
/// autorebirth has ONE master switch that costs (its rails are free
/// conditions), and the overview totals it all and holds presets.
///
/// DRAW-ONLY PLUS REGION HITS, all off the geometry declared here. The
/// sliders are drawn tracks with a drag handled in the Step rather than
/// the settings screen's bound widget instances: those exist to keep a
/// LIST of heterogeneous rows in sync, and this screen has fixed pages
/// where the geometry is known at build time.

autom_init();
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by automation_close; the Step destroys at zero

bby     = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar
band_y  = bby + 16;          // the RAM band, under the title strip
band_h  = 12;
list_y  = band_y + band_h;
rail_w  = 72;
cont_x  = rail_w + 6;
cont_w  = room_width - cont_x - 8;

tab   = 0;
tabs  = ["overview", "dials", "rebirth", "upgrades", "tiles"];
tcol  = [c_gold, c_sblue, c_hred, c_lavender, c_seagreen];
NTAB  = 5;
#macro AT_OVER  0
#macro AT_DIALS 1
#macro AT_REB   2
#macro AT_UPG   3
#macro AT_TILES 4

// the page scroll, in rows, one per tab - a page taller than the
// room rolls on the wheel; __row_y subtracts it, and rows off either
// end are skipped by the Draw and the Step alike
scroll = array_create(NTAB, 0);

// THE RARITY CHIPS on the upgrades page: eight of them across one row,
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

row_h = 12;
row_p = 14;
top_y = list_y + 6;
/// rows that fit between the top and the footer band
__rows_fit = function() { return floor((room_height - 30 - top_y) / row_p); };

// the drag in progress: which control, so a slider keeps the pointer
// even when it slides off its own track (the settings screen's rule -
// a knob you can lose by moving too fast is a knob that fights you)
drag_row   = -1;   // -1 = nothing being dragged
drag_tab   = 0;
drag_which = 0;    // 0 the wide track, 1 the timer track, 2 the cap track
drag_lo    = 0;
drag_hi    = 100;

// the hover, for the meter (the Draw finds it; the band reads it)
hov     = -1;
hov_ram = 0;
hov_on  = false;

__tab_rect = function(_i) {
	return { x : 2, y : list_y + 3 + _i * 20, w : rail_w - 6, h : 17 };
};

// ---- one row's furniture, shared by Draw and Step ----
// A row is: label, a toggle pill, a slider track, a readout, and on
// the autobuy rows a second, shorter track for the timer. Not every
// row uses all of it; the ones that do all put it in the same place,
// which is the only reason a page of them is readable.
tog_x = 0; tog_w = 30;
trk_x = 0; trk_w = 150;     // the wide track (kinds 1 and 2)
cap_x = 0; cap_w = 76;      // the cap track (kind 5)...
tm_x  = 0; tm_w  = 56;      // ...and the timer track beside it
btn_w = 40; btn_h = 10;     // the overview's action buttons
__seat = function() {
	tog_x = cont_x + 96;
	trk_x = cont_x + 134;
	// 96 rather than 60: a dial row shows BOTH a percentage readout and
	// a verdict pill, and they were being right-aligned to the same
	// pixel - the pill drew straight over the number
	trk_w = cont_w - 134 - 96;
	cap_x = cont_x + 132;
	tm_x  = cont_x + 240;
};
__seat();
__chip_seat();

__row_y  = function(_i) { return top_y + (_i - scroll[tab]) * row_p; };
/// is row _i on the page (not scrolled off either end)?
__row_vis = function(_i) {
	var _k = _i - scroll[tab];
	return (_k >= 0 && _k < __rows_fit());
};
__tog_r  = function(_i) { return { x : tog_x, y : __row_y(_i) + 1, w : tog_w, h : 10 }; };
__trk_r  = function(_i) { return { x : trk_x, y : __row_y(_i) + 4, w : trk_w, h : 5 }; };
__cap_r  = function(_i) { return { x : cap_x, y : __row_y(_i) + 4, w : cap_w, h : 5 }; };
__tm_r   = function(_i) { return { x : tm_x,  y : __row_y(_i) + 4, w : tm_w,  h : 5 }; };
/// the k-th button of an action row (n of them), packed from the right
__btn_r  = function(_i, _k, _n) {
	return { x : cont_x + cont_w - (_n - _k) * (btn_w + 4),
	         y : __row_y(_i) + 1, w : btn_w, h : btn_h };
};

// a slider's value from the pointer, snapped to whole units
__slide = function(_r, _lo, _hi) {
	return round(lerp(_lo, _hi, clamp((mouse_x - _r.x) / max(1, _r.w), 0, 1)));
};

// ---- the RAM meter's geometry: one stick per unit, sized to fit ----
stk_x0 = 62; stk_w = 4; stk_gap = 1;
__stick_seat = function(_n) {
	var _room = room_width - stk_x0 - 96;   // the throttle readout keeps the right
	stk_w = clamp(floor(_room / max(1, _n)) - 1, 2, 5);
};
__stick_r = function(_k) {
	return { x : stk_x0 + _k * (stk_w + stk_gap), y : band_y + 2, w : stk_w, h : band_h - 4 };
};

/// what a page's automations cost right now, for the overview
__ram_page = function(_t) {
	var _a = g.autom;
	var _u = 0;
	if (_t == AT_DIALS) {
		if (_a.tap.on) _u += ram_cost("speed", _a.tap.rate * 10);
		if (_a.run.on) _u += ram_cost("speed", _a.run.spd);
		for (var _i = 0; _i < array_length(_a.dial); _i++)
			if (_a.dial[_i].on) _u += ram_cost("timer", _a.dial[_i].t);
	}
	if (_t == AT_REB)  if (_a.reb.on) _u += ram_cost("rebirth");
	if (_t == AT_UPG) {
		if (_a.upg.roll) _u += 1;
		if (_a.upg.sell) _u += 1;
		if (_a.upg.buy)  _u += ram_cost("timer", _a.upg.t);
	}
	if (_t == AT_TILES) {
		if (_a.fab.on) _u += ram_cost("speed", _a.fab.spd);
		if (variable_global_exists("tiles") && g.tiles.automerge) _u += ram_cost("speed", _a.am_speed);
		var _tn = variable_struct_get_names(_a.tiles);
		for (var _i = 0; _i < array_length(_tn); _i++)
			if (_a.tiles[$ _tn[_i]].on) _u += ram_cost("timer", _a.tiles[$ _tn[_i]].t);
	}
	return _u;
};

/// a section band, with an optional button at its right (btn + act)
__section = function(_name, _col, _btn = "", _act = "") {
	return { kind : 8, name : _name, on : true, val : 0, st : -1, col : _col, ram : 0,
	         help : "", btn : _btn, act : _act };
};

/// the dial rows' readout in the DRAWER's own view (g.display_gps: 0 p/c,
/// 1 p/s, 2 the share of the fleet) - his ask, 2026-09-11: the drawer's
/// view button brought over, and it IS the drawer's setting, so the
/// two pages can never show different figures. The share is the
/// drawer's law verbatim (log space; hidden under 10/s)
__dial_readout = function(_d) {
	var _m = variable_global_exists("display_gps") ? g.display_gps : 1;
	if (_m == 0) return (_d.gpc >= arb(1)) ? (crunch_arb(_d.gpc) + "/c") : "-";
	if (_m == 2) {
		if (!(g.all_gps_raw >= arb(10)) || !(_d.gps >= arb(1))) return "-";
		var _lg = arb_log10(_d.gps) - arb_log10(g.all_gps_raw) + 2;
		return (_lg >= 0) ? (crunch_arb(log_to_arb(_lg)) + "%") : ("-E" + string(round(abs(_lg))));
	}
	return (_d.gps >= arb(1)) ? (crunch_arb(_d.gps) + "/s") : "-";
};
__view_label = function() {
	var _m = variable_global_exists("display_gps") ? g.display_gps : 1;
	return (_m == 0) ? "p/c" : ((_m == 1) ? "p/s" : "%");
};

// ==================================================================
// THE PAGES, declared once and read by both the Step and the Draw.
// Region law: one description of what a page contains, so a hit test
// can never disagree with what was painted.
//   kind 0 = toggle only            1 = slider only (wide)
//        2 = toggle + slider (wide) 3 = the rarity chip strip
//        4 = keep/sell flag         5 = toggle + cap + TIMER (autobuy)
//        6 = an info line (val, and `right` at the row's end)
//        7 = action buttons (btns[], act)   8 = a section band
// every row carries `ram`: what it costs on (or would cost, off) - the
// meter's hover preview reads it, so the price shown is the price paid
// ==================================================================
__page_rows = function() {
	var _o = [];
	var _a = g.autom;

	if (tab == AT_OVER) {
		var _u = ram_used(), _c = ram_cap(), _th = ram_throttle();
		array_push(_o, { kind : 6, name : "ram",
			val : string(_u) + " of " + string(_c) + " sticks in use",
			right : (_th < 1) ? ("over budget - everything runs at x" + string_format(_th, 1, 2))
			                  : (string(_c - _u) + " free"),
			on : true, st : -1, col : c_gold, ram : 0,
			help : "every automation costs sticks. over the budget nothing "
			     + "switches off - every clock runs at cap / used instead. "
			     + "rebirths bank +" + string(RAM_REB) + " each" });

		array_push(_o, __section("running", c_gold));
		var _dn = 0;
		for (var _i = 0; _i < array_length(_a.dial); _i++) if (_a.dial[_i].on) _dn++;
		var _bst = "";
		if (variable_global_exists("dial")) {
			var _bi = -1;
			for (var _i = 0; _i < g.dial_total; _i++)
				if (g.dial[_i].gps >= arb(1) && (_bi == -1 || g.dial[_i].gps > g.dial[_bi].gps)) _bi = _i;
			if (_bi >= 0) _bst = "  -  strongest: " + dial_config(_bi).name + " " + crunch_arb(g.dial[_bi].gps) + "/s";
		}
		array_push(_o, { kind : 6, name : "dials",
			val : (_a.tap.on ? ("autotap " + string(_a.tap.rate) + "/s  -  ") : "")
			    + (_a.run.on ? ("cycling " + string(_a.run.spd) + "%") : "cycling off (manual)")
			    + "  -  " + string(_dn) + " autobuy" + ((_dn == 1) ? "" : "s") + _bst,
			right : string(__ram_page(AT_DIALS)) + " ram",
			on : true, st : -1, col : tcol[AT_DIALS], ram : 0, help : "" });
		var _r = _a.reb;
		var _rails = (_r.t_on || _r.u_on || _r.g_on || _r.c_on || _r.p_on);
		array_push(_o, { kind : 6, name : "rebirth",
			val : _r.on ? (_rails ? "on, rails armed" : "on, NO RAIL ARMED - it will not fire") : "off",
			right : string(__ram_page(AT_REB)) + " ram",
			on : true, st : -1, col : tcol[AT_REB], ram : 0, help : "" });
		var _g = _a.upg;
		var _ut = "";
		if (_g.roll) _ut += "roll";
		if (_g.buy)  _ut += ((_ut == "") ? "" : ", ") + "buy " + string(_g.t) + "s";
		if (_g.sell) _ut += ((_ut == "") ? "" : ", ") + "sell";
		array_push(_o, { kind : 6, name : "upgrades",
			val : (_ut == "") ? "off" : _ut,
			right : string(__ram_page(AT_UPG)) + " ram",
			on : true, st : -1, col : tcol[AT_UPG], ram : 0, help : "" });
		var _tn = 0;
		var _tk = variable_struct_get_names(_a.tiles);
		for (var _i = 0; _i < array_length(_tk); _i++) if (_a.tiles[$ _tk[_i]].on) _tn++;
		var _am = variable_global_exists("tiles") && g.tiles.automerge;
		array_push(_o, { kind : 6, name : "tiles",
			val : (_a.fab.on ? ("fabricator " + string(_a.fab.spd) + "%") : "fabricator off")
			    + "  -  " + (_am ? ("merge " + string(_a.am_speed) + "%") : "merge off")
			    + "  -  " + string(_tn) + " autobuy" + ((_tn == 1) ? "" : "s"),
			right : string(__ram_page(AT_TILES)) + " ram",
			on : true, st : -1, col : tcol[AT_TILES], ram : 0, help : "" });

		array_push(_o, __section("presets", c_gold));
		array_push(_o, { kind : 7, name : "defaults",
			val : "cycling + fabricator on at 100%, nothing else",
			btns : ["load"], act : "defaults",
			on : true, st : -1, col : c_white, ram : 0,
			help : "the shipped setup: the two machines on, no autobuys, no rebirth" });
		for (var _k = 0; _k < 3; _k++) {
			var _has = (_a.presets[_k] != "");
			array_push(_o, { kind : 7, name : "preset " + string(_k + 1),
				val : _has ? "saved" : "empty",
				btns : _has ? ["load", "save"] : ["save"], act : "preset", k : _k,
				on : _has, st : -1, col : c_white, ram : 0,
				help : "save keeps the whole setup here - every switch, cap, "
				     + "timer and speed; load restores it" });
		}
		return _o;
	}

	if (tab == AT_DIALS) {
		// THE AUTOTAPPER (his ask, 2026-09-11) heads the page: the
		// tapper is the money room's first machine
		array_push(_o, __section("tap process automation", tcol[AT_DIALS]));
		array_push(_o, { kind : 2, lo : 1, hi : 10, name : "auto tap",
			on : _a.tap.on, val : _a.tap.rate, sfx : " taps/s", st : -1,
			col : c_gold, ram : ram_cost("speed", _a.tap.rate * 10),
			help : "taps the money room for you, that many a second - a stick "
			     + "per 2 taps/s. its taps are not counted as yours" });
		array_push(_o, __section("dial process automation", tcol[AT_DIALS]));
		array_push(_o, { kind : 2, lo : 5, hi : 100, name : "cycling",
			on : _a.run.on, val : _a.run.spd, sfx : "% speed", st : -1,
			col : c_sgreen, ram : ram_cost("speed", _a.run.spd),
			help : "the dials running on their own - slower is cheaper, off "
			     + "makes every dial manual" });
		array_push(_o, __section("autobuy", tcol[AT_DIALS], __view_label(), "view"));
		// THE RESERVE heads the autobuys, because it is the counterweight
		// to everything under it: autobuy spends profit, and this is the
		// share autobuy may not touch.
		array_push(_o, {
			kind : 1, lo : 0, hi : 90,
			name : "reserve",
			on   : (_a.lock_pct > 0),
			val  : _a.lock_pct,
			// ⚖️ "% held", not "% of profit" (his report: "the slider feels
			// backwards"). Every other percentage on this page is a
			// spending CAP where bigger means spends more.
			sfx  : "% held",
			st   : -1,
			col  : c_gold, ram : 0,
			help : "held out of spending: this share of the HIGHEST pile "
			     + "you have held this run. turn it down to release it",
		});
		if (!variable_global_exists("dial")) return _o;
		var _n = min(g.dial_total, array_length(_a.dial));
		// WHICH DIALS ARE THE STRONGEST (his ask, 2026-09-11): each row
		// carries the dial's own p/s, and the best of them is marked -
		// the number you need to decide where the autobuy goes
		var _best = -1;
		for (var _i = 0; _i < _n; _i++) {
			var _gp = g.dial[_i].gps;
			if (_gp >= arb(1) && (_best == -1 || _gp > g.dial[_best].gps)) _best = _i;
		}
		for (var _i = 0; _i < _n; _i++) {
			var _p = _a.dial[_i];
			array_push(_o, {
				kind : 5, lo : 1, hi : 100,
				name : "dial " + dial_config(_i).name,
				sub  : __dial_readout(g.dial[_i]),
				top  : (_i == _best),
				on   : _p.on,
				val  : _p.pct,
				t    : _p.t,
				sfx  : "%",
				st   : _p.st,
				col  : dial_color(_i), ram : ram_cost("timer", _p.t),
				help : "cap % of spendable profit per buy - timer: secs between "
				     + "tries, faster costs ram",
			});
		}
	}

	if (tab == AT_REB) {
		var _r = _a.reb;
		// ONE MASTER SWITCH costs the RAM; the rails under it are free
		// conditions, and it needs at least one of them armed to fire
		array_push(_o, { kind : 0, name : "auto rebirth",
			on : _r.on, val : 0, sfx : "", st : -1, col : c_hred,
			ram : ram_cost("rebirth"),
			help : "the switch. it fires only when every armed rail below passes "
			     + "- and never while this page is open" });
		array_push(_o, __section("rails - every armed one must pass", c_hred));
		array_push(_o, { kind : 2, lo : 1, hi : 240, name : "run length",
			on : _r.t_on, val : _r.t_min, sfx : "m", st : -1, col : c_hred, ram : 0,
			help : "at least this long into the run" });
		array_push(_o, { kind : 2, lo : 1, hi : 500, name : "units gained",
			on : _r.u_on, val : _r.u_min, sfx : "", st : -1, col : c_hred, ram : 0,
			help : "the press would award at least this many" });
		array_push(_o, { kind : 2, lo : 1, hi : 200, name : "gain vs held",
			on : _r.g_on, val : _r.g_pct, sfx : "%", st : -1, col : c_hred, ram : 0,
			help : "the award is at least this much of what you hold" });
		array_push(_o, { kind : 2, lo : 1, hi : 60, name : "profit reach",
			on : _r.p_on, val : _r.p_oom, sfx : " ooms", st : -1, col : c_hred, ram : 0,
			help : "profit has passed 10^this" });
		array_push(_o, { kind : 0, name : "no timeclamp",
			on : _r.c_on, val : 0, sfx : "", st : -1, col : c_hred, ram : 0,
			help : "wait until the early-run penalty has expired" });
	}

	// ---- THE UPGRADE TABLE, filter included (his call: the filter is
	// this page's own business) ----
	if (tab == AT_UPG) {
		var _u = _a.upg;
		array_push(_o, __section("upgrade table automation", tcol[AT_UPG]));
		array_push(_o, { kind : 0, name : "auto roll",
			on : _u.roll, val : 0, sfx : "", st : -1, col : c_sblue, ram : 1,
			help : "fills every empty slot, once a second" });
		array_push(_o, { kind : 5, lo : 1, hi : 100, name : "auto buy",
			on : _u.buy, val : _u.pct, t : _u.t, sfx : "%", st : -1,
			col : c_sgreen, ram : ram_cost("timer", _u.t),
			help : "buys a tier while its price fits that share of credits - "
			     + "timer: secs between tries" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto sell",
			on : _u.sell, val : _u.keep, sfx : "% quick-set", st : -1,
			col : c_lavender, ram : 1,
			help : "sells what the filter below rejects - drag to set the "
			     + "rarity flags from the live odds" });
		array_push(_o, __section("filter - what auto sell rejects", tcol[AT_UPG]));
		array_push(_o, { kind : 3, name : "rarity", on : true, val : 0,
			sfx : "", st : -1, col : c_horange, ram : 0,
			help : "chips lit are kept - the dark ones get sold" });
		var _cfg = upgrade_config();
		for (var _i = 0; _i < array_length(_cfg); _i++) {
			var _e = _cfg[_i];
			array_push(_o, { kind : 4, name : _e.name,
				on : (_u.kind[$ _e.id] ?? true), val : 0, sfx : "",
				st : -1, col : _e.col, id : _e.id, ram : 0,
				help : _e.help });
		}
	}

	// ---- THE TILE TABLE ----
	if (tab == AT_TILES) {
		array_push(_o, __section("tile process automation", tcol[AT_TILES]));
		array_push(_o, { kind : 2, lo : 5, hi : 100, name : "fabricator",
			on : _a.fab.on, val : _a.fab.spd, sfx : "% speed", st : -1,
			col : c_seagreen, ram : ram_cost("speed", _a.fab.spd),
			help : "the table making tiles on its own - slower is cheaper, "
			     + "off makes nothing" });
		array_push(_o, { kind : 2, lo : 5, hi : 100, name : "auto merge",
			on : (variable_global_exists("tiles") && g.tiles.automerge),
			val : _a.am_speed, sfx : "% speed", st : -1, col : c_seagreen,
			ram : ram_cost("speed", _a.am_speed),
			help : "the table merging its lowest equal pair on its own clock - "
			     + "the speed scales that clock" });
		array_push(_o, __section("autobuy", tcol[AT_TILES]));
		var _tc = tile_upg_config();
		for (var _i = 0; _i < array_length(_tc); _i++) {
			var _e = _tc[_i];
			var _p = _a.tiles[$ _e.id];
			if (_p == undefined) continue;
			array_push(_o, { kind : 5, lo : 1, hi : 100,
				name : _e.name, on : _p.on, val : _p.pct, t : _p.t, sfx : "%",
				st : _p.st, col : c_seagreen, id : _e.id, ram : ram_cost("timer", _p.t),
				help : "cap % of the shards per buy - timer: secs between tries" });
		}
	}
	return _o;
};

// the toggle, per page and row (row indices follow __page_rows' order,
// section bands included)
__flip = function(_t, _i) {
	var _a = g.autom;
	if (_t == AT_DIALS) {
		// 0 band, 1 auto tap, 2 band, 3 cycling, 4 band, 5 reserve (no
		// toggle), 6.. the dials
		if (_i == 1) { _a.tap.on = !_a.tap.on; return; }
		if (_i == 3) { _a.run.on = !_a.run.on; return; }
		if (_i < 6) return;
		var _d = _a.dial[_i - 6];
		_d.on = !_d.on;
		if (!_d.on) _d.st = 0;
		return;
	}
	if (_t == AT_REB) {
		var _r = _a.reb;
		switch (_i) {
			case 0: _r.on   = !_r.on;   break;
			case 2: _r.t_on = !_r.t_on; break;
			case 3: _r.u_on = !_r.u_on; break;
			case 4: _r.g_on = !_r.g_on; break;
			case 5: _r.p_on = !_r.p_on; break;
			case 6: _r.c_on = !_r.c_on; break;
		}
		return;
	}
	if (_t == AT_UPG) {
		// 0 band, 1 roll, 2 buy, 3 sell, 4 band, 5 chips, 6.. the kinds
		var _u = _a.upg;
		switch (_i) {
			case 1: _u.roll = !_u.roll; return;
			case 2: _u.buy  = !_u.buy;  return;
			case 3: _u.sell = !_u.sell; return;
		}
		var _cfg = upgrade_config();
		var _k = _i - 6;
		if (_k < 0 || _k >= array_length(_cfg)) return;
		var _id = _cfg[_k].id;
		_u.kind[$ _id] = !(_u.kind[$ _id] ?? true);
		return;
	}
	if (_t == AT_TILES) {
		// 0 band, 1 fabricator, 2 merge, 3 band, 4.. the upgrades
		if (_i == 1) { _a.fab.on = !_a.fab.on; return; }
		if (_i == 2) {   // the automerger - the TABLE's flag, saved with it
			if (variable_global_exists("tiles")) g.tiles.automerge = !g.tiles.automerge;
			return;
		}
		var _tc = tile_upg_config();
		var _k = _i - 4;
		if (_k < 0 || _k >= array_length(_tc)) return;
		var _p = _a.tiles[$ _tc[_k].id];
		if (_p == undefined) return;
		_p.on = !_p.on;
		if (!_p.on) _p.st = 0;
	}
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
// drag, while the flags themselves stay the thing the runner reads.
__quickset = function() {
	var _fl = upgrade_keep_rarity();
	for (var _k = 0; _k < UPG_RARITY_N; _k++) g.autom.upg.rar[_k] = (_k >= _fl);
};

// the slider, per page and row. which: 0 the main track, 1 the timer
__set_slider = function(_t, _i, _v, _which = 0) {
	var _a = g.autom;
	if (_t == AT_DIALS) {
		if (_i == 1)      _a.tap.rate = clamp(_v, 1, 10);
		else if (_i == 3) _a.run.spd  = clamp(_v, 5, 100);
		else if (_i == 5) _a.lock_pct = clamp(_v, 0, 90);
		else if (_i >= 6) {
			if (_which == 1) _a.dial[_i - 6].t   = clamp(_v, RAM_TIMER_MIN, RAM_TIMER_MAX);
			else             _a.dial[_i - 6].pct = _v;
		}
		return;
	}
	if (_t == AT_REB) {
		var _r = _a.reb;
		switch (_i) {
			case 2: _r.t_min = _v; break;
			case 3: _r.u_min = _v; break;
			case 4: _r.g_pct = _v; break;
			case 5: _r.p_oom = _v; break;
		}
		return;
	}
	if (_t == AT_UPG) {
		var _u = _a.upg;
		switch (_i) {
			case 2: if (_which == 1) _u.t = clamp(_v, RAM_TIMER_MIN, RAM_TIMER_MAX); else _u.pct = _v; break;
			case 3: _u.keep = _v; __quickset(); break;
		}
		return;
	}
	if (_t == AT_TILES) {
		if (_i == 1) { _a.fab.spd  = clamp(_v, 5, 100); return; }
		if (_i == 2) { _a.am_speed = clamp(_v, 5, 100); return; }
		var _tc = tile_upg_config();
		var _k = _i - 4;
		if (_k < 0 || _k >= array_length(_tc)) return;
		var _p = _a.tiles[$ _tc[_k].id];
		if (_p == undefined) return;
		if (_which == 1) _p.t = clamp(_v, RAM_TIMER_MIN, RAM_TIMER_MAX);
		else             _p.pct = _v;
	}
};

// ---- the overview's actions ----
/// the shipped setup: the two machines on at full speed, every autobuy
/// and the rebirth off, caps and timers at their defaults
__defaults = function() {
	var _a = g.autom;
	_a.tap = { on : false, rate : 1, acc : 0 };
	_a.run = { on : true, spd : 100 };
	_a.fab = { on : true, spd : 100 };
	_a.am_speed = 100;
	if (variable_global_exists("tiles")) g.tiles.automerge = false;
	for (var _i = 0; _i < array_length(_a.dial); _i++) {
		var _d = _a.dial[_i];
		_d.on = false; _d.pct = 50; _d.t = 30; _d.st = 0;
	}
	var _r = _a.reb;
	_r.on = false;
	_r.t_on = false; _r.u_on = false; _r.g_on = false; _r.c_on = false; _r.p_on = false;
	var _u = _a.upg;
	_u.roll = false; _u.buy = false; _u.sell = false; _u.pct = 50; _u.keep = 50; _u.t = 30;
	var _tn = variable_struct_get_names(_a.tiles);
	for (var _i = 0; _i < array_length(_tn); _i++) {
		var _p = _a.tiles[$ _tn[_i]];
		_p.on = false; _p.pct = 50; _p.t = 30; _p.st = 0;
	}
	save_mark_dirty();
};

/// an action row's button was tapped: the row and which button
__action = function(_rw, _b) {
	if (_rw.act == "view") {
		// the drawer's view button: p/c > p/s > % - the drawer's own
		// setting, so it follows there too
		g.display_gps = ((variable_global_exists("display_gps") ? g.display_gps : 1) + 1) mod 3;
		save_mark_dirty();
		play_sound_ext(snd_softclick, .9, 1.1, .4, 1);
		return;
	}
	if (_rw.act == "defaults") {
		__defaults();
		play_sound_ext(snd_apply, .9, 1.1, .5, 1);
		assign_banner("automation reset to defaults", c_white, c_black);
		return;
	}
	if (_rw.act == "preset") {
		var _k = _rw.k;
		var _lbl = _rw.btns[_b];
		if (_lbl == "save") {
			g.autom.presets[_k] = autom_pack();
			save_mark_dirty();
			play_sound_ext(snd_apply, 1.0, 1.2, .5, 1);
			assign_banner("preset " + string(_k + 1) + " saved", c_white, c_black);
		} else if (_lbl == "load") {
			if (autom_unpack(g.autom.presets[_k])) {
				play_sound_ext(snd_apply, .9, 1.1, .5, 1);
				assign_banner("preset " + string(_k + 1) + " loaded", c_white, c_black);
			}
		}
	}
};
