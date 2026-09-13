/// @description exped_fight_turn(fight) - one turn: everyone still up
/// acts in initiative order (ties go to the crew). A member hits the
/// foe; the foe hits one of the crew at random; a hit can be countered.
/// Luck (luck_mod) leans the crew's rolls. Over when the foe falls
/// (won) or the whole crew is down (routed). The foe's damage and its
/// extra swings are REALS paid by a weighted coin (exped_fight_new).
function exped_fight_turn(_f) {
	if (_f.over) return;
	_f.turn += 1;
	var _lm = luck_mod();
	var _coin = function(_x) { return floor(_x) + ((random(1) < frac(_x)) ? 1 : 0); };
	// the film: a frame per swing, for the combat window's replay of a
	// fight that ended while you were elsewhere (syst_exped_panel)
	var _film = function(_f, _side, _i, _dmg, _txt) {
		if (!variable_struct_exists(_f, "ev")) _f.ev = [];
		var _thp = (_side == "a" && _i >= 0) ? _f.party[_i].hp : _f.b.hp;
		var _php = [];
		for (var _q = 0; _q < array_length(_f.party); _q++) array_push(_php, _f.party[_q].hp);
		array_push(_f.ev, { side : _side, i : _i, dmg : _dmg, thp : _thp, fhp : _f.b.hp, txt : _txt, php : _php });
		if (array_length(_f.ev) > 80) array_delete(_f.ev, 0, 1);
	};
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
				var _t1 = _m.name + (_q ? " lands a quality hit on " : " hits ") + _f.b.name + " for " + string(_dmg);
				array_push(_f.log, _t1);
				_f.last = { side : "b", i : -1, dmg : _dmg, at : current_time };
				_film(_f, "b", -1, _dmg, _t1);
				if (_f.b.hp > 0 && roll_perc(15)) {
					_m.hp = max(0, _m.hp - 1);
					var _t2 = _f.b.name + " counters " + _m.name + " for 1";
					array_push(_f.log, _t2);
					_f.last = { side : "a", i : _act.i, dmg : 1, at : current_time };
					_film(_f, "a", _act.i, 1, _t2);
				}
			} else { array_push(_f.log, _m.name + " misses"); _film(_f, "b", -1, 0, _m.name + " misses"); }
		} else {
			if (_f.b.hp <= 0) continue;
			var _swings = 1 + _coin(_f.b[$ "swings"] ?? 0);
			repeat (_swings) {
				var _up = [];
				for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp > 0) array_push(_up, _k);
				if (array_length(_up) == 0) break;
				var _ti = _up[irandom(array_length(_up) - 1)];
				var _t = _f.party[_ti];
				if (roll_perc(_f.b.hit)) {
					var _fd = max(1, _coin(_f.b.dmg));
					_t.hp = max(0, _t.hp - _fd);
					var _t3 = _f.b.name + " hits " + _t.name + " for " + string(_fd);
					array_push(_f.log, _t3);
					_f.last = { side : "a", i : _ti, dmg : _fd, at : current_time };
					_film(_f, "a", _ti, _fd, _t3);
					if (_t.hp > 0 && roll_perc(15 * _lm)) {
						_f.b.hp = max(0, _f.b.hp - 1);
						var _t4 = _t.name + " counters for 1";
						array_push(_f.log, _t4);
						_f.last = { side : "b", i : -1, dmg : 1, at : current_time };
						_film(_f, "b", -1, 1, _t4);
					}
				} else { var _t5 = _f.b.name + " misses " + _t.name; array_push(_f.log, _t5); _film(_f, "a", _ti, 0, _t5); }
			}
		}
		var _alive = 0;
		for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp > 0) _alive++;
		if (_f.b.hp <= 0 || _alive == 0) {
			_f.over = true;
			_f.won  = (_f.b.hp <= 0 && _alive > 0);
			var _t6 = _f.won ? (_f.b.name + " falls") : "the crew is routed";
			array_push(_f.log, _t6);
			_film(_f, _f.won ? "b" : "a", -1, 0, _t6);
		}
	}
	if (array_length(_f.log) > 12) array_delete(_f.log, 0, array_length(_f.log) - 12);
}
