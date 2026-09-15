/// @description starmap_generate(seed) -> g.starmap: the galaxy, all at once (starmap_gen_begin + starmap_gen_step to the end)
/// THE GALAXY (the tech demo's scr_starmap_generate v3, ported 2026-09-15;
/// cut into PASSES the same day so the boot can build it a pass a frame
/// behind the loading spinner - his ask: no hitch). Parametric and
/// seed-driven, no density image, no readback:
///   arms     placed BY CONSTRUCTION: each arm star picks a radius, the
///            spiral centerline angle at that radius, a gaussian offset
///   core     a small hot marker at the centre
///   halo     thin dust across the disc so the space between arms is sparse
///   islands  dense continents anchored ON arm points
///   paths    star roads chaining the continents + the core
///   feats    rings / arcs / streams to stumble onto
/// perlin-style GAPS (3-octave value noise) carve holes through every
/// pass; the threshold is measured by percentile so cfg.gap_frac is the
/// carved fraction. Every pass enforces cfg.star_spacing via a hash grid;
/// rarity climbs with distance from the core (calculate_rarity).
/// EVERY PASS SEEDS ITS OWN STREAM (seed ^ pass): the passes may run on
/// different frames with other rolls between them and the galaxy is still
/// the same galaxy for the seed.
function starmap_generate(_seed) {
	var _c = starmap_gen_begin(_seed);
	while (!starmap_gen_step(_c)) {}
	return g.starmap;
}

/// @description starmap_gen_begin(seed) -> the build's context (pass 0 pending)
/// gml function literals do not capture locals: every helper takes the
/// context as its last argument (the demo's design)
function starmap_gen_begin(_seed) {
	var _cfg = starmap_config();
	var _w  = _cfg.plane_w, _h = _cfg.plane_h;
	var _cell = _cfg.star_spacing;
	var _gw = ceil(_w / _cell), _gh = ceil(_h / _cell);
	var _c = {
		seed : _seed, cfg : _cfg, pass : 0, done : false,
		cx : _w * .5, cy : _h * .5, r : _cfg.gal_r, w : _w, h : _h,
		soft : _cfg.gal_soft,
		nseed : _seed, gap_wl : _cfg.gap_wl, gap_core : _cfg.gap_core, gapt : 0,
		arm_a0 : 0, arm_count : _cfg.arm_count, arm_turns : _cfg.arm_turns,
		arm_width_base : _cfg.arm_width_base, arm_width_grow : _cfg.arm_width_grow,
		arm_r_min : _cfg.arm_r_min, arm_r_bias : _cfg.arm_r_bias,
		grid : array_create(_gw * _gh, undefined), gw : _gw, gh : _gh, cell : _cell, mind : _cfg.star_spacing,
		pts : [], isl : [], edges : [], stars : [], regions : [],
		hash2 : undefined, fbm : undefined, keep : undefined, fits : undefined, mark : undefined, arm_pt : undefined, swirl : undefined,
	};
	_c.hash2 = function(_ix, _iy, _salt, _c) {
		var _hv = (_ix * 374761393 + _iy * 668265263 + (_c.nseed + _salt) * 144269504) & $7fffffff;
		_hv = ((_hv ^ (_hv >> 13)) * 1274126177) & $7fffffff;
		return ((_hv ^ (_hv >> 16)) & $ffffff) / $ffffff;
	};
	_c.fbm = function(_px, _py, _c) {
		var _n = 0, _amp = 1, _wl = _c.gap_wl, _tot = 0, _salt = 0;
		repeat (3) {
			var _fx = _px / _wl, _fy = _py / _wl;
			var _ix = floor(_fx), _iy = floor(_fy);
			var _tx = _fx - _ix; _tx = _tx * _tx * (3 - 2 * _tx);
			var _ty = _fy - _iy; _ty = _ty * _ty * (3 - 2 * _ty);
			var _a = _c.hash2(_ix, _iy, _salt, _c), _b = _c.hash2(_ix + 1, _iy, _salt, _c);
			var _c2 = _c.hash2(_ix, _iy + 1, _salt, _c), _d2 = _c.hash2(_ix + 1, _iy + 1, _salt, _c);
			_n += lerp(lerp(_a, _b, _tx), lerp(_c2, _d2, _tx), _ty) * _amp;
			_tot += _amp; _amp *= .5; _wl *= .5; _salt += 101;
		}
		return _n / _tot;
	};
	// keep a candidate? inside the feathered rim, outside the noise gaps
	_c.keep = function(_px, _py, _c) {
		var _d = point_distance(_px, _py, _c.cx, _c.cy);
		if (_d >= _c.r) return false;
		var _rim = _c.r * (1 - _c.soft);
		if (_d > _rim) if (random(1) < (_d - _rim) / (_c.r - _rim)) return false;
		if (_d > _c.gap_core) {
			var _fn = _c.fbm(_px, _py, _c);
			if (_fn < _c.gapt) return false;
			if (_fn < _c.gapt + .02) if (random(1) < (_c.gapt + .02 - _fn) / .02) return false;
		}
		return true;
	};
	_c.fits = function(_px, _py, _c) {
		var _gx = floor(_px / _c.cell), _gy = floor(_py / _c.cell);
		for (var _j = max(0, _gy - 1); _j <= min(_c.gh - 1, _gy + 1); _j++)
		for (var _i = max(0, _gx - 1); _i <= min(_c.gw - 1, _gx + 1); _i++) {
			var _o = _c.grid[_i + _j * _c.gw];
			if (is_undefined(_o)) continue;
			if (point_distance(_px, _py, _o.x, _o.y) < _c.mind) return false;
		}
		return true;
	};
	_c.mark = function(_px, _py, _c) { _c.grid[floor(_px / _c.cell) + floor(_py / _c.cell) * _c.gw] = { x : _px, y : _py }; };
	// a random point ON a spiral arm
	_c.arm_pt = function(_c) {
		var _u  = power(random(1), _c.arm_r_bias);
		var _rr = _c.r * lerp(_c.arm_r_min, .96, _u);
		var _arm = irandom(_c.arm_count - 1);
		var _ang = _c.arm_a0 + _arm * (360 / _c.arm_count) + _c.arm_turns * 360 * power(_rr / _c.r, .85);
		var _wd  = _c.arm_width_base + _rr * _c.arm_width_grow;
		var _off;
		if (random(1) < .35) _off = (random(1) + random(1) - 1) * _wd;
		else                 _off = random_range(-1, 1) * _wd * 3.2;
		return { x : _c.cx + lengthdir_x(_rr, _ang) + lengthdir_x(_off, _ang + 90),
		         y : _c.cy + lengthdir_y(_rr, _ang) + lengthdir_y(_off, _ang + 90) };
	};
	_c.swirl = function(_px, _py, _c, _deg) {
		var _d = point_distance(_px, _py, _c.cx, _c.cy);
		var _a = point_direction(_c.cx, _c.cy, _px, _py) + _deg * (1 - _d / _c.r);
		return { x : _c.cx + lengthdir_x(_d, _a), y : _c.cy + lengthdir_y(_d, _a) };
	};
	return _c;
}

/// @description starmap_gen_step(ctx) -> true when the galaxy is done (g.starmap set)
/// ONE PASS a call, on its own seeded stream (seed ^ pass), so the passes
/// can run on separate frames: 0 the gap threshold, 1 the core, 2 the
/// arms, 3 the halo, 4 the islands, 5 the roads, 6 the features, 7 the
/// stars themselves (class / colour / rarity), 8 the regions, 9 the
/// nebula grid, the draw grid and the finish
function starmap_gen_step(_c) {
	if (_c.done) return true;
	var _cfg = _c.cfg;
	var _rs = random_get_seed();
	random_set_seed((_c.seed ^ ((_c.pass + 1) * 2654435761)) & $7fffffff);
	var _cx = _c.cx, _cy = _c.cy, _R = _c.r;
	switch (_c.pass) {
		case 0: {
			_c.arm_a0 = random(360);
			// the gap threshold: measure, don't guess - the gap_frac percentile
			var _ns = 2000;
			var _samples = array_create(_ns);
			for (var _i = 0; _i < _ns; _i++) {
				var _sr = _R * sqrt(random(1)), _sa = random(360);
				_samples[_i] = _c.fbm(_cx + lengthdir_x(_sr, _sa), _cy + lengthdir_y(_sr, _sa), _c);
			}
			array_sort(_samples, true);
			_c.gapt = _samples[floor(_ns * _cfg.gap_frac)];
			break;
		}
		case 1: {
			// the core marker
			var _n = round(_cfg.star_target * _cfg.frac_core), _placed = 0, _guard = _n * 40;
			while (_placed < _n && _guard > 0) {
				_guard--;
				var _rr = _cfg.core_r * power(random(1), .8), _aa = random(360);
				var _px = _cx + lengthdir_x(_rr, _aa), _py = _cy + lengthdir_y(_rr, _aa);
				if (!_c.keep(_px, _py, _c)) continue;
				if (!_c.fits(_px, _py, _c)) continue;
				array_push(_c.pts, { x : _px, y : _py }); _c.mark(_px, _py, _c); _placed++;
			}
			break;
		}
		case 2: {
			// the spiral arms, by construction
			var _n = round(_cfg.star_target * _cfg.frac_arms), _placed = 0, _guard = _n * 40;
			while (_placed < _n && _guard > 0) {
				_guard--;
				var _pt = _c.arm_pt(_c);
				if (!_c.keep(_pt.x, _pt.y, _c)) continue;
				if (!_c.fits(_pt.x, _pt.y, _c)) continue;
				array_push(_c.pts, { x : _pt.x, y : _pt.y }); _c.mark(_pt.x, _pt.y, _c); _placed++;
			}
			break;
		}
		case 3: {
			// the halo dust, centre-weighted
			var _n = round(_cfg.star_target * _cfg.frac_halo), _placed = 0, _guard = _n * 40;
			while (_placed < _n && _guard > 0) {
				_guard--;
				var _rr = _R * power(random(1), .7), _aa = random(360);
				var _px = _cx + lengthdir_x(_rr, _aa), _py = _cy + lengthdir_y(_rr, _aa);
				if (!_c.keep(_px, _py, _c)) continue;
				if (!_c.fits(_px, _py, _c)) continue;
				array_push(_c.pts, { x : _px, y : _py }); _c.mark(_px, _py, _c); _placed++;
			}
			break;
		}
		case 4: {
			// the island continents, anchored on the arms
			var _guard = 400;
			while (array_length(_c.isl) < _cfg.isl_count && _guard > 0) {
				_guard--;
				var _pt = _c.arm_pt(_c);
				if (!_c.keep(_pt.x, _pt.y, _c)) continue;
				var _ok = true;
				for (var _i = 0; _i < array_length(_c.isl); _i++) if (point_distance(_pt.x, _pt.y, _c.isl[_i].x, _c.isl[_i].y) < 420) { _ok = false; break; }
				if (!_ok) continue;
				array_push(_c.isl, { x : _pt.x, y : _pt.y, r : random_range(_cfg.isl_r_min, _cfg.isl_r_max) });
			}
			var _n = round(_cfg.star_target * _cfg.frac_islands), _placed = 0; _guard = _n * 40;
			while (_placed < _n && _guard > 0 && array_length(_c.isl) > 0) {
				_guard--;
				var _is = _c.isl[irandom(array_length(_c.isl) - 1)];
				var _rr = (random(1) + random(1)) * .5 * _is.r, _aa = random(360);
				var _sw = _c.swirl(_is.x + lengthdir_x(_rr, _aa), _is.y + lengthdir_y(_rr, _aa), _c, _cfg.swirl_deg);
				if (!_c.keep(_sw.x, _sw.y, _c)) continue;
				if (!_c.fits(_sw.x, _sw.y, _c)) continue;
				array_push(_c.pts, { x : _sw.x, y : _sw.y }); _c.mark(_sw.x, _sw.y, _c); _placed++;
			}
			break;
		}
		case 5: {
			// the star roads: a spanning chain of the continents + the core
			var _isl = _c.isl, _edges = [];
			if (array_length(_isl) > 1) {
				var _linked = [0];
				while (array_length(_linked) < array_length(_isl)) {
					var _best_d = infinity, _best_a = 0, _best_b = 1;
					for (var _i = 0; _i < array_length(_linked); _i++) {
						var _a = _isl[_linked[_i]];
						for (var _j = 0; _j < array_length(_isl); _j++) {
							if (array_contains(_linked, _j)) continue;
							var _d = point_distance(_a.x, _a.y, _isl[_j].x, _isl[_j].y);
							if (_d < _best_d) { _best_d = _d; _best_a = _linked[_i]; _best_b = _j; }
						}
					}
					array_push(_edges, { x1 : _isl[_best_a].x, y1 : _isl[_best_a].y, x2 : _isl[_best_b].x, y2 : _isl[_best_b].y });
					array_push(_linked, _best_b);
				}
			}
			if (array_length(_isl) > 0) {
				var _ni = 0, _nd = infinity;
				for (var _i = 0; _i < array_length(_isl); _i++) { var _d = point_distance(_cx, _cy, _isl[_i].x, _isl[_i].y); if (_d < _nd) { _nd = _d; _ni = _i; } }
				array_push(_edges, { x1 : _cx, y1 : _cy, x2 : _isl[_ni].x, y2 : _isl[_ni].y });
			}
			var _budget = round(_cfg.star_target * _cfg.frac_paths);
			for (var _e = 0; _e < array_length(_edges); _e++) {
				if (_budget <= 0) break;
				var _ed = _edges[_e];
				var _len = point_distance(_ed.x1, _ed.y1, _ed.x2, _ed.y2), _dir = point_direction(_ed.x1, _ed.y1, _ed.x2, _ed.y2);
				var _steps = max(2, floor(_len / _cfg.path_step));
				var _bow = random_range(-1, 1) * _cfg.path_bow;
				for (var _s = 0; _s <= _steps; _s++) {
					if (_budget <= 0) break;
					var _t = _s / _steps;
					var _bx = lerp(_ed.x1, _ed.x2, _t) + lengthdir_x(sin(_t * pi) * _bow + random_range(-1, 1) * _cfg.path_jitter, _dir + 90);
					var _by = lerp(_ed.y1, _ed.y2, _t) + lengthdir_y(sin(_t * pi) * _bow + random_range(-1, 1) * _cfg.path_jitter, _dir + 90);
					var _sw = _c.swirl(_bx, _by, _c, _cfg.swirl_deg);
					// roads ignore the noise gaps on purpose (bridges through emptiness)
					if (point_distance(_sw.x, _sw.y, _cx, _cy) >= _R) continue;
					if (!_c.fits(_sw.x, _sw.y, _c)) continue;
					array_push(_c.pts, { x : _sw.x, y : _sw.y }); _c.mark(_sw.x, _sw.y, _c); _budget--;
				}
			}
			break;
		}
		case 6: {
			// the unique features: rings, arcs, streams
			var _budget = round(_cfg.star_target * _cfg.frac_feats);
			var _per = max(8, _budget div max(1, _cfg.feat_count));
			repeat (_cfg.feat_count) {
				if (_budget <= 0) break;
				var _fr = _R * random_range(.15, .8), _fa = random(360);
				var _fx = _cx + lengthdir_x(_fr, _fa), _fy = _cy + lengthdir_y(_fr, _fa);
				var _type = irandom(2);
				var _n = min(_per, _budget);
				if (_type == 0 || _type == 1) {
					var _rad = random_range(_cfg.feat_ring_min, _cfg.feat_ring_max), _a0 = random(360);
					var _span = (_type == 1) ? random_range(90, 220) : 360;
					for (var _s = 0; _s < _n; _s++) {
						var _aa2 = _a0 + (_s / _n) * _span, _rr2 = _rad + random_range(-24, 24);
						var _sw = _c.swirl(_fx + lengthdir_x(_rr2, _aa2), _fy + lengthdir_y(_rr2, _aa2), _c, _cfg.swirl_deg);
						if (!_c.keep(_sw.x, _sw.y, _c)) continue;
						if (!_c.fits(_sw.x, _sw.y, _c)) continue;
						array_push(_c.pts, { x : _sw.x, y : _sw.y }); _c.mark(_sw.x, _sw.y, _c); _budget--;
						if (_budget <= 0) break;
					}
				} else {
					var _sx2 = _fx, _sy2 = _fy, _dir2 = random(360);
					repeat (_cfg.feat_stream_steps) {
						if (_budget <= 0) break;
						_dir2 += random_range(-25, 25);
						_sx2 += lengthdir_x(22, _dir2); _sy2 += lengthdir_y(22, _dir2);
						repeat (irandom_range(1, 2)) {
							if (_budget <= 0) break;
							var _sw = _c.swirl(_sx2 + random_range(-26, 26), _sy2 + random_range(-26, 26), _c, _cfg.swirl_deg);
							if (!_c.keep(_sw.x, _sw.y, _c)) continue;
							if (!_c.fits(_sw.x, _sw.y, _c)) continue;
							array_push(_c.pts, { x : _sw.x, y : _sw.y }); _c.mark(_sw.x, _sw.y, _c); _budget--;
						}
					}
				}
			}
			break;
		}
		case 7: {
			// the stars themselves: class, colour, size, rarity by radius, seed
			var _classes = [
				{ cls : "M", weight : 40,  lo :  .8, hi : 1.8 }, { cls : "K", weight : 22,  lo :  .9, hi : 2.2 },
				{ cls : "G", weight : 15,  lo : 1.0, hi : 2.8 }, { cls : "F", weight : 10,  lo : 1.1, hi : 3.4 },
				{ cls : "A", weight : 7,   lo : 1.3, hi : 4.2 }, { cls : "B", weight : 4.5, lo : 1.6, hi : 5.4 },
				{ cls : "O", weight : 1.5, lo : 2.0, hi : 7.0 },
			];
			var _rarity_cols = [ c_rarity_basic, c_rarity_common, c_rarity_uncommon, c_rarity_rare, c_rarity_epic, c_rarity_elite, c_rarity_master,
			                     c_rarity_exotic, c_rarity_ancient, c_rarity_legendary, c_rarity_cosmic, c_rarity_mythic, c_rarity_divine, c_rarity_ultimate ];
			var _pts = _c.pts, _count = array_length(_pts);
			var _stars = array_create(_count);
			for (var _i = 0; _i < _count; _i++) {
				var _roll = random(100), _acc = 0, _ck = 0;
				for (var _k = 0; _k < array_length(_classes); _k++) { _acc += _classes[_k].weight; if (_roll < _acc) { _ck = _k; break; } }
				var _cl = _classes[_ck];
				var _rd = clamp(point_distance(_pts[_i].x, _pts[_i].y, _cx, _cy) / _R, 0, 1);
				var _rrate = lerp(_cfg.rarity_rate_center, _cfg.rarity_rate_edge, power(_rd, _cfg.rarity_curve));
				var _tier = clamp(floor(_rrate / _cfg.rarity_base) + calculate_rarity(_rrate, _cfg.rarity_scale, _cfg.rarity_growth, _cfg.rarity_base), 0, 13);
				var _sseed = (_c.seed ^ ((_i + 1) * 2654435761)) & $7fffffff;
				_stars[_i] = {
					id : _i, x : _pts[_i].x, y : _pts[_i].y, seed : _sseed,
					d : .85 + .3 * ((_sseed mod 997) / 997),
					props : { name : "", stellar_class : _cl.cls, color : color_set_random(), size : random_range(_cl.lo, _cl.hi),
					          rarity : _tier, rarity_color : _rarity_cols[_tier], region : 0,
					          resources : undefined, hazards : undefined, inhabitants : undefined },
				};
			}
			_c.stars = _stars;
			break;
		}
		case 8: {
			// the regions: named neighbourhoods, a voronoi of picked stars
			var _stars = _c.stars, _count = array_length(_stars);
			var _rcount = max(1, round(_count / _cfg.region_stars));
			var _regions = [];
			var _rguard = _rcount * 80;
			while (array_length(_regions) < _rcount && _rguard > 0) {
				_rguard--;
				var _cand = _stars[irandom(_count - 1)];
				var _rok = true;
				for (var _i = 0; _i < array_length(_regions); _i++) if (point_distance(_cand.x, _cand.y, _regions[_i].x, _regions[_i].y) < _cfg.region_min_sep) { _rok = false; break; }
				if (!_rok) continue;
				array_push(_regions, { id : array_length(_regions), name : galaxy_region_name(), x : _cand.x, y : _cand.y, count : 0 });
			}
			for (var _i = 0; _i < _count; _i++) {
				var _best = 0, _bd = infinity;
				for (var _k = 0; _k < array_length(_regions); _k++) {
					var _d = point_distance(_stars[_i].x, _stars[_i].y, _regions[_k].x, _regions[_k].y);
					if (_d < _bd) { _bd = _d; _best = _k; }
				}
				_stars[_i].props.region = _best;
				_regions[_best].count += 1;
			}
			_c.regions = _regions;
			break;
		}
		default: {
			// the nebula density grid (a coarse count, blurred), the draw grid, the finish
			var _stars = _c.stars, _count = array_length(_stars), _w = _c.w;
			var _ngw = 64, _ncell = _w / _ngw;
			var _ngrid = array_create(_ngw * _ngw, 0);
			for (var _i = 0; _i < _count; _i++) {
				var _gx2 = clamp(floor(_stars[_i].x / _ncell), 0, _ngw - 1), _gy2 = clamp(floor(_stars[_i].y / _ncell), 0, _ngw - 1);
				_ngrid[_gx2 + _gy2 * _ngw] += 1;
			}
			var _nblur = array_create(_ngw * _ngw, 0);
			for (var _gy2 = 0; _gy2 < _ngw; _gy2++)
			for (var _gx2 = 0; _gx2 < _ngw; _gx2++) {
				var _acc = _ngrid[_gx2 + _gy2 * _ngw] * 4, _wt = 4;
				for (var _j = max(0, _gy2 - 1); _j <= min(_ngw - 1, _gy2 + 1); _j++)
				for (var _i = max(0, _gx2 - 1); _i <= min(_ngw - 1, _gx2 + 1); _i++) {
					if (_i == _gx2 && _j == _gy2) continue;
					_acc += _ngrid[_i + _j * _ngw]; _wt += 1;
				}
				_nblur[_gx2 + _gy2 * _ngw] = _acc / _wt;
			}
			var _nmax = 1;
			for (var _i = 0; _i < _ngw * _ngw; _i++) _nmax = max(_nmax, _nblur[_i]);
			var _dcell = 300, _dgw = ceil(_w / _dcell), _dgh = ceil(_c.h / _dcell);
			var _dgrid = array_create(_dgw * _dgh, 0);
			for (var _i = 0; _i < _dgw * _dgh; _i++) _dgrid[_i] = [];
			for (var _i = 0; _i < _count; _i++) {
				var _gx2 = clamp(floor(_stars[_i].x / _dcell), 0, _dgw - 1), _gy2 = clamp(floor(_stars[_i].y / _dcell), 0, _dgh - 1);
				array_push(_dgrid[_gx2 + _gy2 * _dgw], _i);
			}
			g.starmap = {
				seed : _c.seed, name : gen_name_planet() + " galaxy",
				width : _w, height : _c.h, cx : _cx, cy : _cy, gal_r : _R,
				count : _count, stars : _stars, regions : _c.regions,
				ngrid : _nblur, ngw : _ngw, ncell : _ncell, nmax : _nmax,
				dgrid : _dgrid, dgw : _dgw, dgh : _dgh, dcell : _dcell,
			};
			_c.done = true;
			show("starmap generated > seed " + string(_c.seed) + ", " + string(_count) + " stars");
			break;
		}
	}
	rng_release(_rs);
	if (!_c.done) _c.pass += 1;
	return _c.done;
}
