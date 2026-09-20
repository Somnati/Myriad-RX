/// @description faction_mult(dest, ri, kind, [region], [boss]) -> { m, leaderless, str } the multiplier on a foe of this kind here (q283): FOE_LEADERLESS while the kind has no chief (foe_weak's law, folded in), and a BOSS or a named one besides at (1 - FAC_BOSS_CUT) + FAC_BOSS_CUT x the faction's strength - a gutted faction's king stands nearly alone
function faction_mult(_d, _ri, _kind, _rg = undefined, _boss = false) {
	var _out = { m : 1, leaderless : false, str : 1 };
	if (!is_string(_kind) || _kind == "") return _out;
	var _f = faction_get(_d, _ri, _kind, _rg);
	_out.str = _f.str;
	var _ss = g.exped[$ "seat"];
	if (is_struct(_ss)) {
		var _k = lane_key(_d, _ri), _v = _ss[$ _k], _s = _ss[$ _k + ":" + _kind];
		if ((is_struct(_v) && _v.left > 0 && (_v[$ "foe"] ?? "") == _kind) || (is_struct(_s) && _s.left > 0)) { _out.leaderless = true; _out.m *= FOE_LEADERLESS; }
	}
	if (_boss) _out.m *= (1 - FAC_BOSS_CUT) + FAC_BOSS_CUT * _f.str;
	return _out;
}
