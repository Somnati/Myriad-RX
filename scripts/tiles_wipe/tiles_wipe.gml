/// @description tiles_wipe([fresh]) - the table back to nothing: board,
/// hopper, shards, lifetime earned, highest tier, merge count, EVERY
/// upgrade level.
/// @param [fresh]  true = the FLUX and the rebirth count go too. The
///                 board's RESET passes it (his call, 2026-09-10: "that
///                 reset button needs to wipe all tiles to be fresh...
///                 flux needs reset too"); the rebirth does not - flux
///                 is what the rebirth just banked.
///
/// ⚖️ ONE WIPE, TWO BUTTONS (his report with a screenshot, 2026-09-10:
/// "i hit the reset button and it only resets my tiles. i still have
/// all my spark and the upgrades still arent reset"). There are two
/// red buttons on the tile screen - the board's RESET at the bottom
/// and TABLE REBIRTH in the drawer - and until today they wiped
/// different things: the rebirth took the shards and (since this
/// morning) the upgrades, the reset took only the tiles and left
/// 136m shards and thirteen profit levels standing. Two buttons that
/// both say reset and disagree about what that means is a screen
/// arguing with itself. So this is the one definition, and the two
/// buttons differ only in what they PAY: the rebirth banks flux first,
/// the reset banks nothing.
///
/// EARNED GOES WITH IT, deliberately. earned is what the rebirth
/// prices flux on; a reset that kept it would be a free way to clear
/// the board and still collect - and a reset that drops it is why the
/// board's button now asks twice.
///
/// The view's own state (the held slot, the glow array) is the view's
/// to clear - syst_tiles does that at its press site. g.tiles.grab is
/// cleared here because the ENGINE reads it.
function tiles_wipe(_fresh = false) {
	tiles_init();
	var _t = g.tiles;

	if (_fresh) {
		_t.flux     = 0;
		_t.rb_total = 0;
	}

	for (var _i = 0; _i < _t.slots; _i++) _t.tier[_i] = 0;
	_t.stored  = 0;
	_t.fab     = 0;
	_t.am_tic  = 0;
	_t.shards  = 0;
	_t.earned  = 0;      // the measure resets with the thing it measured
	_t.highest = 1;
	_t.merges  = 0;
	_t.gps     = 0;
	_t.report  = undefined;
	_t.ev      = [];
	_t.grab    = -1;
	_t.dirty   = true;
	_t.rev++;

	// EVERY upgrade level, by key rather than by roster - a level that
	// survived here would be a level the save writes back out, and the
	// upg struct can hold keys the roster no longer lists (slots, and
	// whatever a later roster adds)
	var _ks = variable_struct_get_names(_t.upg);
	for (var _k = 0; _k < array_length(_ks); _k++) _t.upg[$ _ks[_k]] = 0;

	tiles_sync();        // the board takes its new shape at once
}
