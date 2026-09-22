/// @description syz_pack() -> the clockwork as one string for the save: the ledger, then every cycle as per:t:lv:anchor
function syz_pack() {
	var _s = syz_init(), _cy = "";
	for (var _i = 0; _i < array_length(_s.cycles); _i++) { var _c = _s.cycles[_i]; _cy += ((_i > 0) ? ";" : "") + string(_c.per) + ":" + string(_c.t) + ":" + string(_c.lv) + ":" + (_c.anchor ? "1" : "0"); }
	var _cj = "";
	for (var _i = 0; _i < array_length(_s.conj); _i++) _cj += ((_i > 0) ? "," : "") + string(_s.conj[_i]);
	return "1|" + string(_s.flux) + "|" + string(_s.life) + "|" + string(_s.tokens) + "|" + string(_s.harm) + "|" + string(_s.cap) + "|" + string(_s.drift_t) + "|" + string(_s.sync_cd) + "|" + string(_s.wobbles) + "|" + string(_s.syncs) + "|" + string(_s.grand) + "|" + string(_s.best) + "|" + string(_s.last) + "|" + _cy + "|" + _cj;
}
