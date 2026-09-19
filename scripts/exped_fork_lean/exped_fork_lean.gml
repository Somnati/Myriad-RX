/// @description exped_fork_lean(trip) -> the choice the crew makes on its own (an index into fork.choices) - THE STANCE decides, the leader leans it (q258; his call: stance only)
/// The odds of the check from its DC and the modifiers; the stance's
/// weight on a mishap (cautious x2.5 - and never a pass under seventy
/// percent; greedy x.6; steady x1); the LEADER (the first standing
/// member) by personality: brave and eager x.7, nervous and shy x1.6,
/// curious x.85, sleepy x1.2. A shortcut is taken when its hours plus the
/// weighted risk (a mishap costs road-hours: a pass or the tundra 4, a
/// marsh 3.5, hills 2.5, the rest 3) come under the road's. An
/// encounter: fight when the crew is whole enough for the stance (.85 /
/// .6 / .4 of its hp, the leader +-.15), else go round; a cautious crew
/// goes round whenever the odds are even
function exped_fork_lean(_tr) {
	var _fk = _tr.fork, _stn = exped_stance(_tr);
	var _sum = 0;
	for (var _i = 0; _i < array_length(_fk.mods); _i++) _sum += _fk.mods[_i].v;
	var _pok = clamp((21 - (_fk.dc - _sum)) / 20, .05, .95);
	var _lead = undefined;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) { _lead = exped_sprite(_tr.sids[_k]); break; }
	var _pl = sprite_personalities();
	var _pn = is_undefined(_lead) ? "" : _pl[clamp(_lead[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
	var _rk = (_stn.key == "cautious") ? 2.5 : ((_stn.key == "greedy") ? .6 : 1);
	if (_pn == "brave" || _pn == "eager") _rk *= .7;
	else if (_pn == "nervous" || _pn == "shy") _rk *= 1.6;
	else if (_pn == "curious") _rk *= .85;
	else if (_pn == "sleepy") _rk *= 1.2;
	// THE LEADER'S MOOD (q261): shaken, grieving or glum weighs the risk half again (the road); cocky halves it (the
	// pass on bad odds - confidence's own flaw); angry would rather fight than go round
	var _mw = is_undefined(_lead) ? "" : mood_word(_lead).key;
	if (_mw == "shaken" || _mw == "grieving" || _mw == "glum" || _mw == "tired") _rk *= 1.5;
	else if (_mw == "cocky") _rk *= .5;
	if (_fk.kind == "shortcut") {
		if (_stn.key == "cautious" && _pok < .7) return 0;
		var _cost = 3;
		switch (_fk.land) { case "mountains": case "tundra": _cost = 4; break; case "marsh": _cost = 3.5; break; case "hills": _cost = 2.5; break; }
		return (_fk.through + (1 - _pok) * _cost * _rk < _fk.road) ? 1 : 0;
	}
	var _hpf = 0, _n = 0;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) { _hpf += _tr.hp[_k] / max(1, _tr.hpmax[_k]); _n++; }
	_hpf = (_n > 0) ? _hpf / _n : 0;
	var _need = (_stn.key == "cautious") ? .85 : ((_stn.key == "greedy") ? .4 : .6);
	if (_pn == "brave" || _pn == "eager") _need -= .15;
	else if (_pn == "nervous" || _pn == "shy") _need += .15;
	if (_mw == "angry") _need -= .2; else if (_mw == "shaken" || _mw == "grieving") _need += .15;   // (the mood - q261)
	if (_stn.key == "cautious" && _pok >= .5) return 1;
	return (_hpf >= _need) ? 0 : 1;
}
