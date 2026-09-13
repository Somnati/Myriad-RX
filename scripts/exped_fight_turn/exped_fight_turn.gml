/// @description exped_fight_turn(fight) - one turn: everyone still up
/// acts in initiative order (ties go to the crew). A member hits the
/// foe; the foe hits one of the crew at random; a hit can be countered.
/// Luck (luck_mod) leans the crew's rolls. Over when the foe falls
/// (won) or the whole crew is down (routed).
function exped_fight_turn(_f) {
	if (_f.over) return;
	_f.turn += 1;
	var _lm = luck_mod();
	// the order: the crew and the foe by initiative
	var _order = [];
	for (var _k = 0; _k < array_length(_f.party); _k++) array_push(_order, { side : "a", i : _k, init : _f.party[_k].init });
	array_push(_order, { side : "b", i : -1, init : _f.b.init });
	array_sort(_order, function(_p, _q) { return (_q.init - _p.init) != 0 ? sign(_q.init - _p.init) : ((_p.side == "a") ? -1 : 1); });
	for (var _o = 0; _o < array_length(_order); _o++) {
		if (_f.over) break;
		var _act = _order[_o];
		if (_act.side == "a") {
			var _m = _f.party[_act.i];
			if (_m.hp <= 0) continue;
			if (roll_perc(_m.hit * _lm)) {
				var _q = roll_perc(10 * _lm);
				var _dmg = _m.dmg * (_q ? 2 : 1);
				_f.b.hp = max(0, _f.b.hp - _dmg);
				array_push(_f.log, _m.name + (_q ? " lands a quality hit on " : " hits ") + _f.b.name + " for " + string(_dmg));
				_f.last = { side : "b", i : -1, dmg : _dmg, at : current_time };
				if (_f.b.hp > 0 && roll_perc(15)) {
					_m.hp = max(0, _m.hp - 1);
					array_push(_f.log, _f.b.name + " counters " + _m.name + " for 1");
					_f.last = { side : "a", i : _act.i, dmg : 1, at : current_time };
				}
			} else array_push(_f.log, _m.name + " misses");
		} else {
			if (_f.b.hp <= 0) continue;
			var _up = [];
			for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp > 0) array_push(_up, _k);
			if (array_length(_up) == 0) break;
			var _ti = _up[irandom(array_length(_up) - 1)];
			var _t = _f.party[_ti];
			if (roll_perc(_f.b.hit)) {
				_t.hp = max(0, _t.hp - _f.b.dmg);
				array_push(_f.log, _f.b.name + " hits " + _t.name + " for " + string(_f.b.dmg));
				_f.last = { side : "a", i : _ti, dmg : _f.b.dmg, at : current_time };
				if (_t.hp > 0 && roll_perc(15 * _lm)) {
					_f.b.hp = max(0, _f.b.hp - 1);
					array_push(_f.log, _t.name + " counters for 1");
					_f.last = { side : "b", i : -1, dmg : 1, at : current_time };
				}
			} else array_push(_f.log, _f.b.name + " misses " + _t.name);
		}
		var _alive = 0;
		for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp > 0) _alive++;
		if (_f.b.hp <= 0 || _alive == 0) {
			_f.over = true;
			_f.won  = (_f.b.hp <= 0 && _alive > 0);
			array_push(_f.log, _f.won ? (_f.b.name + " falls") : "the crew is routed");
		}
	}
	if (array_length(_f.log) > 12) array_delete(_f.log, 0, array_length(_f.log) - 12);
}
