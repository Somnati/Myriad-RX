/// @description region_road_name(region, ei) -> the road's name ("the low road", "Kesso's way", "the drovers' track", "the Idawich road"), generated once and kept on the edge
/// ROADS HAVE NAMES (his wondering, 2026-09-16: "should we give roads proc
/// gen names as well" - yes): hashed off the region's seed and the edge's
/// index (hash_mix: no roll of the ambient stream), in four shapes - "the
/// <word> road", "<a name>'s way" (sprite_name_gen under a seed of the
/// road's own), "the <thing> track", or the road named for the bigger of
/// its two ends. A boat crossing is "the <word> crossing" or "the ferry".
/// Cached as edge.rname (the region itself is cached - region_get).
function region_road_name(_rg, _ei) {
	var _ed = _rg.edges[_ei];
	if (is_string(_ed[$ "rname"])) return _ed.rname;
	var _seed = _rg.seed, _base = 5000 + _ei * 97;
	var _pick = function(_arr, _salt, _seed2, _base2) { return _arr[hash_mix(_seed2, _base2 + _salt) mod array_length(_arr)]; };
	var _nm;
	if (_ed[$ "boat"] ?? false) {
		_nm = (hash_mix(_seed, _base + 1) mod 3 == 0) ? "the ferry" : ("the " + _pick(["narrow", "grey", "salt", "slack", "cold", "long", "quiet"], 2, _seed, _base) + " crossing");
	} else {
		var _shape = hash_mix(_seed, _base + 1) mod 4;
		switch (_shape) {
			case 0: _nm = "the " + _pick(["low", "high", "old", "long", "salt", "black", "green", "hollow", "broken", "king's", "north", "mill", "stone", "cold", "quiet", "back", "sunken"], 2, _seed, _base) + " road"; break;
			case 1: {
				var _rs = random_get_seed();
				random_set_seed(hash_mix(_seed, _base + 3));
				_nm = str_cap(sprite_name_gen()) + "'s " + _pick(["way", "lane", "road", "walk"], 4, _seed, _base);
				rng_release(_rs);
				break;
			}
			case 2: _nm = "the " + _pick(["drovers'", "pilgrims'", "carters'", "reed", "sheep", "ford", "ridge", "chalk", "coffin", "wood", "coal", "tinkers'"], 2, _seed, _base) + " " + _pick(["track", "path", "way"], 5, _seed, _base); break;
			default: {
				// named for the bigger end (a settled place first, the dot's radius as the measure)
				var _kk = region_kinds();
				var _na = _rg.nodes[_ed.a], _nb = _rg.nodes[_ed.b];
				var _ka = _kk[$ _na.kind] ?? _kk.field, _kb = _kk[$ _nb.kind] ?? _kk.field;
				var _ra = _ka.r + (_ka.civ ? 10 : 0), _rb = _kb.r + (_kb.civ ? 10 : 0);
				var _big = (_rb > _ra) ? _nb : _na;
				var _bn = _big.name;
				if (string_copy(_bn, 1, 4) == "the ") _bn = string_delete(_bn, 1, 4);
				_nm = "the " + _bn + " road";
				break;
			}
		}
	}
	_ed.rname = _nm;
	return _nm;
}
