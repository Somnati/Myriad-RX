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
	var _rg = exped_region(_tr);
	var _nd = _rg.nodes[_tr.pos];
	var _k = _nd.kind;
	var _q = _tr[$ "quest"];
	var _qhere = (is_struct(_q) && exped_quest_target(_q) == _tr.pos && _q.done < _q.n);   // (the stop the crew heads for now - the two-stop kinds, 2026-09-15)
	var _bo = _tr[$ "bounty"];
	if (is_struct(_bo) && _bo.node == _tr.pos && _bo.done < _bo.n) {
		_tr.act = { kind : "hunt", left : EXPED_ROOM_T * .5, steps : 3 };
		if (!_again) array_push(_tr.log, "the bounty: " + _bo.foe + "s at " + _nd.name);
		return;
	}
	if (_qhere) {
		switch (_q.kind) {
			case "slay":  _tr.act = { kind : "hunt",  left : EXPED_ROOM_T * .5, steps : 3 }; if (!_again) array_push(_tr.log, "the hunt for " + _q.foe + "s begins at " + _nd.name); break;
			case "clear": _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) { array_push(_tr.log, "into " + _nd.name); exped_say(_tr, "delve", undefined, .6); } break;
			case "rout":  _tr.act = { kind : "camp",  left : EXPED_ROOM_T * .5, steps : max(1, _q.n - _q.done) }; if (!_again) array_push(_tr.log, "the camp at " + _nd.name + " - " + exped_crew_txt(_tr.names) + " " + ((array_length(_tr.names) > 1) ? "go" : "goes") + " in"); break;
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
		}
		return;
	}
	var _kk = region_kinds()[$ _k] ?? { civ : false, wild : true };
	var _hurt = false, _mean = 0, _up = 0;
	for (var _i = 0; _i < array_length(_tr.hp); _i++) if (_tr.hp[_i] > 0) { _mean += _tr.hp[_i] / max(1, _tr.hpmax[_i]); _up++; }
	_mean = (_up > 0) ? _mean / _up : 1;
	if (_kk.civ) {
		// a bed at night when there is coin (his ask: the time of day tells)
		var _night2 = (_tr[$ "night"] ?? false);
		if (_mean < .6 || (_night2 && _tr.credits >= EXPED_INN && roll_perc(55)) || (_tr.mode == "explore" && roll_perc(25))) _tr.act = { kind : "rest", left : EXPED_HOUR * .5, steps : 1 };
		else if (_tr.mode == "explore" && roll_perc(40)) _tr.act = { kind : "tavern", left : EXPED_ROOM_T, steps : 1 };
		else _tr.act = { kind : "shop", left : EXPED_ROOM_T, steps : 1 };
		return;
	}
	switch (_k) {
		case "dungeon": { var _rm = _nd[$ "rooms"]; if (is_undefined(_rm)) _rm = irandom_range(3, 5); _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : _rm }; array_push(_tr.log, "into " + _nd.name + " (" + string(_rm) + " rooms)"); exped_say(_tr, "delve", undefined, .6); break; }   // (the dungeon's own rooms, 2026-09-15)
		case "crypt":   { var _rm = _nd[$ "rooms"]; if (is_undefined(_rm)) _rm = irandom_range(3, 5); _tr.act = { kind : "delve", left : EXPED_ROOM_T * .5, steps : _rm }; array_push(_tr.log, "down into " + _nd.name + " (" + string(_rm) + " rooms). it is cold"); exped_say(_tr, "delve", undefined, .6); break; }
		case "camp":    _tr.act = { kind : "camp",  left : EXPED_ROOM_T * .5, steps : 2 }; array_push(_tr.log, "the camp at " + _nd.name); exped_say(_tr, "camp", undefined, .5); break;
		case "mine":    _tr.act = { kind : "mine",  left : EXPED_ROOM_T, steps : 1 }; break;
		case "shrine":  _tr.act = { kind : "shrine", left : EXPED_ROOM_T * .5, steps : 1 }; break;
		case "ruin":    _tr.act = { kind : "ruin",  left : EXPED_ROOM_T, steps : 1 }; break;
		case "landing": break;
		default:        _tr.act = { kind : "wild",  left : EXPED_ROOM_T * .5, steps : 1 }; break;
	}
}
