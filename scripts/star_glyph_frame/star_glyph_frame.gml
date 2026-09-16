/// @description star_glyph_frame(s) -> spr_star_glyph's frame (0..9) for a star s px across on the page; + 10 is that frame's core alone
/// The ladder (2026-09-16, v2: from one pixel): 1 / 3 / 5 / 7 / 9 / 11 / 15 / 19 / 25 / 31 px glyphs; the spikes live on the
/// three biggest only (19 px up - a star next door), and a glyph under five px is a dot with no halo. STAR_GLYPH_CORE = the core frames' offset.
function star_glyph_frame(_s) {
	if (_s < 1.5) return 0;
	if (_s < 2.5) return 1;
	if (_s < 4)   return 2;
	if (_s < 6)   return 3;
	if (_s < 8)   return 4;
	if (_s < 10)  return 5;
	if (_s < 13)  return 6;
	if (_s < 17)  return 7;
	if (_s < 22)  return 8;
	return 9;
}
#macro STAR_GLYPH_CORE 10
