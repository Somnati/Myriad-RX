/// @description sprite_notes_kinds(sprite) -> the foe kinds it has notes on (["goblin", ...])
function sprite_notes_kinds(_sp) {
	var _sh = sprite_sheet(_sp);
	var _out = [];
	for (var _i = 0; _i < array_length(_sh.notes); _i++)
		if (string_pos("foe:", _sh.notes[_i].tag) == 1) array_push(_out, string_delete(_sh.notes[_i].tag, 1, 4));
	return _out;
}
