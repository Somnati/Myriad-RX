/// @description cbt_film(fight, target, dmg, txt) - one frame of the
/// fight's film: who was hit, for how much, everyone's hp after. The
/// combat window plays these back for a fight that ended while you were
/// elsewhere (syst_exped_panel's replay), and `last` is its flash.
/// side "a" i = the member's index, side "b" i = the foe's (php / fhps =
/// everyone's hp after). Eighty frames are kept.
/// @param target   the pawn hit (or healed); undefined = a plain line
function cbt_film(_f, _t, _dmg, _txt) {
	var _side = "b", _i = -1;
	if (!is_undefined(_t)) { _side = (_t.team == 0) ? "a" : "b"; _i = _t.k; }
	var _php = [], _fhps = [];
	for (var _q = 0; _q < array_length(_f.party); _q++) array_push(_php, _f.party[_q].hp);
	for (var _q = 0; _q < array_length(_f.foes);  _q++) array_push(_fhps, _f.foes[_q].hp);
	array_push(_f.ev, { side : _side, i : _i, dmg : _dmg,
		thp : is_undefined(_t) ? 0 : _t.hp, fhp : _f.b.hp, fhps : _fhps, txt : _txt, php : _php });
	if (array_length(_f.ev) > 80) array_delete(_f.ev, 0, 1);
	if (!is_undefined(_t) && _dmg > 0) _f.last = { side : _side, i : _i, dmg : _dmg, at : current_time };
}
