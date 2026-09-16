/// @description galaxy_world_biome(planet) -> the expedition biome index a galaxy planet lands as (exped_biomes), or -1 (a gas world: no landing)
/// The star system's word (kind rock / gas, clim 0 hot .. 1 frozen) into
/// the board's families: the hot ones ash, the dry ones dust, the frozen
/// ones ice, the cool ones stone, the temperate band living / ocean /
/// fungal / ruined by a hash of the planet's seed (so the same world is
/// always the same kind). 2026-09-16: the star map, to click another planet.
function galaxy_world_biome(_pl) {
	if (_pl.kind == "gas") return -1;
	var _c = _pl.clim, _h = hash_mix(_pl.seed & $7fffffff, 77) mod 100;
	if (_c < .2) return 4;    // ash
	if (_c < .35) return 6;   // dust
	if (_c > .8) return 3;    // ice
	if (_c > .65) return 0;   // stone
	return (_h < 40) ? 1 : ((_h < 60) ? 5 : ((_h < 80) ? 7 : 2));   // living / ocean / fungal / ruined
}
