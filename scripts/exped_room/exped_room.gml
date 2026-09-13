/// @description exped_room(trip) - the crew walks into the next room.
/// find pays a loot roll into the haul; rest heals everyone; a trap
/// hurts one of them (all down = routed); a fight opens (exped_fight_new)
/// and holds the clock until it ends. Every room writes its truth line
/// and lets the diary speak (exped_say).
function exped_room(_tr) {
	_tr.room_i += 1;
	var _kind = _tr.rooms[_tr.room_i];
	var _rm = "room " + string(_tr.room_i + 1) + ": ";
	switch (_kind) {
		case "find":
			var _l = exped_loot_roll(_tr);
			array_push(_tr.finds, _l);
			array_push(_tr.log, _rm + "found " + _l.txt);
			_tr.cleared += 1;
			exped_say(_tr, "find", { item : _l.txt }, .8);
			break;
		case "rest":
			for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + 3);
			array_push(_tr.log, _rm + "a quiet room - rested");
			_tr.cleared += 1;
			exped_say(_tr, "rest", undefined, .85);
			exped_say(_tr, "sky", undefined, .2);
			break;
		case "trap":
			var _dmg = 1 + irandom(_tr.dest.tier);
			// one of the crew takes it - whoever is still up
			var _up = [];
			for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
			var _who = (array_length(_up) > 0) ? _up[irandom(array_length(_up) - 1)] : 0;
			_tr.hp[_who] = max(0, _tr.hp[_who] - _dmg);
			array_push(_tr.log, _rm + "a trap - " + ((array_length(_tr.names) > 1) ? (_tr.names[_who] + " ") : "") + "-" + string(_dmg) + " hp");
			if (exped_alive(_tr) <= 0) { _tr.routed = true; array_push(_tr.log, exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " limp home" : " limps home")); }
			else _tr.cleared += 1;
			exped_say(_tr, "trap", undefined, .85);
			break;
		case "fight":
			_tr.fight = exped_fight_new(_tr);
			array_push(_tr.log, _rm + _tr.fight.b.name + " blocks the way");
			exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .85);
			break;
	}
}
