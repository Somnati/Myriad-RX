/// @description away_init([force]);
/// @param [force]
/// PER-MECHANIC AWAY LEDGERS. Each mechanic carries its own last-seen
/// wall stamp plus accumulators fed at that mechanic's ONE credit site.
/// Because the offline fastforwards bump the same counters the live
/// code does, a window mixes closed-game time and live time spent
/// elsewhere seamlessly: boot into the clicker, walk to the tiles three
/// minutes later, and the tiles honestly report the whole span.
///
/// Techdemo II's, cut down to the one mechanic RX has so far. It kept
/// ledgers for production, dimensions and the energy sinks as well;
/// those grow back one line at a time as their systems land, which is
/// the point of the shape. RX's own g.offline_report is a different
/// thing and stays: that is the ONE welcome-back banner for an absence,
/// where this is a per-room panel that settles between visits.
///
/// _force rebuilds even when it exists - a new game wants fresh stamps
/// and empty windows.
function away_init(_force = false) {
	if (variable_global_exists("away") && !_force) return;
	var _now = date_current_datetime();
	g.away = {
		// the tile table: fabricated tiles + auto-merges in the window
		// (hi = highest tier at the stamp, for the panel's tier line)
		tiles : { dt : _now, fab : 0, merges : 0, hi : 1 },
	};
}
