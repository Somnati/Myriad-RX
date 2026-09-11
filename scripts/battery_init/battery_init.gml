/// @description battery_init([force]);
/// @param [force]
/// THE BATTERY - the offline budget (his design, 2026-09-11: "a battery
/// mechanic that limits offline gain so the automerger can't run
/// endlessly and break progression"). The genre's offline cap, made a
/// thing you can see, top up and buy bigger.
///
///   charge   seconds of absence the machines can run, 0..battery_cap.
///            Fills ONLINE at battery_rate (every room, real seconds -
///            your attention, banked; 2 minutes from empty at level
///            0/0) and by the crank in the battery panel. Drains only
///            while you are AWAY: offline_replay covers
///            min(absence, charge / battery_draw) seconds and the
///            machines stop for the rest - a hard stop, his call.
///   cap_lv   capacity levels (credits): cap x(1 + .5 lv)
///   rate_lv  charge-speed levels (credits): rate x(1 + .5 lv). The
///            same factor as the cap, so lv10/lv10 fills in the same
///            two minutes lv0/lv0 does, and a capacity ahead of its
///            rate takes longer - the incentive to buy both
///   rate     { run, fab, merge } - each machine's OFFLINE rate, 5..100
///            %: its speed while you are away AND its draw. Draw falls
///            with the SQUARE of the rate (battery_draw), so slowing a
///            machine stretches the charge further than it costs in
///            output - the optimisation the panel is for
///
/// Survives rebirth untouched (meta, credit-bought, like the ngu cap);
/// game_reset wipes it. Save section "battery".
function battery_init(_force = false) {
	if (variable_global_exists("battery") && !_force) return;
	g.battery = {
		charge  : BAT_CAP0,     // a fresh game starts full
		cap_lv  : 0,
		rate_lv : 0,
		rate    : { run : 100, fab : 100, merge : 100 },
		dry_at  : 0,            // the last absence: seconds it ran before dry (0 = it lasted)
	};
	g.offline_replaying = false;
}
