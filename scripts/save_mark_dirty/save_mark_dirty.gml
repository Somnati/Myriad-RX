/// @description save_mark_dirty();
/// gameplay calls this whenever the player changes the natural state of
/// the game (earning profit, entering a star, spending...). the autosave
/// clock in syst_handle_save only writes when this flag is up, so idle
/// sessions never churn the disk. manual saves clear it too.
function save_mark_dirty() {
	g.save_dirty = true;
}
