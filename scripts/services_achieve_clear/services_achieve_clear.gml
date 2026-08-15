/// @description services_achieve_clear(id) - DEBUG ONLY: relock an
/// achievement so unlock flows can be retested. steam supports this
/// outright; google play has no client-side relock (test with a test
/// account + the play console's reset instead - the stub logs that).
function services_achieve_clear(_id) {
	if (!variable_global_exists("services")) services_init();

	if (!g.services.steam_on) {
		services_log("achieve > STUB clear '" + string(_id) + "'");
		return;
	}

	services_log("achieve > clearing '" + string(_id) + "'");
	// >>> PLUG IN (steam):
	// steam_clear_achievement(_id);
	// steam_store_stats();
	// (google play: no client relock - use play console test resets)
}
