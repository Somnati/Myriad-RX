/// @description cbt_hazard_hold(sprite, hazard) -> { ok, by } - does the sprite hold the hazard off, and by what
/// A worn item of one of the hazard's gear FAMILIES (by = the item's
/// name), or the class (by = "a rogue"). Read fresh off the sheet
/// (sprite_stats' worn list) - nothing stored.
function cbt_hazard_hold(_sp, _hz) {
	var _st = sprite_stats(_sp);
	for (var _i = 0; _i < array_length(_st.worn); _i++) if (array_contains(_hz.gear, _st.worn[_i].fam)) return { ok : true, by : _st.worn[_i].name };
	if (array_contains(_hz.cls, _st.cls.key)) return { ok : true, by : "a " + _st.cls.key };
	return { ok : false, by : "" };
}
