/// @description planet_texel(ps, u, v) - one texel of planet terrain
/// (the tech demo's scr_planet_texel): writes ps.oe (elevation), ps.od /
/// ps.om (the detail and moisture fields) and ps.ob (biome index). Runs
/// thousands of times per world - no allocation. SPLIT (2026-09-17, the
/// zoom tiers): planet_fields samples the noise, planet_biome decides the
/// biome from the fields - so a finer map can INTERPOLATE the fields of
/// the base map's texels and run the same biome law between them
function planet_texel(_ps, _u, _v) {
	planet_fields(_ps, _u, _v);
	planet_biome(_ps, _u, _v);
}
