/// syst_welcome - THE WELCOME-BACK SCREEN (his ask, 2026-09-11: "all
/// the banners that show when i boot up need to go... a clean, easy on
/// the eyes welcome back screen"). One card in the middle of the money
/// room with the absence's story as label / value rows, on the overlay
/// contract every panel shares (oa / closing, ui_overlay lists it,
/// ui_blur_tick softens the room behind, the burger's X and escape
/// close it) - and a tap anywhere closes it too. Made by syst_offline
/// when a report is due; reads g.offline_report.

depth = -510;
oa      = 0;
closing = false;

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;

var _r = g.offline_report;
// ---- the rows: label / value / colour. Only what happened ----
rows = [];
array_push(rows, { l : "away",      v : crunch_time_long(_r.secs * 60), c : c_gold });
array_push(rows, { l : "earned",    v : "+" + ((_r.gain > 0) ? crunch_arb(_r.gain) : "0"), c : g.profit_color });
array_push(rows, { l : "idle rate", v : ((_r.rate > 0) ? crunch_arb(_r.rate) : "0") + "/s", c : color_set_comp(g.profit_color) });
var _bk = _r[$ "banked"] ?? 0;
if (_bk >= 1) array_push(rows, { l : "time bank", v : "+" + crunch_time_long(_bk * 60)
	+ ((_r[$ "bank_full"] ?? false) ? " (full)" : ""), c : c_gold });
if (_r[$ "bat_dry"] ?? false)
	array_push(rows, { l : "battery", v : "dry after " + crunch_time_long((_r[$ "bat_ran"] ?? 0) * 60), c : c_hred });
else
	array_push(rows, { l : "battery", v : "lasted", c : c_sgreen });
var _bo = _r[$ "bat_opt"] ?? 0;
if (_bo > 0) array_push(rows, { l : "optimiser", v : "x" + string_format(_bo, 1, 2), c : c_sgreen });
var _sn = _r[$ "sprite_n"] ?? 0;
if (_sn > 0) {
	var _st = _r[$ "sprite_taps"] ?? 0;
	array_push(rows, { l : (_sn == 1) ? "sprite" : ("sprites x" + string(_sn)),
		v : string(_st) + " taps" + ((_r.secs > SPRITE_NAP) ? ", asleep" : ""), c : c_sgreen });
}

// ---- the card: sized to the room (the money room is 144 wide in
// portrait, 480 in landscape) ----
row_p = 12;
cw = min(room_width - 16, 220);
ch = 30 + array_length(rows) * row_p + 26;
cx = (room_width - cw) * .5;
cy = max(hh + 8, (room_height - ch) * .5);
