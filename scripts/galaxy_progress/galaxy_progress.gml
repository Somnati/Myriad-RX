/// @description galaxy_progress() -> 0..1, how far the background chart has got (1 when ready)
function galaxy_progress() {
	if (galaxy_ready()) return 1;
	if (instance_exists(syst_handle_save) && is_struct(syst_handle_save.bg_gen)) return starmap_gen_progress(syst_handle_save.bg_gen);
	return 0;
}
