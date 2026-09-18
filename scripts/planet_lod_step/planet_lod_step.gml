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
	var _rf = _pn[$ "rfill"], _ra = _pn[$ "racc"], _rt = _pn[$ "rt"] ?? 6, _hasr = is_array(_rf) && is_array(_ra);   // (planet_rivers' keep)
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
				var _bb = _bm[_bi], _natl = !(_b == 0 || _b == 1 || _b == 11 || _b == 25);
				// THE VOLCANOES' LAVA AND BASALT (2026-09-17) ride over from the base map: spokes from the texel's centre toward
				// every neighbour of the same kind (a crater's floor fills, a flow runs as a line), like a river's
				if ((_bb == 17 || _bb == 18) && _b != _bb && _natl) {
					var _vh = false, _vn = 0, _vw = .55 / _k;
					for (var _dy = -1; _dy <= 1 && !_vh; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
						if (_dx == 0 && _dy == 0) continue;
						var _ny = _by + _dy; if (_ny < 0 || _ny >= _th) continue;
						var _nb = _bm[((_bx + _dx + _tw) mod _tw) + _ny * _tw];
						if (_nb != 17 && _nb != 18) continue;
						_vn++;
						var _px2 = _fx - .5, _py2 = _fy - .5, _sx = _dx * .5, _sy = _dy * .5;
						var _tt = clamp((_px2 * _sx + _py2 * _sy) / (_sx * _sx + _sy * _sy), 0, 1);
						var _ddx = _px2 - _sx * _tt, _ddy = _py2 - _sy * _tt;
						if (sqrt(_ddx * _ddx + _ddy * _ddy) < _vw) { _vh = true; break; }
					}
					if (_vn == 0 && point_distance(_fx, _fy, .5, .5) < _vw) _vh = true;
					if (_vh) _b = _bb;
				}
				if (_natl && _el[_bi] >= _sea) {   // (the base texel is land: its water is a lake or a river, not the coast's own call)
					// A LAKE BY ITS OWN SHORE (his report, 2026-09-17: "ponds with hard pixel shores"): where a lake texel
					// lies among the four base texels round this point, the lake is wherever the flood's filled surface
					// (kept, blended) stands over the ground (the cubic) by the lake's depth - the basin's own contour,
					// a curve, not the texel's square
					var _lk = false;
					if (_hasr) {
						var _bl00 = (_bm[_i00] == 1 && _el[_i00] >= _sea), _bl10 = (_bm[_i10] == 1 && _el[_i10] >= _sea), _bl01 = (_bm[_i01] == 1 && _el[_i01] >= _sea), _bl11 = (_bm[_i11] == 1 && _el[_i11] >= _sea);
						if (_bl00 || _bl10 || _bl01 || _bl11) {
							var _fl = _rf[_i00] * _w00 + _rf[_i10] * _w10 + _rf[_i01] * _w01 + _rf[_i11] * _w11;
							_lk = (_fl - _oe > .010);
						}
					} else _lk = (_bb == 1);
					if (_lk) _b = 1;
					else if (_bb == 11) {
						// A RIVER AS A CURVE (his report: "an unnatural look"): through a texel with one way in and one way out
						// the channel is a bend - a quadratic from the in-edge's middle through the texel's (nudged) centre to the
						// out-edge's - not two straight spokes; at a fork or a source the spokes stay. Its WIDTH grows with the
						// catchment (a log law): a thread at the source, a broad reach at the mouth
						var _hit = false, _nn = 0, _d1x = 0, _d1y = 0, _d2x = 0, _d2y = 0;
						var _rw = (.45 + (_hasr ? .55 * clamp(ln(max(1, _ra[_bi]) / _rt) / ln(40), 0, 1) : .15)) / _k;
						for (var _dy = -1; _dy <= 1; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
							if (_dx == 0 && _dy == 0) continue;
							var _ny = _by + _dy; if (_ny < 0 || _ny >= _th) continue;
							var _nb = _bm[((_bx + _dx + _tw) mod _tw) + _ny * _tw];
							if (!(_nb == 0 || _nb == 1 || _nb == 11 || _nb == 25)) continue;
							if (_nn == 0) { _d1x = _dx; _d1y = _dy; } else if (_nn == 1) { _d2x = _dx; _d2y = _dy; }
							_nn++;
						}
						// the centre, nudged by the texel's own hash (a third of a texel at most) so no reach runs dead straight
						var _hc = (_bi * 2654435 + 11) mod 2147483647; _hc = ((_hc ^ (_hc >> 13)) * 48271) mod 2147483647;
						var _ccx = .5 + ((_hc mod 1000) / 1000 - .5) * .3, _ccy = .5 + (((_hc div 1000) mod 1000) / 1000 - .5) * .3;
						if (_nn == 2) {
							var _ax = .5 + _d1x * .5, _ay = .5 + _d1y * .5, _ex = .5 + _d2x * .5, _ey = .5 + _d2y * .5;
							var _lx = _ax, _ly = _ay, _best = 9;
							for (var _s = 1; _s <= 8; _s++) {
								var _tt = _s / 8, _mt = 1 - _tt;
								var _qx = _mt * _mt * _ax + 2 * _mt * _tt * _ccx + _tt * _tt * _ex, _qy = _mt * _mt * _ay + 2 * _mt * _tt * _ccy + _tt * _tt * _ey;
								var _vx = _qx - _lx, _vy = _qy - _ly, _vl = max(.0001, _vx * _vx + _vy * _vy);
								var _pt = clamp(((_fx - _lx) * _vx + (_fy - _ly) * _vy) / _vl, 0, 1);
								var _ddx = _fx - (_lx + _vx * _pt), _ddy = _fy - (_ly + _vy * _pt);
								_best = min(_best, _ddx * _ddx + _ddy * _ddy);
								_lx = _qx; _ly = _qy;
							}
							_hit = (_best < _rw * _rw);
						} else if (_nn > 0) {
							for (var _dy = -1; _dy <= 1 && !_hit; _dy++) for (var _dx = -1; _dx <= 1; _dx++) {
								if (_dx == 0 && _dy == 0) continue;
								var _ny = _by + _dy; if (_ny < 0 || _ny >= _th) continue;
								var _nb = _bm[((_bx + _dx + _tw) mod _tw) + _ny * _tw];
								if (!(_nb == 0 || _nb == 1 || _nb == 11 || _nb == 25)) continue;
								var _px2 = _fx - _ccx, _py2 = _fy - _ccy, _sx = .5 + _dx * .5 - _ccx, _sy = .5 + _dy * .5 - _ccy;
								var _tt = clamp((_px2 * _sx + _py2 * _sy) / max(.0001, _sx * _sx + _sy * _sy), 0, 1);
								var _ddx = _px2 - _sx * _tt, _ddy = _py2 - _sy * _tt;
								if (sqrt(_ddx * _ddx + _ddy * _ddy) < _rw) { _hit = true; break; }
							}
						} else _hit = (point_distance(_fx, _fy, _ccx, _ccy) < _rw);
						if (_hit) _b = 11;
					}
				}
			}
			var _c = _pal[_b];
			buffer_poke(_tb, _o + _or, buffer_u8, colour_get_red(_c)); buffer_poke(_tb, _o + _og, buffer_u8, colour_get_green(_c)); buffer_poke(_tb, _o + _ob, buffer_u8, colour_get_blue(_c)); buffer_poke(_tb, _o + _oa, buffer_u8, 255 - floor(_glow[_b] * 255));
			var _eh = _oe;
			if ((_b == 1 || _b == 11) && _oe >= _sea && _hasr) _eh = min(_oe, _rf[_i00] * _w00 + _rf[_i10] * _w10 + _rf[_i01] * _w01 + _rf[_i11] * _w11);   // (a lake's height is its water's - flat)
			var _h = _gas ? 0 : power(clamp((_eh - _base) / max(.001, 1 - _base), 0, 1), 1.6);
			var _wat = (!_gas && (_b == 0 || _b == 1 || _b == 11 || _b == 25)) ? 255 : 0;
			var _for = (!_gas) ? ((_b == 5 || _b == 6 || _b == 22) ? 255 : ((_b == 12) ? 140 : ((_b == 21) ? 90 : 0))) : 0;
			if (_wat > 0) _for = (_oe >= _sea) ? 0 : max(6, floor(clamp((_sea - _oe) / .08, 0, 1) * 255));   // (the sea's at least 6 - the foam's mark; a river's or a lake's 0)
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
