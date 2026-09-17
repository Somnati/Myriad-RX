/// @description starmap_get() -> g.starmap, building it for THIS save's seed if it is not there
/// THE ONE DOOR to the galaxy. Since 2026-09-17 the chart builds in the
/// background (syst_handle_save's Step, a slice a frame); a caller that
/// gets here first FINISHES that job in place - the same slices, run to
/// the end - rather than starting a second build. galaxy_ready() is the
/// question to ask before calling this from anywhere that would rather wait.
function starmap_get() {
	if (!variable_global_exists("galaxy_seed")) g.galaxy_seed = 1337;
	if (!variable_global_exists("starmap") || !is_struct(g.starmap) || g.starmap.seed != g.galaxy_seed) {
		if (instance_exists(syst_handle_save) && is_struct(syst_handle_save.bg_gen) && syst_handle_save.bg_gen.seed == g.galaxy_seed) {
			while (!starmap_gen_step(syst_handle_save.bg_gen, 50)) {}
			syst_handle_save.bg_gen = undefined;
		} else starmap_generate(g.galaxy_seed);
	}
	return g.starmap;
}
