/// @description exped_fight_turn(fight) - one turn: both sides swing
/// once, in initiative order, and the turn's story lands in the log.
/// A swing: roll the hit (the crew's leaned by luck); a landed swing
/// deals dmg, doubled on a quality hit (10%, leaned); the struck side
/// counters 15% of the time for 1. Over when a side is out.
/// @param fight
function exped_fight_turn(_f) {
	if (_f.over) return;
	_f.turn += 1;
	var _lm = luck_mod();
	var _first = (_f.a.init >= _f.b.init) ? _f.a : _f.b;
	var _second = (_first == _f.a) ? _f.b : _f.a;
	var _sides = [_first, _second];
	for (var _k = 0; _k < 2; _k++) {
		var _me = _sides[_k], _you = _sides[1 - _k];
		if (_f.over) break;
		if (_me.hp <= 0) continue;
		var _mine = (_me == _f.a);
		var _hit = _me.hit * (_mine ? _lm : 1);
		if (roll_perc(_hit)) {
			var _q = roll_perc(10 * (_mine ? _lm : 1));
			var _dmg = _me.dmg * (_q ? 2 : 1);
			_you.hp = max(0, _you.hp - _dmg);
			array_push(_f.log, _me.name + (_q ? " lands a quality hit" : " hits") + " for " + string(_dmg));
			if (_you.hp > 0 && roll_perc(15 * (_mine ? 1 : _lm))) {
				_me.hp = max(0, _me.hp - 1);
				array_push(_f.log, _you.name + " counters for 1");
			}
		} else array_push(_f.log, _me.name + " misses");
		if (_f.a.hp <= 0 || _f.b.hp <= 0) {
			_f.over = true;
			_f.won  = (_f.b.hp <= 0 && _f.a.hp > 0);
			array_push(_f.log, _f.won ? (_f.b.name + " falls") : (_f.a.name + " is routed"));
		}
	}
	if (array_length(_f.log) > 12) array_delete(_f.log, 0, array_length(_f.log) - 12);
}
