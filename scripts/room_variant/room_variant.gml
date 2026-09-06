/// @description room_variant(rm) - the shape of `rm` that matches the
/// live orientation. THE resolver: goto_room runs every destination
/// through it, so naming the portrait room anywhere in the codebase
/// lands you in whichever shape is being played.
///
/// A room with no entry in room_pairs comes straight back out - a
/// one-shape room is not an error, it just cannot be swapped.
/// @param rm
function room_variant(_rm) {
	var _t = room_pairs();
	var _l = (room_orient() == 1);
	for (var _i = 0; _i < array_length(_t); _i++) {
		var _e = _t[_i];
		// match EITHER shape: the caller may hand us the landscape id
		// (a back-history entry recorded before the setting changed)
		if (_rm == _e.p || _rm == _e.l) return _l ? _e.l : _e.p;
	}
	return _rm;
}
