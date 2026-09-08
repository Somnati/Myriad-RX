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
stats_hist_tick();  // the statistics screen's history, same clock
