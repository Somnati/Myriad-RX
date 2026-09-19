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
	// THE TERRAIN'S TEMPER (q247; his ask: "improve / increase variety in terrain generation" - every world was one seed
	// through the same constants: the same continent scale, the same ridged law, the same warp, so two temperate worlds
	// at one sea level were one world in two places). Hashed off the seed, never rolled (the stream holds): the grammar
	// planet_fields reads - continent scale (a few great landmasses .. a thousand islands), relief (a flat old shield ..
	// young and sharp), the ridged mass, the warp of the coasts, the fine grain's roughness, a hemisphere bias, and a
	// LAND SHAPE (free / pangaea / twins / an equatorial belt / polar continents / a ring of islands). A giant has none
	var _th9 = function(_s, _k) { return (hash_mix(_s, 5000 + _k) mod 10000) / 10000; };
	var _shp = _th9(_seed, 8), _shape = (_shp < .35) ? 0 : ((_shp < .50) ? 1 : ((_shp < .62) ? 2 : ((_shp < .72) ? 3 : ((_shp < .80) ? 4 : 5))));
	var _tsa = _th9(_seed, 9) * 360, _tse = (_th9(_seed, 10) - .5) * 140, _tha = _th9(_seed, 6) * 360, _the = (_th9(_seed, 7) - .5) * 160;
	var _tt = {
		cscale : 1.4 + 2.2 * _th9(_seed, 1),
		relief : .45 + .65 * power(_th9(_seed, 2), 1.3),
		ridge  : .04 + .20 * _th9(_seed, 3),
		warp   : .10 + .45 * _th9(_seed, 4),
		rough  : .6 + 1.0 * _th9(_seed, 11),
		hemi   : (_th9(_seed, 5) - .5) * .16,
		hax    : [dcos(_the) * dcos(_tha), dsin(_the), dcos(_the) * dsin(_tha)],
		shape  : _shape,
		sdir   : [dcos(_tse) * dcos(_tsa), dsin(_tse), dcos(_tse) * dsin(_tsa)],
		// THE HYDROLOGY (q248): how readily the land runs to rivers, how readily a basin keeps a lake
		rivers : .35 + 1.15 * _th9(_seed, 12),
		lakes  : .5 + 1.7 * _th9(_seed, 13),
		// THE TECTONIC LINES (q248): a hotspot chain (volcanoes in a row, the last alive), fault-block ranges (one heading)
		hotspot : (_th9(_seed, 14) < .25), faultblock : (_th9(_seed, 15) < .25),
		// THE SIGNATURE (q248): one landmark a world - none / impact sea / caldera / rift / canyon / inland sea / salt flat / ice sheet
		sig : 0, sigh : _th9(_seed, 16), sigu : _th9(_seed, 17), sigv : _th9(_seed, 18), siga : _th9(_seed, 19) * 360,
		// THE CLIMATE (q249): Hadley cells on some worlds (desert belts at +-30 degrees), the rain shadow's strength and the
		// wind's way, a warmer / colder and a wetter / drier lean, the polar cap's latitude
		hadley : (_th9(_seed, 21) < .55) ? 0 : (.08 + .14 * _th9(_seed, 22)),
		shadow : (_th9(_seed, 23) < .40) ? 0 : (.15 + .30 * _th9(_seed, 24)),
		wind   : (_th9(_seed, 25) < .5) ? -1 : 1,
		tshift : (_th9(_seed, 26) - .5) * .14,
		mshift : (_th9(_seed, 27) - .5) * .20,
		cap    : .74 + .14 * _th9(_seed, 28),
	};
	var _sg = _th9(_seed, 20);
	_tt.sig = (_sg < .30) ? 0 : ((_sg < .42) ? 1 : ((_sg < .52) ? 2 : ((_sg < .64) ? 3 : ((_sg < .74) ? 4 : ((_sg < .84) ? 5 : ((_sg < .92) ? 6 : 7))))));
	if (_shape == 5) { _tt.cscale = max(_tt.cscale, 3.2); _tt.relief = min(_tt.relief, .6); }   // (a ring of islands: fine and low)
	if (_shape == 1) _tt.cscale = min(_tt.cscale, 2.2);   // (a pangaea: broad)

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
	var _gstops = [], _gstorms = [], _gw = undefined, _ggloss = 0;   // THE GIANT'S FACE (q236): the colour stops and the storm ovals gas_colour reads (a rock world has none)
	var _sand = c_gray;   // the world's sand (a rock world rolls it below; a giant has none - declared here so no read is outside its scope)
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
		// THE GIANT'S FACE (q236, his references): the colour STOPS up the latitude and the storm ovals gas_colour reads -
		// all HASHED off the seed (the rolls above stand: every giant keeps its hue, ring and storm). Four families: candy
		// (three hues a third of the wheel apart, saturated - the Universe Sandbox look), pastel marble (one hue's
		// neighbours, pale, with a dark accent - Spiritus), jovian (cream / rust / brown / white), ice (blue-cyan, soft)
		var _gf = hash_mix(_seed, 660) mod 100, _gfam = (_gf < 40) ? 0 : ((_gf < 70) ? 1 : ((_gf < 90) ? 2 : 3));
		_ggloss = (_gfam == 3) ? .40 : ((_gfam == 1) ? .18 : ((_gfam == 0) ? .15 : .06));   // THE SHEEN (q242): the ice family glossy, a jovian nearly matte
		_gstops = [];
		var _gv = 0, _gk = 0, _gh0 = _gh;
		while (_gv < 1) {
			var _hh = hash_mix(_seed, 700 + _gk * 3), _hs = hash_mix(_seed, 701 + _gk * 3), _hv = hash_mix(_seed, 702 + _gk * 3);
			var _sh, _ss, _sv;
			if (_gfam == 0)      { _sh = (_gh0 + 85 * (_hh mod 3) + ((_hh div 3) mod 25) - 12 + 512) mod 256; _ss = 165 + (_hs mod 70); _sv = ((_hv mod 100) < 22) ? 250 : 190 + (_hv mod 60); if ((_hv mod 100) < 12) { _ss = 20 + (_hs mod 30); _sv = 245; } }
			else if (_gfam == 1) { _sh = (_gh0 + ((_hh mod 51) - 25) + 512) mod 256; _ss = 45 + (_hs mod 50); _sv = 205 + (_hv mod 50); if ((_hv mod 100) < 25) { _ss = 90 + (_hs mod 60); _sv = 120 + (_hv mod 45); } }
			else if (_gfam == 2) { var _jk = _hh mod 4; _sh = (_jk == 0) ? 32 : ((_jk == 1) ? 14 : ((_jk == 2) ? 20 : 30)); _ss = (_jk == 0) ? 55 + (_hs mod 30) : ((_jk == 1) ? 150 + (_hs mod 60) : ((_jk == 2) ? 120 + (_hs mod 50) : 15 + (_hs mod 20))); _sv = (_jk == 0) ? 225 + (_hv mod 30) : ((_jk == 1) ? 160 + (_hv mod 40) : ((_jk == 2) ? 95 + (_hv mod 40) : 240 + (_hv mod 15))); }
			else                 { _sh = (150 + ((_hh mod 41) - 20) + 256) mod 256; _ss = 110 + (_hs mod 90); _sv = 170 + (_hv mod 85); }
			array_push(_gstops, { v : _gv, col : make_colour_hsv(_sh, min(255, _ss), min(255, _sv)) });
			_gv += .05 + ((hash_mix(_seed, 703 + _gk * 3) mod 1000) / 1000) * ((_gfam == 1) ? .17 : .12);
			_gk++;
		}
		// THE WEATHER'S TEMPER (his question, 2026-09-18: "how much variety in their patterns"): the wander, the shear and its
		// streak frequency, the marbling, the pole caps - hashed a world, so one giant is calm and banded, the next a
		// churned marble, another streaked thin like a jet stream photograph
		var _gwh = function(_s, _k) { return (hash_mix(_s, _k) mod 1000) / 1000; };
		_gw = { wan : .05 + .12 * _gwh(_seed, 740), shr : .02 + .09 * _gwh(_seed, 741), shf : 5 + 9 * _gwh(_seed, 742), mar : .15 + .40 * _gwh(_seed, 743),
		        turb : .0 + .12 * power(_gwh(_seed, 744), 1.5), cap : (_gwh(_seed, 745) < .45) ? (.25 + .35 * _gwh(_seed, 746)) : 0, capd : (_gwh(_seed, 747) < .5) ? -1 : 1 };
		_gstorms = [];
		if (is_struct(_storm)) array_push(_gstorms, { x : _storm.x, y : _storm.y, z : _storm.z, r : _storm.r * .7, col : _pal[_storm.b], spin : (((hash_mix(_seed, 720) mod 2) == 0) ? 1 : -1), asp : 1.5 + .9 * ((hash_mix(_seed, 722) mod 1000) / 1000), eyel : hash_mix(_seed, 723) mod 2, turns : 1.0 + 1.5 * ((hash_mix(_seed, 724) mod 1000) / 1000) });   // (the rolled storm, as it was)
		// THE PEARLS (his Jupiter reference): up to five small pale ovals strung along one band, hashed
		var _gpn = hash_mix(_seed, 750) mod 6;
		if (_gpn > 0) {
			var _gpv = .25 + .5 * ((hash_mix(_seed, 751) mod 1000) / 1000), _gpa0 = ((hash_mix(_seed, 752) mod 1000) / 1000) * 2 * pi, _gpst = .25 + .25 * ((hash_mix(_seed, 753) mod 1000) / 1000);
			var _gpk = 0; for (var _gi2 = 0; _gi2 < array_length(_gstops); _gi2++) if (_gpv >= _gstops[_gi2].v) _gpk = _gi2;
			var _gpc = merge_colour(_gstops[_gpk].col, c_white, .72), _gpy = cos(_gpv * pi), _gpr = sin(_gpv * pi);
			for (var _gi = 0; _gi < _gpn; _gi++) {
				var _gpa = _gpa0 + _gi * _gpst + ((hash_mix(_seed, 760 + _gi) mod 1000) / 1000) * .08;
				array_push(_gstorms, { x : _gpr * cos(_gpa), y : _gpy, z : _gpr * sin(_gpa), r : .018 + .02 * ((hash_mix(_seed, 770 + _gi) mod 1000) / 1000), col : _gpc, spin : 1, asp : 1.4, eyel : 1, pearl : true });
			}
		}
		var _gsn = hash_mix(_seed, 721) mod 3;   // (and up to two more, hashed)
		for (var _gi = 0; _gi < _gsn; _gi++) {
			var _sz = ((hash_mix(_seed, 730 + _gi * 4) mod 1000) / 1000) * 1.2 - .6, _sa = ((hash_mix(_seed, 731 + _gi * 4) mod 1000) / 1000) * 2 * pi, _sr = sqrt(max(0, 1 - _sz * _sz));
			var _sc = _gstops[hash_mix(_seed, 732 + _gi * 4) mod array_length(_gstops)].col;
			array_push(_gstorms, { x : _sr * cos(_sa), y : _sz, z : _sr * sin(_sa), r : .07 + ((hash_mix(_seed, 733 + _gi * 4) mod 1000) / 1000) * .10, col : merge_colour(_sc, ((hash_mix(_seed, 734 + _gi * 4) mod 2) == 0) ? c_white : c_black, .35), spin : (((hash_mix(_seed, 735 + _gi * 4) mod 2) == 0) ? 1 : -1), asp : 1.5 + .9 * ((hash_mix(_seed, 736 + _gi * 4) mod 1000) / 1000), eyel : hash_mix(_seed, 737 + _gi * 4) mod 2, turns : 1.0 + 1.5 * ((hash_mix(_seed, 738 + _gi * 4) mod 1000) / 1000) });
		}
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
		// THE LAVA'S FAMILY (his ask, live test 2026-09-18: "crazy colours of lava instead of lava red"): hashed off the
		// seed, never rolled (the roll order is the save format) - classic orange half the time, else plasma blue,
		// acid green, violet or white-hot; the sky over it leans the same way (the same three rolls as before, hue shifted)
		var _lvf = hash_mix(_seed, 4444) mod 100;
		var _lava_col = rgb(255, 112, 20), _lava_hue = 0;
		if (_lvf >= 50 && _lvf < 68)      { _lava_col = rgb(110, 200, 255); _lava_hue = 145; }   // plasma blue
		else if (_lvf >= 68 && _lvf < 84) { _lava_col = rgb(150, 255, 60);  _lava_hue = 70; }    // acid green
		else if (_lvf >= 84 && _lvf < 94) { _lava_col = rgb(205, 90, 255);  _lava_hue = 200; }   // violet
		else if (_lvf >= 94)              { _lava_col = rgb(255, 246, 215); _lava_hue = 30; }    // white-hot (a gold sky)
		if (_arch == "lava")        _atmo = make_colour_hsv((irandom_range(3, 12) + _lava_hue) mod 256, irandom_range(190, 230), 255);
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
		// THE ALIEN SEAS (q247): one world in eight wears a sea that is not blue - green-teal, wine-dark, milky, black -
		// hashed; the shallows and the coral derive from it below, so the shore agrees
		var _sf = hash_mix(_seed, 5100) mod 100, _sea0 = rgb(38, 70, 130), _sea1 = rgb(62, 112, 175);
		if (_sf < 4)       { _sea0 = rgb(22, 78, 66);   _sea1 = rgb(48, 128, 112); }    // green-teal
		else if (_sf < 7)  { _sea0 = rgb(74, 26, 58);   _sea1 = rgb(118, 46, 92); }     // wine-dark
		else if (_sf < 10) { _sea0 = rgb(128, 146, 166); _sea1 = rgb(176, 192, 210); }  // milky
		else if (_sf < 12) { _sea0 = rgb(10, 12, 22);   _sea1 = rgb(28, 32, 48); }      // black
		_pal = [
			_sea0, _sea1,
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
			merge_colour(_sea1, rgb(110, 215, 205), .55),   // (11 shallows: the sea's own, lifted toward the reef)
			make_colour_hsv(_fh, min(_fs + 30, 255), round(_fv * .59)),
			merge_colour(_sand, c_white, .55),
			rgb(198, 224, 244),
			merge_colour(_sand, c_black, .38),
			merge_colour(_sand, c_white, .28),
			merge_colour(rgb(48, 40, 42), _sand, .18),
			_lava_col);   // (18: the lava's family colour - emissive through the glow slot)
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
	// THE NEW KINDS (2026-09-17): 21 savanna, 22 taiga, 23 badlands, 24 dunes, 25 coral shallows - each from the
	// world's own colours (its grass, its wood, its sand, its shallows), so a strange world's savanna is strange too
	if (_kind == "gas") repeat (5) array_push(_pal, c_gray);
	else {
		var _sav = merge_colour(merge_colour(_pal[4], _sand, .45), c_white, .10);
		var _tai = make_colour_hsv((colour_get_hue(_pal[5]) + 248) mod 256, min(255, colour_get_saturation(_pal[5]) + 20), max(40, colour_get_value(_pal[5]) * .72));
		var _bad = make_colour_hsv((colour_get_hue(_sand) + 250) mod 256, min(255, colour_get_saturation(_sand) + 45), max(50, colour_get_value(_sand) * .72));
		var _dun = merge_colour(_sand, c_white, .18);
		var _cor = merge_colour(_pal[11], rgb(120, 235, 225), .5);
		array_push(_pal, _sav, _tai, _bad, _dun, _cor);
	}
	// emissive mask per palette slot: the bake writes alpha = 1 - glow
	var _glow = array_create(array_length(_pal), 0);
	if (_kind == "rock") _glow[18] = .85;
	_glow[19] = .50;
	_glow[20] = .30;
	var _ringc = merge_colour(color_set_comp(_atmo), rgb(205, 195, 178), .55);
	var _ring  = (_kind == "gas") ? (random(1) < .45) : (random(1) < .12);
	if (!is_undefined(_hint) && !is_undefined(_hint[$ "ring"])) _ring = _hint.ring;   // (the galaxy's planet says - the home world, 2026-09-15; the roll above still runs)
	if (RING_ALL) _ring = true;   // (debug: every world ringed - his ask 2026-09-17)
	// THE RING'S MAKE (his picks, 2026-09-17): its kind - ice (bright, banded) five in nine, dust (faint, wide, smooth)
	// a quarter, debris (sparse chunks) the rest - its reach, its two colours across the bands (from the world's own),
	// and the seed of its bands and gaps; hashed off the seed, nothing rolled
	var _rh = hash_mix(_seed, 4747);
	var _rkind = ((_rh mod 100) < 55) ? 0 : (((_rh mod 100) < 80) ? 1 : 2);
	var _rin = (_rkind == 1) ? 1.40 : (1.50 + ((_rh div 100) mod 25) / 100), _rout = (_rkind == 1) ? 2.55 : (2.05 + ((_rh div 10000) mod 40) / 100);
	// VIVID (his ask, 2026-09-17): the ring's hue is the sky's far side with a hashed lean, saturated; the second colour
	// a turn round the wheel from it - ice pale and bright, dust gold and deep, debris a hue and its opposite
	var _ringc2, _rhue = (colour_get_hue(_atmo) + 128 + ((_rh div 3) mod 61) - 30 + 256) mod 256;
	if (_rkind == 0)      { _ringc = make_colour_hsv(_rhue, 105, 248); _ringc2 = make_colour_hsv((_rhue + 36) mod 256, 185, 225); }
	else if (_rkind == 1) { _ringc = make_colour_hsv((18 + ((_rh div 13) mod 24) + 256) mod 256, 165, 238); _ringc2 = make_colour_hsv((_rhue + 200) mod 256, 200, 170); }
	else                  { _ringc = make_colour_hsv(_rhue, 120, 205); _ringc2 = make_colour_hsv((_rhue + 128) mod 256, 150, 165); }
	var _rseed = ((_rh div 7) mod 1000) / 1000;

	// THE CLOUD REGIMES (his picks, 2026-09-17: "more unique cloud patterns"): a rock world's sky is one of four -
	// cumulus (the old recipe: puffs and belts), SCATTERED (many small puffs, no belts, well torn - a dry world's
	// sky), STREAKED (no puffs: thin belts torn along their length, a fast world's sky), FRONTS (long arcs of
	// cloud with a clear wake behind each, a few puffs) - hashed off the seed; nothing rolled, so every roll below
	// lands where it did. A giant keeps its bands (creg 0)
	var _creg = 0, _cregp = {};
	if (_kind != "gas") {
		var _crh = hash_mix(_seed, 6161), _crv = _crh mod 100;
		if (_dry || _wet < .25) _creg = (_crv < 55) ? 1 : ((_crv < 80) ? 2 : 0);
		else if (_dayh < 2.4)   _creg = (_crv < 50) ? 2 : ((_crv < 75) ? 3 : 0);
		else                    _creg = (_crv < 40) ? 0 : ((_crv < 60) ? 1 : ((_crv < 78) ? 3 : 2));
		if (_creg == 1) {
			// scattered: twenty to forty small puffs of the seed's own
			var _sp = [];
			var _spn = 20 + (hash_mix(_seed, 6200) mod 21);
			for (var _q = 0; _q < _spn; _q++) {
				var _qz = (hash_mix(_seed, 6300 + _q * 3) mod 1000) / 1000 * 1.8 - .9, _qa = (hash_mix(_seed, 6301 + _q * 3) mod 1000) / 1000 * 2 * pi, _qr = sqrt(max(0, 1 - _qz * _qz));
				array_push(_sp, { x : _qr * cos(_qa), y : _qz, z : _qr * sin(_qa), r : .05 + .06 * (hash_mix(_seed, 6302 + _q * 3) mod 1000) / 1000 });
			}
			_cregp = { puffs : _sp };
		} else if (_creg == 2) {
			// streaked: six to ten thin belts across the latitudes
			var _st = [];
			var _stn = 6 + (hash_mix(_seed, 6400) mod 5);
			for (var _q = 0; _q < _stn; _q++) array_push(_st, { v : .12 + .76 * (hash_mix(_seed, 6500 + _q * 2) mod 1000) / 1000, w : .010 + .018 * (hash_mix(_seed, 6501 + _q * 2) mod 1000) / 1000 });
			_cregp = { streaks : _st };
		} else if (_creg == 3) {
			// fronts: two to four arcs - each a band about a great circle (its axis), over a window of that circle (its span)
			var _fr = [];
			var _frn = 2 + (hash_mix(_seed, 6600) mod 3);
			for (var _q = 0; _q < _frn; _q++) {
				var _fz = (hash_mix(_seed, 6700 + _q * 5) mod 1000) / 1000 * 2 - 1, _fa = (hash_mix(_seed, 6701 + _q * 5) mod 1000) / 1000 * 2 * pi, _fr2 = sqrt(max(0, 1 - _fz * _fz));
				var _ax = [_fr2 * cos(_fa), _fz, _fr2 * sin(_fa)];
				// a second axis, perpendicular to the first, for the window along the circle
				var _bx = [-_ax[2], 0, _ax[0]], _bl = max(.001, sqrt(_bx[0] * _bx[0] + _bx[2] * _bx[2])); _bx = [_bx[0] / _bl, 0, _bx[2] / _bl];
				var _rot = (hash_mix(_seed, 6702 + _q * 5) mod 1000) / 1000 * 2 * pi;
				var _cx2 = [_ax[1] * _bx[2] - _ax[2] * _bx[1], _ax[2] * _bx[0] - _ax[0] * _bx[2], _ax[0] * _bx[1] - _ax[1] * _bx[0]];
				var _bx2 = [_bx[0] * cos(_rot) + _cx2[0] * sin(_rot), _bx[1] * cos(_rot) + _cx2[1] * sin(_rot), _bx[2] * cos(_rot) + _cx2[2] * sin(_rot)];
				array_push(_fr, { ax : _ax, bx : _bx2, c : (hash_mix(_seed, 6703 + _q * 5) mod 1000) / 1000 * .5 - .25, w : .04 + .04 * (hash_mix(_seed, 6704 + _q * 5) mod 1000) / 1000, span : .55 + .35 * (hash_mix(_seed, 6705 + _q * 5) mod 1000) / 1000 });
			}
			_cregp = { fronts : _fr };
		}
	}
	// ---- the texel sampler's params ----
	var _ps = {
		ctx : _ctx, o1 : _o1, o2 : _o2, o3 : _o3, o4 : _o4,
		kind : _kind, sea : _sea,
		mshift : lerp(-.30, .12, _wet) + ((_kind == "gas") ? 0 : _tt.mshift),   // (+ the temper's lean, q249)
		tt : (_kind == "gas") ? undefined : _tt,   // the terrain's temper (q247) - planet_fields' grammar
		hbase  : max(_sea, .42),
		arch : _arch, craters : _craters,
		theat : (.5 - _clim) * .5 + ((_kind == "gas") ? 0 : _tt.tshift),   // (+ the temper's lean, q249)
		bands : _bands, storm : _storm,
		gstops : _gstops, gstorms : _gstorms, gw : _gw, gseed : (_seed mod 100000), oc : 0,   // (the giant's face - gas_colour; oc = the texel's colour it wrote; q236)
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
				if (_bio <= 2 || _bio == 9 || _bio == 10 || _bio == 11 || _bio == 14 || _bio == 25) continue;
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
		ring : _ring, ring_col : _ringc, ring_col2 : _ringc2, ring_kind : _rkind, ring_in : _rin, ring_out : _rout, ring_seed : _rseed, civ : _civ,
		pal : _pal, glow : _glow, smp : _ps, cbl : _cbl, belts : _belts, dry : _dry,
		gcol : (_kind == "gas") ? array_create(_tw * _th, 0) : undefined,   // THE GIANT'S COLOUR MAP (q236): gas_colour a texel, the terrain sheet's rgb for a gas world
		gloss : _ggloss,   // the giant's sheen (q242; 0 on a rock)
		tt : (_kind == "gas") ? undefined : _tt,   // the terrain's temper (q247), for the passes that read it
		plateau_ask : (!is_undefined(_hint) && (_hint[$ "plateau"] ?? false)),   // (a plateau asked for by the hint - the galaxy's word on a world; q210/q212)
		hint_gal : (!is_undefined(_hint) && !is_undefined(_hint[$ "ring"])),   // (the galaxy's word taken - else planet_get lays it on late; bug hunt 5)
		creg : _creg, cregp : _cregp,   // THE CLOUD REGIME (2026-09-17): 0 cumulus / 1 scattered / 2 streaked / 3 fronts, and its hashed makings
		elev : array_create(_tw * _th, 0), biome : array_create(_tw * _th, 0), carr : array_create(_tw * _th, 0), cthk : array_create(_tw * _th, 0), det : array_create(_tw * _th, 0), moi : array_create(_tw * _th, 0),
		row : 0,            // planet_gen_step's cursor; ready when row == th
		brow : 0,           // planet_bake's cursor: rows stamped across the three textures (0..3*th)
		tsurf : -1, csurf : -1, hsurf : -1,   // planet_bake's textures
	};
}
