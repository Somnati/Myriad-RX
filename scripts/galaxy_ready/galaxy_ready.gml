/// @description galaxy_ready() -> true when the star map for THIS save's seed
/// is built. Never builds it (starmap_get does, synchronously) - the
/// question the panel's veil and exped_tick ask before touching the galaxy
/// (his call, 2026-09-17: the chart moved off the boot into the background)
function galaxy_ready() {
	return variable_global_exists("galaxy_seed") && variable_global_exists("starmap") && is_struct(g.starmap) && g.starmap.seed == g.galaxy_seed;
}
