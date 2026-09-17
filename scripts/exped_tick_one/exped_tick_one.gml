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
		if (!is_array(_tr[$ "mp"])) _tr.mp = array_create(array_length(_tr.sids), 1);
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			_tr.hp[_f.party[_k].mi] = round(_f.party[_k].hp * 10) / 10;
			_tr.mp[_f.party[_k].mi] = clamp(_f.party[_k].mp / max(1, _f.party[_k].maxmp), 0, 1);   // (mp rides the trip)
		}
		var _drawn = (_f[$ "withdrew"] ?? false);   // (the 300-action rail: nobody won, nobody is robbed)
		if (_f.won) { _tr.cleared += 1; _tr.wins = (_tr[$ "wins"] ?? 0) + 1; } else if (!_drawn) _tr.routed = true;
		// THE LEDGER: the fight, the slain, the down (a party pawn was up going in)
		if (!_drawn) exped_stat(_f.won ? "fights_won" : "fights_lost");
		for (var _j = 0; _j < array_length(_f.foes); _j++) {
			var _bf = _f.foes[_j];
			bestiary_note(_bf[$ "kind"] ?? "", "seen", _bf[$ "variant"] ?? "", _bf[$ "boss"] ?? false);   // THE BESTIARY (2026-09-16): every foe that stood here
			if (_bf.hp <= 0) { exped_stat("slain"); bestiary_note(_bf[$ "kind"] ?? "", "slain"); exped_tally(_tr, "slain"); }
		}
		for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp <= 0) exped_stat("downs");
		// DAMAGE, dealt and taken (his ask, 2026-09-17): the pawns' own
		// counters (cbt_hit's dd / dt), summed once as the fight closes -
		// the expedition's ledger, and each member's own (won / lost /
		// down / dealt / taken)
		var _dd = 0, _dtk = 0;
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			var _pm = _f.party[_k];
			_dd += _pm[$ "dd"] ?? 0; _dtk += _pm[$ "dt"] ?? 0;
			var _msp = (is_array(_tr[$ "sids"]) && _pm.mi < array_length(_tr.sids)) ? exped_sprite(_tr.sids[_pm.mi]) : undefined;
			if (is_undefined(_msp)) continue;
			if (!_drawn) sprite_led(_msp, _f.won ? "won" : "lost");
			if (_pm.hp <= 0) sprite_led(_msp, "downs");
			sprite_led(_msp, "dmg", round(_pm[$ "dd"] ?? 0));
			sprite_led(_msp, "dtaken", round(_pm[$ "dt"] ?? 0));
		}
		exped_stat("dmg", round(_dd)); exped_stat("dtaken", round(_dtk));
		if (!_drawn) bestiary_payout(_tr, _f);   // THE BESTIARY PAYS (2026-09-16): the hunt's rungs, the land's set
		// THE KILL'S XP (his law): the pack's stat total to every survivor
		if (_f.won) exped_xp_grant(_tr, _f[$ "xp"] ?? 0, "");
		// the quest's and the bounty's tallies
		if (_f.won) {
			var _q = _tr[$ "quest"], _bo = _tr[$ "bounty"];
			for (var _j = 0; _j < array_length(_f.foes); _j++) {
				var _kd = _f.foes[_j][$ "kind"] ?? "";
				if (is_struct(_q) && (_q.kind == "slay" || _q.kind == "cellars") && _q.foe == _kd && _q.done < _q.n) _q.done += 1;   // (the cellars: a slay under a town, 2026-09-16)
				if (is_struct(_bo) && _bo.foe == _kd && _bo.done < _bo.n) _bo.done += 1;
			}
			if (is_struct(_q) && _q.kind == "rout" && is_struct(_tr.act) && _tr.act.kind == "camp" && _q.node == _tr.pos && _q.done < _q.n) _q.done += 1;
			// the mission-type pass (2026-09-15): the named boss down, a wave held
			if (is_struct(_q) && (_q.kind == "bounty" || _q.kind == "well") && _q.done < _q.n) for (var _j = 0; _j < array_length(_f.foes); _j++) if ((_f.foes[_j][$ "named"] ?? false) && _f.foes[_j].hp <= 0) {
				_q.done = _q.n; array_push(_tr.log, _q.who + " is down. " + choose("it took a while", "nobody cheered. then everybody did", "the hat is a trophy now"));
				// the well's giant keeps an elixir, one time in three (2026-09-16)
				if (_q.kind == "well" && roll_perc(33)) { var _esp = exped_sprite(_tr.sids[irandom(array_length(_tr.sids) - 1)]); if (!is_undefined(_esp)) { var _etk = sprite_take(_esp, use_gen("elixir", 1, exped_trip_lv(_tr), choose("hp", "atk", "def", "spd", "luck"))); exped_tally(_tr, "items"); array_push(_tr.log, "in the well's mud, a bottle. " + _etk.txt); } }
			}
			if (is_struct(_q) && _q.kind == "defend" && is_struct(_tr.act) && _tr.act.kind == "defend" && _q.node == _tr.pos && _q.done < _q.n) { _q.done += 1; if (_q.done >= _q.n) array_push(_tr.log, exped_region(_tr).nodes[_tr.pos].name + " holds. the villagers come out again"); }
			if (is_struct(_q) && _q.done >= _q.n && !(_tr[$ "quest_said"] ?? false)) { _tr.quest_said = true; array_push(_tr.log, "the quest is done: " + _q.txt); }
			if (is_struct(_bo) && _bo.done >= _bo.n) { _tr.credits += _bo.pay; exped_tally(_tr, "earned", _bo.pay); exped_stat("bounties"); array_push(_tr.log, "+ the bounty is done - " + string(_bo.pay) + " credits, paid by a passing clerk"); _tr.bounty = undefined; }
			// a camp's chest, on its last fight
			if (is_struct(_tr.act) && _tr.act.kind == "camp" && (_tr.act[$ "loot"] ?? false)) {
				var _ldx = region_node_leader(_tr.dest, exped_region(_tr), _tr.pos);   // (a careless chief: a fatter chest - 2026-09-16)
				var _cr = 2 + irandom(2) + _tr.dest.tier + ((is_struct(_ldx) && _ldx.trait == "careless") ? 2 : 0);
				_cr = max(1, round(_cr * (1 + exped_party_ab(_tr).scav / 100)));   // (the scavenger - 2026-09-17)
				_tr.credits += _cr; exped_tally(_tr, "earned", _cr);
				exped_stat("camps");
				array_push(_tr.log, "+ the camp's chest: " + string(_cr) + " credits");
				// THE WORLD REMEMBERS (2026-09-16): the camp is ashes for four days - nobody home, the road past it quieter
				exped_mem_set(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "routed", 96);
				array_push(_tr.log, "the camp burns. " + choose("the road past it will be quieter for a while", "nobody will be home there for a while", "the crows have it now"));
				if (roll_perc(50)) exped_room_find(_tr, "and in the chest, ");
			}
		}
		exped_quest_after(_tr);   // (a quest just done: gratitude, and the follow-up card - 2026-09-16)
		// THE PACK'S DROP (his ask: "temoo acquired ..." in the diary)
		if (_f.won) exped_fight_loot(_tr, _f);
		exped_drink(_tr);   // (the pocket, after: a red potion for whoever is low - 2026-09-16)
		// ...and now and then a trick learned in the fight (sprite_skill_learn)
		if (_f.won) exped_skill_beat(_tr, .06);
		// THE NOTEPAD: someone who is still up writes about a foe they met
		exped_note_fight(_tr, _f);
		if (_f.won) array_push(_tr.log, "the way is clear");
		if (!_drawn) exped_say(_tr, _f.won ? "fight_won" : "fight_lost", { foe : _f.b.name });
		// THE REASON (2026-09-15): a loss under a hazard says what would have held it
		if (!_f.won && !_drawn && is_struct(_f[$ "hazard"]) && array_length(_f.hazard.bare) > 0)
			array_push(_tr.log, _f.hazard.name + " did it - " + _f.hazard.hold + " holds it" + ((array_length(_f.hazard.bare) == array_length(_f.party)) ? "" : (", and " + exped_crew_txt(_f.hazard.bare) + " had none of that")));
		// THE STANCE (2026-09-16): a cautious crew turns for home when one of them goes down
		if (_f.won && exped_stance(_tr).fall && !(_tr[$ "recall"] ?? false)) {
			var _dn = "";
			for (var _k = 0; _k < array_length(_f.party); _k++) if (_f.party[_k].hp <= 0 && _dn == "") _dn = _tr.names[_f.party[_k].mi];
			if (_dn != "") {
				var _qd = _tr[$ "quest"];
				var _open = is_struct(_qd) && _qd.done < _qd.n;
				_tr.recall = true;
				if (_tr.mode == "quest" && _open) { _tr.aborted = true; exped_stat("aborted"); }
				array_push(_tr.log, _dn + " is down. cautious: " + choose("they turn for the landing zone", "that is enough. home", "nobody argues. home") + (_open ? " - the quest is dropped" : ""));
				_tr.act = undefined; _tr.path = [];
			}
		}
		// THE FILM stays on the trip for the panel's replay (not saved)
		var _rfoes = [];
		for (var _j = 0; _j < array_length(_f.foes); _j++) array_push(_rfoes, { name : _f.foes[_j].name, hpmax : _f.foes[_j].hpmax, lv : _f.foes[_j][$ "lv"] ?? 1, kind : _f.foes[_j][$ "kind"] ?? "", col : _f.foes[_j][$ "col"] ?? c_hred });
		_tr.replay = { ev : _f[$ "ev"] ?? [], party : _f.party, foes : _rfoes, foe : _rfoes[0],
		               won : _f.won, drawn : _drawn, seen : false, room : _tr[$ "fights"] ?? 0 };   // (room = the fight's number: the panel's seen-live key)
		_tr.fight = undefined;
		if (_tr.routed) { exped_stat("routs"); exped_rout(_tr); _tr.act = undefined; _tr.road = undefined; }
		return false;
	}
	_tr.t += _dt;
	if (_tr.stage != 1) exped_stat("flight_h", _dt / EXPED_HOUR);
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
			var _ssl = region_season(_tr.dest, _rg);   // THE SEASON (2026-09-16): named on landing
			if (_ssl.on) _tr.season = _ssl.name;
			var _evl = region_event(_tr.dest, _tr[$ "rgi"] ?? 0);   // ...and the region's event
			_tr.event = is_struct(_evl) ? _evl.kind : "";
			array_push(_tr.log, "# landed on " + _tr.dest.name + " - " + _rg.name + ", " + _rg.nodes[_tr.pos].name + (_ssl.on ? (". " + _ssl.name + " here") : "") + (is_struct(_evl) ? (". word is: " + _evl.txt) : ""));
			// DISCOVERED: the world and the region, once each (the ledger's set)
			exped_stat("landings");
			var _sk = string(_tr.dest.seed) + ":" + string(_tr[$ "rgi"] ?? 0);
			if (!is_array(g.exped[$ "seen"])) g.exped.seen = [];
			if (!array_contains(g.exped.seen, _sk)) array_push(g.exped.seen, _sk);
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
		// the pay: 3 a tier, and one for every four hours on the world (the credits twin, 2026-09-16: an explore bled without it)
		var _payn = 3 * _tr.dest.tier + floor((_tr[$ "planet_t"] ?? 0) / (4 * EXPED_HOUR));
		_payn = round(_payn * (1 + exped_party_ab(_tr, false).gold / 100));   // (golden touch - 2026-09-17)
		var _floor = { kind : "credits", rar : 0, n : _payn, txt : string(_payn) + " credits - the trip's pay", col : c_lavender };   // ("the floor" made no sense on the card - 2026-09-15)
		array_insert(_tr.finds, 0, _floor);
		exped_tally(_tr, "earned", _floor.n);
		if ((_tr[$ "credits"] ?? 0) > 0) array_push(_tr.finds, { kind : "credits", rar : 0, n : _tr.credits, txt : string(_tr.credits) + " credits - the pocket, unspent", col : c_lavender });
		// THE TREASURES (his ask, 2026-09-17): whatever trinkets came home in the pockets are sold at the door
		var _tsum = 0, _tnames = [], _tn = 0;
		for (var _tk = 0; _tk < array_length(_tr.sids); _tk++) {
			var _tsp = exped_sprite(_tr.sids[_tk]);
			if (is_undefined(_tsp)) continue;
			var _tsh = sprite_sheet(_tsp);
			for (var _ti = array_length(_tsh.inv) - 1; _ti >= 0; _ti--) {
				var _tit = _tsh.inv[_ti];
				if ((_tit[$ "slot"] ?? "") != "treasure") continue;
				_tsum += max(1, round(_tit.val * (1 + sprite_ab(_tsp).sell / 100))); _tn += 1;
				if (array_length(_tnames) < 3) array_push(_tnames, _tit.name);
				array_delete(_tsh.inv, _ti, 1);
			}
		}
		if (_tsum > 0) {
			exped_tally(_tr, "earned", _tsum); exped_stat("sold", _tn);
			var _tlist = exped_crew_txt(_tnames) + ((_tn > 3) ? (" and " + string(_tn - 3) + " more") : "");
			array_push(_tr.finds, { kind : "credits", rar : 1, n : _tsum, txt : string(_tsum) + " credits - the treasures, sold at the door (" + _tlist + ")", col : c_gold });
		}
		var _q = _tr[$ "quest"];
		if (is_struct(_q)) {
			var _done = clamp(_q.done / max(1, _q.n), 0, 1);
			if (_done >= 1) { var _qr = max(1, round(_q.reward * (1 + exped_party_ab(_tr, false).quest / 100))); exped_stat("quests"); exped_tally(_tr, "earned", _qr); array_push(_tr.finds, { kind : "credits", rar : 1, n : _qr, txt : string(_qr) + " credits - the quest's reward", col : c_gold }); }   // (the courier - 2026-09-17)
			// THE QUEST'S XP (his law): a par foe's xp x 2..5 by how much got done
			// (an abort before anything was done pays nothing)
			if (_done > 0 || (!_tr.routed && !(_tr[$ "aborted"] ?? false))) exped_xp_grant(_tr, sprite_xp_quest(exped_trip_lv(_tr), _done, _q.mult), "the quest");
		} else if (!_tr.routed && (_tr[$ "planet_t"] ?? 0) > 0) {
			// an explore's worth: the hours wandered, up to a day
			exped_xp_grant(_tr, sprite_xp_quest(exped_trip_lv(_tr), clamp((_tr[$ "planet_t"] ?? 0) / (24 * EXPED_HOUR), 0, 1)), "the wandering");
		}
		array_push(_tr.log, _tr.routed ? "home, limping" : ((_tr[$ "aborted"] ?? false) ? "home, early" : "home"));
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
