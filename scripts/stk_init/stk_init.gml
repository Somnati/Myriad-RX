/// @description stk_init([force]) -> g.stk: THE STACK's state (q316) - three layers of sinks { alloc, prog, level }, the spark, the cap bought, the focus a layer, the cinders and the turns
function stk_init(_force = false) {
	if (!_force && variable_global_exists("stk") && is_struct(g.stk)) return g.stk;
	var _cfg = stk_config(), _layers = [];
	for (var _l = 0; _l < array_length(_cfg); _l++) {
		var _sinks = [];
		for (var _i = 0; _i < array_length(_cfg[_l]); _i++) array_push(_sinks, { alloc : 0, prog : 0, level : 0, ups : 0 });
		array_push(_layers, { sinks : _sinks, focus : -1 });
	}
	var _s = { spark : 0, life : 0, cap_lv : 0, cinders : 0, turns : 0, layers : _layers, last : universal_now(), rate : 0, rate_acc : 0, rate_t : 0, tab : 0 };
	g.stk = _s;
	return _s;
}
