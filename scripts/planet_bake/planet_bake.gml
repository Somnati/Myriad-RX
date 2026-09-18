/// @description planet_bake(pn, [until]) -> true once the world's three
/// textures stand: the terrain (rgb = the biome's colour, alpha = 1 - glow,
/// the emissive mask), the cloud cover (alpha), and THE HEIGHT (red =
/// elevation above the sea, 0..1 - sh_planet marches it for the mountains
/// on the limb; green marks water for the glint). Uploads are per-texel
/// stamps on purpose (buffer byte order is platform-dependent; draws are
/// not).
/// RESUMABLE (2026-09-16, the boot's stutter): pn.brow counts the rows
/// stamped so far across the three surfaces (0..3*th); with `until` (a
/// get_timer deadline) it stamps rows until the clock runs out and returns
/// false, the next call carrying on - the boot spreads a world's 150,000
/// stamps over frames. Without a deadline it bakes whole in one call, as
/// before (planet_draw's path). A surface lost mid-way (the gpu, an
/// alt-tab) restarts its own third; the ones before it stand.
function planet_bake(_pn, _until = undefined) {
	if (_pn.row < _pn.th) return false;
	var _tw = _pn.tw, _th = _pn.th, _n3 = 3 * _th;
	var _brow = _pn[$ "brow"] ?? 0;
	var _srf = [_pn.tsurf, _pn.csurf, _pn.hsurf];
	for (var _p0 = 0; _p0 < 3; _p0++) if (_brow > _p0 * _th && !surface_exists(_srf[_p0])) { _brow = _p0 * _th; break; }
	if (_brow >= _n3) { _pn.brow = _brow; return true; }
	planet_ranges(_pn);   // (once a world, before the first stamp - the range skeleton, 2026-09-17; it guards itself)
	planet_volcanoes(_pn);   // (then the volcanoes on the land the ranges left, and their plumes into the cloud map's green)
	planet_rivers(_pn);   // (then the drainage, in the valleys the ranges leave - it guards itself)
	// a bake under a shader someone left set (the ui fade) would keep its
	// tint for good: the stamps go through the plain pipeline (bug hunt 2026-09-15)
	var _sh = shader_current();
	if (_sh != -1) shader_reset();
	var _lim = is_undefined(_until) ? infinity : _until;
	var _base = (_pn.kind == "gas") ? 1 : max(_pn.sea, .34);
	while (_brow < _n3 && get_timer() < _lim) {
		var _p = _brow div _th, _ty = _brow mod _th;
		if (_ty == 0) {
			// the third's surface, made and cleared on its first row
			if (surface_exists(_srf[_p])) surface_free(_srf[_p]);
			_srf[_p] = surface_create(_tw, _th);
			if (_p == 0) _pn.tsurf = _srf[_p]; else if (_p == 1) _pn.csurf = _srf[_p]; else _pn.hsurf = _srf[_p];
			surface_set_target(_srf[_p]);
			draw_clear_alpha(c_black, (_p == 1) ? 0 : 1);
			surface_reset_target();
		}
		surface_set_target(_srf[_p]);
		gpu_set_blendmode_ext(bm_one, bm_zero);   // (every pass straight, the cloud's too: its red is the thickness, its alpha the coverage - 2026-09-17)
		for (var _tx = 0; _tx < _tw; _tx++) {
			var _i = _tx + _ty * _tw;
			if (_p == 0) {
				var _b3 = _pn.biome[_i];
				draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, _pn.pal[_b3], 1 - _pn.glow[_b3]);
			} else if (_p == 1) {
				var _ca2 = _pn.carr[_i];
				if (_ca2 > 0) draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, make_colour_rgb(floor(clamp(_pn.cthk[_i], 0, 1) * 255), 255, 255), _ca2);   // (red = the thickness - the cloud relief, 2026-09-17; the plumes left the green for the shader)
			} else {
				// height above the sea (or the world's base level), 0..1 in red:
				// water is flat, the land climbs, peaks reach 1; the gradient rides
				// a curve so lowlands stay low and the peaks stand up (the tallest
				// 20% carries half the relief)
				// (a LAKE's or a river's height is its water's - the flood's fill level, kept by planet_rivers - not the ground's under
				// it, which the ranges and the carve had made ridged; his screenshot 2026-09-17: "water with ridgyness")
				var _bw0 = _pn.biome[_i], _eh = _pn.elev[_i];
				if (_bw0 == 1 && _eh >= _pn.sea && is_array(_pn[$ "rfill"])) _eh = max(_eh, _pn.rfill[_i]);   // (a lake: its surface is the basin's fill level, flat; a river keeps its carved bed - bug hunt: min() put a lake on its carved floor)
				var _h = (_pn.kind == "gas") ? 0 : clamp((_eh - _base) / max(.001, 1 - _base), 0, 1);
				_h = power(_h, 1.6);
				var _v = floor(_h * 255);
				// (green marks WATER - deep ocean, ocean, shallows - for the shader's glint, 2026-09-15)
				var _bw = _pn.biome[_i];
				var _wat = (_pn.kind != "gas" && (_bw == 0 || _bw == 1 || _bw == 11 || _bw == 25)) ? 255 : 0;
				// (blue marks the WOODS - forest, jungle full, swamp thinner - for the shader's canopy, 2026-09-17)
				var _for = (_pn.kind != "gas") ? (((_bw == 5 || _bw == 6 || _bw == 22) ? 255 : ((_bw == 12) ? 140 : ((_bw == 21) ? 90 : 0)))) : 0;   // (the taiga a full wood, the savanna a sparse one)
				// (...and under WATER blue is the DEPTH, 0 at the shore to 1 at .08 under the sea - the sea's gradient, his ask 2026-09-17; a river's or a lake's is 0)
				if (_wat > 0) _for = (_pn.elev[_i] >= _pn.sea) ? 0 : max(6, floor(clamp((_pn.sea - _pn.elev[_i]) / .08, 0, 1) * 255));   // (the SEA's is at least 6: the foam knows the sea's shore from a river or a lake, whose depth is 0 - 2026-09-17)
				draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, 1, 1, 0, make_colour_rgb(_v, _wat, _for), 1);
			}
		}
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		_brow += 1;
	}
	_pn.brow = _brow;
	if (_sh != -1) shader_set(_sh);
	return (_brow >= _n3);
}
