/// @description galaxy_neb_sheet() -> the galaxy's nebula sheet: a surface ngw x ngw, the DENSITY as gray (r = g = b), alpha 1
/// The map's density grid (starmap_generate: blurred star counts per
/// cell) baked once a galaxy, warm toward the core and cool at the rim -
/// the map's fog (sh_galaxy_fog) and every sky's nebulae (sh_sky_fog's
/// march along the galactic plane) read this one sheet, so a cloud on the
/// map is the cloud in the sky (his ask, 2026-09-16).
/// GRAY, ALPHA ONE (2026-09-16, after a night of nothing showing): a bake
/// that carries the density in the alpha channel is at the mercy of the
/// blend mode's alpha factors (a normal bake over a cleared surface squares
/// it, an "overwrite" may or may not reach the alpha); a gray texel under
/// alpha 1 writes the same under every mode. The colour law (warm toward
/// the core, cool at the rim, darker where thin) lives in the shaders,
/// which know the galaxy's centre and radius (u_gal).
function galaxy_neb_sheet() {
	static _surf = -1;
	static _seed = -1;
	var _sm = starmap_get();
	if (surface_exists(_surf) && _seed == _sm.seed) return _surf;
	if (surface_exists(_surf)) surface_free(_surf);
	var _ngw = _sm.ngw;
	_surf = surface_create(_ngw, _ngw);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);   // (a sheet baked under a fade shader keeps that alpha for good)
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 1);
	for (var _cy = 0; _cy < _ngw; _cy++)
	for (var _cx = 0; _cx < _ngw; _cx++) {
		var _acc = 0, _wsm = 0;
		for (var _oy = -1; _oy <= 1; _oy++)
		for (var _ox = -1; _ox <= 1; _ox++) {
			var _nx = _cx + _ox, _ny = _cy + _oy;
			if (_nx < 0 || _ny < 0 || _nx >= _ngw || _ny >= _ngw) continue;
			var _wt = ((_ox == 0) ? 2 : 1) * ((_oy == 0) ? 2 : 1);
			_acc += _sm.ngrid[_nx + _ny * _ngw] * _wt;
			_wsm += _wt;
		}
		var _dn = (_acc / _wsm) / _sm.nmax;
		if (_dn <= .01) continue;
		_dn = power(_dn, .40);
		var _v = clamp(round(_dn * 255), 0, 255);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, 1, 1, 0, make_colour_rgb(_v, _v, _v), 1);
	}
	surface_reset_target();
	ui_fade_set(_fa);
	_seed = _sm.seed;
	return _surf;
}
