/// rm_stack - THE STACK (q316; his ask: "use the NGU energy framework for your own new mechanic... a layered NGU energy
/// feature... as much depth / complexity as you can"). THE FRAMEWORK'S LAWS whole: energy is a budget, never spent;
/// allocation instant and free; progress = allocation x time; geometric thresholds; a bonus derives as level^0.75.
/// THE LAYERS: energy (its cap bought with spark, the stack's own coin, which its generator makes), aether (its cap IS
/// energy's well), quintessence (its cap IS aether's deep well) - every layer reaching down (speeds, thresholds, spark)
/// and up (the wells). FOCUS a sink; MILESTONES star a sink; PRESETS a layer; THE TURN banks cinders. The controller is a
/// VIEW: the state g.stk (stk_init), the runner stk_tick, the laws stk_*.
s = stk_init();
bby = obj_ui_header.sprite_height;
caught = stk_catchup(s);
note = ""; note_t = 0;
if (caught >= 60) { note = "away " + string(floor(caught / 60)) + " min: the stack ran on"; note_t = 6; }
tut = (s.life < 1 && s.turns == 0);
// ---- layout ----
tab_y = bby + 18;                     // the layer pills
band_y = tab_y + 16;                  // the layer's band: the cap bar, the speed, the cap buy
row_y0 = band_y + 26;                 // the first sink row
row_h = 24; row_gap = 1;
row_x = 6; row_w = room_width - 12;
bx_minus = row_x + row_w - 120; bx_num = bx_minus + 15; bx_plus = bx_num + 32; bx_max = bx_plus + 17; bx_clear = bx_max + 33;   // the cluster [-][n][+][max][0]
bar_x = row_x + 92; bar_w = bx_minus - 8 - bar_x;
foot_y = row_y0 + 6 * (row_h + row_gap) + 2;   // the presets, the turn, the line
rep_l = -1; rep_i = -1; rep_dir = 0; rep_t = 0;   // hold-to-repeat on the steppers
flash = 0;
__tab_r  = function(_l) { return { x : 6 + _l * 100, y : tab_y, w : 96, h : 13 }; };
__buy_r  = function() { return { x : room_width - 6 - 128, y : band_y + 1, w : 128, h : 15 }; };
__row_r  = function(_i) { return { x : row_x, y : row_y0 + _i * (row_h + row_gap), w : row_w, h : row_h }; };
__name_r = function(_i) { var _r = __row_r(_i); return { x : _r.x + 2, y : _r.y + 2, w : 86, h : 10 }; };
__btn    = function(_i, _bx, _w) { var _r = __row_r(_i); return { x : _bx, y : _r.y + 6, w : _w, h : 13 }; };
__even_r = function() { return { x : 6, y : foot_y, w : 52, h : 13 }; };
__chase_r = function() { return { x : 62, y : foot_y, w : 52, h : 13 }; };
__clear_r = function() { return { x : 118, y : foot_y, w : 40, h : 13 }; };
__turn_r = function() { return { x : room_width - 6 - 150, y : foot_y, w : 150, h : 13 }; };
__back_r = function() { return { x : room_width - 62, y : bby + 1, w : 56, h : 13 }; };
__hit    = function(_r) { return point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h); };
__open   = function(_l) { return (_l == 0) || (stk_cap(s, _l) > 0); };
/// the bonus, in words, for a sink
__bonus_txt = function(_l, _i) {
	var _cfg = stk_config()[_l][_i], _b = stk_bonus(s, _l, _i), _lv = s.layers[_l].sinks[_i].level;
	switch (_cfg.kind) {
		case "gen":  return string_format((stk_per(s, _l, _i) / 100) * ((_lv > 0) ? power(_lv, STK_BONUS_POW) : 0), 1, 2) + " spark/s";
		case "cap_ae": case "cap_qu": case "cap_en_flat": case "cap_ae_flat": case "cap_qu_flat": return "+" + string(stk_capof(s, _l, _i)) + " " + _cfg.what;
		case "thr_en": case "thr_ae": case "thr_qu": case "capcost": return "/" + string_format(_b, 1, 2) + " " + _cfg.what;
	}
	return "x" + string_format(_b, 1, 2) + " " + _cfg.what;
};
