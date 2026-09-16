/// @description sprite_note_has(sprite, tag) -> true when the notepad holds a note with that tag (the useful notes: road:<land>, wx:<weather>, haz:<hazard>, night, inn, shop)
function sprite_note_has(_sp, _tag) {
	if (is_undefined(_sp) || _tag == "") return false;
	var _sh = sprite_sheet(_sp);
	for (var _i = 0; _i < array_length(_sh.notes); _i++) if (_sh.notes[_i].tag == _tag) return true;
	return false;
}
