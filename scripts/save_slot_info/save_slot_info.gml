/// @description save_slot_info(file);
/// @param file
/// peeks a savefile's display data WITHOUT loading it into game state:
/// { valid, name, color, profit, playtime }. the save menu reads every
/// slot through this to fill its rows. color -1 = file predates colors.
/// profit = THE money since the currency split; the retired "gold" key
/// (pre-split saves) is ignored here like everywhere else — those slots
/// just show 0 until their next save writes the real key.
function save_slot_info(_file) {
	if (!file_exists(_file)) return { valid : false, name : "", color : -1, profit : 0, playtime : 0 };
	ini_open(_file);
	var _info = {
		valid    : ini_key_exists("system", "save_datetime"),
		name     : ini_read_string("player", "name", ""),
		color    : ini_read_real("player", "color", -1),
		profit   : ini_read_real("player", "profit", 0),
		playtime : ini_read_real("player", "playtime", 0),
	};
	ini_close();
	return _info;
}
