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
	var _gws = galaxy_world_sys(_d);   // (any world of the map: its ring and moons - 2026-09-16)
	if (is_struct(_gws) && _gws.planet_seed == _d.seed) {
		var _gp = _gws.sys.planets[_gws.planet];
		_h.ring = _gp[$ "has_ring"] ?? false;
		_h.moon_n = max(1, _gp[$ "moon_n"] ?? 1);   // (at least one - his ask, 2026-09-16: "give the starter planet a moon")
	}
	// DEBUG_HOME (q210): the home world and the home system's desert world take a PLATEAU (planet_plateaus sites it on the
	// biggest river: the canyon) - his ask, "plateaus on the starter planet... a desert planet with canyons"
	if (DEBUG_HOME && is_struct(_gws)) { var _hm0 = galaxy_home(); if (_gws.star == _hm0.star && (_gws.planet_seed == _hm0.planet_seed || _b.name == "dust")) _h.plateau = true; }
	return _h;
}
