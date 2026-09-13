/// @description exped_planet_hint(dest) -> the planet generator's hint
/// for an expedition destination: the biome family becomes a kind, a
/// climate, an archetype and a hue, so the full world (planet_get)
/// reads in the colours the board's portrait promised
function exped_planet_hint(_d) {
	var _b = exped_biomes()[_d.biome];
	var _hue = colour_get_hue(_b.col2);
	switch (_b.name) {
		case "stone":  return { kind : "rock", clim : .40, hue : _hue, arch : "barren", wet : .05 };
		case "living": return { kind : "rock", clim : .50, hue : _hue, arch : "terra",  wet : .62 };
		case "ruined": return { kind : "rock", clim : .58, hue : _hue, arch : "terra",  wet : .28 };
		case "ice":    return { kind : "rock", clim : .92, hue : _hue, arch : "terra",  wet : .55 };
	}
	return { kind : "rock", clim : .5 };
}
