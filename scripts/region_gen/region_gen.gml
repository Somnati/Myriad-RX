/// @description region_gen(seed, biome, lv, [ri], [pn]) -> a region { seed, lv, nodes, edges, landing, name, spot, wild }
/// THE REGION GRAPH (his pitch, 2026-09-14): a connection of nodes with
/// distances between them. Seeded from the world's seed, so a world
/// always has the same region, the same towns, the same names - the
/// continuity his pitch wants. ONE region a world for now.
///   nodes  [{ i, kind, name, x, y }]  x / y in 0..1 (the map scales them)
///   edges  [{ a, b, d }]  d = the walk between, in HOURS (1..~14)
///   landing = the landing zone's index (a node on the left edge)
/// The roll (round three, 2026-09-15): 12..17 nodes GROWN from the landing
/// zone inside a circle (each off one before it, .15 clear of the rest -
/// a tree), then 1-3 settled places (settlement / village / town / a city
/// at most once), 1-3 dungeons (a crypt now and then), 1-3 camps, the
/// wild from the terrain for the rest; ONE landing zone, now and then
/// inside a town; the tree's roads plus a few BRIDGES that cross nothing
/// (loops with dead ends left over), isles off the coasts by boat; every
/// road a polyline bent by the land at its ends (edge.pts). Medieval,
/// all of it: the civilisation is his call.
function region_gen(_seed, _biome, _lv, _ri = 0, _pn = undefined) {
	var _old = random_get_seed();
	var _bi = exped_biomes()[_biome].name;
	var _wild = ["field", "forest", "hills", "marsh"];   // living: blue water, green grass
	switch (_bi) {
		case "stone":  _wild = ["hills", "mountains", "mine", "ruin", "desert"]; break;
		case "ruined": _wild = ["ruin", "marsh", "forest", "shrine", "hills"]; break;
		case "ice":    _wild = ["tundra", "hills", "mountains", "ruin", "field"]; break;
		// the biomes pass (2026-09-15)
		case "ash":    _wild = ["mountains", "hills", "desert", "mine", "ruin"]; break;
		case "ocean":  _wild = ["coast", "isle", "marsh", "field", "hills"]; break;
		case "dust":   _wild = ["desert", "hills", "mine", "ruin", "coast"]; break;
		case "fungal": _wild = ["forest", "marsh", "field", "shrine", "hills"]; break;
	}
	// THE SPOT (his ask, 2026-09-15: "the lv1 zone is out in the ocean... it
	// needs to be aware of where on the planet has what type of biome"): a
	// third of the globe a region, the first ON LAND the sampler finds
	// (planet_texel - the texel the shader draws there: u = lon / 360 + .5,
	// v = (90 - lat) / 180, sphere_uv's mapping), and THE WILD IS WHAT
	// GROWS THERE - the terrain around the spot, tallied into the list the
	// wild nodes draw from (a marsh only where there is swamp). Its own
	// stream, so the node roll below is what it always was
	random_set_seed((_seed ^ 7331) & $7fffffff);
	var _spot = { lon : _ri * 120 + random_range(-40, 40), lat : random_range(-35, 35) };
	var _tw = [];
	if (is_struct(_pn) && is_struct(_pn[$ "smp"]) && _pn.kind == "rock") {
		var _ps = _pn.smp;
		var _try = 0, _found = false;
		// THE STARTER IS GREEN (his ask, 2026-09-15: "a grassy field / forest
		// region"): the first region's spot must land on grass or forest -
		// sixty tries for that, then any land will do (a world with no green)
		while (_try < 120 && !_found) {
			_try += 1;
			var _clon = _ri * 120 + random_range(-55, 55), _clat = random_range(-48, 48);
			planet_texel(_ps, frac(_clon / 360 + .5 + 1), (90 - _clat) / 180);
			var _ob = _ps.ob;
			// water, shallows and the ice sheets are no place to land; the peaks neither
			if (_ob == 0 || _ob == 1 || _ob == 11 || _ob == 25 || _ob == 14 || _ob == 9 || _ob == 10) continue;
			// THE LADDER (his call, 2026-09-15): the first reach green (grass, forest,
			// jungle), the second a MARSH (swamp), the third a DESERT (desert, salt flat)
			if (_try <= 60) {
				if (_ri == 0 && !(_ob == 4 || _ob == 5 || _ob == 6 || _ob == 21 || _ob == 22)) continue;
				if (_ri == 1 && _ob != 12) continue;
				if (_ri == 2 && !(_ob == 3 || _ob == 13 || _ob == 23 || _ob == 24)) continue;
			}
			_spot = { lon : _clon, lat : _clat };
			_found = true;
		}
		// the terrain around it: sixteen samples within six degrees
		var _map = function(_b) {
			switch (_b) {
				case 2: return "coast";
				case 3: case 13: case 24: return "desert";
				case 4: case 21: return "field";
				case 5: case 6: case 22: return "forest";
				case 23: return "hills";
				case 7: case 8: case 14: return "tundra";
				case 9: case 10: case 18: return "mountains";
				case 12: return "marsh";
				case 15: case 16: case 17: return "hills";
			}
			return "";
		};
		repeat (16) {
			var _slon = _spot.lon + random_range(-6, 6), _slat = clamp(_spot.lat + random_range(-6, 6), -89, 89);
			planet_texel(_ps, frac(_slon / 360 + .5 + 1), (90 - _slat) / 180);
			var _wk = _map(_ps.ob);
			if (_wk != "") array_push(_tw, _wk);
		}
		// ...and each keeps only its own kinds: the first reach green (fields,
		// forests, hills, a coast), the second marsh-heavy (marshes, forests,
		// fields, a coast), the third desert (deserts, hills, mountains)
		if (_ri <= 2) {
			var _keep = (_ri == 0) ? ["field", "forest", "hills", "coast"] : ((_ri == 1) ? ["marsh", "forest", "field", "coast", "hills"] : ["desert", "hills", "mountains", "coast"]);
			var _tg = [];
			for (var _gi = 0; _gi < array_length(_tw); _gi++) if (array_contains(_keep, _tw[_gi])) array_push(_tg, _tw[_gi]);
			if (_ri == 1) array_push(_tg, "marsh", "marsh", "marsh");       // (the marsh is the region)
			if (_ri == 2) array_push(_tg, "desert", "desert", "desert");    // (the desert is the region)
			if (array_length(_tg) == 0) _tg = (_ri == 0) ? ["field", "forest"] : ((_ri == 1) ? ["marsh", "forest"] : ["desert", "hills"]);
			_tw = _tg;
		}
		if (array_length(_tw) > 0) {
			array_push(_tw, "hills");   // (a floor of variety: every land has a rise somewhere)
			// the biome family's specials keep a seat (mines, ruins, shrines)
			// (ruins everywhere - his ask, 2026-09-15 - and each family's specials)
			array_push(_tw, "ruin");
			switch (_bi) {
				case "stone":  array_push(_tw, "mine"); break;
				case "ruined": array_push(_tw, "ruin", "shrine"); break;
				case "ice":    break;
				case "ash":    array_push(_tw, "mine"); break;
				case "dust":   array_push(_tw, "ruin"); break;
				case "fungal": array_push(_tw, "shrine"); break;
				default:       if (random(1) < .4) array_push(_tw, "shrine"); break;
			}
			_wild = _tw;
		}
	}
	random_set_seed((_seed ^ 48271) & $7fffffff);
	var _n = irandom_range(12, 17);
	var _nodes = [];
	// THE PLACEMENT (his ask, 2026-09-15: "bounded by a circular radius...
	// start generating from the landing zone and branch out"): the landing
	// zone near the middle, then every place GROWN off one already there -
	// a step of .16-.24 in a direction leaning away from its parent, inside
	// the circle (radius .46 about the centre), .15 clear of everything -
	// so the region is a tree from the landing; the bridges below close it
	// into loops. Each node remembers its parent (the road it grew along)
	var _R = .46, _cx0 = .5, _cy0 = .5;
	var _la = random(360), _ld = random_range(0, .22);
	array_push(_nodes, { i : 0, kind : "landing", name : "the landing zone", x : _cx0 + lengthdir_x(_ld, _la), y : _cy0 + lengthdir_y(_ld, _la), par : -1, kids : 0, landing : true });
	var _tries = 0;
	while (array_length(_nodes) < _n && _tries < 900) {
		_tries += 1;
		// a parent: the frontier first (few children), any at a pinch
		var _pi = -1, _pw = 0;
		for (var _i = 0; _i < array_length(_nodes); _i++) { var _wgt = 1 / (1 + _nodes[_i].kids * 1.6); _pw += _wgt; if (random(_pw) < _wgt) _pi = _i; }
		if (_pi < 0) _pi = 0;
		var _par = _nodes[_pi];
		var _dir = random(360);
		if (_par.par >= 0) { var _gp = _nodes[_par.par]; _dir = point_direction(_gp.x, _gp.y, _par.x, _par.y) + random_range(-75, 75); }
		var _len = random_range(.16, .24);
		var _x = _par.x + lengthdir_x(_len, _dir), _y = _par.y + lengthdir_y(_len, _dir);
		if (point_distance(_x, _y, _cx0, _cy0) > _R) continue;
		var _ok = true;
		for (var _i = 0; _i < array_length(_nodes) && _ok; _i++) if (point_distance(_x, _y, _nodes[_i].x, _nodes[_i].y) < .15) _ok = false;
		if (!_ok) continue;
		array_push(_nodes, { i : array_length(_nodes), kind : "", name : "", x : _x, y : _y, par : _pi, kids : 0, landing : false });
		_par.kids += 1;
	}
	_n = array_length(_nodes);
	// THE KINDS (his spec, 2026-09-15): 1-3 settled places, 1-3 dungeons,
	// 1-3 bandit camps, 1-2 landing zones - each next one rarer (a second
	// at 50%, a third at 25%; a second landing at 35%) - and the rest is
	// the wild. The first landing zone is node 0 (the left edge)
	var _slots = [];
	for (var _i = 1; _i < _n; _i++) array_push(_slots, _i);
	array_shuffle_ext(_slots);
	var _must = [];
	var _nciv = 1 + ((random(1) < .5) ? 1 : 0) + ((random(1) < .25) ? 1 : 0);
	var _ndun = 1 + ((random(1) < .5) ? 1 : 0) + ((random(1) < .25) ? 1 : 0);
	var _ncmp = 1 + ((random(1) < .5) ? 1 : 0) + ((random(1) < .25) ? 1 : 0);
	if (_ri == 0) _ncmp = 1;   // THE STARTER IS PEACEFUL (his ask, 2026-09-15: "i want the first region to be peaceful"): one camp at most (the rolls above still go, so the rest holds)
	var _nlnd = 0;   // ONE landing zone a region (his call, 2026-09-15)
	var _city = false;
	repeat (_nciv) {
		var _r = random(100);
		var _k = "settlement";
		if (_r < 45) _k = "settlement"; else if (_r < 70) _k = "village"; else if (_r < 90) _k = "town"; else if (!_city) { _k = "city"; _city = true; } else _k = "town";
		array_push(_must, _k);
	}
	repeat (_ndun) array_push(_must, (random(1) < .3) ? "crypt" : "dungeon");   // (a crypt: a dungeon of the dead, 2026-09-15)
	repeat (_ncmp) array_push(_must, "camp");
	// SOMETIMES THE LANDING ZONE IS INSIDE A TOWN (his ask): node 0 takes a
	// settled kind of its own, keeping its landing flag; the must-list gives
	// one up so the count holds
	var _lz_in = (random(1) < .3);
	if (_lz_in) { _nodes[0].kind = (random(1) < .3 && !_city) ? "city" : "town"; if (_nodes[0].kind == "city") _city = true; if (array_length(_must) > 0) array_delete(_must, 0, 1); }
	// CIVILIZATION BY LEVEL (his call, 2026-09-16: "early regions will have
	// settlements, then lv 3s can spawn towns, lv 10s cities... a pool bound
	// by region level"): the rolls above stand (the stream is the same), the
	// kind is CAPPED - a village from level 2, a town from 3, a city from 10
	var _cap = function(_k, _lv2) {
		if (_k == "city" && _lv2 < 10)   _k = "town";
		if (_k == "town" && _lv2 < 3)    _k = "village";
		if (_k == "village" && _lv2 < 2) _k = "settlement";
		return _k;
	};
	for (var _mi = 0; _mi < array_length(_must); _mi++) _must[_mi] = _cap(_must[_mi], _lv);
	if (_nodes[0].kind != "landing") _nodes[0].kind = _cap(_nodes[0].kind, _lv);
	var _si = 0;
	for (; _si < array_length(_must) && _si < array_length(_slots); _si++) _nodes[_slots[_si]].kind = _must[_si];
	for (; _si < array_length(_slots); _si++) _nodes[_slots[_si]].kind = _wild[irandom(array_length(_wild) - 1)];
	// CAMPS AWAY FROM TOWNS (his ask, 2026-09-15): a camp within .22 of a
	// settled place swaps kinds with the wild node farthest from any
	var _civn = [];
	for (var _i = 1; _i < _n; _i++) { var _kd0 = region_kinds()[$ _nodes[_i].kind]; if (is_struct(_kd0) && _kd0.civ) array_push(_civn, _i); }
	for (var _i = 1; _i < _n; _i++) {
		if (_nodes[_i].kind != "camp") continue;
		var _near = 9;
		for (var _j = 0; _j < array_length(_civn); _j++) _near = min(_near, point_distance(_nodes[_i].x, _nodes[_i].y, _nodes[_civn[_j]].x, _nodes[_civn[_j]].y));
		if (_near >= .22) continue;
		var _best = -1, _bd = -1;
		for (var _w2 = 1; _w2 < _n; _w2++) {
			var _kd2 = region_kinds()[$ _nodes[_w2].kind];
			if (!is_struct(_kd2) || !_kd2.wild) continue;
			var _dm = 9;
			for (var _j = 0; _j < array_length(_civn); _j++) _dm = min(_dm, point_distance(_nodes[_w2].x, _nodes[_w2].y, _nodes[_civn[_j]].x, _nodes[_civn[_j]].y));
			if (_dm > _bd) { _bd = _dm; _best = _w2; }
		}
		if (_best >= 0 && _bd > _near) { var _kk3 = _nodes[_best].kind; _nodes[_best].kind = "camp"; _nodes[_i].kind = _kk3; }
	}
	var _landings = [0];
	if (_nodes[0].kind != "landing") _nodes[0].name = region_name(_nodes[0].kind);   // (a town with the landing zone inside it)
	for (var _i = 1; _i < _n; _i++) _nodes[_i].name = region_name(_nodes[_i].kind);
	// A DUNGEON HAS ITS ROOMS (his ask, 2026-09-15: "dungeons seeded with a
	// fixed number of rooms"): 3-6, off the seed by hash (no roll - the
	// worlds stay the worlds they were); the delve and the clear quest read it
	for (var _i = 0; _i < _n; _i++) if (_nodes[_i].kind == "dungeon" || _nodes[_i].kind == "crypt") _nodes[_i].rooms = 3 + (hash_mix(_seed, _i * 31 + 7) mod 4);
	// THE ROADS: the tree's (every place to the one it grew from), then
	// BRIDGES - a few near pairs joined where the new road crosses none,
	// so the tree closes into loops with dead-end spurs left over (his
	// ask: a main loop with splits and some dead ends)
	var _edges = [];
	var _has = function(_edges, _a, _b) {
		for (var _e = 0; _e < array_length(_edges); _e++) if ((_edges[_e].a == _a && _edges[_e].b == _b) || (_edges[_e].a == _b && _edges[_e].b == _a)) return true;
		return false;
	};
	// do two segments cross (not at a shared end)?
	var _cross = function(_p1, _p2, _p3, _p4) {
		var _d = (_p2.x - _p1.x) * (_p4.y - _p3.y) - (_p2.y - _p1.y) * (_p4.x - _p3.x);
		if (abs(_d) < .000001) return false;
		var _t = ((_p3.x - _p1.x) * (_p4.y - _p3.y) - (_p3.y - _p1.y) * (_p4.x - _p3.x)) / _d;
		var _u = ((_p3.x - _p1.x) * (_p2.y - _p1.y) - (_p3.y - _p1.y) * (_p2.x - _p1.x)) / _d;
		return (_t > .02 && _t < .98 && _u > .02 && _u < .98);
	};
	for (var _i = 1; _i < _n; _i++) if (_nodes[_i].par >= 0) array_push(_edges, { a : _nodes[_i].par, b : _i, d : 0, pts : [] });
	var _cands = [];
	for (var _i = 0; _i < _n; _i++) for (var _j = _i + 1; _j < _n; _j++) {
		if (_has(_edges, _i, _j)) continue;
		var _dd = point_distance(_nodes[_i].x, _nodes[_i].y, _nodes[_j].x, _nodes[_j].y);
		if (_dd < .30) array_push(_cands, { a : _i, b : _j, d : _dd });
	}
	array_shuffle_ext(_cands);
	var _nbr = clamp(2 + irandom(2), 0, array_length(_cands));
	for (var _c = 0; _c < array_length(_cands) && _nbr > 0; _c++) {
		var _cd = _cands[_c];
		var _clear = true;
		for (var _e = 0; _e < array_length(_edges) && _clear; _e++) {
			var _ed = _edges[_e];
			if (_ed.a == _cd.a || _ed.a == _cd.b || _ed.b == _cd.a || _ed.b == _cd.b) continue;
			if (_cross(_nodes[_cd.a], _nodes[_cd.b], _nodes[_ed.a], _nodes[_ed.b])) _clear = false;
		}
		if (!_clear) continue;
		array_push(_edges, { a : _cd.a, b : _cd.b, d : 0, pts : [] });
		_nbr -= 1;
	}
	// THE ISLES (his ask): off a coast, one place out to sea - a boat road
	for (var _i = _n - 1; _i >= 1; _i--) {
		if (_nodes[_i].kind != "coast" || random(1) > .45) continue;
		var _od = point_direction(_cx0, _cy0, _nodes[_i].x, _nodes[_i].y) + random_range(-40, 40);
		var _ol = random_range(.13, .19);
		var _ix = _nodes[_i].x + lengthdir_x(_ol, _od), _iy = _nodes[_i].y + lengthdir_y(_ol, _od);
		if (point_distance(_ix, _iy, _cx0, _cy0) > _R + .05) continue;
		var _iok = true;
		for (var _j = 0; _j < array_length(_nodes) && _iok; _j++) if (point_distance(_ix, _iy, _nodes[_j].x, _nodes[_j].y) < .12) _iok = false;
		if (!_iok) continue;
		array_push(_nodes, { i : array_length(_nodes), kind : "isle", name : region_name("isle"), x : _ix, y : _iy, par : _i, kids : 0, landing : false, boat : true });
		array_push(_edges, { a : _i, b : array_length(_nodes) - 1, d : 0, pts : [], boat : true });
	}
	// THE SEWERS (his ask, 2026-09-16): under every city, and under a town in the
	// odd case - a place of its own a short road off the settled one, a dungeon
	// of the town's vermin (region_kinds "sewer"; the quests that want a dungeon
	// take it too)
	for (var _i = _n - 1; _i >= 0; _i--) {
		var _sk = _nodes[_i].kind;
		if (_sk != "city" && !(_sk == "town" && random(1) < .45)) continue;
		var _sd = random(360), _sl = random_range(.06, .09);
		var _sx = _nodes[_i].x + lengthdir_x(_sl, _sd), _sy = _nodes[_i].y + lengthdir_y(_sl, _sd);
		var _sok = (point_distance(_sx, _sy, _cx0, _cy0) <= _R + .02);
		for (var _j = 0; _j < array_length(_nodes) && _sok; _j++) if (point_distance(_sx, _sy, _nodes[_j].x, _nodes[_j].y) < .05) _sok = false;
		if (!_sok) continue;
		array_push(_nodes, { i : array_length(_nodes), kind : "sewer", name : region_name("sewer"), x : _sx, y : _sy, par : _i, kids : 0, landing : false });
		array_push(_edges, { a : _i, b : array_length(_nodes) - 1, d : 0, pts : [] });
	}
	_n = array_length(_nodes);
	// THE BENT ROADS (his ask: "procedural curves and corners based off the
	// type of biome"; round two 2026-09-15: "not zig zaggy literally... more
	// dynamic pathing"): every road is a polyline - points along it pushed
	// sideways by the land at its ends: a BOW of one to two waves (a bend,
	// an S, a double bend - by hash, no roll) plus a soft wobble, the
	// amplitude by the land: mountains wind wide, hills less, marsh and
	// forest wander, fields and coasts barely bend, a boat road runs
	// straight. The hours follow the bent length
	// THE GRAMMARS (his call, 2026-09-15: "dynamic pathing based on the
	// biome", not a sawtooth and not one bow for everything): rank = which
	// end's land shapes the road (a pass beats a marsh beats hills...)
	var _bend = function(_k) {
		switch (_k) {
			case "mountains": return { amp : .05,  n : 10, gram : "pass",   rank : 5 };   // switchbacks: two or three hairpins on long legs
			case "marsh":     return { amp : .04,  n : 6,  gram : "marsh",  rank : 4 };   // wide detours, as if round the pools
			case "hills":     return { amp : .035, n : 8,  gram : "hills",  rank : 3 };   // a lazy S
			case "forest":    return { amp : .03,  n : 6,  gram : "wander", rank : 2 };   // a wandering line, no bow
			case "desert": case "tundra": case "field": case "coast": return { amp : .012, n : 4, gram : "straight", rank : 1 };
		}
		return { amp : .018, n : 5, gram : "straight", rank : 1 };
	};
	for (var _e = 0; _e < array_length(_edges); _e++) {
		var _ed = _edges[_e];
		var _ea = _nodes[_ed.a], _eb = _nodes[_ed.b];
		var _ba = _bend(_ea.kind), _bb = _bend(_eb.kind);
		var _pts = [ { x : _ea.x, y : _ea.y } ];
		if (!(_ed[$ "boat"] ?? false)) {
			var _bg = (_ba.rank >= _bb.rank) ? _ba : _bb;   // the land that shapes this road
			var _np = _bg.n;
			var _dx = _eb.x - _ea.x, _dy = _eb.y - _ea.y;
			var _len = point_distance(_ea.x, _ea.y, _eb.x, _eb.y);
			var _nx = -_dy / max(.0001, _len), _ny = _dx / max(.0001, _len);
			var _sgn = choose(1, -1), _prev = 0;
			var _hv = hash_mix(_seed, _e * 13 + 5);
			var _turns = 2 + (_hv mod 2);                 // a pass: two or three hairpins
			var _wv = 1 + ((_hv >> 3) mod 2);             // a marsh: one or two detours
			for (var _k = 1; _k < _np; _k++) {
				var _t = _k / _np;
				var _nz = _prev * .5 + random_range(-1, 1) * .5; _prev = _nz;   // (one roll a point, as before - the stream holds)
				var _env = sin(_t * pi);                                        // (pinned at both ends)
				var _off = 0;
				switch (_bg.gram) {
					case "pass": {
						// switchbacks: a triangle wave of `_turns` legs under a flat-topped
						// envelope - long straight legs, sharp reversals, the hairpins of a pass
						var _ph = frac(_t * _turns * .5 + .25);
						var _tri = 4 * abs(_ph - .5) - 1;   // -1..1, straight legs
						_off = _sgn * _bg.amp * _tri * clamp(_env * 1.7, 0, 1) + _nz * _bg.amp * .12;
						break;
					}
					case "hills":    _off = _sgn * _bg.amp * sin(_t * pi * 1.5) * _env + _nz * _bg.amp * .3; break;   // a lazy S
					case "wander":   _off = _nz * _bg.amp * 1.6 * _env; break;                                       // the noise IS the road
					case "marsh":    _off = _sgn * _bg.amp * sin(_t * pi * _wv) * _env + _nz * _bg.amp * .35; break;   // wide detours
					default:         _off = _sgn * _bg.amp * .8 * _env * sin(_t * pi) + _nz * _bg.amp * .3; break;    // near straight
				}
				array_push(_pts, { x : _ea.x + _dx * _t + _nx * _off, y : _ea.y + _dy * _t + _ny * _off });
			}
		}
		array_push(_pts, { x : _eb.x, y : _eb.y });
		_ed.pts = _pts;
		var _pl = 0;
		for (var _k = 1; _k < array_length(_pts); _k++) _pl += point_distance(_pts[_k - 1].x, _pts[_k - 1].y, _pts[_k].x, _pts[_k].y);
		_ed.d = max(1, round(_pl * 14 * ((_ed[$ "boat"] ?? false) ? 1.5 : 1)));
	}
	// the region's name and its SPOT on the world (his ask: a region is a
	// spot on the planet - lon / lat, a third of the globe apart)
	// THE REGION'S NAME (the region-names pass, 2026-09-15): off the land it
	// mostly is - the commonest wild kind among its places - region_title
	var _kct = {}, _kbest = "", _kn = 0, _kkr = region_kinds();
	for (var _i = 0; _i < array_length(_nodes); _i++) {
		var _nk = _nodes[_i].kind, _nkd = _kkr[$ _nk];
		if (!is_struct(_nkd) || !_nkd.wild || _nk == "ruin" || _nk == "shrine" || _nk == "mine") continue;
		_kct[$ _nk] = (_kct[$ _nk] ?? 0) + 1;
		if (_kct[$ _nk] > _kn) { _kn = _kct[$ _nk]; _kbest = _nk; }
	}
	var _rname = region_title(_kbest);
	// THE MOOD (his ask, 2026-09-15: "a single word... war torn, peaceful,
	// prosperous"): read off what is here
	var _mciv = 0, _mcmp = 0, _mdun = 0, _mruin = 0, _mcity = false;
	for (var _i = 1; _i < _n; _i++) {
		var _mk = _nodes[_i].kind;
		var _mkd = region_kinds()[$ _mk];
		if (is_struct(_mkd) && _mkd.civ) _mciv++;
		if (_mk == "city") _mcity = true;
		if (_mk == "camp") _mcmp++;
		if (_mk == "dungeon" || _mk == "crypt") _mdun++;
		if (_mk == "ruin") _mruin++;
	}
	// ...rated 0..3 (mood_t: the word's colour) and worded from a pool
	// (his ask: variety); the starter (ri 0) always reads calm
	var _mood = "quiet", _mood_t = 0;
	// (the pools grown 2026-09-15 - his ask: more words; one roll each, as before)
	if (_ri == 0)                              { _mood = _mcity ? choose("prosperous", "thriving", "well-off", "bustling", "comfortable") : choose("peaceful", "calm", "untroubled", "gentle", "easy", "sunlit", "content", "unhurried"); _mood_t = 0; }
	else if (_mcmp >= 3)                       { _mood = choose("war torn", "overrun", "in flames", "lost to bandits", "ravaged", "bleeding"); _mood_t = 3; }
	else if (_mciv >= 2 && _mcmp >= 2)         { _mood = choose("at war", "besieged", "embattled", "under siege", "on edge", "fortified"); _mood_t = 3; }
	else if (_mcmp >= 2 && _mcmp >= _mciv)     { _mood = choose("lawless", "bandit-ridden", "outlaw country", "rough", "ungoverned", "wild"); _mood_t = 2; }
	else if (_mcity && _mcmp <= 1)             { _mood = choose("prosperous", "thriving", "wealthy", "busy", "bustling", "well-fed"); _mood_t = 0; }
	else if (_mdun >= 3)                       { _mood = choose("haunted", "cursed", "ill-omened", "grave-quiet", "uneasy", "restless dead"); _mood_t = 2; }
	else if (_mruin >= 2)                      { _mood = choose("ruined", "forsaken", "fallen", "abandoned", "long-emptied", "overgrown"); _mood_t = 2; }
	else if (_mciv >= 3)                       { _mood = choose("peaceful", "settled", "gentle", "tidy", "orderly", "well-kept", "homely"); _mood_t = 0; }
	else if (_mciv == 1 && _mdun <= 1)         { _mood = choose("remote", "lonely", "quiet", "far-flung", "out of the way", "sparse", "hushed"); _mood_t = 1; }
	else                                       { _mood = choose("quiet", "sleepy", "untroubled", "calm", "drowsy", "still", "backwater", "mild"); _mood_t = 0; }
	// the distinct wild kinds here (the planet window lists them)
	var _wk2 = [];
	for (var _i = 0; _i < array_length(_wild); _i++) if (!array_contains(_wk2, _wild[_i])) array_push(_wk2, _wild[_i]);
	rng_release(_old);
	return { seed : _seed, lv : _lv, ri : _ri, name : _rname, spot : _spot, nodes : _nodes, edges : _edges, landing : 0, landings : _landings, biome : _bi,
	         nciv : _nciv, ndun : _ndun, ncmp : _ncmp, wild : _wk2, mood : _mood, mood_t : _mood_t, radius : _R, cx : _cx0, cy : _cy0 };
}
