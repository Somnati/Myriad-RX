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
	var _tw = _pn.tw, _th = _pn.th, _n3 = 3 * _th, _npx = _tw * _th;
	var _brow = _pn[$ "brow"] ?? 0;
	// a sheet the gpu dropped: back from its kept buffer at once; a buffer missing too, that third bakes again
	var _srf = [_pn.tsurf, _pn.csurf, _pn.hsurf], _bufs = [_pn[$ "tbuf"] ?? -1, _pn[$ "cbuf"] ?? -1, _pn[$ "hbuf"] ?? -1];
	for (var _p0 = 0; _p0 < 3; _p0++) {
		if (_brow <= _p0 * _th || surface_exists(_srf[_p0])) continue;
		if (_brow >= (_p0 + 1) * _th && buffer_exists(_bufs[_p0])) { _srf[_p0] = surface_create(_tw, _th); buffer_set_surface(_bufs[_p0], _srf[_p0], 0); if (_p0 == 0) _pn.tsurf = _srf[_p0]; else if (_p0 == 1) _pn.csurf = _srf[_p0]; else _pn.hsurf = _srf[_p0]; }
		else { _brow = _p0 * _th; break; }
	}
	if (_brow >= _n3) { _pn.brow = _brow; return true; }
	planet_ranges(_pn);   // (once a world, before the first stamp - the range skeleton, 2026-09-17; it guards itself)
	planet_coast(_pn);    // (then the shores frayed and the island arcs - q207)
	planet_volcanoes(_pn);   // (then the volcanoes on the land the ranges left, and their plumes into the cloud map's green)
	planet_craters(_pn);     // (then the impact craters - q206; before the rivers, so a living world's may fill as a lake)
	planet_rivers(_pn);   // (then the drainage, in the valleys the ranges leave - it guards itself)
	planet_plateaus(_pn); // (then the tablelands rise round the rivers that cross them: the canyons - q208)
	var _lim = is_undefined(_until) ? infinity : _until;
	var _base = (_pn.kind == "gas") ? 1 : max(_pn.sea, .34);
	var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
	var _gas = (_pn.kind == "gas"), _hasf = is_array(_pn[$ "rfill"]);
	while (_brow < _n3 && get_timer() < _lim) {
		var _p = _brow div _th, _ty = _brow mod _th;
		if (_ty == 0) {
			// the third's buffer, made on its first row (an old one let go)
			if (buffer_exists(_bufs[_p])) buffer_delete(_bufs[_p]);
			_bufs[_p] = buffer_create(_npx * 4, buffer_fixed, 1);
			if (_p == 0) _pn.tbuf = _bufs[_p]; else if (_p == 1) _pn.cbuf = _bufs[_p]; else _pn.hbuf = _bufs[_p];
		}
		var _bf = _bufs[_p], _o = _ty * _tw * 4;
		for (var _tx = 0; _tx < _tw; _tx++) {
			var _i = _tx + _ty * _tw;
			var _r8 = 0, _g8 = 0, _b8 = 0, _a8 = 255;
			if (_p == 0) {
				// the terrain: rgb the biome's colour, alpha 1 - glow (the emissive mask)
				var _b3 = _pn.biome[_i], _c3 = _pn.pal[_b3];
				_r8 = colour_get_red(_c3); _g8 = colour_get_green(_c3); _b8 = colour_get_blue(_c3);
				_a8 = floor(clamp(1 - _pn.glow[_b3], 0, 1) * 255);
			} else if (_p == 1) {
				// the clouds: red the thickness (the cloud relief), green free, BLUE the sand under it (the dunes full, the desert
				// half - the shader's dune grain, q209), alpha the coverage - never exactly 0 (a sheet read is gated on the thickness)
				var _bs2 = _pn.biome[_i];
				_r8 = floor(clamp(_pn.cthk[_i], 0, 1) * 255); _g8 = 255; _b8 = (_bs2 == 24) ? 255 : ((_bs2 == 3) ? 110 : 0);
				_a8 = max(1, floor(clamp(_pn.carr[_i], 0, 1) * 255));
			} else {
				// the height above the sea (or the world's base level), 0..1 in red on a curve (the tallest 20% carries half the
				// relief); a lake's is its water's (the fill level, flat), a river keeps its carved bed; green marks WATER for
				// the glint; blue the WOODS (forest / jungle full, swamp thinner, taiga full, savanna sparse) - or under water
				// the DEPTH (the sea's at least 6: the foam knows the sea's shore from a river's or a lake's, whose depth is 0)
				var _bw = _pn.biome[_i], _eh = _pn.elev[_i];
				if (_bw == 1 && _eh >= _pn.sea && _hasf) _eh = max(_eh, _pn.rfill[_i]);
				var _h = _gas ? 0 : power(clamp((_eh - _base) / max(.001, 1 - _base), 0, 1), 1.6);
				var _wat = (!_gas && (_bw == 0 || _bw == 1 || _bw == 11 || _bw == 25)) ? 255 : 0;
				var _for = (!_gas) ? ((_bw == 5 || _bw == 6 || _bw == 22) ? 255 : ((_bw == 12) ? 140 : ((_bw == 21) ? 90 : 0))) : 0;
				if (_wat > 0) _for = (_pn.elev[_i] >= _pn.sea) ? 0 : max(6, floor(clamp((_pn.sea - _pn.elev[_i]) / .08, 0, 1) * 255));
				_r8 = floor(_h * 255); _g8 = _wat; _b8 = _for;
			}
			buffer_poke(_bf, _o + _or, buffer_u8, _r8); buffer_poke(_bf, _o + _og, buffer_u8, _g8); buffer_poke(_bf, _o + _ob, buffer_u8, _b8); buffer_poke(_bf, _o + _oa, buffer_u8, _a8);
			_o += 4;
		}
		_brow += 1;
		if ((_brow mod _th) == 0) {
			// the third stands: up as its sheet, whole, once
			var _pd = _p;
			if (surface_exists(_srf[_pd])) surface_free(_srf[_pd]);
			_srf[_pd] = surface_create(_tw, _th);
			buffer_set_surface(_bufs[_pd], _srf[_pd], 0);
			if (_pd == 0) _pn.tsurf = _srf[_pd]; else if (_pd == 1) _pn.csurf = _srf[_pd]; else _pn.hsurf = _srf[_pd];
		}
	}
	_pn.brow = _brow;
	return (_brow >= _n3);
}
