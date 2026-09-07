/// the production heartbeat (Myriad DE's syst_production): persistent,
/// so dials keep earning in every room - the settings screen, the save
/// menu, anywhere. All the work lives in prod_dials(); this object is
/// only its clock.
/// Called bare, prod_dials uses this frame's delta. The seconds-budget
/// argument is what the offline catch-up will drive when it is rebuilt
/// - the same code, never a fork.

if (!variable_global_exists("dial")) exit;
prod_dials();
credit_tick();      // the dropper's pool + cooldown, same clock
stats_hist_tick();  // the statistics screen's history, same clock
