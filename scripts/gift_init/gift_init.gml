/// @description gift_init([force]) - build the daily gift state. The
/// stored footprint is FOUR numbers (house doctrine - everything else
/// derives at read time):
///   claims   - total gifts ever collected (level/xp derive from it)
///   pos      - the next slot to punch on the current 2-week board
///   cycle    - which board we are on (seeds the per-slot rarities)
///   last_day - CALENDAR day stamp of the last collect (gift_day();
///              one gift per real day, missed days just wait - no
///              reset, his spec)
/// force = true rebuilds from scratch (game_reset's fresh run).
/// Every gift_* reader calls this first - it is the lazy-init guard.
/// PORTED FROM TECHDEMO II (2026-09-10, his ask), rewards re-cut for
/// RX's currencies - see gift_config.
function gift_init(_force = false) {
	if (!variable_global_exists("gift_cfg") || _force) gift_config();
	if (variable_global_exists("gift") && !_force) return;
	g.gift = { claims : 0, pos : 0, cycle : 0, last_day : -1 };
}
