/// @description statistics_close() - take the statistics screen down.
///
/// Lighter than settings_close, and that asymmetry is real rather than
/// an oversight: statistics WRITES almost nothing. Favourites persist
/// through the save section and are marked dirty at the tap, the open
/// folders and the scroll page live in globals that outlive the object,
/// and there is no debounce and no confirm to unwind. So closing is
/// closing - the CleanUp sweeps the furniture.
///
/// ⚖️ IT ARMS THE EXIT, IT DOES NOT DESTROY (2026-09-09, with the open
/// animation). The panel has to be alive to animate off, so this flips
/// `closing` and the Step destroys it once the ease reaches zero.
function statistics_close() {
	if (!instance_exists(syst_statistics_v2)) return;
	syst_statistics_v2.closing = true;
}
