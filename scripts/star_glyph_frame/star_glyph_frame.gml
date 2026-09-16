/// @description star_glyph_frame(s) -> spr_star_glyph's frame (0..7) for a star s px across on the page; + 8 is that frame's core alone
/// The ladder: 5 / 7 / 9 / 11 / 15 / 19 / 25 / 31 px glyphs (2026-09-16).
function star_glyph_frame(_s) {
	if (_s < 1.4) return 0;
	if (_s < 2.2) return 1;
	if (_s < 3.2) return 2;
	if (_s < 4.5) return 3;
	if (_s < 6.5) return 4;
	if (_s < 9)   return 5;
	if (_s < 14)  return 6;
	return 7;
}
