/// @description save_slot_path(slot, [profile]);
/// @param slot
/// @param [profile]
/// THE naming authority for every save file. slot: 0 = main save,
/// 1-3 = rotating autosaves, 4 = rebirth save. profile defaults to the
/// active one (g.profile, 0-based). every reader/writer goes through
/// here, so multi-profile lives in exactly one place.
function save_slot_path(_slot, _prof = -1) {
	if (!variable_global_exists("profile")) g.profile = 0;
	if (_prof < 0) _prof = g.profile;
	var _p = "p" + string(_prof + 1);
	if (_slot == 0) return "save_"    + _p + ".ini";
	if (_slot == 4) return "rebirth_" + _p + ".ini";
	return "autosave_" + _p + "_" + string(_slot) + ".ini";
}
