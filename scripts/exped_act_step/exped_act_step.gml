/// @description exped_act_step(trip) - one step of the crew's activity at its node (the clock paid for it)
/// The step happens, then the next is queued or the activity ends
/// (trip.act = undefined). A step that opens a fight lets the fight hold
/// the clock; the activity resumes when it ends.
function exped_act_step(_tr) {
	var _a = _tr.act;
	if (!is_struct(_a)) return;
	if (_a.steps <= 0) { _tr.act = undefined; return; }   // (spent - it waited out its last fight)
	var _rg = exped_region(_tr);
	var _nd = _rg.nodes[_tr.pos];
	var _n = array_length(_tr.sids);
	var _q = _tr[$ "quest"];
	switch (_a.kind) {
		case "rest": {
			var _cost = 0, _beds = 0;
			for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _beds++;
			_cost = _beds * EXPED_INN;
			if (_tr.credits >= _cost) {
				_tr.credits -= _cost;
				for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = _tr.hpmax[_k];
				if (is_array(_tr[$ "mp"])) for (var _k = 0; _k < array_length(_tr.mp); _k++) _tr.mp[_k] = 1;
				exped_stat("inns");
				array_push(_tr.log, "a night at the inn in " + _nd.name + " (" + string(_cost) + " credits) - everyone is whole again");
			} else {
				for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .5);
				array_push(_tr.log, "no coin for the inn - slept in a barn in " + _nd.name + ". half a night's rest");
			}
			exped_say(_tr, "rest", undefined, .7);
			exped_note_beat(_tr, "rest", .3);
			break;
		}
		case "shop": exped_shop(_tr); break;
		case "tavern": {
			exped_stat("taverns");
			exped_skill_beat(_tr, .12);   // (a trick off a drunk, sometimes)
			var _r = random(100);
			if (_r < 35) {
				var _who = _tr.names[irandom(_n - 1)];
				if (_tr.credits > 0) _tr.credits -= 1;
				array_push(_tr.log, _who + " got " + choose("drunk", "very drunk", "into an argument with a chair", "a round in for everyone", "lost at cards") + " in the tavern at " + _nd.name + ((_tr.credits > 0) ? " (a credit, gone)" : ""));
			} else if (_r < 60) {
				_tr.fight = exped_fight_new(_tr, "bandit", 1, 0);
				_tr.fight.foes[0].name = "a drunk"; _tr.fight.foes[0].kind = "drunk";   // (not a bandit for the quest's count - bug hunt 2026-09-15)
				array_push(_tr.log, "a bar fight in " + _nd.name + ". nobody remembers who started it");
			} else if (_r < 85 && !is_struct(_tr[$ "bounty"])) {
				// a bounty: a nearby dungeon or camp, a few kills
				var _cand = [];
				for (var _i = 1; _i < array_length(_rg.nodes); _i++) if (_rg.nodes[_i].kind == "dungeon" || _rg.nodes[_i].kind == "crypt" || _rg.nodes[_i].kind == "camp") array_push(_cand, _i);
				if (array_length(_cand) > 0) {
					var _bn = _cand[irandom(array_length(_cand) - 1)];
					var _bk = (_rg.nodes[_bn].kind == "camp") ? "bandit" : ((_rg.nodes[_bn].kind == "crypt") ? choose("skeleton", "wisp") : choose("goblin", "rat", "skeleton", "wolf"));
					_tr.bounty = { node : _bn, foe : _bk, n : irandom_range(2, 4), done : 0, pay : 3 + 2 * _tr.dest.tier };
					array_push(_tr.log, "took a bounty off the board in " + _nd.name + ": " + string(_tr.bounty.n) + " " + _bk + "s at " + _rg.nodes[_bn].name + ", " + string(_tr.bounty.pay) + " credits");
				}
			} else array_push(_tr.log, "the tavern at " + _nd.name + ": " + choose("gossip about a rock that watches", "someone sang. badly.", "the stew was a colour", "a bard was thrown out", "nothing happened, at length"));
			break;
		}
		case "hunt": {
			var _fk = is_struct(_q) ? _q.foe : "";
			var _bo = _tr[$ "bounty"];
			if (_fk == "" && is_struct(_bo)) _fk = _bo.foe;
			_tr.fight = exped_fight_new(_tr, _fk, -1, 0);
			array_push(_tr.log, _tr.fight.b.name + ((array_length(_tr.fight.foes) > 1) ? " and more " : " ") + "found at " + _nd.name);
			break;
		}
		case "delve": {
			// a room: a fight, a find, a trap, a quiet one (exped_room's kinds)
			var _r = random(100);
			if (_r < 45) { _tr.fight = exped_fight_new(_tr, (_nd.kind == "crypt") ? choose("skeleton", "wisp") : "", -1, 0); array_push(_tr.log, "a room of " + _nd.name + ": " + _tr.fight.b.name + " blocks the way"); exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6); }
			else if (_r < 75) exped_room_find(_tr, "a room of " + _nd.name + ": ");
			else if (_r < 90) exped_room_trap(_tr, "a room of " + _nd.name + ": ");
			else { for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .25); array_push(_tr.log, "a room of " + _nd.name + ": quiet. they rested"); exped_say(_tr, "rest", undefined, .5); }
			if (is_struct(_q) && _q.kind == "clear" && _q.node == _tr.pos) { _q.done = min(_q.n, _q.done + 1); if (_q.done >= _q.n) array_push(_tr.log, _nd.name + " is cleared. the quest is done"); }
			_tr.cleared += 1;
			break;
		}
		case "camp": {
			_tr.fight = exped_fight_new(_tr, "bandit", irandom_range(2, 3), 0);   // a camp is never one bandit
			array_push(_tr.log, "bandits at " + _nd.name + ": " + string(array_length(_tr.fight.foes)) + " of them");
			exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6);
			if (_a.steps <= 1) _a.loot = true;   // the last fight's win pays the camp's chest (exped_tick_one)
			break;
		}
		case "mine": {
			var _fam = ["ferrite", "bloom", "glass"][_tr.dest.biome mod 3];
			var _cnt = 1 + irandom(2) + _tr.dest.tier;
			array_push(_tr.finds, { kind : "mats", rar : 0, fam : _fam, tier : _tr.dest.tier, n : _cnt, txt : string(_cnt) + " " + _fam + " (t" + string(_tr.dest.tier) + ")", col : c_white });
			array_push(_tr.log, "mined " + string(_cnt) + " " + _fam + " at " + _nd.name);
			break;
		}
		case "shrine": {
			for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .3);
			exped_skill_beat(_tr, .3);   // (a shrine teaches, sometimes)
			array_push(_tr.log, "the shrine at " + _nd.name + ": " + choose("a small blessing", "the water was cold and helped", "someone left a candle. it counted"));
			if (roll_perc(20)) { array_push(_tr.finds, { kind : "charm", rar : 0, txt : "a charm (+1 luck)", col : c_seagreen }); array_push(_tr.log, "...and a charm, left on the step"); }
			break;
		}
		case "ruin": {
			var _r = random(100);
			if (_r < 50) exped_room_find(_tr, _nd.name + ": ");
			else if (_r < 80) exped_room_trap(_tr, _nd.name + ": ");
			else array_push(_tr.log, _nd.name + ": " + choose("stones. old ones.", "a floor with no house", "someone lived here. they left"));
			break;
		}
		case "wild": {
			var _r = random(100);
			if (_r < 30) { _tr.fight = exped_fight_new(_tr, choose("wolf", "rat", "goblin"), irandom_range(1, 2), 0); array_push(_tr.log, _nd.name + ": " + _tr.fight.b.name + " " + choose("was not pleased", "objected", "came out of the grass")); }
			else if (_r < 50) exped_room_find(_tr, _nd.name + ": ");
			else {
				var _isit = ((_nd.kind == "hills" || _nd.kind == "mountains") ? "they are " : ((_nd.kind == "tundra") ? "it is " : "it is a ")) + _nd.kind;
				array_push(_tr.log, _nd.name + ": " + choose("looked at it. " + _isit + ".", "walked through. nothing in it.", "a good place for a sit. they sat.", "wind."));
			}
			if (_tr.mode == "explore" && _nd.kind == "forest" && roll_perc(30) && is_undefined(_tr.fight)) { _tr.fight = exped_fight_new(_tr, "wolf", -1, 0); array_push(_tr.log, "went hunting in " + _nd.name); }
			break;
		}
		case "look": break;
	}
	_a.steps -= 1;
	// a fight opened: the activity waits for it (exped_tick_one reads act.kind
	// for the camp's chest and the rout quest) and looks again after
	if (!is_undefined(_tr.fight)) { _a.left = EXPED_ROOM_T * .5; return; }
	if (_a.steps > 0) _a.left = EXPED_ROOM_T;
	else {
		if (_a.kind == "delve") { exped_stat("delves"); array_push(_tr.log, "out of " + _nd.name + ", into the light"); }
		_tr.act = undefined;
	}
}
