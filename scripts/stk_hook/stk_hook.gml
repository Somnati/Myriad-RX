/// @description stk_hook() -> { spark, life, rate, cinders, turns, levels, caps } THE TIE-IN (q316), unwired by his ask. Ideas kept: energy's cap bought with PROFIT (the NGU way: the late-game sink), spark sold at the tap room's rate, the keystone's per read by the game's own multipliers (an all-bonus lane), the turn's cinders as a rebirth garnish, a sink whose bonus is a dial lane (resin) - the roster is append-only for exactly this
function stk_hook() {
	var _s = stk_init(), _lv = 0;
	for (var _l = 0; _l < array_length(_s.layers); _l++) for (var _i = 0; _i < array_length(_s.layers[_l].sinks); _i++) _lv += _s.layers[_l].sinks[_i].level;
	return { spark : _s.spark, life : _s.life, rate : stk_spark_rate(_s), cinders : _s.cinders, turns : _s.turns, levels : _lv, caps : [stk_cap(_s, 0), stk_cap(_s, 1), stk_cap(_s, 2)] };
}
