/// @description exped_tick_one(trip, dt) -> true the moment the crew gets home
/// One trip's clock: FLY there (dur x EXPED_TRAVEL) -> ON THE WORLD (the
/// agent, exped_agent: roads, nodes, fights; a fight HOLDS the clock,
/// its actions first) -> FLY home (dur x EXPED_RETURN from leave_t). A
/// rout robs the crew (exped_rout) and sends it home. Home: the credits
/// floor, the pocket's remainder, the quest's reward and xp, the
/// diary's last word, every member's MEMORY, the crew's BONDS.
function exped_tick_one(_tr, _dt) {
	// a fight holds the trip's clock: its actions first
	if (!is_undefined(_tr.fight)) {
		var _f = _tr.fight;
		_f.t += _dt;
		while (_f.t >= EXPED_FIGHT_T && !_f.over) { _f.t -= EXPED_FIGHT_T; exped_fight_turn(_f); }
		if (!_f.over) return false;
		// the hp comes back by trip index (mi); a pawn's own maxhp may have
		// ERODED in the fight - the trip's hpmax is the sheet's, untouched
		for (var _k = 0; _k < array_length(_f.party); _k++) _tr.hp[_f.party[_k].mi] = round(_f.party[_k].hp * 10) / 10;
		if (_f.won) { _tr.cleared += 1; _tr.wins = (_tr[$ "wins"] ?? 0) + 1; } else _tr.routed = true;
		// THE KILL'S XP (his law): the pack's stat total to every survivor
		if (_f.won) exped_xp_grant(_tr, _f[$ "xp"] ?? 0, "");
		// the quest's and the bounty's tallies
		if (_f.won) {
			var _q = _tr[$ "quest"], _bo = _tr[$ "bounty"];
			for (var _j = 0; _j < array_length(_f.foes); _j++) {
				var _kd = _f.foes[_j][$ "kind"] ?? "";
				if (is_struct(_q) && _q.kind == "slay" && _q.foe == _kd && _q.done < _q.n) _q.done += 1;
				if (is_struct(_bo) && _bo.foe == _kd && _bo.done < _bo.n) _bo.done += 1;
			}
			if (is_struct(_q) && _q.kind == "rout" && is_struct(_tr.act) && _tr.act.kind == "camp" && _q.node == _tr.pos && _q.done < _q.n) _q.done += 1;
			if (is_struct(_q) && _q.done >= _q.n && !(_tr[$ "quest_said"] ?? false)) { _tr.quest_said = true; array_push(_tr.log, "the quest is done: " + _q.txt); }
			if (is_struct(_bo) && _bo.done >= _bo.n) { _tr.credits += _bo.pay; array_push(_tr.log, "the bounty is done - " + string(_bo.pay) + " credits, paid by a passing clerk"); _tr.bounty = undefined; }
			// a camp's chest, on its last fight
			if (is_struct(_tr.act) && _tr.act.kind == "camp" && (_tr.act[$ "loot"] ?? false)) {
				var _cr = 2 + irandom(2) + _tr.dest.tier;
				_tr.credits += _cr;
				array_push(_tr.log, "the camp's chest: " + string(_cr) + " credits");
				if (roll_perc(50)) exped_room_find(_tr, "and in the chest, ");
			}
		}
		// THE NOTEPAD: someone who is still up writes about a foe they met
		exped_note_fight(_tr, _f);
		if (_f.won) array_push(_tr.log, "the way is clear");
		exped_say(_tr, _f.won ? "fight_won" : "fight_lost", { foe : _f.b.name });
		// THE FILM stays on the trip for the panel's replay (not saved)
		var _rfoes = [];
		for (var _j = 0; _j < array_length(_f.foes); _j++) array_push(_rfoes, { name : _f.foes[_j].name, hpmax : _f.foes[_j].hpmax, lv : _f.foes[_j][$ "lv"] ?? 1, kind : _f.foes[_j][$ "kind"] ?? "", col : _f.foes[_j][$ "col"] ?? c_hred });
		_tr.replay = { ev : _f[$ "ev"] ?? [], party : _f.party, foes : _rfoes, foe : _rfoes[0],
		               won : _f.won, seen : false, room : _tr[$ "fights"] ?? 0 };   // (room = the fight's number: the panel's seen-live key)
		_tr.fight = undefined;
		if (_tr.routed) { exped_rout(_tr); _tr.act = undefined; _tr.road = undefined; }
		return false;
	}
	_tr.t += _dt;
	var _travel = _tr.dur * EXPED_TRAVEL;
	// ---- stage 0: the flight there ----
	if (_tr.stage == 0) {
		if (!(_tr[$ "said_travel"] ?? false) && _tr.t >= _travel * .5) {
			_tr.said_travel = true;
			exped_say(_tr, "travel");
			exped_say(_tr, "sky", undefined, .3);
		}
		if (_tr.t >= _travel) {
			_tr.stage = 1;
			var _rg = exped_region(_tr);
			_tr.pos = clamp(_tr[$ "home"] ?? _rg.landing, 0, array_length(_rg.nodes) - 1);   // the landing zone nearest the objective (exped_start)
			_tr.path = []; _tr.road = undefined; _tr.act = undefined;
			array_push(_tr.log, "landed on " + _tr.dest.name + " - " + _rg.name + ", " + _rg.nodes[_tr.pos].name);
			exped_say(_tr, "land");
			exped_note_beat(_tr, "land", .3);
		}
		return false;
	}
	// ---- stage 1: on the world ----
	if (_tr.stage == 1) {
		if (_tr.routed) {
			_tr.stage = 2; _tr.leave_t = _tr.t; _tr.rout_t = _tr.t;
			array_push(_tr.log, exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " limp" : " limps") + " back to the ship");
			exped_say(_tr, "return", undefined, .8);
			return false;
		}
		if (exped_agent(_tr, _dt)) {
			_tr.stage = 2; _tr.leave_t = _tr.t;
			array_push(_tr.log, "back at the landing zone - lifting off");
			exped_say(_tr, "return", undefined, .8);
		}
		return false;
	}
	// ---- stage 2: the flight home ----
	if (_tr.stage == 2 && _tr.t >= (_tr[$ "leave_t"] ?? _tr.t) + _tr.dur * EXPED_RETURN) {
		// home: the floor of credits by distance, the pocket's remainder, the quest's reward
		var _floor = { kind : "credits", rar : 0, n : 3 * _tr.dest.tier, txt : string(3 * _tr.dest.tier) + " credits", col : c_lavender };
		array_insert(_tr.finds, 0, _floor);
		if ((_tr[$ "credits"] ?? 0) > 0) array_push(_tr.finds, { kind : "credits", rar : 0, n : _tr.credits, txt : string(_tr.credits) + " credits - the pocket, unspent", col : c_lavender });
		var _q = _tr[$ "quest"];
		if (is_struct(_q)) {
			var _done = clamp(_q.done / max(1, _q.n), 0, 1);
			if (_done >= 1) array_push(_tr.finds, { kind : "credits", rar : 1, n : _q.reward, txt : string(_q.reward) + " credits - the quest's reward", col : c_gold });
			// THE QUEST'S XP (his law): a par foe's xp x 2..5 by how much got done
			if (!_tr.routed || _done > 0) exped_xp_grant(_tr, round(sprite_par_pts(exped_trip_lv(_tr)) * SPRITE_FOE_BUDGET * SPRITE_XP_PER_PT * lerp(SPRITE_QUEST_XP_LO, _q.mult, _done)), "the quest");
		} else if (!_tr.routed) {
			// an explore's worth: the hours wandered, up to a day
			exped_xp_grant(_tr, sprite_xp_quest(exped_trip_lv(_tr), clamp((_tr[$ "planet_t"] ?? 0) / (24 * EXPED_HOUR), 0, 1)), "the wandering");
		}
		array_push(_tr.log, _tr.routed ? "home, limping" : "home");
		exped_say(_tr, "home");
		exped_note_beat(_tr, "home", .25);
		for (var _si = 0; _si < array_length(g.sprites); _si++) {
			var _sp = g.sprites[_si];
			if (!array_contains(_tr.sids, _sp.id)) continue;
			if (!is_struct(_sp[$ "mem"])) _sp.mem = { trips : 0, wins : 0, routs : 0, last : "", streak : 0 };
			_sp.mem.trips  += 1;
			_sp.mem.wins   += _tr[$ "wins"] ?? 0;
			_sp.mem.last    = _tr.dest.name;
			if (_tr.routed) { _sp.mem.routs += 1; _sp.mem.streak = 0; } else _sp.mem.streak += 1;
		}
		var _n = array_length(_tr.sids);
		for (var _a = 0; _a < _n; _a++)
			for (var _b = _a + 1; _b < _n; _b++)
				exped_bond_add(_tr.sids[_a], _tr.sids[_b],
					EXPED_BOND_TRIP + EXPED_BOND_WIN * (_tr[$ "wins"] ?? 0) - (_tr.routed ? EXPED_BOND_ROUT : 0));
		return true;
	}
	return false;
}
