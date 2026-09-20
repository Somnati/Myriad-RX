/// @description exped_room_find(trip, prefix) - a find where the crew stands (the delve's / the wild's)
/// exped_loot_roll's kinds; gear goes to whoever is up (sprite_take).
function exped_room_find(_tr, _pre, _again = true) {   // (again = the prospector may double it - 2026-09-17)
	var _l = exped_loot_roll(_tr);
	exped_stat("finds");
	if (_l.kind == "gear") {
		exped_stat("gear_found");
		var _up = [];
		for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
		var _who = (array_length(_up) > 0) ? _up[irandom(array_length(_up) - 1)] : 0;
		var _sp = exped_sprite(_tr.sids[_who]);
		if (!is_undefined(_sp)) {
			var _tk = sprite_take(_sp, _l.item, exped_party_up(_tr));   // (the party hands it round - 2026-09-16)
			if (_tk[$ "dumb"] ?? false) exped_tally(_tr, "mist", 1, _sp); else exped_tally(_tr, "items");   // (the tally, 2026-09-16)
			sprite_led(_sp, "finds");
			_l.txt = _tk.txt;
			array_push(_tr.log, _pre + _tk.txt);
			if (_tk.worn) exped_hp_refresh(_tr, _tk[$ "given"] ?? _sp.id);   // (the wearer's, handed round or not - q268)
		} else array_push(_tr.log, _pre + "found " + _l.txt);
	} else array_push(_tr.log, _pre + "found " + _l.txt);
	// AN EGG IS ITS FINDER'S (2026-09-16): one of the party who is up keeps it close - it rides the sprite home (exped_collect)
	if (_l.kind == "egg") {
		var _eup = exped_party_up(_tr);
		if (array_length(_eup) > 0) { var _ek = _eup[irandom(array_length(_eup) - 1)]; _l.who = _ek.id; _l.txt = "a " + _l.fam + " egg, warm - " + _ek.name + " is keeping it close"; }
	}
	array_push(_tr.finds, _l);
	exped_say(_tr, "find", { item : (_l.kind == "gear") ? _l.item.name : _l.txt }, .7);
	exped_note_beat(_tr, "find", .2, (_l.kind == "gear") ? _l.item.name : _l.txt);
	// THE PROSPECTOR (the second roster, 2026-09-17): one find is often two
	if (_again && roll_perc(exped_party_ab(_tr).rooms)) exped_room_find(_tr, "and another: ", false);
}
