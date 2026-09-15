/// @description region_gen(seed, biome, lv) -> a region { seed, lv, nodes, edges, landing, name }
/// THE REGION GRAPH (his pitch, 2026-09-14): a connection of nodes with
/// distances between them. Seeded from the world's seed, so a world
/// always has the same region, the same towns, the same names - the
/// continuity his pitch wants. ONE region a world for now.
///   nodes  [{ i, kind, name, x, y }]  x / y in 0..1 (the map scales them)
///   edges  [{ a, b, d }]  d = the walk between, in HOURS (1..~14)
///   landing = the landing zone's index (a node on the left edge)
/// The roll: 12..17 nodes placed by rejection (no two closer than .17);
/// the landing zone first; then 1-3 settled places (settlement / village
/// / town / a city at most once), 1-3 dungeons, 1-3 camps, maybe a second
/// landing zone (his spec, 2026-09-15: "each consecutive one being
/// rarer"), the wilderness from the biome's list for the rest.
/// Edges: every node to its nearest, to its second nearest half the
/// time (so branches end in dead ends), then the graph is stitched
/// connected (union-find, nearest pair across components). Medieval,
/// all of it: the civilisation is his call.
function region_gen(_seed, _biome, _lv, _ri = 0) {
	var _old = random_get_seed();
	random_set_seed((_seed ^ 48271) & $7fffffff);
	var _bi = exped_biomes()[_biome].name;
	var _wild = ["field", "forest", "hills", "marsh"];   // living: blue water, green grass
	switch (_bi) {
		case "stone":  _wild = ["hills", "mountains", "mine", "ruin", "desert"]; break;
		case "ruined": _wild = ["ruin", "marsh", "forest", "shrine", "hills"]; break;
		case "ice":    _wild = ["tundra", "hills", "mountains", "ruin", "field"]; break;
	}
	var _n = irandom_range(12, 17);
	var _nodes = [];
	// the landing zone, on the left edge
	array_push(_nodes, { i : 0, kind : "landing", name : "the landing zone", x : random_range(.04, .10), y : random_range(.3, .7) });
	// the rest of the places, by rejection
	var _tries = 0;
	while (array_length(_nodes) < _n && _tries < 600) {
		_tries += 1;
		var _x = random_range(.08, .96), _y = random_range(.08, .92);
		var _ok = true;
		for (var _i = 0; _i < array_length(_nodes) && _ok; _i++)
			if (point_distance(_x, _y, _nodes[_i].x, _nodes[_i].y) < .17) _ok = false;
		if (_ok) array_push(_nodes, { i : array_length(_nodes), kind : "", name : "", x : _x, y : _y });
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
	var _nlnd = ((random(1) < .35) ? 1 : 0);
	var _city = false;
	repeat (_nciv) {
		var _r = random(100);
		var _k = "settlement";
		if (_r < 45) _k = "settlement"; else if (_r < 70) _k = "village"; else if (_r < 90) _k = "town"; else if (!_city) { _k = "city"; _city = true; } else _k = "town";
		array_push(_must, _k);
	}
	repeat (_ndun) array_push(_must, "dungeon");
	repeat (_ncmp) array_push(_must, "camp");
	repeat (_nlnd) array_push(_must, "landing");
	var _si = 0;
	for (; _si < array_length(_must) && _si < array_length(_slots); _si++) _nodes[_slots[_si]].kind = _must[_si];
	for (; _si < array_length(_slots); _si++) _nodes[_slots[_si]].kind = _wild[irandom(array_length(_wild) - 1)];
	var _landings = [0];
	for (var _i = 1; _i < _n; _i++) if (_nodes[_i].kind == "landing") array_push(_landings, _i);
	for (var _i = 1; _i < _n; _i++) _nodes[_i].name = (_nodes[_i].kind == "landing") ? ("the " + choose("second", "far", "high", "old", "north") + " landing") : region_name(_nodes[_i].kind);
	// the edges: two nearest each
	var _edges = [];
	var _has = function(_edges, _a, _b) {
		for (var _e = 0; _e < array_length(_edges); _e++) if ((_edges[_e].a == _a && _edges[_e].b == _b) || (_edges[_e].a == _b && _edges[_e].b == _a)) return true;
		return false;
	};
	for (var _i = 0; _i < _n; _i++) {
		var _d1 = -1, _d2 = -1, _b1 = 999, _b2 = 999;
		for (var _j = 0; _j < _n; _j++) {
			if (_j == _i) continue;
			var _d = point_distance(_nodes[_i].x, _nodes[_i].y, _nodes[_j].x, _nodes[_j].y);
			if (_d < _b1) { _b2 = _b1; _d2 = _d1; _b1 = _d; _d1 = _j; }
			else if (_d < _b2) { _b2 = _d; _d2 = _j; }
		}
		if (_d1 >= 0 && !_has(_edges, _i, _d1)) array_push(_edges, { a : _i, b : _d1, d : 0 });
		// the second road only half the time (his ask, 2026-09-15: "branches that end in dead ends")
		if (_d2 >= 0 && random(1) < .5 && !_has(_edges, _i, _d2)) array_push(_edges, { a : _i, b : _d2, d : 0 });
	}
	// stitch the components together: union-find, nearest pair across
	var _parent = array_create(_n);
	for (var _i = 0; _i < _n; _i++) _parent[_i] = _i;
	var _find = function(_parent, _x) { while (_parent[_x] != _x) _x = _parent[_x]; return _x; };
	for (var _e = 0; _e < array_length(_edges); _e++) {
		var _ra = _find(_parent, _edges[_e].a), _rb = _find(_parent, _edges[_e].b);
		if (_ra != _rb) _parent[_ra] = _rb;
	}
	var _guard = 0;
	while (_guard < _n) {
		_guard += 1;
		var _r0 = _find(_parent, 0);
		var _best = -1, _bi2 = -1, _bd = 999;
		for (var _i = 0; _i < _n; _i++) {
			if (_find(_parent, _i) != _r0) continue;
			for (var _j = 0; _j < _n; _j++) {
				if (_find(_parent, _j) == _r0) continue;
				var _d = point_distance(_nodes[_i].x, _nodes[_i].y, _nodes[_j].x, _nodes[_j].y);
				if (_d < _bd) { _bd = _d; _best = _i; _bi2 = _j; }
			}
		}
		if (_best < 0) break;   // one component: done
		array_push(_edges, { a : _best, b : _bi2, d : 0 });
		_parent[_find(_parent, _bi2)] = _r0;
	}
	// the distances: hours of walking, by the map's length
	for (var _e = 0; _e < array_length(_edges); _e++) {
		var _ea = _nodes[_edges[_e].a], _eb = _nodes[_edges[_e].b];
		_edges[_e].d = max(1, round(point_distance(_ea.x, _ea.y, _eb.x, _eb.y) * 14));
	}
	// the region's name and its SPOT on the world (his ask: a region is a
	// spot on the planet - lon / lat, a third of the globe apart)
	var _rname = (_ri == 0) ? "the landing reach" : (region_name("village") + choose(" reach", " lowlands", " marches", " uplands", " fens", " holds"));
	var _spot = { lon : _ri * 120 + random_range(-40, 40), lat : random_range(-35, 35) };
	rng_release(_old);
	return { seed : _seed, lv : _lv, ri : _ri, name : _rname, spot : _spot, nodes : _nodes, edges : _edges, landing : 0, landings : _landings, biome : _bi,
	         nciv : _nciv, ndun : _ndun, ncmp : _ncmp };
}
