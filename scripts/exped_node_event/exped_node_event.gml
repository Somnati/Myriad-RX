/// @description exped_node_event(trip, [again]) - the crew arrives at its node: what it does here
/// Sets trip.act = { kind, left, steps } (exped_act_step performs the
/// steps as the clock pays for them). The QUEST'S node overrides while
/// the quest is open (hunt / delve / camp / look); otherwise the node's
/// own purpose: rest when hurt and shop where people live (a tavern
/// visit on an explore), delve a dungeon, raid a camp, mine a mine, a
/// shrine's blessing, poke a ruin, cross the wild. The landing zone is
/// nothing. `again` = a second pass at the same node (the quest is not
/// done yet).
function exped_node_event(_tr, _again = false) {
	if (!_again) exped_drink(_tr);   // (arriving: the pocket, for whoever is low - 2026-09-16)
	static _kk_civ_count = function(_k) { var _kd = region_kinds()[$ _k]; return is_struct(_kd) && _kd.civ; };   // (the count quest: a settled place has more of everything)
	var _rg = exped_region(_tr);
	var _nd = _rg.nodes[_tr.pos];
	var _k = _nd.kind;
	var _q = _tr[$ "quest"];
	var _qhere = (is_struct(_q) && exped_quest_target(_q) == _tr.pos && _q.done < _q.n);   // (the stop the crew heads for now - the two-stop kinds, 2026-09-15)
	var _bo = _tr[$ "bounty"];
	if (is_struct(_bo) && _bo.node == _tr.pos && _bo.done < _bo.n) {
		_tr.act = { kind : "hunt", left : EXPED_ROOM_T * .5, steps : 3 };
		if (!_again) array_push(_tr.log, "the bounty: " + foe_plural(_bo.foe) + " at " + _nd.name);
		return;
	}
	if (_qhere) {
		switch (_q.kind) {
			case "slay":  _tr.act = { kind : "hunt",  left : EXPED_ROOM_T * .5, steps : 3 }; if (!_again) array_push(_tr.log, "the hunt for " + foe_plural(_q.foe) + " begins at " + _nd.name); break;
			case "clear": _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) { array_push(_tr.log, "into " + _nd.name); exped_say(_tr, "delve", undefined, .6); } break;
			case "rout":  exped_mem_clear(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "routed"); _tr.act = { kind : "camp",  left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) array_push(_tr.log, "the camp at " + _nd.name + " - " + exped_crew_txt(_tr.names) + " " + ((array_length(_tr.names) > 1) ? "go" : "goes") + " in"); break;
			case "scout": _q.done = _q.n; array_push(_tr.log, "scouted " + _nd.name + ". it is there. the quest is done"); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; break;
			// THE MISSION-TYPE PASS (2026-09-15): the two-stop kinds at their first stop, then their delivery; the rest at their place
			case "escort":
				if ((_q[$ "at"] ?? 0) == 0) { _tr.act = { kind : "meet", left : EXPED_ROOM_T * .5, steps : 1 }; if (!_again) array_push(_tr.log, "asking after " + _q.who + " in " + _nd.name); }
				else { _q.done = _q.n; array_push(_tr.log, _q.who + " delivered to " + _nd.name + ", cart and all. paid on the nail. the quest is done"); exped_say(_tr, "deliver", undefined, .8); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; }
				break;
			case "fetch":
				if ((_q[$ "at"] ?? 0) == 0) { _tr.act = { kind : "fetch", left : EXPED_ROOM_T * .5, steps : 2 }; if (!_again) array_push(_tr.log, _nd.name + ": " + _q.who + " should be around here"); }
				else { _q.done = _q.n; array_push(_tr.log, "handed " + _q.who + " over in " + _nd.name + ". " + choose("nobody said thank you", "there was a small fuss", "it was the wrong one, but they kept it") + ". the quest is done"); exped_say(_tr, "deliver", undefined, .8); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; }
				break;
			case "rescue":
				if ((_q[$ "at"] ?? 0) == 0) { var _rr = _nd[$ "rooms"]; if (is_undefined(_rr)) _rr = irandom_range(3, 5); _tr.act = { kind : "rescue", left : EXPED_ROOM_T * .5, steps : _rr }; if (!_again) array_push(_tr.log, "into " + _nd.name + ", calling for " + _q.who); }
				else { _q.done = _q.n; array_push(_tr.log, _q.who + " home in " + _nd.name + ", to some fuss. the quest is done"); exped_say(_tr, "deliver", undefined, .8); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; }
				break;
			case "bounty": _tr.act = { kind : "bossfight", left : EXPED_ROOM_T * .5, steps : 2 }; if (!_again) array_push(_tr.log, _q.who + " is somewhere in " + _nd.name + ". " + choose("tracks, big ones", "the birds have gone quiet", "someone has been eating here")); break;
			case "defend": _tr.act = { kind : "defend", left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) array_push(_tr.log, "at " + _nd.name + ". the villagers point at the treeline and go indoors"); break;
			case "survey": {
				_q.done = min(_q.n, _q.done + 1);
				array_push(_tr.log, "charted " + _nd.name + " (" + string(_q.done) + " of " + string(_q.n) + ")" + ((_q.done >= _q.n) ? ". the chart is done. the quest is done" : ""));
				exped_say(_tr, "chart", undefined, .55);
				_tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 };
				break;
			}
			case "gather": _tr.act = { kind : "gather", left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) array_push(_tr.log, "the mine at " + _nd.name + ": sacks out, " + string(_q.n) + " to fill"); break;
			// THE TOWN QUESTS (2026-09-16)
			case "parcel":
				if ((_q[$ "at"] ?? 0) == 0) { _tr.act = { kind : "pickup", left : EXPED_ROOM_T * .5, steps : 1 }; if (!_again) array_push(_tr.log, "asking after " + _q.who + " in " + _nd.name); }
				else { _q.done = _q.n; array_push(_tr.log, "handed " + _q.who + " over in " + _nd.name + ". " + choose("it was the wrong one, but they kept it", "nobody said thank you", "they weighed it and said nothing", "it was opened at once and not shown to anyone", "the client cried a little", "it had got heavier") + ". the quest is done"); exped_say(_tr, "deliver", undefined, .8); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; }
				break;
			case "goat":
				if ((_q[$ "at"] ?? 0) == 0) { _tr.act = { kind : "goatmeet", left : EXPED_ROOM_T * .5, steps : 1 }; if (!_again) array_push(_tr.log, "collecting " + _q.who + " in " + _nd.name); }
				else { _q.done = _q.n; array_push(_tr.log, _q.who + " delivered to " + _nd.name + ". it went " + choose("straight for the cabbages", "for the washing", "up the church steps", "into the inn", "back the way it came, briefly") + ". the quest is done"); exped_say(_tr, "deliver", undefined, .8); _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; }
				break;
			case "count": {
				// a place counted: a number of the thing (the sum rides q.at; the client disputes it at the end)
				var _cn = irandom_range(0, 9) + ((_kk_civ_count(_nd.kind)) ? irandom_range(2, 12) : 0);
				_q.at = (_q[$ "at"] ?? 0) + _cn;
				_q.done = min(_q.n, _q.done + 1);
				array_push(_tr.log, "counted " + string(_cn) + " " + _q.who + " at " + _nd.name + " (" + string(_q.done) + " of " + string(_q.n) + " places)"
					+ ((_q.done >= _q.n) ? (". reported " + string(_q.at) + " " + _q.who + " in all. the client says " + string(_q.at + choose(-2, -1, 1, 1, 2, 3)) + ". the quest is done") : ""));
				_tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 };
				break;
			}
			case "shop":    _tr.act = { kind : "mind", left : EXPED_ROOM_T * .5, steps : 4 }; if (!_again) array_push(_tr.log, _q.who + " hands over the keys to the shop in " + _nd.name + " and goes. " + choose("the cat stays", "the shelf is half full", "there is a bell over the door", "the till does not lock")); break;
			case "nothing": _tr.act = { kind : "stand", left : EXPED_ROOM_T * .5, steps : _q.n }; if (!_again) array_push(_tr.log, _nd.name + ". the crew stands in it, as asked"); break;
			case "cellars": _tr.act = { kind : "hunt", left : EXPED_ROOM_T * .5, steps : 3 }; if (!_again) array_push(_tr.log, "down the cellar steps in " + _nd.name + ". " + choose("something skitters", "the villagers wait on the stairs", "a lamp is handed down", "the smell of turnips and worse")); break;
			case "well":    _tr.act = { kind : "bossfight", left : EXPED_ROOM_T * .5, steps : 2 }; if (!_again) array_push(_tr.log, "the well at " + _nd.name + ". " + choose("the rope goes down a long way", "the water is the wrong colour", "somebody lowers a lantern and pulls it up fast", "nobody has drawn from it in a month")); break;
		}
		return;
	}
	var _kk = region_kinds()[$ _k] ?? { civ : false, wild : true };
	// THE GOAT (2026-09-16): with the goat in tow, a wild place is where it wanders off - an hour, and a mistake
	if (!_again && is_struct(_q) && _q.kind == "goat" && (_q[$ "at"] ?? 0) == 1 && _kk.wild && _k != "mine" && _k != "shrine" && roll_perc(35)) {
		_tr.act = { kind : "goatlost", left : EXPED_HOUR, steps : 1 };
		exped_tally(_tr, "mist");
		array_push(_tr.log, _q.who + " wandered off in " + _nd.name + ". " + choose("everyone went a different way", "it was not far. it was not near, either", _tr.names[irandom(array_length(_tr.names) - 1)] + " has the rope. the rope has nothing", "a goat is faster than it looks"));
		return;
	}
	var _hurt = false, _mean = 0, _up = 0;
	for (var _i = 0; _i < array_length(_tr.hp); _i++) if (_tr.hp[_i] > 0) { _mean += _tr.hp[_i] / max(1, _tr.hpmax[_i]); _up++; }
	_mean = (_up > 0) ? _mean / _up : 1;
	if (_kk.civ) {
		// THE TOWN AS A PLAN OF BEATS (his asks, 2026-09-16: "events at a town
		// popped into the log all at once"; "they might get distracted in
		// towns"): one beat a step, each with its own hours - a look round
		// (the papers' line), the shop opened, a look at the shelf each, the
		// shop closed, a tavern sometimes, a linger or two, and a night at the
		// inn when hurt or late. Four to nine hours of it (exped_act_step)
		if (_again) { _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; return; }
		var _plan = [], _stn = exped_stance(_tr);   // (the stance leans the tavern and the inn, 2026-09-16)
		array_push(_plan, { k : "arrive", t : .5 });
		array_push(_plan, { k : "shop_open", t : .4 });
		for (var _pi = 0; _pi < array_length(_tr.sids); _pi++) if (_tr.hp[_pi] > 0) array_push(_plan, { k : "shop_buy", i : _pi, t : .35 });
		array_push(_plan, { k : "shop_close", t : .25 });
		var _evp = region_event(_tr.dest, _tr[$ "rgi"] ?? 0), _fairp = (is_struct(_evp) && _evp.kind == "fair" && _evp.node == _tr.pos);   // (the fair: the tavern always, a linger more - 2026-09-16)
		var _ldp = region_node_leader(_tr.dest, _rg, _tr.pos), _tvo = 1;   // (a pious leader keeps the tavern quiet, a drunk one does not - 2026-09-16)
		if (is_struct(_ldp)) _tvo = (_ldp.trait == "pious") ? .6 : ((_ldp.trait == "drunk") ? 1.5 : 1);
		if ((_fairp || roll_perc(((_tr.mode == "explore") ? 45 : 25) * _stn.tavern * _tvo)) && is_undefined(exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "barred"))) array_push(_plan, { k : "tavern", t : 1.2 });   // (not while barred - the world remembers)
		if (_fairp) array_push(_plan, { k : "linger", t : 1 });
		repeat (1 + (roll_perc(40) ? 1 : 0)) array_push(_plan, { k : "linger", t : random_range(.5, 1.5) });
		var _night2 = (_tr[$ "night"] ?? false);
		if (_mean < _stn.hurt + .2 || (_night2 && _tr.credits >= EXPED_INN && roll_perc(60))) array_push(_plan, { k : "rest", t : 4 });   // (cautious books a bed at three quarters, greedy under half)
		_tr.act = { kind : "town", left : 0, steps : array_length(_plan), plan : _plan, i : 0, next_t : EXPED_ROOM_T };
		return;
	}
	switch (_k) {
		case "dungeon": { var _rm = _nd[$ "rooms"]; if (is_undefined(_rm)) _rm = irandom_range(3, 5); var _qm = exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "quiet"); if (is_struct(_qm)) _rm = max(1, floor(_rm * .5)); var _rvq = (!is_struct(_qm) && roll_perc(12)); if (_rvq) { var _rvc = exped_rivals(_tr.dest)[irandom(2)]; array_push(_tr.log, _rvc.name + " came out of " + _nd.name + " as they went in. \"nothing left,\" said " + _rvc.lead + ". " + choose("there was, a little", "there was a lot, actually", "they were lying", "there was a chest they had missed")); } _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : _rm, quiet : is_struct(_qm) || _rvq }; array_push(_tr.log, "into " + _nd.name + " (" + string(_rm) + " rooms)"); exped_say(_tr, "delve", undefined, .6); break; }   // (the dungeon's own rooms, 2026-09-15)
		case "crypt":   { var _rm = _nd[$ "rooms"]; if (is_undefined(_rm)) _rm = irandom_range(3, 5); var _qm = exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "quiet"); if (is_struct(_qm)) _rm = max(1, floor(_rm * .5)); var _rvq = (!is_struct(_qm) && roll_perc(12)); if (_rvq) { var _rvc = exped_rivals(_tr.dest)[irandom(2)]; array_push(_tr.log, _rvc.name + " came out of " + _nd.name + " as they went in. \"nothing left,\" said " + _rvc.lead + ". " + choose("there was, a little", "there was a lot, actually", "they were lying", "there was a chest they had missed")); } _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : _rm, quiet : is_struct(_qm) || _rvq }; array_push(_tr.log, "down into " + _nd.name + " (" + string(_rm) + " rooms). it is cold"); exped_say(_tr, "delve", undefined, .6); break; }
		case "sewer":   { var _rm = _nd[$ "rooms"]; if (is_undefined(_rm)) _rm = irandom_range(3, 5); var _qm = exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "quiet"); if (is_struct(_qm)) _rm = max(1, floor(_rm * .5)); var _rvq = (!is_struct(_qm) && roll_perc(12)); if (_rvq) { var _rvc = exped_rivals(_tr.dest)[irandom(2)]; array_push(_tr.log, _rvc.name + " came out of " + _nd.name + " as they went in. \"nothing left,\" said " + _rvc.lead + ". " + choose("there was, a little", "there was a lot, actually", "they were lying", "there was a chest they had missed")); } _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : _rm, quiet : is_struct(_qm) || _rvq }; array_push(_tr.log, "down the grate into " + _nd.name + " (" + string(_rm) + " rooms). " + choose("the smell arrives first", "somebody's boot is never the same", "it is warmer than it should be", "there are things in the water")); exped_say(_tr, "delve", undefined, .6); break; }
		case "camp": {
			// THE WORLD REMEMBERS (2026-09-16): a camp routed lately is ashes - nobody home
			var _rmm = exped_mem_get(_tr.dest, _tr[$ "rgi"] ?? 0, _tr.pos, "routed");
			if (is_struct(_rmm)) { _tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 }; array_push(_tr.log, "the camp at " + _nd.name + ": " + choose("cold ashes and a boot. nobody home", "burnt poles, a pot, no bandits", "empty since they burned it. a crow has it now")); break; }
			var _ldcc = region_node_leader(_tr.dest, _rg, _tr.pos);   // (the chief of the month - 2026-09-16)
			_tr.act = { kind : "camp",  left : EXPED_ROOM_T * .5, steps : 2 }; array_push(_tr.log, "the camp at " + _nd.name + (is_struct(_ldcc) ? (" - " + _ldcc.name + " the " + _ldcc.title + "'s, " + _ldcc.trait + ((_ldcc.days < 7) ? ", new since " + _ldcc.prev[0].name + " " + _ldcc.prev[0].went : "")) : "")); exped_say(_tr, "camp", undefined, .5); break;
		}
		case "mine":    _tr.act = { kind : "mine",  left : EXPED_ROOM_T, steps : 1 }; break;
		case "shrine":  _tr.act = { kind : "shrine", left : EXPED_ROOM_T * .5, steps : 1 }; break;
		case "ruin":    _tr.act = { kind : "ruin",  left : EXPED_ROOM_T, steps : 1 }; break;
		case "landing": break;
		case "pass": {
			// THE BORDER (q291): an exploring crew crosses into the next territory - not recalled, not hurt, by the stance's odds
			// (cautious 40, steady 65, greedy 85) - a road of the crossing's hours with `cross` on it (exped_agent switches the
			// region at its end); else a look over it and back. A quest keeps to its own country
			var _xto = _nd[$ "to"] ?? -1, _xrg = (_xto >= 0) ? region_get(_tr.dest, _xto) : undefined;
			var _xhurt = (_mean < exped_stance(_tr).hurt);
			var _xgo = is_struct(_xrg) && ((_tr[$ "mode"] ?? "quest") == "explore") && !(_tr[$ "recall"] ?? false) && !_xhurt && !_again;
			if (_xgo) { var _xst = exped_stance(_tr).key; _xgo = roll_perc((_xst == "cautious") ? 40 : ((_xst == "greedy") ? 85 : 65)); }
			if (_xgo) {
				var _xp = -1;
				for (var _j = 0; _j < array_length(_xrg.nodes); _j++) if (_xrg.nodes[_j].kind == "pass" && (_xrg.nodes[_j][$ "to"] ?? -1) == (_tr[$ "rgi"] ?? 0)) { _xp = _j; break; }
				if (_xp >= 0) {
					var _xh = _nd[$ "cross_h"] ?? 1;
					_tr.road = { a : _tr.pos, b : _tr.pos, d : _xh, t : 0, cross : _xto, cross_pos : _xp };
					array_push(_tr.log, ((_nd[$ "sea"] ?? false) ? "a boat across into " : "over the border into ") + _xrg.name + " (" + string(_xh) + "h)" + ((_xrg.lv > _rg.lv) ? ". harder country, by the look of it" : ""));
					exped_stat("crossings");
					return;
				}
			}
			_tr.act = { kind : "look", left : EXPED_ROOM_T * .5, steps : 1 };
			if (!_again) array_push(_tr.log, is_struct(_xrg) ? ("the border of " + _xrg.name + ". " + choose("they looked over it and turned back", "not today", "a look, and back the way they came")) : "the border. nothing past it worth the walk");
			break;
		}
		default:        _tr.act = { kind : "wild",  left : EXPED_ROOM_T * .5, steps : 1 }; break;
	}
}
