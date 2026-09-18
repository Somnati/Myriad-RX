/// @description planet_sheet_terrain(col, glow) -> the TERRAIN sheet's texel, packed r | g << 8 | b << 16 | a << 24: rgb the biome's colour, alpha 1 - glow (the emissive mask: 0 = lit from within)
/// THE ONE ENCODER (q216), the bake's and the tier's; unpack with & $ff, >> 8, >> 16, >> 24 (each & $ff)
function planet_sheet_terrain(_col, _glow) {
	return colour_get_red(_col) | (colour_get_green(_col) << 8) | (colour_get_blue(_col) << 16) | (floor(clamp(1 - _glow, 0, 1) * 255) << 24);
}
