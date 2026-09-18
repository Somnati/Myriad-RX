/// syst_offlog - THE OFFLINE LOG (his ask, 2026-09-12: "tech demo had
/// an offline log... it needs to be clean and legible cause im sure it
/// will have lots of info... maybe even a debug version that i can swap
/// to in that screen that shows more detailed info"). Every absence
/// this session replayed, newest first, as a card: a header line (how
/// long, what triggered it, how long ago) and then SECTIONS of label /
/// value rows in the welcome card's language - only what happened.
/// The [debug] chip in the strip swaps every card for its raw form:
/// every snapshot offline_replay took, unrounded, plus a row of SIM
/// buttons that feed offline_replay for real (Techdemo II's bench,
/// labelled so). On the overlay contract every panel shares (oa /
/// closing, ui_overlay lists it, ui_blur_tick softens the room behind,
/// the burger's X and escape close it); cards scroll in pixels on the
/// house bar (the faq's frame). Reads g.offlog (offlog_init) - a view,
/// nothing here writes the sim.

offlog_init();
depth   = -510;   // over the room and its drawers, under the menu (-520) and the header (-1000)
oa      = 0;
closing = false;

hh     = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
land   = (room_width > 300);
list_y = hh + 16;                                   // under the title strip
sbw    = sprite_get_width(spr_scrollbar);
cx     = 4;                                         // the cards' x
cw     = room_width - cx - sbw - 5;                 // ...and width
lab_x  = cx + 10;                                   // a row's label
val_x  = cx + cw - 6;                               // a row's value, right-aligned
ind_x  = cx + 16;                                   // a sub-row's label (per dial / per sprite)
dim    = rgb(120, 130, 150);
scroll = 0;

// row heights (fnt is 7px + leading)
RH_HDR = 16;   // a run's header line
RH_SEC = 11;   // a section's name
RH_ROW = 10;   // label / value
RH_SUB = 9;    // a sub-row
RH_GAP = 5;    // between cards
RH_NOTE = 10;  // a plain line

// THE HOUSE SCROLLBAR (pixel mode against the cards' stacked height)
sb = create_obj(room_width - sbw - 1, list_y, obj_scrollbar);
sb.i = scrl_offlog;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.wheel_x1 = 0; sb.wheel_x2 = room_width;
sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
sb.col = c_sgreen;

// the strip's chips (the region law: Step's hits and Draw share these)
// (left of the x chip and the burger - it used to sit under the burger, so a
// press on it closed the log; his report, 2026-09-13)
__dbg_r = function() { return { x : room_width - 96, y : hh + 1, w : 42, h : 13 }; };
// the sim row (debug only): four chips under the strip, applied for real
sims = [[300, "5m"], [3600, "1h"], [28800, "8h"], [86400, "24h"]];
__sim_r = function(_i) {
	var _w = land ? 34 : 26, _gap = land ? 4 : 3;
	var _x0 = cx + (land ? 30 : 24);
	return { x : _x0 + _i * (_w + _gap), y : list_y + 3, w : _w, h : 12 };
};
__sim_h = function() { return g.offlog.debug ? 19 : 0; };   // the row's height when shown

// ---- formatters ----
__ar  = function(_a) { return (_a >= arb(1)) ? crunch_arb(_a) : "0"; };
__lg  = function(_a) { return (_a >= arb(1)) ? ("lg " + string_format(arb_log10(_a), 1, 3)) : "0"; };
__tm  = function(_s) { return crunch_time_long(_s * 60); };
__n   = function(_v, _d = 2) { return string_format(_v, 1, _d); };
__pct = function(_v) { return string(floor(_v)) + "%"; };
__st  = function(_s) {
	switch (_s) { case 0: return "locked"; case 1: return "producing"; case 2: return "full"; case 3: return "cooling"; }
	return string(_s);
};

/// @func __rows()
/// @desc THE ROW MODEL, rebuilt each frame from the ledger (a handful of
///       runs, a few hundred rows worst case - cheap). kinds:
///       hdr {run, e}, sec {txt, col}, row {l, v, col}, sub {l, v, col},
///       note {txt, col}, gap. Each carries its own height; the draw
///       and the scroll range agree by construction.
__rows = function() {
	var _out = [];
	var _runs = g.offlog.runs;
	var _dbg  = g.offlog.debug;
	var _pc   = g.profit_color;
	var _push = function(_o, _k, _h, _s) { _s.kind = _k; _s.h = _h; array_push(_o, _s); };
	if (array_length(_runs) == 0) {
		_push(_out, "note", RH_NOTE, { txt : "no absences yet this session", col : dim });
		_push(_out, "note", RH_NOTE, { txt : _dbg ? "press a sim button above to run one for real" : "the log fills when you come back from one", col : dim });
		return _out;
	}
	for (var _r = 0; _r < array_length(_runs); _r++) {
		var _e = _runs[_r];
		_push(_out, "hdr", RH_HDR, { run : _r, e : _e });

		// ---- profit ----
		var _p = _e[$ "profit"];
		if (!is_undefined(_p)) {
			_push(_out, "sec", RH_SEC, { txt : "profit", col : _pc });
			_push(_out, "row", RH_ROW, { l : "earned", v : "+" + __ar(_p.gain), col : _pc });
			_push(_out, "row", RH_ROW, { l : "idle rate", v : __ar(_p.rate) + "/s", col : color_set_comp(_pc) });
			if (_p.pool1 >= arb(1)) _push(_out, "row", RH_ROW, { l : "in the pile", v : __ar(_p.pool1) + (_dbg ? "" : " - tap it"), col : c_gold });
			if (_dbg) {
				_push(_out, "sub", RH_SUB, { l : "profit before", v : __lg(_p.before), col : dim });
				_push(_out, "sub", RH_SUB, { l : "gain", v : __lg(_p.gain), col : dim });
				_push(_out, "sub", RH_SUB, { l : "pool before > after", v : __lg(_p.pool0) + " > " + __lg(_p.pool1), col : dim });
				_push(_out, "sub", RH_SUB, { l : "all_gps", v : __lg(_p.rate), col : dim });
			}
		}

		// ---- time bank ----
		var _tb = _e[$ "tb"];
		if (!is_undefined(_tb) && (_tb.add >= 1 || _dbg)) {
			_push(_out, "sec", RH_SEC, { txt : "time bank", col : c_gold });
			_push(_out, "row", RH_ROW, { l : "banked", v : "+" + __tm(_tb.add) + (_tb.full ? " - full" : ""), col : _tb.full ? c_horange : c_gold });
			if (_dbg) {
				_push(_out, "sub", RH_SUB, { l : "bank before > after", v : __tm(_tb.bank0) + " > " + __tm(_tb.bank1) + " of " + __tm(_tb.cap), col : dim });
				_push(_out, "sub", RH_SUB, { l : "rate", v : __n(_tb.mph, 1) + " min per hour", col : dim });
				_push(_out, "sub", RH_SUB, { l : "away x rate", v : __n(_e.secs * _tb.mph / 60, 0) + "s owed, " + __n(_tb.add, 0) + "s kept", col : dim });
			}
		}

		// ---- battery ----
		var _b = _e[$ "bat"];
		if (!is_undefined(_b)) {
			_push(_out, "sec", RH_SEC, { txt : "battery", col : _b.dry ? c_hred : c_sgreen });
			if (_b.dry) _push(_out, "row", RH_ROW, { l : "ran dry", v : "after " + __tm(_e.cov), col : c_hred });
			else {
				var _left = floor(100 * _b.ch1 / max(1, _b.cap));
				_push(_out, "row", RH_ROW, { l : "charge left", v : __pct(_left), col : (_left < 25) ? c_horange : c_sgreen });
			}
			if (_b.opt > 0) _push(_out, "row", RH_ROW, { l : "optimiser", v : "x" + __n(_b.opt, 2) + " on the rates", col : c_sgreen });
			var _mach = (_b.run_on ? ("run " + string(round(_b.run))) : "run off")
			          + (_b.fab_on ? ("  fab " + string(round(_b.fab))) : "  fab off")
			          + (_b.merge_on ? ("  merge " + string(round(_b.merge))) : "  merge off");
			_push(_out, "row", RH_ROW, { l : "machines", v : _mach, col : sett_ink });
			if (_dbg) {
				_push(_out, "sub", RH_SUB, { l : "charge before > after", v : __tm(_b.ch0) + " > " + __tm(_b.ch1) + " of " + __tm(_b.cap), col : dim });
				_push(_out, "sub", RH_SUB, { l : "draw", v : __n(_b.draw, 4) + " charge/s", col : dim });
				_push(_out, "sub", RH_SUB, { l : "covered", v : __tm(_e.cov) + " of " + __tm(_e.secs), col : dim });
			}
		}

		// ---- dials ----
		var _dd = _e[$ "dials"];
		if (!is_undefined(_dd) && (array_length(_dd.paid) > 0 || _dbg)) {
			_push(_out, "sec", RH_SEC, { txt : "dials", col : c_sblue });
			_push(_out, "row", RH_ROW, { l : "paid out", v : string(array_length(_dd.paid)) + " of " + string(_dd.n), col : c_sblue });
			if (array_length(_dd.paid) > 0 && !_dbg) {
				var _top = _dd.paid[0];
				for (var _k = 1; _k < array_length(_dd.paid); _k++) if (_dd.paid[_k].amt > _top.amt) _top = _dd.paid[_k];
				_push(_out, "row", RH_ROW, { l : "top earner", v : "dial " + chr(ord("a") + _top.i) + "  +" + __ar(_top.amt), col : c_sblue });
			}
			if (_dbg)
				for (var _k = 0; _k < array_length(_dd.paid); _k++) {
					var _pd = _dd.paid[_k];
					_push(_out, "sub", RH_SUB, { l : "dial " + chr(ord("a") + _pd.i) + "  lv " + string(_pd.lv), v : "+" + __ar(_pd.amt) + "  " + __lg(_pd.amt), col : dim });
				}
		}

		// ---- tiles ----
		var _t = _e[$ "tiles"];
		if (!is_undefined(_t)) {
			var _fab = _t.made1 - _t.made0, _mg = _t.mg1 - _t.mg0;
			if (_fab > 0 || _mg > 0 || _dbg) {
				_push(_out, "sec", RH_SEC, { txt : "tiles", col : c_aqua });
				_push(_out, "row", RH_ROW, { l : "fabricated", v : "+" + string(_fab), col : c_aqua });
				// (the merge row only while the automerger is ON - his ask, 2026-09-17)
				if (_t[$ "merge_on"] ?? true)
					_push(_out, "row", RH_ROW, { l : "auto-merges", v : string(_mg), col : c_aqua });
				if (_t.hi1 > _t.hi0) _push(_out, "row", RH_ROW, { l : "highest tier", v : string(_t.hi0) + " > " + string(_t.hi1), col : c_gold });
				if (_t.sh1 > _t.sh0) _push(_out, "row", RH_ROW, { l : "shards", v : "+" + __ar(do_subtract(_t.sh1, _t.sh0)), col : c_aqua });
				if (_dbg) {
					_push(_out, "sub", RH_SUB, { l : "board rate before > after", v : __lg(_t.gps0) + " > " + __lg(_t.gps1), col : dim });
					_push(_out, "sub", RH_SUB, { l : "dial boost lg (the profit rung's)", v : __n(_t[$ "lg"] ?? (_t[$ "lgm"] ?? 0), 3), col : dim });   // (one constant across a replay - q231; an older entry's lgm read the same)
					_push(_out, "sub", RH_SUB, { l : "made lifetime", v : string(_t.made0) + " > " + string(_t.made1), col : dim });
					if (_t.bailed) _push(_out, "sub", RH_SUB, { l : "merge loop", v : "bailed on the budget", col : c_horange });
				}
			}
		}

		// ---- sprites ----
		var _sp = _e[$ "sprites"];
		if (!is_undefined(_sp) && array_length(_sp.list) > 0) {
			_push(_out, "sec", RH_SEC, { txt : (array_length(_sp.list) == 1) ? "sprite" : ("sprites x" + string(array_length(_sp.list))), col : c_sgreen });
			_push(_out, "row", RH_ROW, { l : "taps", v : string(_sp.taps) + ((_e.secs > SPRITE_NAP) ? "  - asleep now" : ""), col : c_sgreen });
			if (_dbg) {
				_push(_out, "sub", RH_SUB, { l : "attention", v : __tm(_sp.work) + " of work in " + __tm(_e.secs), col : dim });
				for (var _k = 0; _k < array_length(_sp.list); _k++) {
					var _s = _sp.list[_k];
					var _why = _s.trip ? "on a trip" : ((_s.job != "tap") ? ("on the " + _s.job) : (_s.asleep ? "asleep" : ""));
					_push(_out, "sub", RH_SUB, { l : _s.name + "  r" + string(_s.rar), v : string(_s.taps) + " taps" + ((_why != "") ? ("  " + _why) : ""), col : dim });
				}
			}
		}

		// ---- credits: the dropper's pool, the core ----
		var _c = _e[$ "credits"];
		if (!is_undefined(_c)) {
			var _poolup = (_c.pool1 > _c.pool0 + .01);
			var _coreup = (_c.lv > 0 && _c.st1 != _c.st0);
			if (_poolup || _coreup || _dbg) {
				_push(_out, "sec", RH_SEC, { txt : "credits", col : c_lavender });
				if (_poolup || _dbg) _push(_out, "row", RH_ROW, { l : "dropper pool", v : string(floor(_c.pool0)) + " > " + string(floor(_c.pool1)) + " of " + string(_c.cap), col : c_lavender });
				if (_c.lv > 0) {
					if (_c.st1 == 2) _push(_out, "row", RH_ROW, { l : "credit core", v : "full - collect it", col : c_lavender });
					else if (_coreup || _dbg) _push(_out, "row", RH_ROW, { l : "credit core", v : __st(_c.st0) + " > " + __st(_c.st1), col : c_lavender });
					if (_dbg) _push(_out, "sub", RH_SUB, { l : "well before > after", v : __n(_c.xp0, 2) + " > " + __n(_c.xp1, 2) + " of " + string(_c.ccap), col : dim });
				}
			}
		}

		// ---- the expedition ----
		var _x = _e[$ "exped"];
		if (!is_undefined(_x) && is_struct(_x.after) && variable_struct_exists(_x.after, "trips") && array_length(_x.after.trips) > 0) {
			_push(_out, "sec", RH_SEC, { txt : (array_length(_x.after.trips) == 1) ? "expedition" : "expeditions", col : c_steelblue });
			for (var _ti = 0; _ti < array_length(_x.after.trips); _ti++) {
				var _a = _x.after.trips[_ti];
				var _v = _a.home ? (_a.routed ? "limped home from " + _a.planet : "home from " + _a.planet + " - a haul waits")
				       : ((_a.stage == 0) ? ("travelling to " + _a.planet) : ((_a.stage == 1) ? (_a.planet + ": " + (_a[$ "where"] ?? "on the world")) : ("heading home from " + _a.planet)));
				_push(_out, "row", RH_ROW, { l : _a.name, v : _v, col : (_a.home && _a.routed) ? c_horange : c_steelblue });
				var _nl = min(array_length(_a.lines), _dbg ? 99 : 2);
				for (var _k = 0; _k < _nl; _k++) {
					var _lv = _a.lines[_k], _lp = string_copy(_lv, 1, 2);   // (the diary's prefixes - a header, the sky, the voice, a reward - are the panel's, not the report's; 2026-09-16)
					if (_lp == "# " || _lp == "* " || _lp == "~ " || _lp == "+ ") _lv = string_delete(_lv, 1, 2);
					_push(_out, "sub", RH_SUB, { l : "", v : _lv, col : sett_ink });
				}
			}
			if (_dbg) _push(_out, "sub", RH_SUB, { l : "out before > after / home", v : string(_x.before.n) + " > " + string(_x.after.n) + " / " + string(_x.after.homes), col : dim });
		}

		// ---- the away mode, and the replay's own facts ----
		if (_e.mode != "" || _dbg) {
			_push(_out, "sec", RH_SEC, { txt : "replay", col : dim });
			if (_e.mode != "") _push(_out, "row", RH_ROW, { l : "away mode", v : _e.mode, col : c_sblue });
			if (_dbg) {
				_push(_out, "sub", RH_SUB, { l : "returned", v : _e.when, col : dim });
				_push(_out, "sub", RH_SUB, { l : "away / covered", v : string(_e.secs) + "s / " + __n(_e.cov, 1) + "s", col : dim });
				_push(_out, "sub", RH_SUB, { l : "replay took", v : __n(_e.ms, 1) + " ms", col : dim });
			}
		}
		_push(_out, "gap", RH_GAP, {});
	}
	return _out;
};

__content_h = function() {
	var _rows = __rows();
	var _t = __sim_h();
	for (var _i = 0; _i < array_length(_rows); _i++) _t += _rows[_i].h;
	return _t + 6;
};

__scroll_max = function() {
	return max(0, __content_h() - (room_height - list_y - 4));
};
