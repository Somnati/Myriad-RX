/// @description services_achieve(id) - unlock an achievement by its
/// api name (the SAME id string registered on steamworks AND google
/// play, e.g. "ACH_FIRST_MERGE" - keep the two dashboards in sync so
/// one call serves both stores). the game calls THIS at unlock
/// moments; it routes to whichever sdk is alive. idempotent on both
/// platforms, so calling it again for an unlocked one is fine.
function services_achieve(_id) {
	if (!variable_global_exists("services")) services_init();

	if (!g.services.steam_on && !g.services.gpgs_on) {
		services_log("achieve > STUB unlock '" + string(_id) + "'");
		return;
	}

	services_log("achieve > unlocking '" + string(_id) + "'");
	// >>> PLUG IN (steam):
	// if (g.services.steam_on) {
	//     steam_set_achievement(_id);
	//     steam_store_stats(); // flush now so the toast pops
	// }
	// >>> PLUG IN (google play):
	// if (g.services.gpgs_on && g.services.signed_in)
	//     GooglePlayServices_Achievements_Unlock(_id);
	// NOTE google play ids are auto-generated strings - keep a lookup
	// from the shared api name to the play console id here when the
	// dashboard exists.
}
