/// @description planet_sheet_height(eh, ge, sea, base, gas, b, [dep]) -> the HEIGHT sheet's texel, packed r | g << 8 | b << 16: red the height above the base on the relief curve, green WATER (255 on the waters, for the glint), blue the WOODS (forest / jungle / taiga full, swamp thinner, savanna sparse) or under water the DEPTH (the sea's at least 6 - the foam's mark; a river's or a lake's 0)
/// (blue: the sea's depth over .08 to 1; a lake's fill over the ground over .12, .04 .. .36; a river's given by the tier - q278/q279)
/// THE ONE ENCODER (q216): planet_bake writes the map's sheet with it and
/// planet_lod_step the zoom tier's - the same law, so a tier can never
/// disagree with its map (they drifted by hand three times in a week).
/// eh = the height the red takes (a lake's is its fill level, flat); ge =
/// the ground's own height (the depth under water reads it); the callers
/// unpack with & $ff, >> 8 & $ff, >> 16 & $ff
function planet_sheet_height(_eh, _ge, _sea, _base, _gas, _b, _dep = -1) {   // (dep: an inland water's depth given outright, 0..1 - the tier's river channel; q278)
	if (_gas) return 0;
	var _h = power(clamp((_eh - _base) / max(.001, 1 - _base), 0, 1), 1.6);
	var _wat = (_b == 0 || _b == 1 || _b == 11 || _b == 25) ? 255 : 0;
	var _for = (_b == 5 || _b == 6 || _b == 22) ? 255 : ((_b == 12) ? 140 : ((_b == 21) ? 90 : 0));
	// THE INLAND WATERS' DEPTH (q272; his ask: "visual consistency between the rivers / ponds / oceans" - they carried 0, so no
	// foam and no depth): a lake's is its fill over the ground (shallow edges foam, the middle goes to open water, never
	// the abyss - .45 at most); a river's a set .10, a faint lap along its banks
	// A RIVER'S CHANNEL (q278; his screenshot: the river "lacks the shoreline look" the lake and the sea have - one flat
	// depth): the tier hands the depth in by the texel's distance to the channel's centreline - the banks shallow (the
	// shallows' colour, the foam), the middle open water
	// A LAKE'S DEPTH (q279; his screenshot: a filled crater was a disc of open-ocean blue with a one-texel shelf - its
	// floor is flat at depth): the fill over the ground on a gentler scale (.12: the shelf twice as wide), a floor of
	// .04 (the shallows' colour, the foam's fringe), a cap of .36 - a lake never wears the open sea's colour, and a
	// river's channel (.24 in the middle) meets it without a step
	if (_wat > 0) _for = (_dep >= 0) ? max(6, floor(clamp(_dep, 0, 1) * 255)) : ((_ge >= _sea) ? max(6, floor(clamp(max((_eh - _ge) / .12, .04), 0, .36) * 255)) : max(6, floor(clamp((_sea - _ge) / .08, 0, 1) * 255)));
	return floor(_h * 255) | (_wat << 8) | (_for << 16);
}
