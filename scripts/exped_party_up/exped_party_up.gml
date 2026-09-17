/// @description exped_party_up(trip) -> the sprites of the party who are up (hp > 0), as structs - the hands a find can go to
function exped_party_up(_tr) {
	var _out = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_k < array_length(_tr.hp) && _tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (!is_undefined(_sp)) array_push(_out, _sp);
	}
	return _out;
}
