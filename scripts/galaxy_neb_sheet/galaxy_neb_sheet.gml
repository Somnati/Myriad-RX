/// @description galaxy_neb_sheet() -> the galaxy's nebula sheet: a surface ngw x ngw, the DENSITY as gray (r = g = b), alpha 1
/// The map's density grid (starmap_generate: blurred star counts per
/// cell) baked once a galaxy, warm toward the core and cool at the rim -
/// the map's fog (sh_galaxy_fog) and every sky's nebulae (sh_sky_fog's
/// march along the galactic plane) read this one sheet, so a cloud on the
/// map is the cloud in the sky (his ask, 2026-09-16).
/// GRAY, FROM A BUFFER (2026-09-16, after a night of nothing showing): a bake
/// that carried the density in the alpha channel was at the mercy of the
/// blend mode's alpha factors, and a drawn bake at all sat on the target
/// stack, the blend mode and whatever shader was current; the bytes now go
/// straight into the texture (buffer_set_surface), red = density. The
/// colour law (warm toward the core, cool at the rim, darker where thin)
/// lives in the shaders, which know the galaxy's centre and radius (u_gal).
/// The panel's Step asks for the sheet each frame so it bakes there, never
/// inside a page's target.
function galaxy_neb_sheet() {
	static _surf = -1;
	static _seed = -1;
	var _sm = starmap_get();
	if (surface_exists(_surf) && _seed == _sm.seed) return _surf;
	if (surface_exists(_surf)) surface_free(_surf);
	var _ngw = _sm.ngw;
	_surf = surface_create(_ngw, _ngw);
	// STRAIGHT INTO THE TEXTURE (2026-09-16, after two bakes that showed nothing): a buffer of bytes, every
	// byte of a texel the same value, so the platform's byte order (rgba / bgra / argb - it differs) cannot
	// misplace it - red is the density wherever the bytes land, and no draw call, target stack, blend mode
	// or shader is party to it
	var _buf = buffer_create(_ngw * _ngw * 4, buffer_fixed, 1);
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
		var _v = (_dn <= .01) ? 0 : clamp(round(power(_dn, .40) * 255), 0, 255);
		buffer_write(_buf, buffer_u8, _v); buffer_write(_buf, buffer_u8, _v); buffer_write(_buf, buffer_u8, _v); buffer_write(_buf, buffer_u8, _v);
	}
	buffer_set_surface(_buf, _surf, 0);
	buffer_delete(_buf);
	_seed = _sm.seed;
	return _surf;
}
