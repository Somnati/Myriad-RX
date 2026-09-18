/// @description planet_sheet_height(eh, ge, sea, base, gas, b) -> the HEIGHT sheet's texel, packed r | g << 8 | b << 16: red the height above the base on the relief curve, green WATER (255 on the waters, for the glint), blue the WOODS (forest / jungle / taiga full, swamp thinner, savanna sparse) or under water the DEPTH (the sea's at least 6 - the foam's mark; a river's or a lake's 0)
/// THE ONE ENCODER (q216): planet_bake writes the map's sheet with it and
/// planet_lod_step the zoom tier's - the same law, so a tier can never
/// disagree with its map (they drifted by hand three times in a week).
/// eh = the height the red takes (a lake's is its fill level, flat); ge =
/// the ground's own height (the depth under water reads it); the callers
/// unpack with & $ff, >> 8 & $ff, >> 16 & $ff
function planet_sheet_height(_eh, _ge, _sea, _base, _gas, _b) {
	if (_gas) return 0;
	var _h = power(clamp((_eh - _base) / max(.001, 1 - _base), 0, 1), 1.6);
	var _wat = (_b == 0 || _b == 1 || _b == 11 || _b == 25) ? 255 : 0;
	var _for = (_b == 5 || _b == 6 || _b == 22) ? 255 : ((_b == 12) ? 140 : ((_b == 21) ? 90 : 0));
	if (_wat > 0) _for = (_ge >= _sea) ? 0 : max(6, floor(clamp((_sea - _ge) / .08, 0, 1) * 255));
	return floor(_h * 255) | (_wat << 8) | (_for << 16);
}
