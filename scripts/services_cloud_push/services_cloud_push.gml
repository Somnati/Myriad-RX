/// @description services_cloud_push() - upload the active profile's
/// save to the cloud (google play saved games on mobile, steam cloud
/// on pc). the LOCAL file stays the source of truth: push ships a
/// copy, it never mutates anything - so the stub is completely safe.
function services_cloud_push() {
	if (!variable_global_exists("services")) services_init();

	// the payload: the active profile's save file as text (the same
	// content save_export ships to the clipboard - one save pipeline)
	var _path = save_slot_path(g.profile);
	if (!file_exists(_path)) { services_log("cloud push > no local save yet"); return; }
	var _b = buffer_load(_path);
	var _txt = buffer_read(_b, buffer_text);
	buffer_delete(_b);

	if (!g.services.gpgs_on && !g.services.steam_on) {
		g.services.cloud_stamp = "pushed (stub) " + string(current_time);
		services_log("cloud push > STUB ok, " + string(string_length(_txt)) + " chars");
		return;
	}

	services_log("cloud push > uploading " + string(string_length(_txt)) + " chars...");
	// >>> PLUG IN (google play): saved-games flow -
	// GooglePlayServices_SavedGames_CommitAndClose(_slot_name, _txt, _desc);
	// async result -> services_log + g.services.cloud_stamp = date.
	// >>> PLUG IN (steam): steam cloud is FILE-BASED and automatic
	// once cloud is enabled for the app id (it syncs the save dir);
	// for manual control: steam_file_write(_slot_name, _txt,
	// string_byte_length(_txt)); then log steam_file_persisted(...).
}
