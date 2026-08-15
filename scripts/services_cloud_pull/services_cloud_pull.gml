/// @description services_cloud_pull() - download the cloud save and
/// apply it through the ONE import pipeline (save_import_apply: the
/// same validated path the clipboard/file imports use, so a corrupt
/// cloud blob can never stomp a good local save).
/// CAUTION even in stub mode this is the destructive direction -
/// pulling replaces local progress. the bench button says so.
function services_cloud_pull() {
	if (!variable_global_exists("services")) services_init();

	if (!g.services.gpgs_on && !g.services.steam_on) {
		g.services.cloud_stamp = "pulled (stub) " + string(current_time);
		services_log("cloud pull > STUB: nothing applied (no sdk). when "
			+ "live, the blob routes through save_import_apply()");
		return;
	}

	services_log("cloud pull > downloading...");
	// >>> PLUG IN (google play):
	// GooglePlayServices_SavedGames_Open(_slot_name); then read the
	// content in the async event and hand it to save_import_apply(_txt);
	// >>> PLUG IN (steam):
	// var _sz = steam_file_size(_slot_name);
	// var _txt = steam_file_read(_slot_name);
	// if (_txt != "") save_import_apply(_txt);
	// then g.services.cloud_stamp = date + services_log the result.
}
