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
	while (!starmap_gen_step(_c, 1000000)) {}   // (a thousand seconds: whole, in one call)
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
		// THE SLICES (2026-09-16): a pass's place in its work, so starmap_gen_step
		// can return mid-pass and resume - sub the stage, i the index, placed /
		// guard / n the placement loop, rs the pass's own random stream (see __smg_rnd)
		sub : 0, i : 0, placed : 0, guard : 0, n : 0, rs : 1, tmp : undefined,
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
		if (_d > _rim) if (__smg_rnd(_c) < (_d - _rim) / (_c.r - _rim)) return false;
		if (_d > _c.gap_core) {
			var _fn = _c.fbm(_px, _py, _c);
			if (_fn < _c.gapt) return false;
			if (_fn < _c.gapt + .02) if (__smg_rnd(_c) < (_c.gapt + .02 - _fn) / .02) return false;
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
		var _u  = power(__smg_rnd(_c), _c.arm_r_bias);
		var _rr = _c.r * lerp(_c.arm_r_min, .96, _u);
		var _arm = __smg_ri(_c, _c.arm_count - 1);
		var _ang = _c.arm_a0 + _arm * (360 / _c.arm_count) + _c.arm_turns * 360 * power(_rr / _c.r, .85);
		var _wd  = _c.arm_width_base + _rr * _c.arm_width_grow;
		var _off;
		if (__smg_rnd(_c) < .35) _off = (__smg_rnd(_c) + __smg_rnd(_c) - 1) * _wd;
		else                      _off = __smg_rr(_c, -1, 1) * _wd * 3.2;
		return { x : _c.cx + lengthdir_x(_rr, _ang) + lengthdir_x(_off, _ang + 90),
		         y : _c.cy + lengthdir_y(_rr, _ang) + lengthdir_y(_off, _ang + 90) };
	};
	_c.swirl = function(_px, _py, _c, _deg) {
		var _d = point_distance(_px, _py, _c.cx, _c.cy);
		var _a = point_direction(_c.cx, _c.cy, _px, _py) + _deg * (1 - _d / _c.r);
		return { x : _c.cx + lengthdir_x(_d, _a), y : _c.cy + lengthdir_y(_d, _a) };
	};
	__smg_seed(_c);   // pass 0's stream
	return _c;
}

/// the passes' own random numbers (starmap_gen_step, 2026-09-16): an xorshift32
/// on ctx.rs -> [0, 1). GM's random() cannot resume across frames (random_get_seed
/// returns the seed that was SET, not where the stream is), and a pass sliced
/// over frames has other rolls between its slices - so the passes carry their
/// own stream, seeded per pass by __smg_seed, and a slice boundary changes nothing
function __smg_rnd(_c) {
	var _s = _c.rs;
	_s = (_s ^ (_s << 13)) & $ffffffff;
	_s = (_s ^ (_s >> 17)) & $ffffffff;
	_s = (_s ^ (_s << 5)) & $ffffffff;
	_c.rs = _s;
	return _s / 4294967296;
}
/// a random real in [a, b] off the pass's stream (random_range's shape)
function __smg_rr(_c, _a, _b) { return _a + (_b - _a) * __smg_rnd(_c); }
/// a random integer in 0..n off the pass's stream (irandom's shape)
function __smg_ri(_c, _n) { return min(_n, floor(__smg_rnd(_c) * (_n + 1))); }
/// the pass's stream: seed ^ pass, never zero (xorshift's dead state)
function __smg_seed(_c) {
	_c.rs = (_c.seed ^ ((_c.pass + 1) * 2654435761)) & $ffffffff;
	if (_c.rs == 0) _c.rs = 88172645;
}
/// the next pass: the stage counters back to zero, a stream of its own
function __smg_next(_c) {
	_c.pass += 1; _c.sub = 0; _c.i = 0; _c.placed = 0; _c.guard = 0; _c.n = 0; _c.tmp = undefined;
	__smg_seed(_c);
}
/// starmap_gen_progress(ctx) -> 0..1, how far the build is (the boot's bar)
function starmap_gen_progress(_c) {
	if (_c.done) return 1;
	var _f = 0;
	switch (_c.pass) {
		case 0: _f = _c.i / 2000; break;
		case 1: case 2: case 3: case 4: _f = (_c.n > 0) ? _c.placed / _c.n : 0; break;
		case 6: _f = _c.i / max(1, _c.cfg.feat_count); break;
		case 7: case 8: _f = (array_length(_c.pts) > 0) ? _c.i / array_length(_c.pts) : 0; break;
		case 9: _f = _c.sub / 5; break;
	}
	return clamp((_c.pass + clamp(_f, 0, 1)) / 10, 0, 1);
}

/// @description starmap_gen_step(ctx, [budget_ms]) -> true when the galaxy is done (g.starmap set)
/// THE BUDGET (2026-09-16, his report: "the boot loading screen... stutters
/// pretty bad"): a pass was one call, and the arms alone are four thousand
/// placements through the noise - a hitch of frames each. Now the call
/// works until budget_ms have gone (get_timer) and returns, and the next
/// call picks up EXACTLY where it stopped - the spinner turns at the frame
/// rate however slow the machine. What makes that possible: the passes roll
/// their own numbers (__smg_rnd, seeded per pass) and the few house rolls a
/// star needs (color_set_random, calculate_rarity) run under a seed of the
/// star's own, so a slice boundary between two stars changes nothing.
/// THE GALAXY FOR A SEED CHANGED ONCE with this (a new roll order): an old
/// save's home star moves (galaxy_home derives it), the world it walks is
/// its own seed and stays; a new game lines the two up again.
/// The passes: 0 the gap threshold, 1 the core, 2 the arms, 3 the halo,
/// 4 the islands, 5 the roads, 6 the features, 7 the stars themselves
/// (class / colour / rarity), 8 the regions, 9 the nebula grid, the draw
/// grid and the finish. ctx.sub / i / placed / guard / n are a pass's place
/// in its work (starmap_gen_begin).
function starmap_gen_step(_c, _budget_ms = 8) {
	if (_c.done) return true;
	var _cfg = _c.cfg;
	var _lim = get_timer() + _budget_ms * 1000;
	var _rs = random_get_seed();
	var _cx = _c.cx, _cy = _c.cy, _R = _c.r;
	while (!_c.done && get_timer() < _lim) {
		switch (_c.pass) {
			case 0: {
				// the gap threshold: measure, don't guess - the gap_frac percentile
				if (_c.sub == 0) { _c.arm_a0 = __smg_rnd(_c) * 360; _c.tmp = array_create(2000, 0); _c.i = 0; _c.sub = 1; }
				while (_c.i < 2000 && get_timer() < _lim) {
					var _sr = _R * sqrt(__smg_rnd(_c)), _sa = __smg_rnd(_c) * 360;
					_c.tmp[_c.i] = _c.fbm(_cx + lengthdir_x(_sr, _sa), _cy + lengthdir_y(_sr, _sa), _c);
					_c.i += 1;
				}
				if (_c.i >= 2000) {
					array_sort(_c.tmp, true);
					_c.gapt = _c.tmp[floor(2000 * _cfg.gap_frac)];
					__smg_next(_c);
				}
				break;
			}
			case 1: case 2: case 3: {
				// 1 the core marker / 2 the spiral arms, by construction / 3 the halo dust, centre-weighted
				if (_c.sub == 0) {
					var _fr = (_c.pass == 1) ? _cfg.frac_core : ((_c.pass == 2) ? _cfg.frac_arms : _cfg.frac_halo);
					_c.n = round(_cfg.star_target * _fr); _c.placed = 0; _c.guard = _c.n * 40; _c.sub = 1;
				}
				while (_c.placed < _c.n && _c.guard > 0 && get_timer() < _lim) {
					_c.guard -= 1;
					var _px, _py;
					if (_c.pass == 2) { var _pt = _c.arm_pt(_c); _px = _pt.x; _py = _pt.y; }
					else {
						var _rr = (_c.pass == 1) ? _cfg.core_r * power(__smg_rnd(_c), .8) : _R * power(__smg_rnd(_c), .7);
						var _aa = __smg_rnd(_c) * 360;
						_px = _cx + lengthdir_x(_rr, _aa); _py = _cy + lengthdir_y(_rr, _aa);
					}
					if (!_c.keep(_px, _py, _c)) continue;
					if (!_c.fits(_px, _py, _c)) continue;
					array_push(_c.pts, { x : _px, y : _py }); _c.mark(_px, _py, _c); _c.placed += 1;
				}
				if (_c.placed >= _c.n || _c.guard <= 0) __smg_next(_c);
				break;
			}
			case 4: {
				// the island continents, anchored on the arms (the anchors in one go, the stars sliced)
				if (_c.sub == 0) {
					var _ag = 400;
					while (array_length(_c.isl) < _cfg.isl_count && _ag > 0) {
						_ag -= 1;
						var _apt = _c.arm_pt(_c);
						if (!_c.keep(_apt.x, _apt.y, _c)) continue;
						var _ok = true;
						for (var _ii = 0; _ii < array_length(_c.isl); _ii++) if (point_distance(_apt.x, _apt.y, _c.isl[_ii].x, _c.isl[_ii].y) < 420) { _ok = false; break; }
						if (!_ok) continue;
						array_push(_c.isl, { x : _apt.x, y : _apt.y, r : __smg_rr(_c, _cfg.isl_r_min, _cfg.isl_r_max) });
					}
					_c.n = round(_cfg.star_target * _cfg.frac_islands); _c.placed = 0; _c.guard = _c.n * 40; _c.sub = 1;
				}
				var _nisl = array_length(_c.isl);
				while (_c.placed < _c.n && _c.guard > 0 && _nisl > 0 && get_timer() < _lim) {
					_c.guard -= 1;
					var _is = _c.isl[__smg_ri(_c, _nisl - 1)];
					var _irr = (__smg_rnd(_c) + __smg_rnd(_c)) * .5 * _is.r, _iaa = __smg_rnd(_c) * 360;
					var _isw = _c.swirl(_is.x + lengthdir_x(_irr, _iaa), _is.y + lengthdir_y(_irr, _iaa), _c, _cfg.swirl_deg);
					if (!_c.keep(_isw.x, _isw.y, _c)) continue;
					if (!_c.fits(_isw.x, _isw.y, _c)) continue;
					array_push(_c.pts, { x : _isw.x, y : _isw.y }); _c.mark(_isw.x, _isw.y, _c); _c.placed += 1;
				}
				if (_c.placed >= _c.n || _c.guard <= 0 || _nisl <= 0) __smg_next(_c);
				break;
			}
			case 5: {
				// the star roads: a spanning chain of the continents + the core (one go - a few hundred stars, no noise)
				var _isl = _c.isl, _edges = [];
				if (array_length(_isl) > 1) {
					var _linked = [0];
					while (array_length(_linked) < array_length(_isl)) {
						var _best_d = infinity, _best_a = 0, _best_b = 1;
						for (var _li = 0; _li < array_length(_linked); _li++) {
							var _la = _isl[_linked[_li]];
							for (var _lj = 0; _lj < array_length(_isl); _lj++) {
								if (array_contains(_linked, _lj)) continue;
								var _ld = point_distance(_la.x, _la.y, _isl[_lj].x, _isl[_lj].y);
								if (_ld < _best_d) { _best_d = _ld; _best_a = _linked[_li]; _best_b = _lj; }
							}
						}
						array_push(_edges, { x1 : _isl[_best_a].x, y1 : _isl[_best_a].y, x2 : _isl[_best_b].x, y2 : _isl[_best_b].y });
						array_push(_linked, _best_b);
					}
				}
				if (array_length(_isl) > 0) {
					var _ni = 0, _nd = infinity;
					for (var _ci = 0; _ci < array_length(_isl); _ci++) { var _cd = point_distance(_cx, _cy, _isl[_ci].x, _isl[_ci].y); if (_cd < _nd) { _nd = _cd; _ni = _ci; } }
					array_push(_edges, { x1 : _cx, y1 : _cy, x2 : _isl[_ni].x, y2 : _isl[_ni].y });
				}
				var _budget = round(_cfg.star_target * _cfg.frac_paths);
				for (var _e = 0; _e < array_length(_edges); _e++) {
					if (_budget <= 0) break;
					var _ed = _edges[_e];
					var _len = point_distance(_ed.x1, _ed.y1, _ed.x2, _ed.y2), _dir = point_direction(_ed.x1, _ed.y1, _ed.x2, _ed.y2);
					var _steps = max(2, floor(_len / _cfg.path_step));
					var _bow = __smg_rr(_c, -1, 1) * _cfg.path_bow;
					for (var _st = 0; _st <= _steps; _st++) {
						if (_budget <= 0) break;
						var _t = _st / _steps;
						var _bx = lerp(_ed.x1, _ed.x2, _t) + lengthdir_x(sin(_t * pi) * _bow + __smg_rr(_c, -1, 1) * _cfg.path_jitter, _dir + 90);
						var _by = lerp(_ed.y1, _ed.y2, _t) + lengthdir_y(sin(_t * pi) * _bow + __smg_rr(_c, -1, 1) * _cfg.path_jitter, _dir + 90);
						var _rsw = _c.swirl(_bx, _by, _c, _cfg.swirl_deg);
						// roads ignore the noise gaps on purpose (bridges through emptiness)
						if (point_distance(_rsw.x, _rsw.y, _cx, _cy) >= _R) continue;
						if (!_c.fits(_rsw.x, _rsw.y, _c)) continue;
						array_push(_c.pts, { x : _rsw.x, y : _rsw.y }); _c.mark(_rsw.x, _rsw.y, _c); _budget--;
					}
				}
				__smg_next(_c);
				break;
			}
			case 6: {
				// the unique features: rings, arcs, streams - a feature a slice (n = the stars left to spend)
				if (_c.sub == 0) { _c.n = round(_cfg.star_target * _cfg.frac_feats); _c.i = 0; _c.sub = 1; }
				if (_c.i < _cfg.feat_count && _c.n > 0) {
					var _per = max(8, round(_cfg.star_target * _cfg.frac_feats) div max(1, _cfg.feat_count));
					var _fr2 = _R * __smg_rr(_c, .15, .8), _fa = __smg_rnd(_c) * 360;
					var _fx = _cx + lengthdir_x(_fr2, _fa), _fy = _cy + lengthdir_y(_fr2, _fa);
					var _type = __smg_ri(_c, 2);
					var _fn2 = min(_per, _c.n);
					if (_type == 0 || _type == 1) {
						var _rad = __smg_rr(_c, _cfg.feat_ring_min, _cfg.feat_ring_max), _a0 = __smg_rnd(_c) * 360;
						var _span = (_type == 1) ? __smg_rr(_c, 90, 220) : 360;
						for (var _fs = 0; _fs < _fn2; _fs++) {
							var _aa2 = _a0 + (_fs / _fn2) * _span, _rr2 = _rad + __smg_rr(_c, -24, 24);
							var _fsw = _c.swirl(_fx + lengthdir_x(_rr2, _aa2), _fy + lengthdir_y(_rr2, _aa2), _c, _cfg.swirl_deg);
							if (!_c.keep(_fsw.x, _fsw.y, _c)) continue;
							if (!_c.fits(_fsw.x, _fsw.y, _c)) continue;
							array_push(_c.pts, { x : _fsw.x, y : _fsw.y }); _c.mark(_fsw.x, _fsw.y, _c); _c.n -= 1;
							if (_c.n <= 0) break;
						}
					} else {
						var _sx2 = _fx, _sy2 = _fy, _dir2 = __smg_rnd(_c) * 360;
						repeat (_cfg.feat_stream_steps) {
							if (_c.n <= 0) break;
							_dir2 += __smg_rr(_c, -25, 25);
							_sx2 += lengthdir_x(22, _dir2); _sy2 += lengthdir_y(22, _dir2);
							repeat (1 + __smg_ri(_c, 1)) {
								if (_c.n <= 0) break;
								var _ssw = _c.swirl(_sx2 + __smg_rr(_c, -26, 26), _sy2 + __smg_rr(_c, -26, 26), _c, _cfg.swirl_deg);
								if (!_c.keep(_ssw.x, _ssw.y, _c)) continue;
								if (!_c.fits(_ssw.x, _ssw.y, _c)) continue;
								array_push(_c.pts, { x : _ssw.x, y : _ssw.y }); _c.mark(_ssw.x, _ssw.y, _c); _c.n -= 1;
							}
						}
					}
					_c.i += 1;
				}
				if (_c.i >= _cfg.feat_count || _c.n <= 0) __smg_next(_c);
				break;
			}
			case 7: {
				// the stars themselves: class, colour, size, rarity by radius, seed -
				// each under a seed of its own (the house rolls), so a slice may end between any two
				var _classes = [
					{ cls : "M", weight : 40,  lo :  .8, hi : 1.8 }, { cls : "K", weight : 22,  lo :  .9, hi : 2.2 },
					{ cls : "G", weight : 15,  lo : 1.0, hi : 2.8 }, { cls : "F", weight : 10,  lo : 1.1, hi : 3.4 },
					{ cls : "A", weight : 7,   lo : 1.3, hi : 4.2 }, { cls : "B", weight : 4.5, lo : 1.6, hi : 5.4 },
					{ cls : "O", weight : 1.5, lo : 2.0, hi : 7.0 },
				];
				var _rarity_cols = [ c_rarity_basic, c_rarity_common, c_rarity_uncommon, c_rarity_rare, c_rarity_epic, c_rarity_elite, c_rarity_master,
				                     c_rarity_exotic, c_rarity_ancient, c_rarity_legendary, c_rarity_cosmic, c_rarity_mythic, c_rarity_divine, c_rarity_ultimate ];
				var _pts = _c.pts, _count = array_length(_pts);
				if (_c.sub == 0) { _c.stars = array_create(_count, undefined); _c.i = 0; _c.sub = 1; }
				while (_c.i < _count && get_timer() < _lim) {
					var _si = _c.i;
					var _sseed = (_c.seed ^ ((_si + 1) * 2654435761)) & $7fffffff;
					random_set_seed(_sseed);
					var _roll = random(100), _acc = 0, _ck = 0;
					for (var _k = 0; _k < array_length(_classes); _k++) { _acc += _classes[_k].weight; if (_roll < _acc) { _ck = _k; break; } }
					var _cl = _classes[_ck];
					var _rd = clamp(point_distance(_pts[_si].x, _pts[_si].y, _cx, _cy) / _R, 0, 1);
					var _rrate = lerp(_cfg.rarity_rate_center, _cfg.rarity_rate_edge, power(_rd, _cfg.rarity_curve));
					var _tier = clamp(floor(_rrate / _cfg.rarity_base) + calculate_rarity(_rrate, _cfg.rarity_scale, _cfg.rarity_growth, _cfg.rarity_base), 0, 13);
					_c.stars[_si] = {
						id : _si, x : _pts[_si].x, y : _pts[_si].y, seed : _sseed,
						d : .85 + .3 * ((_sseed mod 997) / 997),
						props : { name : "", stellar_class : _cl.cls, color : color_set_random(), size : random_range(_cl.lo, _cl.hi),
						          rarity : _tier, rarity_color : _rarity_cols[_tier], region : 0, skind : "main",
						          resources : undefined, hazards : undefined, inhabitants : undefined },
					};
					// THE KINDS (his picks, 2026-09-17): a RED GIANT six in a hundred - huge, orange-red, its inner worlds
					// scorched; a WHITE DWARF five in a hundred - a blue-white pinprick, its worlds cold; a PULSAR one and a
					// half in a hundred - a white point with a lighthouse beam, its worlds dead and frozen. Hashed off the
					// seed like the holes; the rolls after the star's own are safe
					var _sk = hash_mix(_sseed, 4050) mod 1000, _pk = _c.stars[_si].props;
					if (_sk < 60) {
						// THE GIANT'S PALETTE (his ask, 2026-09-19): yellow (a G giant), orange (K), red (M), and the carbon star's ruby - hashed
						var _gp = hash_mix(_sseed, 4051) mod 100;
						_pk.skind = "giant"; _pk.size = random_range(3.0, 4.6);
						if (_gp < 28)      { _pk.color = merge_colour(_pk.color, rgb(255, 218, 130), .78); _pk.stellar_class = choose("G III", "G II"); }
						else if (_gp < 58) { _pk.color = merge_colour(_pk.color, rgb(255, 150, 70),  .76); _pk.stellar_class = choose("K III", "K II"); }
						else if (_gp < 86) { _pk.color = merge_colour(_pk.color, rgb(255, 100, 58),  .78); _pk.stellar_class = choose("M III", "M II"); }
						else               { _pk.color = merge_colour(_pk.color, rgb(215, 42, 46),   .86); _pk.stellar_class = "C"; }
					}
					else if (_sk < 110) { _pk.skind = "dwarf";  _pk.size = random_range(.35, .55); _pk.color = merge_colour(_pk.color, rgb(205, 218, 255), .8); _pk.stellar_class = choose("DA", "DB", "DQ"); }
					// THE NEW KINDS (q253, his picks): a BROWN DWARF four in a hundred, a WOLF-RAYET one, a CEPHEID two and a half, a PROTOSTAR one and a half
					else if (_sk >= 125 && _sk < 165) { _pk.skind = "brown"; _pk.size = random_range(.45, .70); _pk.color = merge_colour(_pk.color, rgb(160, 68, 80), .86); _pk.stellar_class = choose("L", "T"); }
					// THE IMAGINARY KINDS (q267, his: the Wolf-Rayet and the cepheid out, these in their bands): a CHROMATIC STAR - white,
					// its light split into fringes; a SWELLING STAR - bloated and orange, swelling as if to blow and snapping back
					else if (_sk >= 165 && _sk < 175) { _pk.skind = "chroma"; _pk.size = random_range(1.2, 1.8); _pk.color = merge_colour(_pk.color, c_white, .82); _pk.stellar_class = "Ch"; }
					else if (_sk >= 175 && _sk < 200) { _pk.skind = "swell"; _pk.size = random_range(1.6, 2.6); _pk.color = merge_colour(_pk.color, rgb(255, 150, 70), .60); _pk.stellar_class = "Sw"; _pk.period = random_range(1200, 5400); }
					else if (_sk >= 200 && _sk < 215) { _pk.skind = "proto"; _pk.size = random_range(.9, 1.5); _pk.color = merge_colour(_pk.color, rgb(255, 150, 90), .72); _pk.stellar_class = "T Tau"; }
					else if (_sk < 125) { _pk.skind = "pulsar"; _pk.size = random_range(.30, .42); _pk.color = merge_colour(_pk.color, rgb(235, 240, 255), .85); _pk.stellar_class = "PSR"; _pk.spin = random_range(.7, 2.4); _pk.tilt = random_range(20, 70); }
					// BLACK HOLES (his ask, 2026-09-17): one star in two hundred, hashed off its seed - and the core's own,
					// supermassive, whatever sits nearest the galaxy's centre. The rolls after the star's own are safe: the
					// next star seeds afresh. Its colour is its accretion disc's - a hot blue-white or an orange-white
					var _hole = ((hash_mix(_sseed, 4040) mod 1000) < 5), _core = (_rd < .012);
					if (_hole || _core) {
						var _pp = _c.stars[_si].props;
						_pp.hole = true; _pp.stellar_class = "BH"; _pp.skind = "hole";
						_pp.size = _core ? random_range(5.2, 6.5) : random_range(1.5, 2.6);
						_pp.color = merge_colour(_pp.color, ((hash_mix(_sseed, 4041) mod 2) == 0) ? rgb(175, 205, 255) : rgb(255, 195, 130), .65);
					}
					_c.i += 1;
				}
				if (_c.i >= _count) __smg_next(_c);
				break;
			}
			case 8: {
				// the regions: named neighbourhoods, a voronoi of picked stars (the pick in one go
				// under the pass's seed - the names are house rolls; the voronoi sliced)
				if (_c.sub == 0) {
					random_set_seed((_c.seed ^ ((_c.pass + 1) * 2654435761)) & $7fffffff);
					var _pstars = _c.stars, _pcount = array_length(_pstars);
					var _rcount = max(1, round(_pcount / _cfg.region_stars));
					var _regions = [];
					var _rguard = _rcount * 80;
					while (array_length(_regions) < _rcount && _rguard > 0) {
						_rguard--;
						var _cand = _pstars[__smg_ri(_c, _pcount - 1)];
						var _rok = true;
						for (var _ri = 0; _ri < array_length(_regions); _ri++) if (point_distance(_cand.x, _cand.y, _regions[_ri].x, _regions[_ri].y) < _cfg.region_min_sep) { _rok = false; break; }
						if (!_rok) continue;
						array_push(_regions, { id : array_length(_regions), name : galaxy_region_name(), x : _cand.x, y : _cand.y, count : 0 });
					}
					_c.regions = _regions; _c.i = 0; _c.sub = 1;
				}
				var _vstars = _c.stars, _vcount = array_length(_vstars), _vregs = _c.regions, _nr = array_length(_vregs);
				while (_c.i < _vcount && get_timer() < _lim) {
					var _vi = _c.i;
					var _best = 0, _bd = infinity;
					for (var _vk = 0; _vk < _nr; _vk++) {
						var _vd = point_distance(_vstars[_vi].x, _vstars[_vi].y, _vregs[_vk].x, _vregs[_vk].y);
						if (_vd < _bd) { _bd = _vd; _best = _vk; }
					}
					_vstars[_vi].props.region = _best;
					_vregs[_best].count += 1;
					_c.i += 1;
				}
				if (_c.i >= _vcount) __smg_next(_c);
				break;
			}
			default: {
				// the nebula density grid (a coarse count, blurred), the draw grid, the finish - in slices
				var _stars = _c.stars, _count2 = array_length(_stars), _w = _c.w;
				var _ngw = 64, _ncell = _w / _ngw;
				var _dcell = 300, _dgw = ceil(_w / _dcell), _dgh = ceil(_c.h / _dcell);
				if (_c.sub == 0) {
					_c.tmp = { ngrid : array_create(_ngw * _ngw, 0), nblur : array_create(_ngw * _ngw, 0), dgrid : array_create(_dgw * _dgh, 0), nmax : 1 };
					_c.i = 0; _c.sub = 1;
				}
				var _tp = _c.tmp;
				if (_c.sub == 1) {
					// the count
					while (_c.i < _count2 && get_timer() < _lim) {
						var _gx2 = clamp(floor(_stars[_c.i].x / _ncell), 0, _ngw - 1), _gy2 = clamp(floor(_stars[_c.i].y / _ncell), 0, _ngw - 1);
						_tp.ngrid[_gx2 + _gy2 * _ngw] += 1;
						_c.i += 1;
					}
					if (_c.i >= _count2) { _c.sub = 2; _c.i = 0; }
				}
				if (_c.sub == 2) {
					// the blur, a row a step
					while (_c.i < _ngw && get_timer() < _lim) {
						var _by2 = _c.i;
						for (var _bx2 = 0; _bx2 < _ngw; _bx2++) {
							var _acc2 = _tp.ngrid[_bx2 + _by2 * _ngw] * 4, _wt = 4;
							for (var _bj = max(0, _by2 - 1); _bj <= min(_ngw - 1, _by2 + 1); _bj++)
							for (var _bi = max(0, _bx2 - 1); _bi <= min(_ngw - 1, _bx2 + 1); _bi++) {
								if (_bi == _bx2 && _bj == _by2) continue;
								_acc2 += _tp.ngrid[_bi + _bj * _ngw]; _wt += 1;
							}
							_tp.nblur[_bx2 + _by2 * _ngw] = _acc2 / _wt;
						}
						_c.i += 1;
					}
					if (_c.i >= _ngw) {
						for (var _mi = 0; _mi < _ngw * _ngw; _mi++) _tp.nmax = max(_tp.nmax, _tp.nblur[_mi]);
						for (var _di = 0; _di < _dgw * _dgh; _di++) _tp.dgrid[_di] = [];
						_c.sub = 3; _c.i = 0;
					}
				}
				if (_c.sub == 3) {
					// the draw grid
					while (_c.i < _count2 && get_timer() < _lim) {
						var _dx2 = clamp(floor(_stars[_c.i].x / _dcell), 0, _dgw - 1), _dy2 = clamp(floor(_stars[_c.i].y / _dcell), 0, _dgh - 1);
						array_push(_tp.dgrid[_dx2 + _dy2 * _dgw], _c.i);
						_c.i += 1;
					}
					if (_c.i >= _count2) _c.sub = 4;
				}
				if (_c.sub == 4) {
					// the finish (the galaxy's name is a house roll: under the pass's seed)
					random_set_seed((_c.seed ^ ((_c.pass + 1) * 2654435761)) & $7fffffff);
					g.starmap = {
						seed : _c.seed, name : gen_name_planet() + " galaxy",
						width : _w, height : _c.h, cx : _cx, cy : _cy, gal_r : _R,
						count : _count2, stars : _stars, regions : _c.regions,
						ngrid : _tp.nblur, ngw : _ngw, ncell : _ncell, nmax : _tp.nmax,
						dgrid : _tp.dgrid, dgw : _dgw, dgh : _dgh, dcell : _dcell,
					};
					_c.tmp = undefined;
					_c.sub = 5;
					_c.done = true;
					show("starmap generated > seed " + string(_c.seed) + ", " + string(_count2) + " stars");
				}
				break;
			}
		}
	}
	rng_release(_rs);
	return _c.done;
}
