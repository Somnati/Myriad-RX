/// the production heartbeat (Myriad DE's syst_production): persistent,
/// so dials keep earning in every room - the settings screen, the save
/// menu, anywhere. All the work lives in prod_dials(); this object is
/// only its clock.
/// Called bare, prod_dials uses this frame's delta. The seconds-budget
/// argument is what the offline catch-up will drive when it is rebuilt
/// - the same code, never a fork.

if (!variable_global_exists("dial")) exit;
// THE BUDGET, once a frame and before anything ticks. At x1 this is
// simply delta/60 and the sim runs as it always did; above x1 the bank
// pays the difference and every lane below gets the bigger number. That
// is the whole trick: x10 for a minute is the SAME call the offline
// replay makes for ten minutes, so live acceleration and offline
// catch-up cannot drift apart - they are one code path.
var _secs = timebank_spend();

prod_dials(_secs);
credit_tick(_secs);   // the dropper's pool + cooldown, same clock
ccore_tick(_secs);    // the credit core's well, same clock
exped_tick(_secs);    // an expedition under way, same clock (its debug speed multiplies it)
unfold_tick();        // what arrives next (once a second; the unfold)

// AUTOMATION runs on the REAL clock, not the accelerated one: a pulse a
// second is a pacing decision, and speeding it up would only spend the
// same money in smaller, dearer pieces (every curve accelerates). It
// lives here rather than in the automation room so it works in every
// room, which is the whole point of automating something.
autom_tick();
battery_tick();     // the offline charge fills while you are here
fleet_refresh();    // the fleet total + the tap follow the tile boost, same clock
stats_hist_tick();  // the statistics screen's history, same clock
