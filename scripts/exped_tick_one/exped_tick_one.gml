/// @description exped_tick_one(trip, dt) -> true the moment the crew
/// gets home. One trip's clock: travel -> delve (one room a tick; a
/// fight HOLDS the clock, its turns first) -> return. A rout skips to
/// the return. Home: the floor of credits by distance, the diary's last
/// word, every member's MEMORY moves on (exped_say's gates), and the
/// crew's BONDS move (exped_bond: a trip together, fights won, a rout).
function exped_tick_one(_tr, _dt) {
	// a fight holds the trip's clock: turns first
	if (!is_undefined(_tr.fight)) {
		var _f = _tr.fight;
		_f.t += _dt;
		while (_f.t >= EXPED_FIGHT_T && !_f.over) { _f.t -= EXPED_FIGHT_T; exped_fight_turn(_f); }
		if (!_f.over) return false;
		// the hp comes back by trip index (mi); a pawn's own maxhp may have
		// ERODED in the fight - the trip's hpmax is the sheet's, untouched
		for (var _k = 0; _k < array_length(_f.party); _k++) _tr.hp[_f.party[_k].mi] = round(_f.party[_k].hp * 10) / 10;
		if (_f.won) { _tr.cleared += 1; _tr.wins = (_tr[$ "wins"] ?? 0) + 1; } else _tr.routed = true;
		// THE KILL'S XP (his law): the foe's stat total to every survivor;
		// a level climbs the sheet and the trip's hp pool grows with it
		if (_f.won) exped_xp_grant(_tr, _f[$ "xp"] ?? 0, "");
		array_push(_tr.log, _f.won ? "the way is clear" : (exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " limp home" : " limps home")));
		exped_say(_tr, _f.won ? "fight_won" : "fight_lost", { foe : _f.b.name });
		// THE FILM stays on the trip for the panel's replay - a fight that
		// ended while you were elsewhere (or away) plays back when you
		// open the page; the panel marks it seen. Not saved.
		var _rfoes = [];
		for (var _j = 0; _j < array_length(_f.foes); _j++) array_push(_rfoes, { name : _f.foes[_j].name, hpmax : _f.foes[_j].hpmax, lv : _f.foes[_j][$ "lv"] ?? 1, kind : _f.foes[_j][$ "kind"] ?? "", col : _f.foes[_j][$ "col"] ?? c_hred });
		_tr.replay = { ev : _f[$ "ev"] ?? [], party : _f.party, foes : _rfoes, foe : _rfoes[0],
		               won : _f.won, seen : false, room : _tr.room_i };
		_tr.fight = undefined;
		return false;
	}
	_tr.t += _dt;
	var _travel = _tr.dur * EXPED_TRAVEL;
	var _delve  = _tr.dur * (1 - EXPED_TRAVEL - EXPED_RETURN);
	// the diary's one line on the crossing, past the halfway mark
	if (_tr.stage == 0 && !(_tr[$ "said_travel"] ?? false) && _tr.t >= _travel * .5) {
		_tr.said_travel = true;
		exped_say(_tr, "travel");
		exped_say(_tr, "sky", undefined, .3);
	}
	if (_tr.stage == 0 && _tr.t >= _travel) {
		_tr.stage = 1;
		array_push(_tr.log, "landed on " + _tr.dest.name);
		exped_say(_tr, "land");
	}
	if (_tr.stage == 1) {
		if (_tr.routed) { _tr.stage = 2; _tr.rout_t = _tr.t; exped_say(_tr, "return", undefined, .8); return false; }
		var _due = floor((_tr.t - _travel) / (_delve / EXPED_ROOMS)) - 1;   // rooms the clock owes
		if (_tr.room_i < min(_due, EXPED_ROOMS - 1)) {
			exped_room(_tr);
			return false;   // one room a tick: a fight that opens holds the clock from here
		}
		if (_tr.t >= _travel + _delve) {
			_tr.stage = 2;
			array_push(_tr.log, "heading home");
			exped_say(_tr, "return", undefined, .8);
		}
	}
	if (_tr.stage == 2 && _tr.t >= (_tr.routed ? (_tr.rout_t + _tr.dur * EXPED_RETURN) : _tr.dur)) {
		// home: the floor of credits by distance
		var _floor = { kind : "credits", rar : 0, n : 3 * _tr.dest.tier,
		               txt : string(3 * _tr.dest.tier) + " credits", col : c_lavender };
		array_insert(_tr.finds, 0, _floor);
		array_push(_tr.log, _tr.routed ? "home, limping" : "home");
		// THE QUEST'S XP (his law, 2026-09-14): the trip done is the quest
		// for now - a par foe's xp at the world's level x 2..5 by the rooms
		// cleared; a routed crew brought nothing home to be paid for
		if (!_tr.routed) exped_xp_grant(_tr, sprite_xp_quest(exped_world_lv(_tr.dest), _tr.cleared / EXPED_ROOMS), "the trip");
		// the diary's last word - a payoff for anything still open, or a
		// home line - and every member's MEMORY moves on
		exped_say(_tr, "home");
		for (var _si = 0; _si < array_length(g.sprites); _si++) {
			var _sp = g.sprites[_si];
			if (!array_contains(_tr.sids, _sp.id)) continue;
			if (!is_struct(_sp[$ "mem"])) _sp.mem = { trips : 0, wins : 0, routs : 0, last : "", streak : 0 };
			_sp.mem.trips  += 1;
			_sp.mem.wins   += _tr[$ "wins"] ?? 0;
			_sp.mem.last    = _tr.dest.name;
			if (_tr.routed) { _sp.mem.routs += 1; _sp.mem.streak = 0; } else _sp.mem.streak += 1;
		}
		// the bonds: every pair that went together
		var _n = array_length(_tr.sids);
		for (var _a = 0; _a < _n; _a++)
			for (var _b = _a + 1; _b < _n; _b++)
				exped_bond_add(_tr.sids[_a], _tr.sids[_b],
					EXPED_BOND_TRIP + EXPED_BOND_WIN * (_tr[$ "wins"] ?? 0) - (_tr.routed ? EXPED_BOND_ROUT : 0));
		return true;
	}
	return false;
}
