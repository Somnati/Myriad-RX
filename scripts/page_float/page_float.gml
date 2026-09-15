/// @description page_float() -> true when the expedition pages can render in 16-bit float (surface_rgba16float)
/// THE FLOAT PAGE (2026-09-15): the world's page, the galaxy's page and
/// the bloom's passes are float surfaces where the gpu allows, so the
/// fog, the stars, the glow composite losslessly and the ONE
/// quantisation is the blit to the screen (sh_page_out dithers it once).
/// Checked once; the 8-bit path keeps its per-layer dithers.
function page_float() {
	static _ok = -1;
	if (_ok < 0) _ok = surface_format_is_supported(surface_rgba16float) ? 1 : 0;
	return (_ok == 1);
}
