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
/// ⚖️ OVERCLOCK (his design, 2026-09-12 - read ram_oc). The [overclock]
/// chip in the RAM band opens three red notches past the end of every
/// "more is better" track - the speeds, the autotapper, every autobuy
/// timer - at x1.2 / x1.5 / x2 for x1.6 / x2.2 / x3 the price. While it
/// is open the normal range keeps RAM_OC_NF of the track and the
/// notches take the rest; off, the track is all normal again and
/// ram_oc_clamp drops anything that sat on a notch. THE TIMER TRACKS
/// RUN RIGHT = FASTEST (his call), so every track in the panel reads
/// "right = more automation" and the notches are always at the right.
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
rows_n = 0;   // this frame's row count (the scrollbar's lane reads it)

// THE HOUSE SCROLLBAR (his ask, 2026-09-13: "the scrollbar system in
// the automation needs to be our house smooth one"). Row mode against
// the page's row count; it owns the wheel (fenced to the content) and
// the touch drag and writes scroll[tab] as FRACTIONAL rows, so the page
// glides. A tab switch re-seats the bar on that tab's own scroll.
sb = create_obj(room_width - sprite_get_width(spr_scrollbar) - 1, list_y, obj_scrollbar);
sb.i = scrl_autom;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.wheel_x1 = cont_x; sb.wheel_x2 = room_width;
sb.image_yscale = (room_height - 30 - list_y) / sprite_get_height(spr_scrollbar);
sb.col = c_sblue;

// THE RARITY CHIPS on the upgrades page: eight of them across one row,
// seated off the content band so they fit whatever the ladder grows to.
chip_x0 = 0; chip_w = 0; chip_gap = 3;
__chip_seat = function() {
	var _n = max(1, UPG_RARITY_N);
	chip_x0 = cont_x + 56;
	chip_w  = floor((cont_x + cont_w - chip_x0 - (_n - 1) * chip_gap) / _n);
};
__chip_r = function(_k, _ry) {
	// the full row height less a px each side: 7px glyphs need 9 with
	// their air, and row_h - 4 clipped them (his report)
	return { x : chip_x0 + _k * (chip_w + chip_gap), y : _ry + 1,
	         w : chip_w, h : row_h - 2 };
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
drag_rw    = -1;   // the row struct at press time (the stops-tracks read it)
mode_open  = -1;   // the mode whose actions are folded out (one at a time)

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
tog_x = 0; tog_w = 36;      // wide enough for "waiting" - the autobuy rows' pill IS the verdict
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
	cap_x = cont_x + 138;
	tm_x  = cont_x + 246;
};
__seat();
__chip_seat();

__row_y  = function(_i) { return top_y + (_i - scroll[tab]) * row_p; };
/// is row _i on the page? With the bar's fractional scroll a row can
/// sit half under the band above (the strip and band draw OVER the
/// page, so that reads right) - but never past the footer line
__row_vis = function(_i) {
	var _k = _i - scroll[tab];
	return (_k > -1 && _k < __rows_fit());
};
/// ...and may it be TAPPED? Only once it is wholly clear of the band
__row_hit = function(_i) {
	var _k = _i - scroll[tab];
	return (_k >= -.05 && _k < __rows_fit());
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

// ---- THE OVERCLOCKABLE TRACKS (read ram_oc) ----
// a track's normal range keeps this share of its width while the
// notches are open, and all of it otherwise
__nf = function(_rw) {
	return (g.autom.oc && variable_struct_exists(_rw, "ock")) ? RAM_OC_NF : 1;
};
/// the STOPS of a snapping track: { v, f, k } - the value, where on the
/// track (0..1) it sits, and the notch it is (-1 for a normal stop).
/// The normal stops spread over the first __nf of the track, the
/// notches over the rest. Draw and Step both read this, so a notch is
/// drawn exactly where it is grabbed
__stops = function(_rw) {
	var _o = [];
	var _n = 0;
	for (var _v = _rw.lo; _v <= _rw.hi; _v += _rw.snap) _n++;
	var _nf = __nf(_rw);
	var _k = 0;
	for (var _v = _rw.lo; _v <= _rw.hi; _v += _rw.snap) {
		array_push(_o, { v : _v, f : ((_n > 1) ? (_k / (_n - 1)) : 0) * _nf, k : -1 });
		_k++;
	}
	if (_nf < 1)
		for (var _q = 0; _q < RAM_OC_N; _q++)
			array_push(_o, { v : ram_oc_value(_rw.ock, _q), f : _nf + (1 - _nf) * (_q + 1) / RAM_OC_N, k : _q });
	return _o;
};
/// where a value sits on a stops-track (the nearest stop's f)
__stop_f = function(_rw, _v) {
	var _st = __stops(_rw);
	var _bf = 0, _bd = 999999999;
	for (var _i = 0; _i < array_length(_st); _i++) {
		var _d = abs(_st[_i].v - _v);
		if (_d < _bd) { _bd = _d; _bf = _st[_i].f; }
	}
	return _bf;
};
/// the stop nearest the pointer on a stops-track
__stop_pick = function(_rw, _r) {
	var _f = clamp((mouse_x - _r.x) / max(1, _r.w), 0, 1);
	var _st = __stops(_rw);
	var _bv = _rw.lo, _bd = 999999999;
	for (var _i = 0; _i < array_length(_st); _i++) {
		var _d = abs(_st[_i].f - _f);
		if (_d < _bd) { _bd = _d; _bv = _st[_i].v; }
	}
	return _bv;
};
/// THE TIMER TRACK: right = fastest. Whole seconds RAM_TIMER_MAX..MIN
/// across the normal range, then the notches (1/1.2, 1/1.5, 1/2 s)
__tm_f = function(_rw, _t) {
	var _nf = __nf(_rw);
	if (_t >= RAM_TIMER_MIN)
		return clamp((RAM_TIMER_MAX - _t) / max(1, RAM_TIMER_MAX - RAM_TIMER_MIN), 0, 1) * _nf;
	return _nf + (1 - _nf) * (ram_oc_k("timer", _t) + 1) / RAM_OC_N;
};
__tm_pick = function(_rw, _r) {
	var _f  = clamp((mouse_x - _r.x) / max(1, _r.w), 0, 1);
	var _nf = __nf(_rw);
	if (_nf >= 1 || _f <= _nf)
		return clamp(round(lerp(RAM_TIMER_MAX, RAM_TIMER_MIN, _f / _nf)), RAM_TIMER_MIN, RAM_TIMER_MAX);
	// past the normal end: the nearest of {the end, the notches}
	var _bv = RAM_TIMER_MIN, _bd = abs(_f - _nf);
	for (var _q = 0; _q < RAM_OC_N; _q++) {
		var _sf = _nf + (1 - _nf) * (_q + 1) / RAM_OC_N;
		if (abs(_f - _sf) < _bd) { _bd = abs(_f - _sf); _bv = ram_oc_value("timer", _q); }
	}
	return _bv;
};
/// a timer's readout: whole seconds, or an overclocked fraction
__tm_str = function(_t) {
	return (_t >= RAM_TIMER_MIN) ? (string(_t) + "s") : (string_format(_t, 1, 2) + "s");
};
/// the value a press or drag lands on the row's track (which: 0 the
/// wide track, 1 the timer, 2 the cap)
__pick = function(_rw, _r, _which) {
	if (_which == 1) return __tm_pick(_rw, _r);
	if (_which == 0 && variable_struct_exists(_rw, "snap")) return __stop_pick(_rw, _r);
	return __slide(_r, _rw.lo, _rw.hi);
};
// the [overclock] chip in the RAM band, left of the verdict
__oc_rect = function() {
	return { x : room_width - 8 - 96 - 60, y : band_y + 1, w : 56, h : band_h - 2 };
};

// ---- the RAM meter's geometry: one stick per unit, sized to fit ----
stk_x0 = 62; stk_w = 4; stk_gap = 1;
__stick_seat = function(_n) {
	var _room = room_width - stk_x0 - 160;  // the verdict and the [overclock] chip keep the right
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
		if (_a.tap.on) _u += ram_cost("tap", _a.tap.rate);
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
	var _dim_c = rgb(120, 130, 150);

	if (tab == AT_OVER) {
		var _u = ram_used(), _c = ram_cap(), _th = ram_throttle();
		array_push(_o, { kind : 6, name : "ram",
			val : string(_u) + " of " + string(_c) + " sticks in use"
			    + (_a.oc ? (ram_oc_any() ? "  -  overclocked" : "  -  overclock open") : ""),
			right : (_th < 1) ? ("over budget - everything runs at x" + string_format(_th, 1, 2))
			                  : (string(_c - _u) + " free"),
			on : true, st : -1, col : c_gold, ram : 0,
			help : "every automation costs sticks. over the budget nothing "
			     + "switches off - every clock runs at cap / used instead. "
			     + "rebirths bank +" + string(RAM_REB) + " each" });

		// THE LEDGER (his list): the last few things automation did,
		// newest first, then the session's tallies per section
		var _st = _a.stat;
		array_push(_o, __section("ledger  -  this session", c_gold));
		var _ln = array_length(_a.ledger);
		if (_ln == 0)
			array_push(_o, { kind : 6, name : "", val : "nothing yet - switch something on",
				right : "", on : true, st : -1, col : _dim_c, ram : 0, help : "" });
		for (var _i = 0; _i < min(_ln, 6); _i++) {
			var _le = _a.ledger[_i];
			array_push(_o, { kind : 6, name : "", val : _le.txt, right : autom_ago(_le.at),
				on : true, st : -1, col : _le.col, ram : 0, help : "" });
		}
		array_push(_o, { kind : 6, name : "spent",
			val : "dials " + ((_st.dial_spent >= arb(1)) ? crunch_arb(_st.dial_spent) : "0") + " (" + string(_st.dial_n) + ")"
			    + "   tiles " + ((_st.tile_spent >= arb(1)) ? crunch_arb(_st.tile_spent) : "0") + " (" + string(_st.tile_n) + ")"
			    + "   upgrades " + ((_st.upg_spent >= arb(1)) ? crunch_arb(_st.upg_spent) : "0") + " cr (" + string(_st.upg_n) + ")"
			    + "   rebirths " + string(_st.reb_n),
			right : "since " + autom_ago(_st.since),
			on : true, st : -1, col : c_gold, ram : 0,
			help : "what automation spent this session, by section - and how many times it acted" });

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

		// STAFF (his list): every sprite and the machine it works - no
		// RAM, works offline, and it stops tapping the room while it is
		// on one (sprite_staff)
		if (variable_global_exists("sprites") && array_length(g.sprites) > 0) {
			array_push(_o, __section("staff  -  sprites on the machines", c_seagreen));
			for (var _k = 0; _k < array_length(g.sprites); _k++) {
				var _sp = g.sprites[_k];
				var _jobs = ["tap", "run", "fab", "merge", "tapper"];
				var _ji = 0;
				for (var _q = 0; _q < 5; _q++) if ((_sp[$ "job"] ?? "tap") == _jobs[_q]) _ji = _q;
				var _bn = SPRITE_STAFF * (1 + (_sp[$ "rar"] ?? 0));
				array_push(_o, { kind : 7, name : _sp.name,
					val : upgrade_rarity_info(_sp[$ "rar"] ?? 0).name + "  +" + string(round(_bn * 100)) + "%"
					    + (_sp.asleep ? "  zzz" : ((_sp[$ "trip"] ?? false) ? "  away" : "")),
					btns : ["room", "cycling", "fab", "merge", "tapper"], act : "staff", k : _k, sel : _ji,
					on : true, st : -1, col : _sp.col, ram : 0,
					help : "room: it taps the money room itself. a machine: its bonus rides "
					     + "that machine's rate instead - no ram, and it works while you are away" });
			}
		}

		// MODES (his list): only the ones you made; [+ new] saves the
		// current setup as another; one may be the AWAY mode
		array_push(_o, __section("modes", c_gold));
		array_push(_o, { kind : 7, name : "defaults",
			val : "cycling + fabricator on at 100%, nothing else",
			btns : ["load"], act : "defaults",
			on : true, st : -1, col : c_white, ram : 0,
			help : "the shipped setup: the two machines on, no autobuys, no rebirth" });
		// ⚖️ ONE ROW A MODE (his ask, 2026-09-13: "consolidate the buttons
		// to a drop-down thing that pulls them all out below the
		// preset"): the row is the name and its state, with a chevron;
		// tap it and its actions fold out on the row beneath
		for (var _k = 0; _k < array_length(_a.presets); _k++) {
			var _pm = _a.presets[_k];
			var _open = (mode_open == _k);
			array_push(_o, { kind : 7, name : _pm.name,
				val : _pm.offline ? "the away mode  -  used while you are gone" : "",
				btns : [], act : "mode_open", k : _k, chev : _open ? "^" : "v",
				on : true, st : -1, col : _pm.offline ? c_gold : c_white, ram : 0,
				help : "tap for its actions - load, save over it, mark it the away mode, delete" });
			if (_open)
				array_push(_o, { kind : 7, name : "",
					val : "",
					btns : ["load", "save", _pm.offline ? "away *" : "away", "delete"], act : "mode", k : _k,
					on : true, st : -1, col : _pm.offline ? c_gold : c_white, ram : 0,
					help : "load restores it, save overwrites it with the setup now, away "
					     + "marks it the mode used while you are offline, delete removes it" });
		}
		if (array_length(_a.presets) < 8)
			array_push(_o, { kind : 7, name : "new mode",
				val : "save the setup as it is now",
				btns : ["+ new"], act : "mode_new",
				on : true, st : -1, col : c_white, ram : 0,
				help : "every switch, cap, timer, speed, strategy and rail, as they are now" });
		return _o;
	}

	if (tab == AT_DIALS) {
		// THE AUTOTAPPER (his ask, 2026-09-11) heads the page: the
		// tapper is the money room's first machine
		array_push(_o, __section("tap process automation", tcol[AT_DIALS]));
		array_push(_o, { kind : 2, lo : 2, hi : 10, snap : 2, name : "auto tap", ock : "tap", tag : "tap",
			on : _a.tap.on, val : _a.tap.rate, sfx : " taps/s", st : -1,
			col : c_gold, ram : ram_cost("tap", _a.tap.rate),
			help : "taps the money room for you, that many a second (x your tps "
			     + "bonuses) - a stick per 2 taps/s; the red notches overclock it. "
			     + "its taps are not counted as yours" });
		array_push(_o, __section("dial process automation", tcol[AT_DIALS]));
		array_push(_o, { kind : 2, lo : 20, hi : 100, snap : 20, name : "cycling", ock : "speed", tag : "run",
			on : _a.run.on, val : _a.run.spd, sfx : "% speed", st : -1,
			col : c_sgreen, ram : ram_cost("speed", _a.run.spd),
			help : "the dials running on their own - slower is cheaper, the red "
			     + "notches overclock them. off FREEZES them where they are; hold "
			     + "the pointer on one to crank it by hand" });
		array_push(_o, __section("autobuy", tcol[AT_DIALS], __view_label(), "view"));
		// THE STRATEGY (his list): manual keeps a row per dial; the other
		// three share one row and walk the dials in their order
		array_push(_o, { kind : 7, name : "strategy", tag : "strat",
			val : ["a row per dial", "the best dial first, leftovers down the list",
			       "the cheapest level first, leftovers down the list", "every dial gets a turn at the front"][_a.strat],
			btns : ["manual", "strongest", "cheapest", "robin"], act : "strat", sel : _a.strat,
			on : true, st : -1, col : tcol[AT_DIALS], ram : 0,
			help : "how the autobuy spreads the cap share over the dials" });
		// THE RESERVE heads the autobuys, because it is the counterweight
		// to everything under it: autobuy spends profit, and this is the
		// share autobuy may not touch.
		array_push(_o, {
			kind : 1, lo : 0, hi : 90, tag : "reserve",
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
		// THE RAIL (his list): a profit floor under which every dial
		// autobuy holds its fire - the reserve's cousin, as a condition
		array_push(_o, { kind : 2, lo : 1, hi : 60, name : "only past 10^", tag : "rail_d",
			on : _a.rails.d_on, val : _a.rails.d_oom, sfx : " profit", st : -1, col : c_gold, ram : 0,
			help : "armed, the dial autobuys wait until the pile has passed this power of ten" });
		if (!variable_global_exists("dial")) return _o;
		var _n = min(g.dial_total, array_length(_a.dial));
		if (_a.strat != 0) {
			// ONE ROW for every dial, then the order it will walk them in
			var _sa = _a.dial_all;
			array_push(_o, { kind : 5, lo : 1, hi : 100, ock : "timer", tag : "dial_all",
				name : "all dials", on : _sa.on, val : _sa.pct, t : _sa.t, tic : _sa.tic, sfx : "%",
				st : _sa.st, col : tcol[AT_DIALS], ram : ram_cost("timer", _sa.t) * max(1, autom_strat_n()),
				help : "cap % of spendable profit per pulse, spread down the order - "
				     + "timer: secs between pulses; a stick-run per dial it watches" });
			var _ord = autom_order(_n);
			for (var _k = 0; _k < array_length(_ord); _k++) {
				var _i = _ord[_k];
				var _dd = g.dial[_i];
				var _why = (_a.strat == 2)
					? ("next lv " + crunch_arb(dial_cost(_i, _dd.level, _dd.level + 1)))
					: __dial_readout(_dd);
				array_push(_o, { kind : 6, name : string(_k + 1) + ".", val : "dial " + dial_config(_i).name
					+ ((_a.dial[_i].st == 2) ? "  -  bought" : ""), right : _why,
					on : true, st : -1, col : dial_color(_i), ram : 0, help : "" });
			}
			return _o;
		}
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
				kind : 5, lo : 1, hi : 100, ock : "timer", tag : "dial", k : _i,
				name : "dial " + dial_config(_i).name,
				sub  : __dial_readout(g.dial[_i]),
				top  : (_i == _best),
				on   : _p.on,
				val  : _p.pct,
				t    : _p.t,
				tic  : _p.tic,
				sfx  : "%",
				st   : _p.st,
				col  : dial_color(_i), ram : ram_cost("timer", _p.t),
				help : "cap % of spendable profit per buy - timer: secs between "
				     + "tries, right is faster and costs more ram",
			});
		}
	}

	if (tab == AT_REB) {
		var _r = _a.reb;
		// ONE MASTER SWITCH costs the RAM; the rails under it are free
		// conditions, and it needs at least one of them armed to fire
		var _eta = "";
		if (_r.on && variable_global_exists("rebirth")) {
			var _rc = rebirth_calc();
			if (_r.t_on && _rc.run_s < _r.t_min * 60) _eta = "time rail in " + crunch_time_long((_r.t_min * 60 - _rc.run_s) * 60);
			else if (_r.u_on && !(_rc.units >= arb(_r.u_min))) _eta = "units " + ((_rc.units >= arb(1)) ? crunch_arb(_rc.units) : "0") + " of " + string(_r.u_min);
			else if (_rc.cool > 0) _eta = "cooldown " + crunch_time_long(_rc.cool * 60);
			else if (_r.t_on || _r.u_on || _r.g_on || _r.c_on || _r.p_on) _eta = "rails passing - fires when you leave this page";
		}
		array_push(_o, { kind : 0, name : "auto rebirth", sub : _eta, tag : "reb",
			on : _r.on, val : 0, sfx : "", st : -1, col : c_hred,
			ram : ram_cost("rebirth"),
			help : "the switch. it fires only when every armed rail below passes "
			     + "- and never while this page is open" });
		array_push(_o, __section("rails - every armed one must pass", c_hred));
		array_push(_o, { kind : 2, lo : 1, hi : 240, name : "run length", tag : "reb_t",
			on : _r.t_on, val : _r.t_min, sfx : "m", st : -1, col : c_hred, ram : 0,
			help : "at least this long into the run" });
		array_push(_o, { kind : 2, lo : 1, hi : 500, name : "units gained", tag : "reb_u",
			on : _r.u_on, val : _r.u_min, sfx : "", st : -1, col : c_hred, ram : 0,
			help : "the press would award at least this many" });
		array_push(_o, { kind : 2, lo : 1, hi : 200, name : "gain vs held", tag : "reb_g",
			on : _r.g_on, val : _r.g_pct, sfx : "%", st : -1, col : c_hred, ram : 0,
			help : "the award is at least this much of what you hold" });
		array_push(_o, { kind : 2, lo : 1, hi : 60, name : "profit reach", tag : "reb_p",
			on : _r.p_on, val : _r.p_oom, sfx : " ooms", st : -1, col : c_hred, ram : 0,
			help : "profit has passed 10^this" });
		array_push(_o, { kind : 0, name : "penalty over", tag : "reb_c",
			on : _r.c_on, val : 0, sfx : "", st : -1, col : c_hred, ram : 0,
			help : "the timeclamp: a rebirth inside the first 5 minutes of a "
			     + "run pays only a fraction of its units. armed, it waits "
			     + "until that penalty has fully expired" });
	}

	// ---- THE UPGRADE TABLE, filter included (his call: the filter is
	// this page's own business) ----
	if (tab == AT_UPG) {
		var _u = _a.upg;
		array_push(_o, __section("upgrade table automation", tcol[AT_UPG]));
		array_push(_o, { kind : 0, name : "auto roll", tag : "upg_roll",
			on : _u.roll, val : 0, sfx : "", st : -1, col : c_sblue, ram : 1,
			help : "fills every empty slot, once a second" });
		array_push(_o, { kind : 5, lo : 1, hi : 100, name : "auto buy", ock : "timer", tag : "upg_buy",
			on : _u.buy, val : _u.pct, t : _u.t, tic : _u.tic, sfx : "%", st : -1,
			col : c_sgreen, ram : ram_cost("timer", _u.t),
			help : "buys a tier while its price fits that share of credits - "
			     + "timer: secs between tries, right is faster" });
		array_push(_o, { kind : 2, lo : 1, hi : 100, name : "auto sell", tag : "upg_sell",
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
			array_push(_o, { kind : 4, name : _e.name, tag : "upg_kind",
				on : (_u.kind[$ _e.id] ?? true), val : 0, sfx : "",
				st : -1, col : _e.col, id : _e.id, ram : 0,
				help : _e.help });
		}
	}

	// ---- THE TILE TABLE ----
	if (tab == AT_TILES) {
		array_push(_o, __section("tile process automation", tcol[AT_TILES]));
		array_push(_o, { kind : 2, lo : 20, hi : 100, snap : 20, name : "fabricator", ock : "speed", tag : "fab",
			on : _a.fab.on, val : _a.fab.spd, sfx : "% speed", st : -1,
			col : c_seagreen, ram : ram_cost("speed", _a.fab.spd),
			help : "the table making tiles on its own - slower is cheaper, the "
			     + "red notches overclock it, off makes nothing" });
		array_push(_o, { kind : 2, lo : 20, hi : 100, snap : 20, name : "auto merge", ock : "speed", tag : "merge",
			on : (variable_global_exists("tiles") && g.tiles.automerge),
			val : _a.am_speed, sfx : "% speed", st : -1, col : c_seagreen,
			ram : ram_cost("speed", _a.am_speed),
			help : "the table merging its lowest equal pair on its own clock - "
			     + "the speed scales that clock, the red notches overclock it" });
		array_push(_o, __section("autobuy", tcol[AT_TILES]));
		array_push(_o, { kind : 2, lo : 1, hi : 30, name : "only past 10^", tag : "rail_t",
			on : _a.rails.t_on, val : _a.rails.t_oom, sfx : " shards", st : -1, col : c_seagreen, ram : 0,
			help : "armed, the tile autobuys wait until the shards have passed this power of ten" });
		var _tc = tile_upg_config();
		for (var _i = 0; _i < array_length(_tc); _i++) {
			var _e = _tc[_i];
			var _p = _a.tiles[$ _e.id];
			if (_p == undefined) continue;
			array_push(_o, { kind : 5, lo : 1, hi : 100, ock : "timer", tag : "tile", id : _e.id,
				name : _e.name, on : _p.on, val : _p.pct, t : _p.t, tic : _p.tic, sfx : "%",
				st : _p.st, col : c_seagreen, id : _e.id, ram : ram_cost("timer", _p.t),
				help : "cap % of the shards per buy - timer: secs between tries, right is faster" });
		}
	}
	return _o;
};

// THE TOGGLE, by the row's TAG (2026-09-12: the rows used to be found
// by their index on the page, which broke the moment a page gained a
// row; every row carries a tag now and the strategy / rails / sprites
// rows slot in anywhere)
__flip_row = function(_rw) {
	var _a = g.autom;
	if (!variable_struct_exists(_rw, "tag")) return;
	switch (_rw.tag) {
		case "tap":  _a.tap.on = !_a.tap.on; return;
		case "run":  _a.run.on = !_a.run.on; return;
		case "fab":  _a.fab.on = !_a.fab.on; return;
		case "merge": if (variable_global_exists("tiles")) g.tiles.automerge = !g.tiles.automerge; return;
		case "dial": {
			var _d = _a.dial[_rw.k];
			_d.on = !_d.on;
			if (!_d.on) _d.st = 0;
			return;
		}
		case "dial_all": _a.dial_all.on = !_a.dial_all.on; if (!_a.dial_all.on) _a.dial_all.st = 0; return;
		case "rail_d": _a.rails.d_on = !_a.rails.d_on; return;
		case "rail_t": _a.rails.t_on = !_a.rails.t_on; return;
		case "reb":   _a.reb.on   = !_a.reb.on;   return;
		case "reb_t": _a.reb.t_on = !_a.reb.t_on; return;
		case "reb_u": _a.reb.u_on = !_a.reb.u_on; return;
		case "reb_g": _a.reb.g_on = !_a.reb.g_on; return;
		case "reb_p": _a.reb.p_on = !_a.reb.p_on; return;
		case "reb_c": _a.reb.c_on = !_a.reb.c_on; return;
		case "upg_roll": _a.upg.roll = !_a.upg.roll; return;
		case "upg_buy":  _a.upg.buy  = !_a.upg.buy;  return;
		case "upg_sell": _a.upg.sell = !_a.upg.sell; return;
		case "upg_kind": _a.upg.kind[$ _rw.id] = !(_a.upg.kind[$ _rw.id] ?? true); return;
		case "tile": {
			var _p = _a.tiles[$ _rw.id];
			if (_p == undefined) return;
			_p.on = !_p.on;
			if (!_p.on) _p.st = 0;
			return;
		}
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

// THE SLIDER, by the row's tag. which: 0 the main track, 1 the timer
__set_row = function(_rw, _v, _which = 0) {
	var _a = g.autom;
	if (!variable_struct_exists(_rw, "tag")) return;
	switch (_rw.tag) {
		case "tap":     _a.tap.rate = ram_snap("tap", _v); return;
		case "run":     _a.run.spd  = ram_snap("speed", _v); return;
		case "fab":     _a.fab.spd  = ram_snap("speed", _v); return;
		case "merge":   _a.am_speed = ram_snap("speed", _v); return;
		case "reserve": _a.lock_pct = clamp(_v, 0, 90); return;
		case "rail_d":  _a.rails.d_oom = clamp(_v, 1, 60); return;
		case "rail_t":  _a.rails.t_oom = clamp(_v, 1, 30); return;
		case "dial": {
			var _d = _a.dial[_rw.k];
			if (_which == 1) _d.t = ram_snap("timer", _v); else _d.pct = _v;
			return;
		}
		case "dial_all":
			if (_which == 1) _a.dial_all.t = ram_snap("timer", _v); else _a.dial_all.pct = _v;
			return;
		case "reb_t": _a.reb.t_min = _v; return;
		case "reb_u": _a.reb.u_min = _v; return;
		case "reb_g": _a.reb.g_pct = _v; return;
		case "reb_p": _a.reb.p_oom = _v; return;
		case "upg_buy":  if (_which == 1) _a.upg.t = ram_snap("timer", _v); else _a.upg.pct = _v; return;
		case "upg_sell": _a.upg.keep = _v; __quickset(); return;
		case "tile": {
			var _p = _a.tiles[$ _rw.id];
			if (_p == undefined) return;
			if (_which == 1) _p.t = ram_snap("timer", _v); else _p.pct = _v;
			return;
		}
	}
};

// ---- the overview's actions ----
/// the shipped setup: the two machines on at full speed, every autobuy
/// and the rebirth off, caps and timers at their defaults
__defaults = function() {
	var _a = g.autom;
	_a.tap = { on : false, rate : 2, acc : 0 };
	_a.run = { on : true, spd : 100 };
	_a.fab = { on : true, spd : 100 };
	_a.am_speed = 100;
	_a.oc = false;
	_a.strat = 0;
	_a.dial_all = { on : false, pct : 50, t : 30, tic : 0, st : 0, cur : 0 };
	_a.rails = { d_on : false, d_oom : 6, t_on : false, t_oom : 3 };
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
	if (_rw.act == "strat") {
		// the strategy pill: manual / strongest / cheapest / robin
		g.autom.strat = _b;
		g.autom.dial_all.cur = 0;
		save_mark_dirty();
		play_sound_ext(snd_softclick, 1, 1.1, .45, 1);
		return;
	}
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
	if (_rw.act == "staff") {
		var _sp = g.sprites[_rw.k];
		_sp.job = ["tap", "run", "fab", "merge", "tapper"][_b];
		save_mark_dirty();
		play_sound_ext(snd_softclick, 1, 1.1, .45, 1);
		return;
	}
	if (_rw.act == "mode_open") {
		mode_open = (mode_open == _rw.k) ? -1 : _rw.k;
		play_sound_ext(snd_softclick, (mode_open >= 0) ? 1.05 : .95, (mode_open >= 0) ? 1.15 : 1.05, .4, 1);
		return;
	}
	if (_rw.act == "mode_new") {
		var _nn = array_length(g.autom.presets) + 1;
		array_push(g.autom.presets, { name : "mode " + string(_nn), pack : autom_pack(), offline : false });
		save_mark_dirty();
		play_sound_ext(snd_apply, 1.0, 1.2, .5, 1);
		assign_banner("mode " + string(_nn) + " saved", c_white, c_black);
		return;
	}
	if (_rw.act == "mode") {
		var _k = _rw.k;
		if (_k < 0 || _k >= array_length(g.autom.presets)) return;
		var _pm = g.autom.presets[_k];
		switch (_b) {
			case 0:   // load
				if (autom_unpack(_pm.pack)) {
					play_sound_ext(snd_apply, .9, 1.1, .5, 1);
					assign_banner(_pm.name + " loaded", c_white, c_black);
				}
				break;
			case 1:   // save over it
				_pm.pack = autom_pack();
				save_mark_dirty();
				play_sound_ext(snd_apply, 1.0, 1.2, .5, 1);
				assign_banner(_pm.name + " saved", c_white, c_black);
				break;
			case 2: { // the away mode: one at a time
				var _was = _pm.offline;
				for (var _q = 0; _q < array_length(g.autom.presets); _q++) g.autom.presets[_q].offline = false;
				_pm.offline = !_was;
				save_mark_dirty();
				play_sound_ext(snd_softclick, _pm.offline ? 1.1 : .9, _pm.offline ? 1.2 : 1, .4, 1);
				break;
			}
			case 3:   // delete
				array_delete(g.autom.presets, _k, 1);
				mode_open = -1;
				save_mark_dirty();
				play_sound_ext(snd_matclick, .8, .9, .5, 1);
				break;
		}
	}
};
