/// @description planet_lod_step(pn, l, until) -> true once the tier stands (l.ready): builds rows of a zoom tier (planet_lod_begin) until the get_timer deadline
/// A tier texel is the base map's FIELDS (elevation, detail, moisture -
/// planet_gen_step keeps them) blended between the four base texels
/// around it on a SMOOTH kernel (an s-curve, not a straight lerp: a
/// texel's value holds near its centre and hands over near its edge), then
/// planet_biome's law run on them; the HEIGHT on a Catmull-Rom cubic over
/// the sixteen texels around it, because the bump shading reads the height's
/// SLOPE and the smooth kernel's slope peaks at every texel edge - the
/// mountains came out ruled into a grid (his screenshot, 2026-09-17); a
/// cubic's slope is continuous. With K ODD the middle tier texel of
/// every base texel sits exactly on its centre, so it IS the base texel -
/// the tier can never disagree with the map where the map was sampled -
/// and the texels between round the map's edges into curves. (Three
/// earlier cuts, 2026-09-17: a straight lerp at even K put every tier
/// texel off-centre and the biomes drifted; sampling the noise at every
/// tier texel was minutes; sampling only along the map's edges seamed
/// where the rule changed hands.)
/// Rivers and lakes ride over from the base biome map: a lake's texel
/// whole, a river as a line through its texel toward each river or water
/// neighbour. The colour texture (rgb the biome's colour, alpha 1 - glow)
/// and the height texture (red the height, green water, blue the woods on
/// land / the depth under water) match planet_bake's exactly. Into
/// buffers (surface_byte_order's channel order), up as textures at the end
function planet_lod_step(_pn, _l, _until) {
	if (_l.ready) return true;
	if (!buffer_exists(_l.tbuf) || !buffer_exists(_l.hbuf)) return false;
	var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
	var _tb = _l.tbuf, _hb = _l.hbuf;
	var _ps = _pn.smp, _tw = _pn.tw, _th = _pn.th, _k = _l.k, _w = _l.w;
	var _el = _pn.elev, _dt = _pn.det, _mo = _pn.moi, _bm = _pn.biome, _pal = _pn.pal, _glow = _pn.glow, _gas = (_pn.kind == "gas"), _sea = _pn.sea;
	var _base = _gas ? 1 : max(_sea, .34);
	while (_l.row < _l.h && get_timer() < _until) {
		var _j = _l.row, _v = (_j + .5) / _l.h, _by = _j div _k, _fy = ((_j mod _k) + .5) / _k;
		var _yy = _v * _th - .5, _y0 = floor(_yy), _ty = _yy - _y0, _y1 = clamp(_y0 + 1, 0, _th - 1);
		var _ym = clamp(_y0 - 1, 0, _th - 1), _y2 = clamp(_y0 + 2, 0, _th - 1);
		_y0 = clamp(_y0, 0, _th - 1);
		// the cubic's row weights (Catmull-Rom), on the raw fraction
		var _t2 = _ty * _ty, _t3 = _t2 * _ty;
		var _cy0 = (-_t3 + 2 * _t2 - _ty) * .5, _cy1 = (3 * _t3 - 5 * _t2 + 2) * .5, _cy2 = (-3 * _t3 + 4 * _t2 + _ty) * .5, _cy3 = (_t3 - _t2) * .5;
		var _rm = _ym * _tw, _r0 = _y0 * _tw, _r1 = _y1 * _tw, _r2 = _y2 * _tw;
		_ty = _ty * _ty * (3 - 2 * _ty);   // (the smooth kernel, for the fields)
		var _o = (_j * _w + _l.col) * 4;
		for (var _i = _l.col; _i < _w; _i++) {
			var _u = (_i + .5) / _w;
			var _xx = _u * _tw - .5, _x0 = floor(_xx), _tx = _xx - _x0;
			var _x1 = (_x0 + 1 + _tw) mod _tw; _x0 = (_x0 + _tw) mod _tw;   // (the seam wraps)
			var _i00 = _x0 + _y0 * _tw, _i10 = _x1 + _y0 * _tw, _i01 = _x0 + _y1 * _tw, _i11 = _x1 + _y1 * _tw;
			// the height: the cubic over the four columns x-1 .. x+2 (wrapping) of the four rows
			var _xm = (_x0 + _tw - 1) mod _tw, _x2 = (_x0 + 2) mod _tw;
			var _s2 = _tx * _tx, _s3 = _s2 * _tx;
			var _cx0 = (-_s3 + 2 * _s2 - _tx) * .5, _cx1 = (3 * _s3 - 5 * _s2 + 2) * .5, _cx2 = (-3 * _s3 + 4 * _s2 + _tx) * .5, _cx3 = (_s3 - _s2) * .5;
			var _hrm = _el[_rm + _xm] * _cx0 + _el[_rm + _x0] * _cx1 + _el[_rm + _x1] * _cx2 + _el[_rm + _x2] * _cx3;
			var _hr0 = _el[_r0 + _xm] * _cx0 + _el[_r0 + _x0] * _cx1 + _el[_r0 + _x1] * _cx2 + _el[_r0 + _x2] * _cx3;
			var _hr1 = _el[_r1 + _xm] * _cx0 + _el[_r1 + _x0] * _cx1 + _el[_r1 + _x1] * _cx2 + _el[_r1 + _x2] * _cx3;
			var _hr2 = _el[_r2 + _xm] * _cx0 + _el[_r2 + _x0] * _cx1 + _el[_r2 + _x1] * _cx2 + _el[_r2 + _x2] * _cx3;
			_ps.oe = _hrm * _cy0 + _hr0 * _cy1 + _hr1 * _cy2 + _hr2 * _cy3;
			_tx = _tx * _tx * (3 - 2 * _tx);
			var _w00 = (1 - _tx) * (1 - _ty), _w10 = _tx * (1 - _ty), _w01 = (1 - _tx) * _ty, _w11 = _tx * _ty;
			_ps.od = _dt[_i00] * _w00 + _dt[_i10] * _w10 + _dt[_i01] * _w01 + _dt[_i11] * _w11;
			_ps.om = _mo[_i00] * _w00 + _mo[_i10] * _w10 + _mo[_i01] * _w01 + _mo[_i11] * _w11;
			planet_biome(_ps, _u, _v);
			var _b = _ps.ob, _oe = _ps.oe;
			if (!_gas) {
				var _bx = _i div _k, _bi = _bx + _by * _tw, _fx = ((_i mod _k) + .5) / _k;
				var _bb = _bm[_bi], _natl = !(_b == 0 || _b == 1 || _b == 11);
				if (_natl && _el[_bi] >= _sea) {   // (the base texel is land: its water is a lake or a river, not the coast's own call)
					if (_bb == 1) _b = 1;
					else if (_bb == 11) {
						var _hit = false, _any = false, _rw = .6 / _k;
						for (var _dy = -1; _dy <= 1 && !_hit; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
							if (_dx == 0 && _dy == 0) continue;
							var _ny = _by + _dy; if (_ny < 0 || _ny >= _th) continue;
							var _nb = _bm[((_bx + _dx + _tw) mod _tw) + _ny * _tw];
							if (!(_nb == 0 || _nb == 1 || _nb == 11)) continue;
							_any = true;
							var _px2 = _fx - .5, _py2 = _fy - .5, _sx = _dx * .5, _sy = _dy * .5;
							var _tt = clamp((_px2 * _sx + _py2 * _sy) / (_sx * _sx + _sy * _sy), 0, 1);
							var _ddx = _px2 - _sx * _tt, _ddy = _py2 - _sy * _tt;
							if (sqrt(_ddx * _ddx + _ddy * _ddy) < _rw) { _hit = true; break; }
						}
						if (!_any && point_distance(_fx, _fy, .5, .5) < _rw) _hit = true;
						if (_hit) _b = 11;
					}
				}
			}
			var _c = _pal[_b];
			buffer_poke(_tb, _o + _or, buffer_u8, colour_get_red(_c)); buffer_poke(_tb, _o + _og, buffer_u8, colour_get_green(_c)); buffer_poke(_tb, _o + _ob, buffer_u8, colour_get_blue(_c)); buffer_poke(_tb, _o + _oa, buffer_u8, 255 - floor(_glow[_b] * 255));
			var _h = _gas ? 0 : power(clamp((_oe - _base) / max(.001, 1 - _base), 0, 1), 1.6);
			var _wat = (!_gas && (_b == 0 || _b == 1 || _b == 11)) ? 255 : 0;
			var _for = (!_gas) ? ((_b == 5 || _b == 6) ? 255 : ((_b == 12) ? 140 : 0)) : 0;
			if (_wat > 0) _for = floor(clamp((_sea - _oe) / .08, 0, 1) * 255);
			buffer_poke(_hb, _o + _or, buffer_u8, floor(_h * 255)); buffer_poke(_hb, _o + _og, buffer_u8, _wat); buffer_poke(_hb, _o + _ob, buffer_u8, _for); buffer_poke(_hb, _o + _oa, buffer_u8, 255);
			_o += 4;
			// (the deadline inside the row too: a row of a tier is a thousand texels and more, and a frame's share is a few ms)
			if ((_i & 31) == 31 && get_timer() >= _until) { _l.col = _i + 1; return false; }
		}
		_l.col = 0;
		_l.row++;
	}
	if (_l.row >= _l.h) { _l.ready = true; planet_lod_upload(_l); }   // (the buffers are KEPT: a lost surface - the window going full screen - is re-uploaded, not rebuilt)
	return _l.ready;
}
