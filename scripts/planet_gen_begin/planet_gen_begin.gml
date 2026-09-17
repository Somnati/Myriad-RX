/// @description planet_gen_begin(seed, [hint]) -> a world, begun: every
/// roll made (palette, atmosphere, clouds, craters, cities), the maps
/// allocated, nothing sampled yet. planet_gen_step fills the rows a few
/// a frame so the page never hitches (the tech demo hung a room on
/// this bake); planet_bake makes the textures once it is done.
/// The tech demo's scr_planet_generate, cut to what the expedition
/// page draws (no moons; cities kept - they light the night side).
/// @param hint  { kind : "rock"/"gas", clim : 0..1, [hue] : 0..255 the
///              family's grass/sand hue, [arch] : "barren"/"terra"/
///              "lava", [wet] : 0..1 } - the expedition biome speaks here
///              (exped_planet_hint) so the full world reads in the
///              colours the board's portrait promised
function planet_gen_begin(_seed, _hint = undefined, _tw_ask = undefined, _th_ask = undefined) {   // (tw / th: the map's size - the star system's lite worlds ask 48x24, 2026-09-16)
	var _rs = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _cfg = planet_config();
	var _tw = _tw_ask ?? _cfg.tex_w, _th = _th_ask ?? _cfg.tex_h;
	var _kind = "rock", _clim = .5, _hue = -1, _arch_f = "", _wet_f = -1;
	if (!is_undefined(_hint)) {
		_kind = _hint[$ "kind"] ?? "rock";
		_clim = _hint[$ "clim"] ?? .5;
		_hue  = _hint[$ "hue"] ?? -1;
		_arch_f = _hint[$ "arch"] ?? "";
		_wet_f  = _hint[$ "wet"] ?? -1;
	}
	var _tilt = random_range(-28, 28);
	// A DAY IS HOURS (his ask, 2026-09-15: "planets might need to rotate much
	// slower... 3hr"): 1.5-6 h a turn, most near three (the same two rolls
	// as before, so nothing downstream moves); gas worlds spin faster
	var _dayh = lerp(1.5, 6, power(random(1), 1.7));
	var _spin = (360 / (_dayh * 3600)) / 60 * choose(1, -1);   // degrees a step (x60 = a second)
	if (_kind == "gas") _spin *= 1.8;
	var _wt  = (random_range(.46, .58) - .46) / .12;
	var _wet = clamp(_wt + (_clim - .5) * .9, 0, 1);
	_wet *= random(1);
	if (_wet_f >= 0) _wet = _wet_f;
	var _dry = (_wet < .16);
	var _sea = _dry ? 0 : lerp(.30, .92, power(_wet, 1.6));
	var _o1 = irandom($ffff), _o2 = irandom($ffff), _o3 = irandom($ffff), _o4 = irandom($ffff);

	// ---- integer-hash 3d value noise (bit-identical everywhere) ----
	var _ctx = {
		sd : _seed,
		h3 : function(_x, _y, _z, _o) {
			var _n = (_x * 374761393 + _y * 668265263 + _z * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff;
			_n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff;
			return ((_n ^ (_n >> 16)) & $ffff) / $ffff;
		},
		// (the eight corners' hashes INLINE - h3's arithmetic, in h3's order, so the values are bit-identical to
		// every world built before; the calls were most of a sample's cost - the zoom tiers, 2026-09-17)
		vn3 : function(_x, _y, _z, _o) {
			var _ix = floor(_x); var _iy = floor(_y); var _iz = floor(_z);
			var _fx = _x - _ix; _fx = _fx * _fx * (3 - 2 * _fx);
			var _fy = _y - _iy; _fy = _fy * _fy * (3 - 2 * _fy);
			var _fz = _z - _iz; _fz = _fz * _fz * (3 - 2 * _fz);
			var _ix1 = _ix + 1, _iy1 = _iy + 1, _iz1 = _iz + 1, _n;
			_n = (_ix * 374761393 + _iy * 668265263 + _iz * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c000 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix1 * 374761393 + _iy * 668265263 + _iz * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c100 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix * 374761393 + _iy1 * 668265263 + _iz * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c010 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix1 * 374761393 + _iy1 * 668265263 + _iz * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c110 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix * 374761393 + _iy * 668265263 + _iz1 * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c001 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix1 * 374761393 + _iy * 668265263 + _iz1 * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c101 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix * 374761393 + _iy1 * 668265263 + _iz1 * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c011 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			_n = (_ix1 * 374761393 + _iy1 * 668265263 + _iz1 * 1274126177 + _o * 69069 + sd * 2654435761) & $7fffffff; _n = ((_n ^ (_n >> 13)) * 1103515245) & $7fffffff; var _c111 = ((_n ^ (_n >> 16)) & $ffff) / $ffff;
			return lerp(
				lerp(lerp(_c000, _c100, _fx), lerp(_c010, _c110, _fx), _fy),
				lerp(lerp(_c001, _c101, _fx), lerp(_c011, _c111, _fx), _fy),
				_fz);
		},
		fbm3 : function(_x, _y, _z, _o, _oct) {
			var _v = 0; var _a = .5; var _t = 0;
			repeat (_oct) {
				_v += vn3(_x, _y, _z, _o) * _a;
				_t += _a;
				_x *= 2.03; _y *= 2.03; _z *= 2.03;
				_a *= .5;
				_o += 131;
			}
			return _v / _t;
		},
	};

	// ---- archetype: palette, atmosphere, cloud systems ----
	var _atmo, _pal, _bands = undefined, _storm = undefined, _cbl = [], _belts = [];
	var _arch = (_kind == "gas") ? "gas" : "terra";
	var _craters = [];
	if (_kind == "gas") {
		var _gh = (_hue >= 0) ? _hue : irandom(255);
		_atmo = make_colour_hsv(_gh, irandom_range(80, 135), 255);
		// TWO HUES (his ask, 2026-09-17: every giant was one hue, banded): the bands alternate between the
		// giant's hue and a SECOND - a neighbour (cream and rust, blue and teal: the Jupiters and the Neptunes)
		// three times in five, its opposite else (the vivid ones) - and a band now and then breaks the
		// alternation, so it reads as weather, not stripes. Hashed off the seed: the stream holds, nothing moves
		var _g2h = hash_mix(_seed, 611);
		var _g2off = ((_g2h mod 100) < 60) ? (38 + ((_g2h div 100) mod 21)) : (118 + ((_g2h div 100) mod 21));
		if (((_g2h div 7) mod 2) == 0) _g2off = -_g2off;
		var _gh2 = (_gh + _g2off + 512) mod 256;
		_bands = []; _pal = [];
		var _v0 = 0, _bi = 0;
		while (_v0 < 1) {
			var _lum = irandom_range(120, 235);
			array_push(_bands, { v0 : _v0 });
			var _useb = ((_bi mod 2) == 1);
			if ((hash_mix(_seed, 640 + _bi) mod 100) < 22) _useb = !_useb;
			array_push(_pal, make_colour_hsv(((_useb ? _gh2 : _gh) + irandom_range(-16, 16) + 256) mod 256, irandom_range(55, 135), _lum));
			_v0 += random_range(.06, .16);
			_bi++;
		}
		if (random(1) < .7) {
			var _sz2 = random_range(-.55, .55);
			var _sa2 = random(2 * pi);
			var _sr2 = sqrt(max(0, 1 - _sz2 * _sz2));
			array_push(_pal, make_colour_hsv((_gh + 128 + irandom_range(-24, 24)) mod 256, irandom_range(120, 180), irandom_range(170, 230)));
			_storm = { x : _sr2 * cos(_sa2), y : _sz2, z : _sr2 * sin(_sa2), r : random_range(.14, .24), b : array_length(_pal) - 1 };
		}
		repeat (irandom_range(1, 2)) array_push(_belts, { v : random_range(.3, .7), w : random_range(.03, .05) });
	} else {
		if (_dry) _arch = (_clim < .22 || (_clim < .5 && random(1) < .3)) ? "lava" : "barren";
		if (_arch_f != "") _arch = _arch_f;
		var _ahr = irandom(255);
		var _asr = irandom_range(70, 140);
		var _act = clamp((_clim - .28) / .2, 0, 1);
		_act = _act * _act * (3 - 2 * _act);
		var _ahue = (lerp(22, 152, _act) + (_ahr / 255 - .5) * 36 + 256) mod 256;
		var _asat = _asr * lerp(1, .6, clamp((_clim - .55) / .45, 0, 1));
		_atmo = make_colour_hsv(_ahue, _asat, 255);
		if (_arch == "lava")        _atmo = make_colour_hsv(irandom_range(3, 12), irandom_range(190, 230), 255);
		else if (_arch == "barren") _atmo = merge_colour(_atmo, c_black, .78);
		var _vh = irandom(255);
		var _vs = irandom_range(120, 200);
		var _vv = irandom_range(175, 220);
		if (_hue >= 0) _vh = _hue;   // the family's hue: the world reads as its portrait promised
		var _fh = (_vh + choose(1, -1) * irandom_range(90, 150) + 256) mod 256;   // (the rolls stay - the stream holds)
		var _fs = irandom_range(130, 210);
		// THE TREES (his ask, 2026-09-17 - the wood was always the grass's far side): five families, hashed off
		// the seed. kin = the grass's own hue, deeper (the earthly wood); autumn = reds, oranges and golds;
		// contrast = the rule of before, the grass's opposite; ink = near-black with a tint; pale = silver and
		// bone (the birch woods, the ghost woods). Jungle and swamp derive from the wood, as before
		var _fv = 150;
		var _tf = hash_mix(_seed, 733) mod 100;
		if (_tf < 38)      { _fh = (_vh + (hash_mix(_seed, 734) mod 21) - 10 + 256) mod 256; _fs = min(255, _vs + 30); _fv = 150; }
		else if (_tf < 55) { _fh = hash_mix(_seed, 735) mod 40; _fs = 150 + (hash_mix(_seed, 736) mod 70); _fv = 165; }
		else if (_tf < 80) { }   // (contrast: as rolled)
		else if (_tf < 90) { _fh = hash_mix(_seed, 737) mod 256; _fs = 60 + (hash_mix(_seed, 738) mod 60); _fv = 85; }
		else               { _fh = hash_mix(_seed, 739) mod 256; _fs = 20 + (hash_mix(_seed, 740) mod 40); _fv = 205; }
		var _sand;
		var _sr = irandom(9);
		if (_sr < 4)      _sand = make_colour_hsv(irandom_range(10, 32),  irandom_range(80, 160), irandom_range(140, 205));
		else if (_sr < 6) _sand = make_colour_hsv(irandom(255),           irandom_range(0, 35),   irandom_range(45, 90));
		else if (_sr < 8) _sand = make_colour_hsv(irandom_range(215, 250), irandom_range(60, 120), irandom_range(215, 245));
		else              _sand = make_colour_hsv(irandom_range(28, 45),  irandom_range(50, 110), irandom_range(220, 248));
		if (_hue >= 0 && _arch == "barren") _sand = make_colour_hsv(_hue, irandom_range(20, 60), irandom_range(120, 180));
		var _peak;
		var _pk = irandom(9);
		if (_pk < 4)      _peak = make_colour_hsv(irandom_range(8, 30), irandom_range(60, 130), irandom_range(105, 165));
		else if (_pk < 7) _peak = make_colour_hsv(0, 0, irandom_range(95, 150));
		else              _peak = make_colour_hsv(0, irandom_range(0, 22), irandom_range(200, 240));
		// 0 deep ocean, 1 ocean, 2 shore, 3 desert, 4 grass, 5 forest,
		// 6 jungle, 7 tundra, 8 snow, 9 rock peaks, 10 snow caps
		_pal = [
			rgb( 38,  70, 130), rgb( 62, 112, 175),
			merge_colour(_sand, c_white, .3),
			_sand,
			make_colour_hsv(_vh, _vs, _vv),
			make_colour_hsv(_fh, _fs, _fv),
			make_colour_hsv((_fh + 12) mod 256, min(_fs + 35, 255), round(_fv * .79)),
			rgb(150, 158, 138), rgb(235, 240, 245),
			_peak,
			rgb(248, 250, 255),
		];
		// 11 shallows, 12 swamp, 13 salt flat, 14 glacier, 15 crater
		// floor, 16 crater rim, 17 basalt crust, 18 lava flow (emissive)
		array_push(_pal,
			merge_colour(rgb(62, 112, 175), rgb(110, 215, 205), .55),
			make_colour_hsv(_fh, min(_fs + 30, 255), round(_fv * .59)),
			merge_colour(_sand, c_white, .55),
			rgb(198, 224, 244),
			merge_colour(_sand, c_black, .38),
			merge_colour(_sand, c_white, .28),
			merge_colour(rgb(48, 40, 42), _sand, .18),
			rgb(255, 112, 20));
		if (_arch == "barren") repeat (irandom_range(12, 24)) {
			var _kz = random_range(-1, 1);
			var _ka = random(2 * pi);
			var _kr = sqrt(max(0, 1 - _kz * _kz));
			array_push(_craters, { x : _kr * cos(_ka), y : _kz, z : _kr * sin(_ka), r : random_range(.05, .15) });
		}
		// the puffs: many and small (2026-09-15 - at the expedition page's
		// size the old .2-.36 ones read as white continents)
		repeat (irandom_range(10, 16)) {
			var _cz = random_range(-.9, .9);
			var _ca = random(2 * pi);
			var _cr = sqrt(max(0, 1 - _cz * _cz));
			array_push(_cbl, { x : _cr * cos(_ca), y : _cz, z : _cr * sin(_ca), r : random_range(.12, .24) });
		}
		repeat (irandom_range(1, 3)) array_push(_belts, { v : random_range(.28, .72), w : random_range(.045, .085) });
	}
	// the city palette slots (19 dark / 20 light)
	while (array_length(_pal) < 19) array_push(_pal, c_gray);
	array_push(_pal, make_colour_hsv(24, 30, 74));
	array_push(_pal, make_colour_hsv(28, 40, 158));
	// emissive mask per palette slot: the bake writes alpha = 1 - glow
	var _glow = array_create(array_length(_pal), 0);
	if (_kind == "rock") _glow[18] = .85;
	_glow[19] = .50;
	_glow[20] = .30;
	var _ringc = merge_colour(color_set_comp(_atmo), rgb(205, 195, 178), .55);
	var _ring  = (_kind == "gas") ? (random(1) < .45) : (random(1) < .12);
	if (!is_undefined(_hint) && !is_undefined(_hint[$ "ring"])) _ring = _hint.ring;   // (the galaxy's planet says - the home world, 2026-09-15; the roll above still runs)

	// ---- the texel sampler's params ----
	var _ps = {
		ctx : _ctx, o1 : _o1, o2 : _o2, o3 : _o3, o4 : _o4,
		kind : _kind, sea : _sea,
		mshift : lerp(-.30, .12, _wet),
		hbase  : max(_sea, .42),
		arch : _arch, craters : _craters,
		theat : (.5 - _clim) * .5,
		bands : _bands, storm : _storm,
		oe : 0, ob : 0,
		cities : undefined,
	};

	// ---- civilization: a few city sites on habitable worlds, found by
	// sampling the terrain at random points BEFORE the map is built (the
	// tech demo rebuilt the whole map after; one pass here) ----
	var _civ = undefined;
	if (_kind == "rock" && _arch == "terra") {
		var _comfy = (_clim > .25 && _clim < .75 && _wet >= .16);
		if (random(1) < (_comfy ? .65 : .12)) {
			var _cities = [];
			var _cn = _comfy ? irandom_range(2, 5) : irandom_range(1, 2);
			var _try = 0;
			while (array_length(_cities) < _cn && _try < 120) {
				_try++;
				var _cu = random(1), _cv = random_range(.12, .88);
				planet_texel(_ps, _cu, _cv);
				var _bio = _ps.ob;
				if (_bio <= 2 || _bio == 9 || _bio == 10 || _bio == 11 || _bio == 14) continue;
				var _sl3 = sin(_cv * pi);
				array_push(_cities, { x : _sl3 * cos(_cu * 2 * pi), y : cos(_cv * pi), z : _sl3 * sin(_cu * 2 * pi), r : random_range(.06, .12) });
			}
			// (the cities are rolled - the stream holds - but never kept: no lights, no street grids; his call 2026-09-15)
		}
	}
	rng_release(_rs);

	return {
		seed : _seed, kind : _kind, clim : _clim, arch : _arch, tw : _tw, th : _th,
		sea : _sea, wet : _wet, tilt : _tilt, spin : _spin, atmo : _atmo,
		ring : _ring, ring_col : _ringc, civ : _civ,
		pal : _pal, glow : _glow, smp : _ps, cbl : _cbl, belts : _belts, dry : _dry,
		elev : array_create(_tw * _th, 0), biome : array_create(_tw * _th, 0), carr : array_create(_tw * _th, 0), cthk : array_create(_tw * _th, 0),
		row : 0,            // planet_gen_step's cursor; ready when row == th
		brow : 0,           // planet_bake's cursor: rows stamped across the three textures (0..3*th)
		tsurf : -1, csurf : -1, hsurf : -1,   // planet_bake's textures
	};
}
