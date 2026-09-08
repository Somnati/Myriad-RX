/// the tile table's global engine (Myriad's syst_moduletimer, reborn):
/// a persistent singleton that runs tiles_tick() every step in every
/// room, so fabrication, automerging, and the g.tiles.gps total all
/// live independently of the tile room. lazy-spawned by tiles_init()
/// (the first thing that touches the table - the save section, the
/// room view, or an offline feed - brings the engine with it).
/// presentation stays in the room view: this object never draws or
/// plays a sound, it just pushes events for a view to drain.

// singleton guard: persistence + a stray room instance could double us
if (instance_number(syst_tiletimer) > 1) { kill; exit; }
persistent = true;

tiles_init();

// the seconds banked toward the next payout - see the Step. RX samples
// its history centrally (stats_hist_tick on the production heartbeat),
// so the tech demo's own per-second push is gone: two feeders for one
// series is two chances to disagree about what a sample means.
pay_acc = 0;
