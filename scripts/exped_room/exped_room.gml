/// @description exped_room(trip) - the crew enters the next room
/// find: a roll from the biome's loot table into the haul. rest: hp
/// back. trap: hp lost (a rout if it empties). fight: exped_fight_new -
/// the tick steps its turns.
/// @param trip
function exped_room(_tr) {
	_tr.room_i += 1;
	var _kind = _tr.rooms[_tr.room_i];
	var _bi = exped_biomes()[_tr.dest.biome];
	switch (_kind) {
		case "find":
			var _l = exped_loot_roll(_tr);
			array_push(_tr.finds, _l);
			array_push(_tr.log, "room " + string(_tr.room_i + 1) + ": found " + _l.txt);
			_tr.cleared += 1;
			break;
		case "rest":
			_tr.hp = min(_tr.hpmax, _tr.hp + 3);
			array_push(_tr.log, "room " + string(_tr.room_i + 1) + ": a quiet room - rested");
			_tr.cleared += 1;
			break;
		case "trap":
			var _dmg = 1 + irandom(_tr.dest.tier);
			_tr.hp = max(0, _tr.hp - _dmg);
			array_push(_tr.log, "room " + string(_tr.room_i + 1) + ": a trap - " + string(_dmg) + " hp");
			if (_tr.hp <= 0) { _tr.routed = true; array_push(_tr.log, _tr.sname + " limps home"); }
			else _tr.cleared += 1;
			break;
		case "fight":
			_tr.fight = exped_fight_new(_tr);
			array_push(_tr.log, "room " + string(_tr.room_i + 1) + ": " + _tr.fight.b.name + " blocks the way");
			break;
	}
}
