/// @description sprite_note(sprite, txt, [tag]) -> true when written
/// THE NOTEPAD (his ask, 2026-09-14: "a notepad they can use to write
/// on... that might help them remember stuff on their journey... dumb
/// useless stuff too"). A line onto the sheet's notes; SPRITE_NOTES at
/// most, the oldest falls off. tag "foe:<kind>" marks a note ABOUT a
/// foe kind - one per kind (a second is not written), and a sprite with
/// one hits that kind a little easier (SPRITE_NOTE_HIT, cbt_hit). The
/// text is scrubbed of the save's separators.
function sprite_note(_sp, _txt, _tag = "") {
	var _sh = sprite_sheet(_sp);
	if (_tag != "") for (var _i = 0; _i < array_length(_sh.notes); _i++) if (_sh.notes[_i].tag == _tag) return false;
	_txt = string_replace_all(string_replace_all(string_replace_all(string_replace_all(string_replace_all(string_replace_all(string_replace_all(_txt,
		"/", " "), "|", " "), ";", " "), ",", " "), "=", " "), "^", " "), "~", " ");
	array_push(_sh.notes, { txt : _txt, tag : _tag });
	while (array_length(_sh.notes) > SPRITE_NOTES) array_delete(_sh.notes, 0, 1);
	save_mark_dirty();
	return true;
}
