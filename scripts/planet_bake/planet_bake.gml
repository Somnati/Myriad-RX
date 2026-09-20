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
	// a sheet the gpu dropped: back from its kept buffer at once; a buffer missing, that third bakes again. ONLY A FINISHED
	// third has a sheet (it is uploaded at the third's end, since q213's buffers) - a third in progress has none by design
	// and is NOT lost. (Bug hunt 2026-09-18: the check asked for the sheet from the third's first row, so every sliced call
	// - the veil's, the boot's, the stamps' - restarted the third it was in, and no world under a deadline ever stood)
	var _srf = [_pn.tsurf, _pn.csurf, _pn.hsurf], _bufs = [_pn[$ "tbuf"] ?? -1, _pn[$ "cbuf"] ?? -1, _pn[$ "hbuf"] ?? -1];
	for (var _p0 = 0; _p0 < 3; _p0++) {
		if (_brow <= _p0 * _th) break;                                          // (untouched from here on)
		if (!buffer_exists(_bufs[_p0])) { _brow = _p0 * _th; break; }           // (its buffer gone: this third again, and the ones after)
		if (_brow < (_p0 + 1) * _th) break;                                     // (in progress: its sheet comes at its end)
		if (surface_exists(_srf[_p0])) continue;                                // (done and standing)
		_srf[_p0] = surface_create(_tw, _th); buffer_set_surface(_bufs[_p0], _srf[_p0], 0);
		if (_p0 == 0) _pn.tsurf = _srf[_p0]; else if (_p0 == 1) _pn.csurf = _srf[_p0]; else _pn.hsurf = _srf[_p0];
	}
	if (_brow >= _n3) { _pn.brow = _brow; return true; }
	planet_ranges(_pn);   // (once a world, before the first stamp - the range skeleton, 2026-09-17; it guards itself)
	planet_coast(_pn);    // (then the shores frayed and the island arcs - q207)
	planet_volcanoes(_pn);   // (then the volcanoes on the land the ranges left, and their plumes into the cloud map's green)
	planet_craters(_pn);     // (then the impact craters - q206; before the rivers, so a living world's may fill as a lake)
	planet_signature(_pn);   // (then the world's one landmark - q248; before the rivers: a caldera fills, a rift chains its lakes)
	planet_rivers(_pn);   // (then the drainage, in the valleys the ranges leave - it guards itself)
	planet_plateaus(_pn); // (then the tablelands rise round the rivers that cross them: the canyons - q208)
	if (!planet_territories(_pn, is_undefined(_until) ? infinity : _until)) { _pn.brow = _brow; return false; }   // THE TERRITORIES (q287): the land cut into regions, sliced - the rows wait on it, so a world that stands has them
	// THE HELD KINDS (q248): a salt flat's white, an ice sheet's glacier - laid over whatever the later passes decided,
	// once, here (never over water)
	if (is_array(_pn[$ "sigmask"]) && !(_pn[$ "sigmask_laid"] ?? false)) { _pn.sigmask_laid = true; var _smk = _pn.sigmask, _bmk = _pn.biome, _elk = _pn.elev, _npk = _pn.tw * _pn.th; for (var _i9 = 0; _i9 < _npk; _i9++) if (_smk[_i9] > 0 && _elk[_i9] >= _pn.sea && _bmk[_i9] != 1 && _bmk[_i9] != 11) _bmk[_i9] = _smk[_i9]; }
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
				// the terrain (planet_sheet_terrain - the one encoder, the tier's too)
				var _b3 = _pn.biome[_i], _v3 = _gas ? planet_sheet_terrain(_pn.gcol[_i], 0) : planet_sheet_terrain(_pn.pal[_b3], _pn.glow[_b3]);   // (a giant: its colour map - q236)
				_r8 = _v3 & $ff; _g8 = (_v3 >> 8) & $ff; _b8 = (_v3 >> 16) & $ff; _a8 = (_v3 >> 24) & $ff;
			} else if (_p == 1) {
				// the clouds: red the thickness (the cloud relief), green free, BLUE the sand under it (the dunes full, the desert
				// half - the shader's dune grain, q209), alpha the coverage - never exactly 0 (a sheet read is gated on the thickness)
				var _bs2 = _pn.biome[_i];
				_r8 = floor(clamp(_pn.cthk[_i], 0, 1) * 255); _g8 = 255; _b8 = _gas ? 0 : ((_bs2 == 24) ? 255 : ((_bs2 == 3) ? 110 : 0));   // (never on a giant: its band index is not a biome - band 3 wore the desert's wind grain; his report 2026-09-18)
				_a8 = max(1, floor(clamp(_pn.carr[_i], 0, 1) * 255));
			} else {
				// the height (planet_sheet_height - the one encoder, the tier's too): a lake's is its water's (the fill level, flat), a
				// river keeps its carved bed
				var _bw = _pn.biome[_i], _eh = _pn.elev[_i];
				if (_bw == 1 && _eh >= _pn.sea && _hasf) _eh = max(_eh, _pn.rfill[_i]);
				var _vh = planet_sheet_height(_eh, _pn.elev[_i], _pn.sea, _base, _gas, _bw);
				_r8 = _vh & $ff; _g8 = (_vh >> 8) & $ff; _b8 = (_vh >> 16) & $ff;
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
