/// @description exped_tick(secs) - the trip's clock, on a seconds budget
/// (the heartbeat and the offline replay both call it - one code path,
/// so a trip away == a trip watched). Travel is EXPED_TRAVEL of the
/// distance; the delve walks a room every (delve share / EXPED_ROOMS),
/// a fight holding the clock while it steps a turn every EXPED_FIGHT_T;
/// a rout skips to the return; home, the haul rolls its floor of
/// credits and waits as a card. The debug speed multiplies the budget.
/// @param secs
function exped_tick(_secs) {
	exped_init();
	var _e = g.exped;
	if (is_undefined(_e.trip)) return;
	var _tr = _e.trip;
	var _dt = _secs * max(1, _e.spd);
	// a fight holds the trip's clock: turns first
	if (!is_undefined(_tr.fight)) {
		var _f = _tr.fight;
		_f.t += _dt;
		while (_f.t >= EXPED_FIGHT_T && !_f.over) { _f.t -= EXPED_FIGHT_T; exped_fight_turn(_f); }
		if (!_f.over) return;
		_tr.hp = _f.a.hp;
		if (_f.won) _tr.cleared += 1; else _tr.routed = true;
		array_push(_tr.log, _f.won ? "the way is clear" : (_tr.sname + " limps home"));
		_tr.fight = undefined;
		return;
	}
	_tr.t += _dt;
	var _travel = _tr.dur * EXPED_TRAVEL;
	var _delve  = _tr.dur * (1 - EXPED_TRAVEL - EXPED_RETURN);
	if (_tr.stage == 0 && _tr.t >= _travel) {
		_tr.stage = 1;
		array_push(_tr.log, "landed on " + _tr.dest.name);
	}
	if (_tr.stage == 1) {
		if (_tr.routed) { _tr.stage = 2; _tr.rout_t = _tr.t; return; }
		var _due = floor((_tr.t - _travel) / (_delve / EXPED_ROOMS)) - 1;   // rooms the clock owes
		if (_tr.room_i < min(_due, EXPED_ROOMS - 1)) {
			exped_room(_tr);
			return;   // one room a tick: a fight that opens holds the clock from here
		}
		if (_tr.t >= _travel + _delve) {
			_tr.stage = 2;
			array_push(_tr.log, "heading home");
		}
	}
	if (_tr.stage == 2 && _tr.t >= (_tr.routed ? (_tr.rout_t + _tr.dur * EXPED_RETURN) : _tr.dur)) {
		// home: the floor of credits by distance, the haul card
		var _floor = { kind : "credits", rar : 0, n : 3 * _tr.dest.tier,
		               txt : string(3 * _tr.dest.tier) + " credits", col : c_lavender };
		array_insert(_tr.finds, 0, _floor);
		_e.haul = { dest : _tr.dest, sname : _tr.sname, sid : _tr.sid, finds : _tr.finds,
		            routed : _tr.routed, cleared : _tr.cleared, log : _tr.log };
		_e.trip = undefined;
		array_push(_tr.log, _tr.routed ? "home, limping" : "home");
		exped_board_roll();
		save_mark_dirty();
	}
}
