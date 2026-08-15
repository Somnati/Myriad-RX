/// Game End - the LAST flush (save-on-mutation law, 2026-07-12): a
/// clean exit writes any dirty state to the main save before the
/// process dies. this fires on rm_quit's game_end() AND on a desktop
/// window close, so "buy, alt-f4" keeps the buy. a hard kill can
/// still lose up to one autosave interval - that's what the rotating
/// slots are for. settings ride along (they're cheap and this is the
/// one moment they can't be caught later).

if (variable_global_exists("save_dirty") && g.save_dirty) {
	action = sv_save;
	handle_save();
	handle_settings(sv_save);
	action = -1;
	g.save_dirty = false;
	show("> game end: dirty state flushed");
}
