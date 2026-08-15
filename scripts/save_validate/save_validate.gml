/// @description save_validate(file);
/// @param file
/// is this a usable savefile? exists on disk and still contains the
/// save_datetime key: a power loss mid-write leaves a truncated or
/// empty ini, which fails this check. used by the boot failsafe to
/// pick a survivor.
function save_validate(_file) {
	if (!file_exists(_file)) return false;
	ini_open(_file);
	var _ok = ini_key_exists("system", "save_datetime");
	ini_close();
	return _ok;
}
