/// @description planet_config() - the full planet's numbers (the tech
/// demo's scr_planet_config, cut to what the expedition page uses)
function planet_config() {
	return {
		tex_w    : 320,    // equirect texels (2:1); every texel costs noise
		tex_h    : 160,    // samples once per world (doubled 2026-09-15, his ask: the terrain's texels read bigger than the render's cells; built behind the boot spinner)
		rows_per_step : 2, // planet_gen_step: rows built per frame (the
		                   // bake is spread so the page never hitches)
		pad      : 1.6,    // quad extent in radii: room for the halo
		px_size  : 2,      // room px per shader cell (0 = no pixelation)
		relief   : .09,    // MOUNTAINS: the tallest peak, in radii (a little taller, 2026-09-16) - the
		                   // silhouette bumps by this (sh_planet marches it)
		keep     : 4,      // worlds the cache remembers (planet_get)
	};
}
