/// rm_syzygy - SYZYGY (q315; his ask: "a new stand alone mechanic... only numbers / buttons / bars... abstract... depth
/// and complexity... fun and engaging"). CLOCKWORK: every cycle is a bar that fills over its period and FIRES when full;
/// fires in the same tick are a CONJUNCTION and each pays k times over. The player tunes the periods - factors shared
/// against long lone periods that pay well and meet nothing - buys cycles, levels, anchors against the drift, and the
/// sync (every cycle fires together in one second). The controller is a VIEW: the state is g.syz (syz_init), the sim
/// syz_tick, the ledger syz_cost / syz_buy, the readout syz_next.
s = syz_init();
bby = obj_ui_header.sprite_height;
y0 = bby + 20;                      // the first row's top
rh = 19;                            // a row's height (nine rows fit above the buttons)
caught = syz_catchup(s);
if (caught >= 60) syz_log(s, "away " + string(floor(caught / 60)) + " min: the clockwork ran on");
note = ""; note_t = 0;
next_t = 0;                         // the readout's refresh
tut = (s.life < 1);
// ---- geometry: a row is [period -][period][period +] [the bar] [lv] [lv +] [anchor] ----
__row_y  = function(_i) { return y0 + _i * rh; };
__per_m  = function(_i) { return { x : 6,   y : __row_y(_i) + 2, w : 13, h : 15 }; };
__per_p  = function(_i) { return { x : 46,  y : __row_y(_i) + 2, w : 13, h : 15 }; };
__bar_r  = function(_i) { return { x : 66,  y : __row_y(_i) + 2, w : 262, h : 15 }; };
__lv_r   = function(_i) { return { x : 334, y : __row_y(_i) + 2, w : 62, h : 15 }; };
__anc_r  = function(_i) { return { x : 402, y : __row_y(_i) + 2, w : 72, h : 15 }; };
__back_r = function() { return { x : room_width - 62, y : bby + 1, w : 56, h : 13 }; };
__sync_r = function() { return { x : 6, y : room_height - 44, w : 110, h : 15 }; };
__cyc_r  = function() { return { x : 122, y : room_height - 44, w : 110, h : 15 }; };
__harm_r = function() { return { x : 238, y : room_height - 44, w : 116, h : 15 }; };
__nin_r  = function() { return { x : 360, y : room_height - 44, w : 114, h : 15 }; };
__hit    = function(_r) { return point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h); };
/// what a row's hover means, in a line
__tip = function(_i) {
	var _c = s.cycles[_i], _y = syz_yield(s, _i);
	if (__hit(__per_m(_i)) || __hit(__per_p(_i))) return "the period: " + string(_c.per) + "s - a fire pays " + syz_num(_y) + " (" + string_format(_y / _c.per, 1, 2) + "/s alone); a second either way costs " + syz_num(syz_cost(s, "per", _i));
	if (__hit(__lv_r(_i))) return "the level: x1.18 a fire each - " + syz_num(syz_cost(s, "lv", _i)) + " flux";
	if (__hit(__anc_r(_i))) return _c.anchor ? "anchored: the drift cannot move this cycle" : ("an anchor holds the phase against the drift - " + syz_num(syz_cost(s, "anchor", _i)) + " flux");
	return "";
};
