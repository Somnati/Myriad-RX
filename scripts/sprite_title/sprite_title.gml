/// @description sprite_title(sprite, txt, [rank]) -> true when it took: THE TITLE (the bestiary's payouts, 2026-09-16)
/// One a sprite, on the sheet under the class ("ranger - bane of the
/// lupi"); a later one of the same or a higher rank replaces it, a lower
/// one does not. sheet.title / sheet.trank, the sheet's tenth field.
function sprite_title(_sp, _txt, _rank = 1) {
	var _sh = sprite_sheet(_sp);
	if ((_sh[$ "trank"] ?? 0) > _rank) return false;
	_sh.title = _txt; _sh.trank = _rank;
	save_mark_dirty();
	return true;
}
