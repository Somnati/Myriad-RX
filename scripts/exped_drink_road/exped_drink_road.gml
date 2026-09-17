/// @description exped_drink_road(trip, when) -> true if drunk - THE ROAD'S POTIONS (2026-09-17):
/// "night" = the first dark hour: an owl's eye potion, from whoever carries
/// one, and the night costs the crew nothing for the rest of the trip
/// (tr.owl); "delve" = the first room of a delve: a potion of fortune, and
/// three luck to the crew for the rest of the trip (tr.luck_pot)
function exped_drink_road(_tr, _when) {
	var _kind = (_when == "night") ? "owl" : ((_when == "delve") ? "fortune" : "");
	if (_kind == "") return false;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _sh = sprite_sheet(_sp);
		for (var _j = 0; _j < array_length(_sh.inv); _j++) {
			var _it = _sh.inv[_j];
			if ((_it[$ "slot"] ?? "") != "use" || _it.kind != _kind) continue;
			array_delete(_sh.inv, _j, 1);
			if (_when == "night") { _tr.owl = true; array_push(_tr.log, _sp.name + " drank the owl's eye potion" + choose(". the dark went thin", ". everything had edges", ". the road showed itself")); }
			else { _tr.luck_pot = 3; array_push(_tr.log, _sp.name + " drank the potion of fortune" + choose(". things will go their way for a while", ". a coin came up heads, twice", ". the dice felt warm")); }
			save_mark_dirty();
			return true;
		}
	}
	return false;
}
