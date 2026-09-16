/// @description station_get(seed) -> undefined, or the world's space station: { seed, style, prm[4], dist, size, ang, spd, incl, col, glow, hull }
/// SPACE STATIONS (2026-09-16, his ask: "shape based ... like no man's
/// sky's"): a share of the landable worlds keep one in orbit - a hash of
/// the world's seed decides (nothing rolled, nothing saved). Its STYLE is
/// one of four silhouettes (ring and spindle / block stack / pod cluster /
/// diamond), its proportions seeded within the style, its own orbit ring
/// (dist in world radii, a slow round - hours - on the universal clock, a
/// lean off the equator), its hull grey-blue or grey-warm, its windows
/// warm. Cached on a struct by seed for the session.
function station_get(_seed) {
	static _c = {};
	var _k = string(_seed);
	if (variable_struct_exists(_c, _k)) return _c[$ _k];
	var _cfg = starmap_config();
	var _h = hash_mix(_seed, 71);
	var _out = undefined;
	if ((_h mod 1000) / 1000 < (_cfg[$ "station_chance"] ?? .45)) {
		var _h2 = hash_mix(_seed, 73), _h3 = hash_mix(_seed, 79), _h4 = hash_mix(_seed, 83), _h5 = hash_mix(_seed, 89), _h6 = hash_mix(_seed, 97);
		var _style = _h2 mod 4;
		var _r = [(_h3 mod 1000) / 1000, (_h4 mod 1000) / 1000, (_h5 mod 1000) / 1000, (_h6 mod 1000) / 1000];
		var _prm = [1, 1, 1, 1];
		switch (_style) {
			case 0: _prm = [.62 + .18 * _r[0], .08 + .05 * _r[1], .8 + .25 * _r[2], .12 + .07 * _r[3]]; break;   // ring R, tube r, spindle half-length, spindle r
			case 1: _prm = [.8 + .4 * _r[0], .6 + .5 * _r[1], 1, 1]; break;                                         // the deck's x / z stretch
			case 2: _prm = [.6 + .8 * _r[0], .8 + .4 * _r[1], 1, 1]; break;                                         // the pods' stagger, their size
			case 3: _prm = [.85 + .3 * _r[0], .9 + .3 * _r[1], 1, 1]; break;                                        // the diamond's size, the band's radius
		}
		var _hull = (_r[2] < .5) ? merge_colour(rgb(150, 160, 185), rgb(120, 125, 140), _r[3]) : merge_colour(rgb(175, 165, 150), rgb(130, 122, 112), _r[3]);
		_out = { seed : _seed, style : _style, prm : _prm,
		         dist : (_cfg[$ "station_dist"] ?? 1.6) + .3 * _r[0], size : (_cfg[$ "station_size"] ?? .26) * (.85 + .3 * _r[1]),
		         ang : (_h3 mod 360), spd : ((_cfg[$ "station_round_min"] ?? 90) > 0 ? 360 / ((_cfg[$ "station_round_min"] ?? 90) * 60 * 60) : 0) * ((_h4 mod 2 == 0) ? 1 : -1),   // (deg a step: a round in station_round_min minutes of wall clock)
		         incl : ((_h5 mod 1000) / 1000 - .5) * 24, spin : .02 + .03 * _r[2],
		         hull : _hull, glow : rgb(255, 214, 150), sseed : (_h6 mod 977) * .0064 };
	}
	_c[$ _k] = _out;
	return _out;
}
