/// @description save_slot_info(file);
/// @param file
/// peeks a savefile's display data WITHOUT loading it into game state:
/// { valid, name, color, profit, playtime, datetime, difficulty,
/// credits, rebirths }. the save menu reads every slot through this to
/// fill its rows. color -1 = file predates colors.
/// DATETIME is the one that makes the menu readable: three rotating
/// autosaves are the same file at three different ages, so the stamp
/// is the ONLY thing that tells them apart. save_validate already
/// leaned on that key being present - this just shows it.
/// profit = THE money since the currency split; the retired "gold" key
/// (pre-split saves) is ignored here like everywhere else — those slots
/// just show 0 until their next save writes the real key.
function save_slot_info(_file) {
	if (!file_exists(_file)) return { valid : false, name : "", color : -1,
		profit : 0, playtime : 0, playtime_off : 0, datetime : 0,
		difficulty : -1, credits : 0, rebirths : 0 };
	ini_open(_file);
	var _info = {
		valid    : ini_key_exists("system", "save_datetime"),
		name     : ini_read_string("player", "name", ""),
		color    : ini_read_real("player", "color", -1),
		profit   : ini_read_real("player", "profit", 0),
		playtime : ini_read_real("player", "playtime", 0),
		// the away clock; absent in saves written before the split, so
		// their card simply reads a zero and the total equals active
		playtime_off : ini_read_real("player", "playtime_off", 0),
		// WHEN it was written (a gm datetime real). 0 = a file old
		// enough to predate the key, which reads as no stamp at all
		datetime   : ini_read_real("system", "save_datetime", 0),
		// stored at new game, never shown until now: 0 easy .. 3
		// critical, -1 for a save written before the difficulty pick
		difficulty : ini_read_real("player", "difficulty", -1),
		credits    : ini_read_real("credits", "credits", 0),
		// how many rebirths this file has behind it. on the REBIRTH
		// backup this is the count BEFORE that rebirth (rebirth_do
		// copies the file, THEN awards), which is why the row can
		// label itself "before rebirth N+1"
		rebirths   : ini_read_real("rebirth", "total", 0),
	};
	ini_close();
	return _info;
}
