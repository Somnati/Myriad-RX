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
		// the biomes pass (2026-09-15)
		case "ash":    _h = { kind : "rock", clim : .12, hue : _hue, arch : "lava",   wet : .05 }; break;
		case "ocean":  _h = { kind : "rock", clim : .50, hue : _hue, arch : "terra",  wet : .96 }; break;
		case "dust":   _h = { kind : "rock", clim : .26, hue : _hue, arch : "terra",  wet : .10 }; break;
		case "fungal": _h = { kind : "rock", clim : .55, hue : _hue, arch : "terra",  wet : .66 }; break;
		case "cloud":  _h = { kind : "gas",  clim : .5,  hue : hash_mix(_d.seed, 505) mod 256 }; break;   // (a giant: its own hue off its seed, not the family's - 2026-09-17)
		default:       _h = { kind : "rock", clim : .5 }; break;
	}
	// THE GALAXY'S WORD only once the chart stands (bug hunt 5, 2026-09-18): a save's trips unpack at boot through
	// region_get -> planet_get -> this hint, and galaxy_world_sys -> galaxy_home -> starmap_get built the WHOLE chart
	// synchronously there (and offline_replay's exped_where the same way) - the boot hitch q202 took off the base game,
	// back whenever a crew was out. Before the chart the hint is the biome's alone: the terrain the regions sample reads
	// none of the ring / moons / plateau, and planet_get lays the galaxy's word on a world begun early when the full
	// hint comes (the panel's first ask, before any rows or sheets)
	if (galaxy_ready()) {
		var _gws = galaxy_world_sys(_d);   // (any world of the map: its ring and moons - 2026-09-16)
		if (is_struct(_gws) && _gws.planet_seed == _d.seed) {
			var _gp = _gws.sys.planets[_gws.planet];
			_h.ring = _gp[$ "has_ring"] ?? false;
			_h.moon_n = max(1, _gp[$ "moon_n"] ?? 1);   // (at least one - his ask, 2026-09-16: "give the starter planet a moon")
			if (_gp[$ "plateau"] ?? false) _h.plateau = true;   // (a plateau asked for by the galaxy's planet - planet_plateaus sites it on the biggest river; q212)
		}
	}
	return _h;
}
