/// @description galaxy_neb_sheet() -> the galaxy's nebula sheet: a surface ngw x ngw, rgb the colour, alpha the density
/// The map's density grid (starmap_generate: blurred star counts per
/// cell) baked once a galaxy, warm toward the core and cool at the rim -
/// the map's fog (sh_galaxy_fog) and every sky's nebulae (sh_sky_fog's
/// march along the galactic plane) read this one sheet, so a cloud on the
/// map is the cloud in the sky (his ask, 2026-09-16).
/// Baked OVERWRITING (bm_one / bm_zero): a texel IS (colour, density). A
/// normal-blend bake over a cleared surface squares the alpha and
/// premultiplies the colour - the old map fog came to density cubed at
/// its blit without anyone meaning it to; the shaders now say the curve.
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
	draw_clear_alpha(c_black, 0);
	gpu_set_blendmode_ext(bm_one, bm_zero);
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
		var _wx = (_cx + .5) * _sm.ncell, _wy = (_cy + .5) * _sm.ncell;
		var _rd = clamp(point_distance(_wx, _wy, _sm.cx, _sm.cy) / _sm.gal_r, 0, 1);
		var _col = merge_colour(rgb(255, 185, 125), rgb(130, 155, 255), _rd);
		_col = merge_colour(rgb(24, 22, 30), _col, .55 + .45 * _dn);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, 1, 1, 0, _col, _dn);
	}
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
	ui_fade_set(_fa);
	_seed = _sm.seed;
	return _surf;
}
