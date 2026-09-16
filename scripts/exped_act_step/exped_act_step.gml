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
	var _stn = exped_stance(_tr);   // THE STANCE (2026-09-16): the tavern's board, the delve's doors
	// THE TOWN (2026-09-16): a visit is a PLAN of beats, one a step, each with its own hours
	var _kind = _a.kind, _beat = undefined;
	if (_kind == "town") {
		if (!is_array(_a[$ "plan"]) || _a.i >= array_length(_a.plan)) { _tr.act = undefined; return; }
		_beat = _a.plan[_a.i]; _a.i += 1; _kind = _beat.k; _a.next_t = _beat.t * EXPED_HOUR;
	}
	switch (_kind) {
		case "arrive": {
			// a look round: the place's papers (region_node_info), in the diary
			var _pp = region_node_info(_tr.dest, _rg, _tr.pos);
			var _rgi_a = _tr[$ "rgi"] ?? 0, _memt = "";   // (the world remembers, 2026-09-16)
			if (is_struct(exped_mem_get(_tr.dest, _rgi_a, _tr.pos, "grateful"))) _memt += choose(". they are remembered here", ". somebody waves. they are known here", ". the word has gone round about them");
			if (is_struct(exped_mem_get(_tr.dest, _rgi_a, _tr.pos, "barred"))) _memt += ". the tavern will not have them";
			var _eva = region_event(_tr.dest, _rgi_a);
			if (is_struct(_eva) && _eva.node == _tr.pos && _eva.kind == "fair") _memt += choose(". the fair is on: stalls, geese, a man on stilts", ". the fair is on. everything costs more and is worth it", ". the fair: bunting, a pig on a rope, three bands at once");
			else if (is_struct(_eva) && _eva.node == _tr.pos && _eva.kind == "rats") _memt += choose(". rats in every gutter", ". the rats have the run of the place", ". a rat on the well-beam, watching");
			array_push(_tr.log, _nd.name + " - " + _pp.desc + _memt);
			break;
		}
		case "shop_open":  exped_shop(_tr, "open"); break;
		case "shop_buy":   exped_shop(_tr, "buy", _beat.i); break;
		case "shop_close": exped_shop(_tr, "close"); exped_say(_tr, "shop", undefined, .4); exped_note_beat(_tr, "shop", .12); break;
		case "linger": {
			// the distractions (his ask): a small thing that took an hour - composed, not picked (exped_compose, 2026-09-16)
			array_push(_tr.log, exped_compose("linger", _tr));
			exped_note_beat(_tr, "rest", .1);
			break;
		}
		case "rest": {
			var _cost = 0, _beds = 0, _cheap = 0;
			for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) { _beds++; if (sprite_note_has(exped_sprite(_tr.sids[_k]), "inn")) _cheap++; }
			_cost = max(ceil(_beds * EXPED_INN * .5), _beds * EXPED_INN - _cheap);   // (a note on inns: a bed cheaper - never below half the bill, 2026-09-16)
			var _evr = region_event(_tr.dest, _tr[$ "rgi"] ?? 0);
			if (is_struct(_evr) && _evr.kind == "fair" && _evr.node == _tr.pos) _cost = ceil(_cost * .5);   // (the fair's beds, 2026-09-16)
			if (is_struct(exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "grateful"))) _cost = 0;   // (a grateful town: on the house - the world remembers)
			if (_tr.credits >= _cost) {
				_tr.credits -= _cost;
				for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = _tr.hpmax[_k];
				if (is_array(_tr[$ "mp"])) for (var _k = 0; _k < array_length(_tr.mp); _k++) _tr.mp[_k] = 1;
				exped_stat("inns");
				array_push(_tr.log, "a night at the inn in " + _nd.name + ((_cost == 0) ? " - on the house. they remember" : (" (" + string(_cost) + " credits)")) + " - everyone is whole again");
				exped_say(_tr, "inn", undefined, .7);
			} else {
				for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .5);
				array_push(_tr.log, "no coin for the inn - slept in a barn in " + _nd.name + ". half a night's rest");
				exped_say(_tr, "poor", undefined, .8);
			}
			exped_note_beat(_tr, "rest", .3);
			break;
		}
		case "shop": exped_shop(_tr); exped_say(_tr, "shop", undefined, .4); break;
		case "tavern": {
			exped_stat("taverns");
			exped_say(_tr, "tavern", undefined, .5);
			exped_skill_beat(_tr, .12);   // (a trick off a drunk, sometimes)
			var _r = random(100);
			if (_r < 35 && roll_perc(55) && exped_dice(_tr)) {
				// (a game of chance in the tavern - his pick, 2026-09-16: exped_dice said its piece)
			} else if (_r < 35 && roll_perc(25)) {
				// a round with a rival crew (2026-09-16): a credit, and a rumour worth less
				var _rvs2 = exped_rivals(_tr.dest), _rc2 = _rvs2[irandom(array_length(_rvs2) - 1)], _who2 = _tr.names[irandom(_n - 1)];
				if (_tr.credits > 0) _tr.credits -= 1;
				array_push(_tr.log, _who2 + " stood " + _rc2.name + " a round in the tavern at " + _nd.name + ". " + choose(_rc2.lead + " told them where the chest is. it was not there", _rc2.lead + " talked for an hour about a door", "they swapped lies about the road. " + _rc2.lead + "'s were better", _rc2.lead + " drank the round and left. that was the whole of it"));
			} else if (_r < 35) {
				var _who = _tr.names[irandom(_n - 1)];
				if (_tr.credits > 0) _tr.credits -= 1;
				array_push(_tr.log, _who + " got " + choose("drunk", "very drunk", "into an argument with a chair", "a round in for everyone", "lost at cards") + " in the tavern at " + _nd.name + ((_tr.credits > 0) ? " (a credit, gone)" : ""));
			} else if (_r < 60) {
				if (roll_perc(40)) {
					// A RIVAL CREW (2026-09-16): a brawl with one of the world's three
					var _rvs = exped_rivals(_tr.dest), _rc = _rvs[irandom(array_length(_rvs) - 1)];
					_tr.fight = exped_fight_new(_tr, "bandit", 2, 0);
					for (var _j = 0; _j < array_length(_tr.fight.foes); _j++) { _tr.fight.foes[_j].name = (_j == 0) ? _rc.lead : ("one of " + _rc.name); _tr.fight.foes[_j].kind = "drunk"; }
					array_push(_tr.log, "a brawl with " + _rc.name + " in the tavern at " + _nd.name + ". nobody remembers who started it. " + _rc.lead + " does");
				} else {
					_tr.fight = exped_fight_new(_tr, "bandit", 1, 0);
					_tr.fight.foes[0].name = "a drunk"; _tr.fight.foes[0].kind = "drunk";   // (not a bandit for the quest's count - bug hunt 2026-09-15)
					array_push(_tr.log, "a bar fight in " + _nd.name + ". nobody remembers who started it");
				}
				if (roll_perc(50)) { exped_mem_set(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "barred", 72); array_push(_tr.log, choose("the keeper says they are barred, whatever happens next", "barred from the tavern in " + _nd.name + ", for a while", "the door of the tavern in " + _nd.name + " is shut to them now")); }   // (the world remembers, 2026-09-16)
			} else if (_r < 85 && !is_struct(_tr[$ "bounty"]) && _stn.bounty == 0) {
				array_push(_tr.log, "a bounty on the board in " + _nd.name + ". " + choose("not this trip - cautious", "they read it twice and left it. cautious", "cautious: the board can keep it", "somebody else's, they decided. cautious"));
			} else if ((_r < 85 || _stn.bounty >= 2) && !is_struct(_tr[$ "bounty"])) {
				// a bounty: a nearby dungeon or camp, a few kills (a greedy crew takes one whenever the board has one)
				var _cand = [];
				for (var _i = 1; _i < array_length(_rg.nodes); _i++) if (_rg.nodes[_i].kind == "dungeon" || _rg.nodes[_i].kind == "crypt" || _rg.nodes[_i].kind == "camp") array_push(_cand, _i);
				if (array_length(_cand) > 0) {
					var _bn = _cand[irandom(array_length(_cand) - 1)];
					var _bkl = foe_kinds_at(_rg.nodes[_bn].kind), _bk = (_rg.nodes[_bn].kind == "camp") ? "bandit" : _bkl[irandom(array_length(_bkl) - 1)];   // (the place's own kinds - the foes pass)
					var _evb = region_event(_tr.dest, _tr[$ "rgi"] ?? 0);
					_tr.bounty = { node : _bn, foe : _bk, n : irandom_range(2, 4), done : 0, pay : ceil((3 + 2 * _tr.dest.tier) * ((is_struct(_evb) && _evb.kind == "lord") ? 1.5 : 1)) };   // (the lord abroad: half again - 2026-09-16)
					array_push(_tr.log, "took a bounty off the board in " + _nd.name + ": " + string(_tr.bounty.n) + " " + foe_plural(_bk) + " at " + _rg.nodes[_bn].name + ", " + string(_tr.bounty.pay) + " credits" + ((_stn.bounty >= 2) ? choose(" - greedy", ". greedy: of course they did", " (greedy)") : ""));
				}
			} else array_push(_tr.log, exped_compose("rumour", _tr));   // (the talk, composed - 2026-09-16)
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
			// THE STANCE (2026-09-16): a cautious crew turns back at the next door once it is hurt
			if (_stn.press < 0) {
				var _mh = 0, _mu = 0;
				for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) { _mh += _tr.hp[_k] / max(1, _tr.hpmax[_k]); _mu++; }
				if (_mu > 0 && _mh / _mu < _stn.hurt) { array_push(_tr.log, choose("a door in " + _nd.name + ". cautious: they do not open it", _nd.name + ": a stair going down. cautious, they go back up instead", "cautious: enough of " + _nd.name + " for one day")); exped_stat("delves"); _tr.act = undefined; return; }
			}
			// a room: a fight, a find, a trap, a quiet one (exped_room's kinds) - a dungeon cleared lately (the world remembers) fights back less
			var _qt = (_a[$ "quiet"] ?? false);
			if (_qt && !(_a[$ "said_quiet"] ?? false)) { _a.said_quiet = true; array_push(_tr.log, choose("quiet since they cleared it. the doors stand open", "their own boot prints, going in. nothing has come back yet", "the place is empty of most things. the smell stays")); }
			var _r = random(100);
			if (_r < (_qt ? 20 : 45)) { _tr.fight = exped_fight_new(_tr, "", -1, 0); array_push(_tr.log, "a room of " + _nd.name + ": " + _tr.fight.b.name + " blocks the way"); exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6); }   // (the place's own kinds)
			else if (_r < (_qt ? 45 : 75)) exped_room_find(_tr, "a room of " + _nd.name + ": ");
			else if (_r < (_qt ? 60 : 90)) exped_room_trap(_tr, "a room of " + _nd.name + ": ");
			else { for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .25); array_push(_tr.log, "a room of " + _nd.name + ": quiet. they rested"); exped_say(_tr, "rest", undefined, .5); }
			if (is_struct(_q) && _q.kind == "clear" && _q.node == _tr.pos) { _q.done = min(_q.n, _q.done + 1); if (_q.done >= _q.n) array_push(_tr.log, _nd.name + " is cleared. the quest is done"); }
			_tr.cleared += 1;
			break;
		}
		case "camp": {
			var _evc = region_event(_tr.dest, _tr[$ "rgi"] ?? 0), _lordc = (is_struct(_evc) && _evc.kind == "lord");
			_tr.fight = exped_fight_new(_tr, "bandit", irandom_range(2, 3) + (_lordc ? 1 : 0), 0);   // a camp is never one bandit (one more with the lord abroad - 2026-09-16)
			array_push(_tr.log, "bandits at " + _nd.name + ": " + string(array_length(_tr.fight.foes)) + " of them");
			exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6);
			if (_a.steps <= 1) _a.loot = true;   // the last fight's win pays the camp's chest (exped_tick_one)
			break;
		}
		case "mine": case "gather": {
			var _fam = ["ferrite", "bloom", "glass"][_tr.dest.biome mod 3];
			var _cnt = 1 + irandom(2) + _tr.dest.tier;
			array_push(_tr.finds, { kind : "mats", rar : 0, fam : _fam, tier : _tr.dest.tier, n : _cnt, txt : string(_cnt) + " " + _fam + " (t" + string(_tr.dest.tier) + ")", col : c_white });
			if (_a.kind == "gather" && is_struct(_q) && _q.kind == "gather" && _q.done < _q.n) {
				// a sack of the quest's ore (the gather kind, 2026-09-15)
				_q.done += 1;
				array_push(_tr.log, "sack " + string(_q.done) + " of " + string(_q.n) + ": " + string(_cnt) + " " + _fam + " out of " + _nd.name + ((_q.done >= _q.n) ? ". the sacks are full. the quest is done" : ""));
			} else array_push(_tr.log, "mined " + string(_cnt) + " " + _fam + " at " + _nd.name);
			exped_say(_tr, "mine", undefined, .4);
			break;
		}
		// ---- THE MISSION-TYPE PASS (2026-09-15) ----
		// THE TOWN QUESTS' ACTS (2026-09-16)
		case "pickup": {
			if (is_struct(_q)) _q.at = 1;
			array_push(_tr.log, "collected " + (is_struct(_q) ? _q.who : "the parcel") + " in " + _nd.name + ". " + choose("it is heavier than it looks", "it was wrapped twice", "the client would not meet anyone's eye", "it came with instructions, in a hand nobody could read", "it was warm", "it rattled"));
			exped_say(_tr, "fetch", undefined, .7);
			break;
		}
		case "goatmeet": {
			if (is_struct(_q)) _q.at = 1;
			array_push(_tr.log, "collected " + (is_struct(_q) ? _q.who : "the goat") + " in " + _nd.name + ". " + choose("it has opinions", "it ate the receipt", "it looked at " + _tr.names[0] + " and decided something", "it is on a rope. the rope is a formality", "it is bigger than a goat should be"));
			exped_say(_tr, "meet", undefined, .7);
			break;
		}
		case "goatlost": {
			array_push(_tr.log, "found " + (is_struct(_q) ? _q.who : "the goat") + " " + choose("eating a hedge", "on a roof, somehow", "in a ditch, pleased", "standing exactly where it had been left, looking innocent", "with another goat. the other goat stays") + ". an hour gone");
			break;
		}
		case "mind": {
			// a customer a step; the last is the cat. the takings go in the pocket
			if (_a.steps >= 2) {
				var _ppm = region_node_info(_tr.dest, _rg, _tr.pos);   // (the place's own elder, one customer in three - the recurring folk, 2026-09-16)
				var _buyer = (is_struct(_ppm[$ "folk"]) && roll_perc(30)) ? (_ppm.folk.elder + " the elder") : exped_npc_name();
				var _take = 1 + irandom(2) + floor(_rg.lv / 3);
				_tr.credits += _take; exped_tally(_tr, "earned", _take);
				array_push(_tr.log, _buyer + " came in and bought " + choose("a spoon", "the wrong nails", "two of something", "a hat off the peg", "a length of string, measured twice", "an onion, after a speech", "the good ladder, on credit", "a lantern and the oil for it", "nothing, at length, then a candle") + " (" + string(_take) + " credits in the till)");
				if (roll_perc(25)) array_push(_tr.log, choose(_tr.names[irandom(_n - 1)] + " gave the wrong change and was thanked for it", "the bell over the door rang with nobody there", "a child came in for the cat. the cat declined", "somebody asked for " + (is_struct(_q) ? _q.who : "the keeper") + " by name and left when told"));
			} else {
				if (is_struct(_q)) _q.done = _q.n;
				array_push(_tr.log, "somebody bought the cat. " + (is_struct(_q) ? _q.who : "the keeper") + " came back, counted the till, and said nothing about the cat. the quest is done");
			}
			break;
		}
		case "stand": {
			// an hour of standing in it, composed
			var _sw = _tr.names[irandom(_n - 1)];
			array_push(_tr.log, choose(_sw + " stood in " + _nd.name, "stood in " + _nd.name + ", as asked", _sw + " sat down and was told to stand", "the crew stood. " + _nd.name + " did not mind", _sw + " counted clouds", "a farmer asked what they were doing. they said. the farmer left") + choose("", ". nothing happened", ". then it rained a little", ". " + _sw + " found a stone", ". the wind changed", ". somebody sang, quietly, and stopped"));
			if (is_struct(_q) && _a.steps <= 1) { _q.done = _q.n; array_push(_tr.log, "the hours are up. the quest is done. nobody can say what it was for"); }
			break;
		}
		case "meet": {
			// the escort's merchant, met; the cart rides with the crew from here (exped_encounter: bandits like it)
			if (is_struct(_q)) _q.at = 1;
			exped_stat("met");
			array_push(_tr.log, "met " + (is_struct(_q) ? _q.who : "the merchant") + " in " + _nd.name + ". " + choose("the cart is full of turnips", "the cart squeaks", "they talk a lot", "the cart is mostly cheese", "it has a hat and opinions", "the mule is called something long"));
			exped_say(_tr, "meet", undefined, .9);
			break;
		}
		case "fetch": {
			// two steps: something may be sitting on it, then the thing itself
			if (_a.steps >= 2) {
				if (roll_perc(40)) { _tr.fight = exped_fight_new(_tr, "", irandom_range(1, 2), 0); array_push(_tr.log, _nd.name + ": " + _tr.fight.b.name + " was sitting on " + (is_struct(_q) ? _q.who : "it")); exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6); }
				else array_push(_tr.log, _nd.name + ": " + choose("looked around", "poked about", "asked a bird", "checked under things"));
			} else {
				if (is_struct(_q)) _q.at = 1;
				array_push(_tr.log, "found " + (is_struct(_q) ? _q.who : "it") + " at " + _nd.name + ". " + choose("it is heavier than it looks", "it is fine", "it complained", "someone had labelled it", "it was under a rock, of course"));
				exped_say(_tr, "fetch", undefined, .8);
			}
			break;
		}
		case "rescue": {
			// room by room until found (the last room always finds them)
			var _last = (_a.steps <= 1), _who = is_struct(_q) ? _q.who : "them";
			var _in = (_nd.kind == "dungeon" || _nd.kind == "crypt") ? ("a room of " + _nd.name + ": ") : ("searching " + _nd.name + ": ");
			var _r = random(100);
			if (_r < 35 && !_last) { _tr.fight = exped_fight_new(_tr, "", -1, 0); array_push(_tr.log, _in + _tr.fight.b.name + " blocks the way"); exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .6); }
			else if (_last || roll_perc(35)) {
				if (is_struct(_q)) _q.at = 1;
				_a.steps = 1;   // (found: the search ends here)
				array_push(_tr.log, "found " + _who + " " + _in + choose("in one piece", "asleep", "annoyed", "under a table", "arguing with a rat", "halfway through a sandwich", "hiding rather well"));
				exped_stat("met");
				exped_say(_tr, "found", undefined, .9);
			}
			else if (_r < 70) array_push(_tr.log, _in + "no sign of " + _who + ". " + choose("a boot", "scratches on the wall", "an echo", "a half-eaten thing", "footprints, going the other way"));
			else exped_room_find(_tr, _in);
			break;
		}
		case "bossfight": {
			// one big fight: the bounty's named boss and whatever it keeps
			if (_a.steps >= 2 && is_struct(_q)) {
				_tr.fight = exped_fight_new(_tr, _q.foe, (_q.kind == "well") ? 1 : irandom_range(1, 2), 1, { boss : true, name : _q.who, variant : (_q.kind == "well") ? "giant" : (((_q[$ "vil"] ?? 0) > 0) ? "greater" : "") });   // (the villain: a greater one - 2026-09-16)   // (the well: one giant thing - 2026-09-16)
				array_push(_tr.log, _q.who + " " + choose("is here, and knows it", "was waiting", "stands up. it is big", "does not run") + " - " + _nd.name);
				exped_say(_tr, "boss", { foe : _q.who }, .9);
			} else array_push(_tr.log, choose("nothing else moves at " + _nd.name, "the rest of them left in a hurry"));
			break;
		}
		case "defend": {
			// a wave; the villagers patch the crew up between waves
			var _wave = is_struct(_q) ? (_q.done + 1) : 1, _nw = is_struct(_q) ? _q.n : 1;
			if (_wave > 1) { for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .15); array_push(_tr.log, "the villagers patch them up between waves"); }
			var _fk = is_struct(_q) ? _q.foe : choose("goblin", "lupus", "kobold", "apero");
			_tr.fight = exped_fight_new(_tr, _fk, irandom_range(2, 3), 0);
			array_push(_tr.log, "wave " + string(_wave) + " of " + string(_nw) + " at " + _nd.name + ": " + string(array_length(_tr.fight.foes)) + " " + foe_plural(_fk) + " " + choose("out of the treeline", "over the fence", "up the road, not quietly"));
			exped_say(_tr, "wave", { foe : _tr.fight.b.name }, .55);
			break;
		}
		case "shrine": {
			// a tonic in the bowl, one time in four (2026-09-16)
			if (roll_perc(25)) {
				var _tsp = exped_sprite(_tr.sids[irandom(_n - 1)]);
				if (!is_undefined(_tsp)) { var _ttk = sprite_take(_tsp, use_gen("tonic", 1, _rg.lv)); exped_tally(_tr, "items"); array_push(_tr.log, "in the bowl at the shrine, a tonic. " + _ttk.txt); }
			}

			for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .3);
			exped_skill_beat(_tr, .3);   // (a shrine teaches, sometimes)
			array_push(_tr.log, "the shrine at " + _nd.name + ": " + choose("a small blessing", "the water was cold and helped", "someone left a candle. it counted"));
			exped_say(_tr, "shrine", undefined, .6);
			if (roll_perc(20)) { array_push(_tr.finds, { kind : "charm", rar : 0, txt : "a charm (+1 luck)", col : c_seagreen }); array_push(_tr.log, "...and a charm, left on the step"); }
			break;
		}
		case "ruin": {
			var _r = random(100);
			if (_r < 50) exped_room_find(_tr, _nd.name + ": ");
			else if (_r < 80) exped_room_trap(_tr, _nd.name + ": ");
			else array_push(_tr.log, _nd.name + ": " + choose("stones. old ones.", "a floor with no house", "someone lived here. they left"));
			exped_say(_tr, "ruin", undefined, .5);
			break;
		}
		case "wild": {
			var _r = random(100);
			if (_r < 30) { _tr.fight = exped_fight_new(_tr, "", irandom_range(1, 2), 0); array_push(_tr.log, _nd.name + ": " + _tr.fight.b.name + " " + choose("was not pleased", "objected", "came out of the grass")); }
			else if (_r < 50) exped_room_find(_tr, _nd.name + ": ");
			else {
				array_push(_tr.log, exped_compose("wild", _tr));   // (the crossing, composed - 2026-09-16)
			}
			if (_tr.mode == "explore" && _nd.kind == "forest" && roll_perc(30) && is_undefined(_tr.fight)) { _tr.fight = exped_fight_new(_tr, "lupus", -1, 0); array_push(_tr.log, "went hunting in " + _nd.name); }
			if (is_undefined(_tr.fight)) exped_say(_tr, "wild", undefined, .3);
			break;
		}
		case "look": break;
	}
	_a.steps -= 1;
	exped_quest_after(_tr);   // (a quest just done: gratitude, and the follow-up card - 2026-09-16)
	// a fight opened: the activity waits for it (exped_tick_one reads act.kind
	// for the camp's chest and the rout quest) and looks again after
	if (!is_undefined(_tr.fight)) { _a.left = EXPED_ROOM_T * .5; return; }
	if (_a.steps > 0) _a.left = (_a.kind == "town") ? (_a[$ "next_t"] ?? EXPED_ROOM_T) : ((_a.kind == "stand") ? EXPED_HOUR : EXPED_ROOM_T);   // (a town's beat: its own hours; standing in a field: an hour a step)
	else {
		// greedy: one room more at the end, sometimes (a room nobody mapped)
		if (_a.kind == "delve" && _stn.press > 0 && !(_a[$ "more"] ?? false) && roll_perc(40)) { _a.more = true; _a.steps = 1; _a.left = EXPED_ROOM_T; array_push(_tr.log, choose(_tr.names[irandom(_n - 1)] + " said one more room. greedy. one more room", "greedy: a door nobody mapped. they open it", "one more room, for the chest that might be there. greedy")); return; }
		if (_a.kind == "delve") {
			exped_stat("delves"); array_push(_tr.log, "out of " + _nd.name + ", into the light");
			// THE WORLD REMEMBERS (2026-09-16): delved to its end, the place is quiet for three days
			if ((_nd.kind == "dungeon" || _nd.kind == "crypt" || _nd.kind == "sewer") && !(_a[$ "quiet"] ?? false)) exped_mem_set(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "quiet", 72);
		}
		_tr.act = undefined;
	}
}
