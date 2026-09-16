/// @description exped_planet_hint(dest) -> the planet generator's hint
/// for an expedition destination: the biome family becomes a kind, a
/// climate, an archetype and a hue, so the full world (planet_get)
/// reads in the colours the board's portrait promised
/// The HOME WORLD (2026-09-15) carries the galaxy's word on its ring and
/// its moons (starsystem_generate's has_ring / moon_n) so the orbit view,
/// the world box and the system agree.
function exped_planet_hint(_d) {
	var _b = exped_biomes()[_d.biome];
	var _hue = colour_get_hue(_b.col2);
	var _h;
	switch (_b.name) {
		case "stone":  _h = { kind : "rock", clim : .40, hue : _hue, arch : "barren", wet : .05 }; break;
		case "living": _h = { kind : "rock", clim : .50, hue : _hue, arch : "terra",  wet : .62 }; break;
		case "ruined": _h = { kind : "rock", clim : .58, hue : _hue, arch : "terra",  wet : .28 }; break;
		case "ice":    _h = { kind : "rock", clim : .92, hue : _hue, arch : "terra",  wet : .55 }; break;
		default:       _h = { kind : "rock", clim : .5 }; break;
	}
	if (variable_global_exists("galaxy_home_c") && is_struct(g.galaxy_home_c) && g.galaxy_home_c.planet_seed == _d.seed) {
		var _gp = g.galaxy_home_c.sys.planets[g.galaxy_home_c.planet];
		_h.ring = _gp[$ "has_ring"] ?? false;
		_h.moon_n = _gp[$ "moon_n"] ?? 1;
	}
	return _h;
}
