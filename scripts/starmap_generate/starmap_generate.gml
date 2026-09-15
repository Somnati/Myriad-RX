/// @description starmap_generate(seed) -> g.starmap (the tech demo's scr_starmap_generate, ported verbatim 2026-09-15)
/// @param seed
/// builds the galaxy into g.starmap, deterministic per seed. v3, ground
/// up: NO density image, no surfaces, no readback. everything is
/// parametric and seed-driven:
///
///   arms     placed BY CONSTRUCTION: each arm star picks a radius,
///            computes the spiral centerline angle at that radius, and
///            offsets perpendicular by a gaussian. the spiral cannot
///            smear out, because arm stars are never anywhere else
///   core     small hot marker at the center (kept deliberately small:
///            big bright bulges saturate the spacing cap into a blob)
///   halo     thin dust across the disc so the space between arms is
///            sparse, not dead
///   islands  dense continents anchored ON arm points
///   paths    star roads chaining the continents + the core
///   feats    rings / arcs / streams to stumble onto
///
/// perlin-style GAPS: 3-octave value noise (hashed, pure gml) carves
/// hard holes through every pass. the threshold is found at runtime by
/// percentile sampling, so cfg.gap_frac is the actual carved fraction,
/// not a guess. cfg.gap_core protects the center.
///
/// every pass enforces cfg.star_spacing via a hash grid (the declump
/// rule), and rarity climbs with distance from the core via the
/// project's calculate_rarity().
function starmap_generate(_seed) {
	var _cfg = starmap_config();
	var _rs0 = random_get_seed();
	random_set_seed(_seed);

	var _w  = _cfg.plane_w;
	var _h  = _cfg.plane_h;
	var _cx = _w * .5;
	var _cy = _h * .5;
	var _R  = _cfg.gal_r;

	// ---- spacing hash grid: one star per cell, cell = min spacing ----
	var _cell = _cfg.star_spacing;
	var _gw = ceil(_w / _cell);
	var _gh = ceil(_h / _cell);

	// shared context (gml function literals don't capture locals, so
	// every helper takes this as its last argument)
	var _ctx = {
		cx : _cx, cy : _cy, r : _R,
		soft : _cfg.gal_soft,
		// noise / gaps
		nseed    : _seed,
		gap_wl   : _cfg.gap_wl,
		gap_core : _cfg.gap_core,
		gapt     : 0,          // set below by percentile sampling
		// arms
		arm_a0         : random(360),
		arm_count      : _cfg.arm_count,
		arm_turns      : _cfg.arm_turns,
		arm_width_base : _cfg.arm_width_base,
		arm_width_grow : _cfg.arm_width_grow,
		arm_r_min      : _cfg.arm_r_min,
		arm_r_bias     : _cfg.arm_r_bias,
		// spacing
		grid : array_create(_gw * _gh, undefined),
		gw : _gw, gh : _gh, cell : _cell, mind : _cfg.star_spacing,
		// helpers wired in below
		hash2 : undefined, fbm : undefined,
	};

	// integer hash -> 0..1, salted per octave
	_ctx.hash2 = function(_ix, _iy, _salt, _c) {
		var _hv = (_ix * 374761393 + _iy * 668265263 + (_c.nseed + _salt) * 144269504) & $7fffffff;
		_hv = ((_hv ^ (_hv >> 13)) * 1274126177) & $7fffffff;
		return ((_hv ^ (_hv >> 16)) & $ffffff) / $ffffff;
	};

	// 3-octave value noise, 0..1, smooth blobs sized by gap_wl
	_ctx.fbm = function(_px, _py, _c) {
		var _n = 0;
		var _amp = 1;
		var _wl = _c.gap_wl;
		var _tot = 0;
		var _salt = 0;
		repeat (3) {
			var _fx = _px / _wl;
			var _fy = _py / _wl;
			var _ix = floor(_fx);
			var _iy = floor(_fy);
			var _tx = _fx - _ix; _tx = _tx * _tx * (3 - 2 * _tx);
			var _ty = _fy - _iy; _ty = _ty * _ty * (3 - 2 * _ty);
			var _a = _c.hash2(_ix,     _iy,     _salt, _c);
			var _b = _c.hash2(_ix + 1, _iy,     _salt, _c);
			var _c2 = _c.hash2(_ix,     _iy + 1, _salt, _c);
			var _d2 = _c.hash2(_ix + 1, _iy + 1, _salt, _c);
			_n += lerp(lerp(_a, _b, _tx), lerp(_c2, _d2, _tx), _ty) * _amp;
			_tot += _amp;
			_amp *= .5;
			_wl  *= .5;
			_salt += 101;
		}
		return _n / _tot;
	};

	// ---- gap threshold: measure, don't guess ----
	// sample the noise across the disc, sort, and cut at the gap_frac
	// percentile, so exactly that fraction of the disc becomes holes
	var _ns = 2000;
	var _samples = array_create(_ns);
	for (var _i = 0; _i < _ns; _i++) {
		var _sr = _R * sqrt(random(1)); // uniform over the disc
		var _sa = random(360);
		_samples[_i] = _ctx.fbm(_cx + lengthdir_x(_sr, _sa),
		                        _cy + lengthdir_y(_sr, _sa), _ctx);
	}
	array_sort(_samples, true);
	_ctx.gapt = _samples[floor(_ns * _cfg.gap_frac)];

	// keep a candidate? inside the feathered rim, outside the noise gaps
	var _keep = function(_px, _py, _c) {
		var _d = point_distance(_px, _py, _c.cx, _c.cy);
		if (_d >= _c.r) return false;
		var _rim = _c.r * (1 - _c.soft);
		if (_d > _rim) if (random(1) < (_d - _rim) / (_c.r - _rim)) return false;
		if (_d > _c.gap_core) {
			var _fn = _c.fbm(_px, _py, _c);
			if (_fn < _c.gapt) return false;                    // hard hole
			if (_fn < _c.gapt + .02)                            // thin feather
				if (random(1) < (_c.gapt + .02 - _fn) / .02) return false;
		}
		return true;
	};

	// spacing check against the 3x3 neighborhood + cell claim
	var _fits = function(_px, _py, _c) {
		var _gx = floor(_px / _c.cell);
		var _gy = floor(_py / _c.cell);
		for (var _j = max(0, _gy - 1); _j <= min(_c.gh - 1, _gy + 1); _j++)
		for (var _i = max(0, _gx - 1); _i <= min(_c.gw - 1, _gx + 1); _i++) {
			var _o = _c.grid[_i + _j * _c.gw];
			if (is_undefined(_o)) continue;
			if (point_distance(_px, _py, _o.x, _o.y) < _c.mind) return false;
		}
		return true;
	};
	var _mark = function(_px, _py, _c) {
		_c.grid[floor(_px / _c.cell) + floor(_py / _c.cell) * _c.gw] = { x : _px, y : _py };
	};

	// a random point ON a spiral arm: radius along the arm, centerline
	// angle at that radius, gaussian perpendicular offset
	var _arm_pt = function(_c) {
		var _u  = power(random(1), _c.arm_r_bias);
		var _rr = _c.r * lerp(_c.arm_r_min, .96, _u);
		var _arm = irandom(_c.arm_count - 1);
		var _ang = _c.arm_a0 + _arm * (360 / _c.arm_count)
		         + _c.arm_turns * 360 * power(_rr / _c.r, .85);
		var _wd  = _c.arm_width_base + _rr * _c.arm_width_grow;
		// band + haze: the band share is the spiral SHARPNESS dial.
		// only a third of arm stars stay banded; the rest smear out to
		// 3.2x width, so the spiral is a whisper over the disc
		var _off;
		if (random(1) < .35) _off = (random(1) + random(1) - 1) * _wd;
		else                 _off = random_range(-1, 1) * _wd * 3.2;
		return {
			x : _c.cx + lengthdir_x(_rr, _ang) + lengthdir_x(_off, _ang + 90),
			y : _c.cy + lengthdir_y(_rr, _ang) + lengthdir_y(_off, _ang + 90),
		};
	};

	// differential rotation for islands/paths/features
	var _swirl = function(_px, _py, _c, _deg) {
		var _d = point_distance(_px, _py, _c.cx, _c.cy);
		var _a = point_direction(_c.cx, _c.cy, _px, _py) + _deg * (1 - _d / _c.r);
		return { x : _c.cx + lengthdir_x(_d, _a), y : _c.cy + lengthdir_y(_d, _a) };
	};

	var _n_core    = round(_cfg.star_target * _cfg.frac_core);
	var _n_arms    = round(_cfg.star_target * _cfg.frac_arms);
	var _n_halo    = round(_cfg.star_target * _cfg.frac_halo);
	var _n_islands = round(_cfg.star_target * _cfg.frac_islands);
	var _n_paths   = round(_cfg.star_target * _cfg.frac_paths);
	var _n_feats   = round(_cfg.star_target * _cfg.frac_feats);

	var _pts = [];

	// ---- pass 1: core marker ----
	var _placed = 0;
	var _guard  = _n_core * 40;
	while (_placed < _n_core && _guard > 0) {
		_guard--;
		var _rr = _cfg.core_r * power(random(1), .8);
		var _aa = random(360);
		var _px = _cx + lengthdir_x(_rr, _aa);
		var _py = _cy + lengthdir_y(_rr, _aa);
		if (!_keep(_px, _py, _ctx)) continue;
		if (!_fits(_px, _py, _ctx)) continue;
		array_push(_pts, { x : _px, y : _py });
		_mark(_px, _py, _ctx);
		_placed++;
	}

	// ---- pass 2: spiral arms, by construction ----
	_placed = 0;
	_guard  = _n_arms * 40;
	while (_placed < _n_arms && _guard > 0) {
		_guard--;
		var _pt = _arm_pt(_ctx);
		if (!_keep(_pt.x, _pt.y, _ctx)) continue;
		if (!_fits(_pt.x, _pt.y, _ctx)) continue;
		array_push(_pts, { x : _pt.x, y : _pt.y });
		_mark(_pt.x, _pt.y, _ctx);
		_placed++;
	}

	// ---- pass 3: halo dust, center-weighted so the middle glows and
	// the density fades gradually toward the rim like a real disc ----
	_placed = 0;
	_guard  = _n_halo * 40;
	while (_placed < _n_halo && _guard > 0) {
		_guard--;
		var _rr = _R * power(random(1), .7);
		var _aa = random(360);
		var _px = _cx + lengthdir_x(_rr, _aa);
		var _py = _cy + lengthdir_y(_rr, _aa);
		if (!_keep(_px, _py, _ctx)) continue;
		if (!_fits(_px, _py, _ctx)) continue;
		array_push(_pts, { x : _px, y : _py });
		_mark(_px, _py, _ctx);
		_placed++;
	}

	// ---- pass 4: island continents, anchored on the arms ----
	var _isl = [];
	_guard = 400;
	while (array_length(_isl) < _cfg.isl_count && _guard > 0) {
		_guard--;
		var _pt = _arm_pt(_ctx);
		if (!_keep(_pt.x, _pt.y, _ctx)) continue;
		// keep centers apart so continents don't stack
		var _ok = true;
		for (var _i = 0; _i < array_length(_isl); _i++)
			if (point_distance(_pt.x, _pt.y, _isl[_i].x, _isl[_i].y) < 420) { _ok = false; break; }
		if (!_ok) continue;
		array_push(_isl, {
			x : _pt.x, y : _pt.y,
			r : random_range(_cfg.isl_r_min, _cfg.isl_r_max),
		});
	}
	_placed = 0;
	_guard  = _n_islands * 40;
	while (_placed < _n_islands && _guard > 0 && array_length(_isl) > 0) {
		_guard--;
		var _is = _isl[irandom(array_length(_isl) - 1)];
		var _rr = (random(1) + random(1)) * .5 * _is.r;
		var _aa = random(360);
		var _sw = _swirl(_is.x + lengthdir_x(_rr, _aa),
		                 _is.y + lengthdir_y(_rr, _aa), _ctx, _cfg.swirl_deg);
		if (!_keep(_sw.x, _sw.y, _ctx)) continue;
		if (!_fits(_sw.x, _sw.y, _ctx)) continue;
		array_push(_pts, { x : _sw.x, y : _sw.y });
		_mark(_sw.x, _sw.y, _ctx);
		_placed++;
	}

	// ---- pass 5: star roads ----
	var _edges = [];
	if (array_length(_isl) > 1) {
		var _linked = [0];
		while (array_length(_linked) < array_length(_isl)) {
			var _best_d = infinity;
			var _best_a = 0;
			var _best_b = 1;
			for (var _i = 0; _i < array_length(_linked); _i++) {
				var _a = _isl[_linked[_i]];
				for (var _j = 0; _j < array_length(_isl); _j++) {
					var _done = false;
					for (var _k = 0; _k < array_length(_linked); _k++)
						if (_linked[_k] == _j) { _done = true; break; }
					if (_done) continue;
					var _d = point_distance(_a.x, _a.y, _isl[_j].x, _isl[_j].y);
					if (_d < _best_d) { _best_d = _d; _best_a = _linked[_i]; _best_b = _j; }
				}
			}
			array_push(_edges, { x1 : _isl[_best_a].x, y1 : _isl[_best_a].y,
			                     x2 : _isl[_best_b].x, y2 : _isl[_best_b].y });
			array_push(_linked, _best_b);
		}
	}
	if (array_length(_isl) > 0) {
		var _ni = 0; var _nd = infinity;
		for (var _i = 0; _i < array_length(_isl); _i++) {
			var _d = point_distance(_cx, _cy, _isl[_i].x, _isl[_i].y);
			if (_d < _nd) { _nd = _d; _ni = _i; }
		}
		array_push(_edges, { x1 : _cx, y1 : _cy, x2 : _isl[_ni].x, y2 : _isl[_ni].y });
	}

	var _path_budget = _n_paths;
	for (var _e = 0; _e < array_length(_edges); _e++) {
		if (_path_budget <= 0) break;
		var _ed    = _edges[_e];
		var _len   = point_distance(_ed.x1, _ed.y1, _ed.x2, _ed.y2);
		var _dir   = point_direction(_ed.x1, _ed.y1, _ed.x2, _ed.y2);
		var _steps = max(2, floor(_len / _cfg.path_step));
		var _bow   = random_range(-1, 1) * _cfg.path_bow;
		for (var _s = 0; _s <= _steps; _s++) {
			if (_path_budget <= 0) break;
			var _t  = _s / _steps;
			var _bx = lerp(_ed.x1, _ed.x2, _t)
			        + lengthdir_x(sin(_t * pi) * _bow + random_range(-1, 1) * _cfg.path_jitter, _dir + 90);
			var _by = lerp(_ed.y1, _ed.y2, _t)
			        + lengthdir_y(sin(_t * pi) * _bow + random_range(-1, 1) * _cfg.path_jitter, _dir + 90);
			var _sw = _swirl(_bx, _by, _ctx, _cfg.swirl_deg);
			// roads may cross gaps: skip only the rim check by testing
			// keep WITHOUT the gap veto would let them bridge voids, but
			// bridges through emptiness are exactly the ff-overworld
			// feel, so roads ignore the noise gaps on purpose
			var _d2 = point_distance(_sw.x, _sw.y, _ctx.cx, _ctx.cy);
			if (_d2 >= _ctx.r) continue;
			if (!_fits(_sw.x, _sw.y, _ctx)) continue;
			array_push(_pts, { x : _sw.x, y : _sw.y });
			_mark(_sw.x, _sw.y, _ctx);
			_path_budget--;
		}
	}

	// ---- pass 6: unique features ----
	var _feat_budget = _n_feats;
	var _per_feat    = max(8, _n_feats div max(1, _cfg.feat_count));
	repeat (_cfg.feat_count) {
		if (_feat_budget <= 0) break;
		var _fr = _R * random_range(.15, .8);
		var _fa = random(360);
		var _fx = _cx + lengthdir_x(_fr, _fa);
		var _fy = _cy + lengthdir_y(_fr, _fa);
		var _type = irandom(2); // 0 ring, 1 arc, 2 stream
		var _n = min(_per_feat, _feat_budget);

		if (_type == 0 || _type == 1) {
			var _rad   = random_range(_cfg.feat_ring_min, _cfg.feat_ring_max);
			var _a0    = random(360);
			var _span  = 360;
			if (_type == 1) _span = random_range(90, 220);
			for (var _s = 0; _s < _n; _s++) {
				var _aa2 = _a0 + (_s / _n) * _span;
				var _rr2 = _rad + random_range(-24, 24); // blurry band,
				                                         // not a wire ring
				var _sw = _swirl(_fx + lengthdir_x(_rr2, _aa2),
				                 _fy + lengthdir_y(_rr2, _aa2), _ctx, _cfg.swirl_deg);
				if (!_keep(_sw.x, _sw.y, _ctx)) continue;
				if (!_fits(_sw.x, _sw.y, _ctx)) continue;
				array_push(_pts, { x : _sw.x, y : _sw.y });
				_mark(_sw.x, _sw.y, _ctx);
				_feat_budget--;
				if (_feat_budget <= 0) break;
			}
		} else {
			var _sx2 = _fx;
			var _sy2 = _fy;
			var _dir2 = random(360);
			repeat (_cfg.feat_stream_steps) {
				if (_feat_budget <= 0) break;
				_dir2 += random_range(-25, 25);
				_sx2 += lengthdir_x(22, _dir2);
				_sy2 += lengthdir_y(22, _dir2);
				repeat (irandom_range(1, 2)) {
					if (_feat_budget <= 0) break;
					var _sw = _swirl(_sx2 + random_range(-26, 26),
					                 _sy2 + random_range(-26, 26), _ctx, _cfg.swirl_deg);
					if (!_keep(_sw.x, _sw.y, _ctx)) continue;
					if (!_fits(_sw.x, _sw.y, _ctx)) continue;
					array_push(_pts, { x : _sw.x, y : _sw.y });
					_mark(_sw.x, _sw.y, _ctx);
					_feat_budget--;
				}
			}
		}
	}

	// ---- wrap positions into full star structs ----
	// size ranges run BROAD: the rarity halo that used to fatten the
	// big stars is gone, so the size spread carries that presence now.
	// colors no longer come from the class (color_set_random() rolls
	// them inside the seeded stream), the class keeps name + size range
	var _classes = [
		{ cls : "M", weight : 40,  lo :  .8, hi : 1.8 },
		{ cls : "K", weight : 22,  lo :  .9, hi : 2.2 },
		{ cls : "G", weight : 15,  lo : 1.0, hi : 2.8 },
		{ cls : "F", weight : 10,  lo : 1.1, hi : 3.4 },
		{ cls : "A", weight : 7,   lo : 1.3, hi : 4.2 },
		{ cls : "B", weight : 4.5, lo : 1.6, hi : 5.4 },
		{ cls : "O", weight : 1.5, lo : 2.0, hi : 7.0 },
	];
	var _rarity_cols = [
		c_rarity_basic,  c_rarity_common,    c_rarity_uncommon, c_rarity_rare,
		c_rarity_epic,   c_rarity_elite,     c_rarity_master,   c_rarity_exotic,
		c_rarity_ancient,c_rarity_legendary, c_rarity_cosmic,   c_rarity_mythic,
		c_rarity_divine, c_rarity_ultimate,
	];

	var _count = array_length(_pts);
	var _stars = array_create(_count);
	for (var _i = 0; _i < _count; _i++) {
		var _roll = random(100);
		var _acc = 0;
		var _ck = 0;
		for (var _k = 0; _k < array_length(_classes); _k++) {
			_acc += _classes[_k].weight;
			if (_roll < _acc) { _ck = _k; break; }
		}
		var _cl = _classes[_ck];

		// rarity climbs with distance from the core: the bulge rolls at
		// the center rate (commons), the rim rolls near the edge rate.
		// rates PAST rarity_base shift the whole ladder up a tier: the
		// calculator's documented base behavior ("lowest rarity falls
		// off, a new one comes in") - it computes that floor internally
		// but returns the raw roll, so the shift is applied here.
		// calculate_rarity() burns global RNG inside the seeded stream,
		// so it stays deterministic
		var _rd = clamp(point_distance(_pts[_i].x, _pts[_i].y, _cx, _cy) / _R, 0, 1);
		var _rrate = lerp(_cfg.rarity_rate_center, _cfg.rarity_rate_edge,
		                  power(_rd, _cfg.rarity_curve));
		var _tier = clamp(floor(_rrate / _cfg.rarity_base)
		                + calculate_rarity(_rrate, _cfg.rarity_scale,
		                  _cfg.rarity_growth, _cfg.rarity_base), 0, 13);

		var _sseed = (_seed ^ ((_i + 1) * 2654435761)) & $7fffffff;
		_stars[_i] = {
			id   : _i,
			x    : _pts[_i].x,
			y    : _pts[_i].y,
			seed : _sseed,
			// fake depth for the map's parallax: .85 (far, drifts slow)
			// to 1.15 (near, drifts fast), deterministic from the seed.
			// renderer AND tap picking both apply it, so stars are
			// clickable exactly where they appear
			d    : .85 + .3 * ((_sseed mod 997) / 997),
			props : {
				// nameless at birth: names are the slowest part of
				// generation, so scr_star_get_name() rolls them lazily
				// (and deterministically, from the star's .seed) the
				// first time anything asks
				name          : "",
				stellar_class : _cl.cls,
				color         : color_set_random(), // seeded stream: deterministic
				size          : random_range(_cl.lo, _cl.hi),
				rarity        : _tier,
				rarity_color  : _rarity_cols[_tier],
				// interior hooks, design not final: generate from .seed
				// when the interior system lands
				resources   : undefined,
				hazards     : undefined,
				inhabitants : undefined,
			},
		};
	}

	// ---- regions: nms-style named neighborhoods ----
	// centers picked from the stars themselves (kept apart), then every
	// star joins its nearest center: spatial voronoi over the galaxy.
	// star.props.region holds the id; scr_star_get_region() resolves it
	var _rcount = max(1, round(_count / _cfg.region_stars));
	var _regions = [];
	var _rguard = _rcount * 80;
	while (array_length(_regions) < _rcount && _rguard > 0) {
		_rguard--;
		var _cand = _stars[irandom(_count - 1)];
		var _rok = true;
		for (var _i = 0; _i < array_length(_regions); _i++)
			if (point_distance(_cand.x, _cand.y, _regions[_i].x, _regions[_i].y) < _cfg.region_min_sep) { _rok = false; break; }
		if (!_rok) continue;
		array_push(_regions, {
			id    : array_length(_regions),
			name  : galaxy_region_name(),
			x     : _cand.x,
			y     : _cand.y,
			count : 0,
		});
	}
	for (var _i = 0; _i < _count; _i++) {
		var _best = 0;
		var _bd = infinity;
		for (var _k = 0; _k < array_length(_regions); _k++) {
			var _d = point_distance(_stars[_i].x, _stars[_i].y, _regions[_k].x, _regions[_k].y);
			if (_d < _bd) { _bd = _d; _best = _k; }
		}
		_stars[_i].props.region = _best;
		_regions[_best].count += 1;
	}

	// ---- nebula density grid ----
	// coarse count of stars per region, softly blurred: the renderers
	// splat additive glow from this, which is what makes the map read
	// as a luminous galaxy instead of scattered points
	var _ngw = 64;
	var _ncell = _w / _ngw;
	var _ngrid = array_create(_ngw * _ngw, 0);
	for (var _i = 0; _i < _count; _i++) {
		var _gx2 = clamp(floor(_stars[_i].x / _ncell), 0, _ngw - 1);
		var _gy2 = clamp(floor(_stars[_i].y / _ncell), 0, _ngw - 1);
		_ngrid[_gx2 + _gy2 * _ngw] += 1;
	}
	// one 3x3 blur pass so the light bleeds past hard cell edges
	var _nblur = array_create(_ngw * _ngw, 0);
	for (var _gy2 = 0; _gy2 < _ngw; _gy2++)
	for (var _gx2 = 0; _gx2 < _ngw; _gx2++) {
		var _acc = _ngrid[_gx2 + _gy2 * _ngw] * 4;
		var _wt  = 4;
		for (var _j = max(0, _gy2 - 1); _j <= min(_ngw - 1, _gy2 + 1); _j++)
		for (var _i = max(0, _gx2 - 1); _i <= min(_ngw - 1, _gx2 + 1); _i++) {
			if (_i == _gx2 && _j == _gy2) continue;
			_acc += _ngrid[_i + _j * _ngw];
			_wt  += 1;
		}
		_nblur[_gx2 + _gy2 * _ngw] = _acc / _wt;
	}
	var _nmax = 1;
	for (var _i = 0; _i < _ngw * _ngw; _i++) _nmax = max(_nmax, _nblur[_i]);

	// ---- draw grid: spatial buckets for the renderer and picker ----
	// cell -> array of star indices. scr_star_visible() queries only
	// the cells the camera's (parallax-padded) view rect touches, so
	// per-frame cost tracks what's VISIBLE, not the population: the
	// 10k map iterates a few hundred stars, not ten thousand
	var _dcell = 300;
	var _dgw = ceil(_w / _dcell);
	var _dgh = ceil(_h / _dcell);
	var _dgrid = array_create(_dgw * _dgh, 0);
	for (var _i = 0; _i < _dgw * _dgh; _i++) _dgrid[_i] = [];
	for (var _i = 0; _i < _count; _i++) {
		var _gx2 = clamp(floor(_stars[_i].x / _dcell), 0, _dgw - 1);
		var _gy2 = clamp(floor(_stars[_i].y / _dcell), 0, _dgh - 1);
		array_push(_dgrid[_gx2 + _gy2 * _dgw], _i);
	}

	g.starmap = {
		seed   : _seed,
		name   : gen_name_planet() + " galaxy", // the whole galaxy's name
		width  : _w,
		height : _h,
		cx     : _cx,
		cy     : _cy,
		gal_r  : _R,
		count  : _count,
		stars  : _stars,
		regions : _regions,
		// nebula glow data
		ngrid  : _nblur,
		ngw    : _ngw,
		ncell  : _ncell,
		nmax   : _nmax,
		// draw grid (spatial buckets)
		dgrid  : _dgrid,
		dgw    : _dgw,
		dgh    : _dgh,
		dcell  : _dcell,
	};

	rng_release(_rs0);
	show("starmap generated > seed " + string(_seed) + ", " + string(_count) + " stars");
	return g.starmap;
}
