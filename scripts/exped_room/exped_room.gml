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
			if (_l.kind == "gear") {
				// GEAR IS THE SPRITE'S (his pitch): whoever is up takes it -
				// worn, pocketed or binned by the sheet's rules (sprite_take);
				// the haul card shows the outcome, collect leaves it alone
				var _upf = [];
				for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_upf, _k);
				var _whof = (array_length(_upf) > 0) ? _upf[irandom(array_length(_upf) - 1)] : 0;
				var _spf = undefined;
				for (var _if = 0; _if < array_length(g.sprites); _if++) if (g.sprites[_if].id == _tr.sids[_whof]) _spf = g.sprites[_if];
				if (_spf != undefined) {
					var _tk = sprite_take(_spf, _l.item, exped_party_up(_tr));   // (the party hands it round - 2026-09-16)
					if (_tk[$ "dumb"] ?? false) exped_tally(_tr, "mist", 1, _spf); else exped_tally(_tr, "items");   // (the tally, 2026-09-16)
					sprite_led(_spf, "finds");
					_l.txt = _tk.txt;
					array_push(_tr.log, _rm + _tk.txt);
					if (_tk.worn) exped_hp_refresh(_tr, _tk[$ "given"] ?? _spf.id);   // (the wearer's, handed round or not - q268)
				} else array_push(_tr.log, _rm + "found " + _l.txt);
			} else array_push(_tr.log, _rm + "found " + _l.txt);
			array_push(_tr.finds, _l);
			_tr.cleared += 1;
			exped_say(_tr, "find", { item : (_l.kind == "gear") ? _l.item.name : _l.txt }, .8);
			exped_note_beat(_tr, "find", .2, (_l.kind == "gear") ? _l.item.name : _l.txt);
			break;
		case "rest":
			for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + max(1, round(_tr.hpmax[_k] * .25)));   // a quarter of the pool (the sheet's hp, not the mock's 10)
			array_push(_tr.log, _rm + "a quiet room - rested");
			_tr.cleared += 1;
			exped_say(_tr, "rest", undefined, .85);
			exped_note_beat(_tr, "rest", .3);
			exped_say(_tr, "sky", undefined, .2);
			break;
		case "trap":
			// one of the crew takes it - whoever is still up; the bite is a
			// share of THEIR pool (8% + 4% a tier), since hp is the sheet's now
			var _up = [];
			for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
			var _who = (array_length(_up) > 0) ? _up[irandom(array_length(_up) - 1)] : 0;
			var _dmg = max(1, round(_tr.hpmax[_who] * (.08 + .04 * _tr.dest.tier)));
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
