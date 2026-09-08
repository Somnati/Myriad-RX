/// @description upgrade_entry(id);
/// @param id
/// THE one lookup from a saved id to its roster entry. A save holds
/// ids, so an id that no longer exists in the roster has to fail
/// softly rather than crash - a retired upgrade should cost the player
/// a slot, not their savefile.
function upgrade_entry(_id) {
	var _c = upgrade_config();
	for (var _i = 0; _i < array_length(_c); _i++)
		if (_c[_i].id == _id) return _c[_i];
	return -1;
}
