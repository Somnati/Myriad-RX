/// @description exped_room_find(trip, prefix) - a find where the crew stands (the delve's / the wild's)
/// exped_loot_roll's kinds; gear goes to whoever is up (sprite_take).
function exped_room_find(_tr, _pre) {
	var _l = exped_loot_roll(_tr);
	if (_l.kind == "gear") {
		var _up = [];
		for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
		var _who = (array_length(_up) > 0) ? _up[irandom(array_length(_up) - 1)] : 0;
		var _sp = exped_sprite(_tr.sids[_who]);
		if (!is_undefined(_sp)) {
			var _tk = sprite_take(_sp, _l.item);
			_l.txt = _tk.txt;
			array_push(_tr.log, _pre + _tk.txt);
			if (_tk.worn) { _tr.hpmax[_who] = sprite_pawn(_sp).maxhp; _tr.hp[_who] = min(_tr.hp[_who], _tr.hpmax[_who]); }
		} else array_push(_tr.log, _pre + "found " + _l.txt);
	} else array_push(_tr.log, _pre + "found " + _l.txt);
	array_push(_tr.finds, _l);
	exped_say(_tr, "find", { item : (_l.kind == "gear") ? _l.item.name : _l.txt }, .7);
	exped_note_beat(_tr, "find", .2, (_l.kind == "gear") ? _l.item.name : _l.txt);
}
