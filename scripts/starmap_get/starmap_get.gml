/// @description starmap_get() -> g.starmap, generated from g.galaxy_seed the first time (or when the seed changed)
/// ONE galaxy a save (the seed rides the exped section; a save from
/// before has 1337, the tech demo's). Ten thousand stars take a moment
/// - the once-a-session hitch lands on the first board roll.
function starmap_get() {
	if (!variable_global_exists("galaxy_seed")) g.galaxy_seed = 1337;
	if (!variable_global_exists("starmap") || !is_struct(g.starmap) || g.starmap.seed != g.galaxy_seed) starmap_generate(g.galaxy_seed);
	return g.starmap;
}
