/// @description stk_thr(s, l, i, lv) -> the energy-seconds level lv of sink (l, i) needs: base x the sink's thk (the wells are deep) x mult^lv (the geometric ladder) over the layer's reduction sinks
function stk_thr(_s, _l, _i, _lv) {
	var _kind = (_l == 0) ? "thr_en" : ((_l == 1) ? "thr_ae" : "thr_qu"), _cfg = stk_config()[_l][_i];
	return STK_THR_BASE * (_cfg[$ "thk"] ?? 1) * power(STK_THR_MULT, _lv) / stk_mult(_s, _kind);
}
