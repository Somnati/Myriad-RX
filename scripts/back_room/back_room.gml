/// @description back_room() - the universal BACK: pops the nav
/// history goto_room has been keeping and returns there (without
/// pushing the room being left - backing up unwinds, never
/// ping-pongs). an empty history falls back to the game's hub
/// (rm_clicker, DE's money room) - or the title screen if the run
/// hasn't started.
function back_room() {
	if (!variable_global_exists("room_hist")) g.room_hist = [];
	var _n = array_length(g.room_hist);
	var _to = (variable_global_exists("game_started") && g.game_started)
		? rm_clicker : rm_titlescreen;
	if (_n > 0) {
		_to = g.room_hist[_n - 1];
		array_delete(g.room_hist, _n - 1, 1);
	}
	g.room_hist_skip = true;
	goto_room(_to);
}
