/// @description region_info(dest, region) -> the info box's lines (the planet page's banner): [{ k, v, t }] - the label, the word, its threat 0..3
/// HIS SHAPE (2026-09-15): "Level 1 - peaceful / temperature - warm /
/// weather - calm / flora - bountiful / fauna - passive / civilization -
/// farmlands", the word coloured by its threat (green / gold / orange /
/// red - the difficulty palette) and picked from a pool by the region's
/// seed so regions differ in their wording. The weather and the time
/// are LIVE (region_weather / region_daylight; a ten-minute slot picks
/// their word, so they hold still while you read).
function region_info(_d, _rg) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _bi = exped_biomes()[_d.biome].name;
	var _out = [];
	var _pick = function(_seed, _salt, _pool) { return _pool[hash_mix(_seed, _salt) mod array_length(_pool)]; };
	// the level and the mood (region_gen's word and rating)
	array_push(_out, { k : "level " + string(_rg.lv), v : _rg[$ "mood"] ?? "quiet", t : _rg[$ "mood_t"] ?? 0 });
	// BIOME (his ask, 2026-09-15): the wild kind most of the region is - the
	// second named too when it is nearly as common; in the kind's colour
	var _kk = region_kinds(), _cnt = {};
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _nk = _rg.nodes[_i].kind, _nkd = _kk[$ _nk];
		if (!is_struct(_nkd) || !_nkd.wild) continue;
		_cnt[$ _nk] = (_cnt[$ _nk] ?? 0) + 1;
	}
	var _cks = variable_struct_get_names(_cnt), _b1 = "", _b2 = "", _n1 = 0, _n2 = 0;
	for (var _i = 0; _i < array_length(_cks); _i++) {
		var _cn = _cnt[$ _cks[_i]];
		if (_cn > _n1) { _b2 = _b1; _n2 = _n1; _b1 = _cks[_i]; _n1 = _cn; }
		else if (_cn > _n2) { _b2 = _cks[_i]; _n2 = _cn; }
	}
	var _plu = function(_w) { if (_w == "marsh") return "marshes"; if (_w == "hills" || _w == "mountains" || _w == "tundra") return _w; return _w + "s"; };
	var _btxt = (_b1 == "") ? "the wild" : (_plu(_b1) + ((_b2 != "" && _n2 >= _n1 * .6) ? (" and " + _plu(_b2)) : ""));
	var _bcol = (_b1 != "" && is_struct(_kk[$ _b1])) ? _kk[$ _b1].col : c_gold;
	array_push(_out, { k : "biome", v : _btxt, t : 0, col : _bcol });
	// TEMPERATURE: the world's climate (0 hot .. 1 frozen) cooled toward the poles
	var _tc = clamp(_pn.clim + abs(_rg.spot.lat) / 90 * .25 - .06, 0, 1);
	var _tp, _tt;
	if (_tc < .18)      { _tp = ["scorching", "blistering", "searing"]; _tt = 3; }
	else if (_tc < .32) { _tp = ["hot", "sweltering", "baking"]; _tt = 2; }
	else if (_tc < .45) { _tp = ["warm", "balmy", "sultry"]; _tt = 0; }
	else if (_tc < .58) { _tp = ["mild", "temperate", "fair", "gentle"]; _tt = 0; }
	else if (_tc < .70) { _tp = ["cool", "brisk", "fresh"]; _tt = 1; }
	else if (_tc < .84) { _tp = ["cold", "chill", "raw"]; _tt = 2; }
	else                { _tp = ["freezing", "bitter", "arctic"]; _tt = 3; }
	array_push(_out, { k : "temperature", v : _pick(_rg.seed, 11, _tp), t : _tt });
	// WEATHER, live (his ask: "a current weather somewhere")
	var _slot = floor(universal_now() / 600);
	var _wx = region_weather(_d, _rg);
	var _wp, _wt;
	switch (_wx) {
		case "rain":  _wp = ["rain", "drizzle", "showers", "wet"]; _wt = 1; break;
		case "snow":  _wp = ["snow", "flurries", "snowfall"]; _wt = 1; break;
		case "wind":  _wp = ["wind", "gusts", "blustery"]; _wt = 1; break;
		case "fog":   _wp = ["fog", "mist", "murk"]; _wt = 2; break;
		case "storm": _wp = ["storm", "thunder", "a gale"]; _wt = 3; break;
		default:      _wp = ["calm", "clear", "still", "fair"]; _wt = 0; break;
	}
	array_push(_out, { k : "weather", v : _pick(_rg.seed, _slot, _wp), t : _wt });
	// TIME, live (his ask: "a current time"): the sun over the spot now, and
	// whether it is rising or setting (a look a minute ahead)
	var _dl = region_daylight(_d, _rg), _dl2 = region_daylight(_d, _rg, 60);
	var _rising = (_dl2 > _dl);
	var _hp, _ht;
	// (the bands follow the render's light: sh_planet's lightband runs
	// -.22 dark to .30 full, so anything under .3 reads dusky on the world)
	if (_dl < -.3)       { _hp = ["night", "deep night", "the small hours", "dead of night"]; _ht = 2; }
	else if (_dl < -.1)  { _hp = _rising ? ["before dawn", "the grey hour", "late night"] : ["nightfall", "early night", "after dark"]; _ht = 2; }
	else if (_dl < .1)   { _hp = _rising ? ["dawn", "first light", "daybreak"] : ["dusk", "sundown", "twilight"]; _ht = 1; }
	else if (_dl < .3)   { _hp = _rising ? ["early morning", "the low sun", "morning light"] : ["evening", "the last light", "late evening"]; _ht = 1; }
	else if (_dl < .55)  { _hp = _rising ? ["morning", "mid-morning", "forenoon"] : ["afternoon", "late day", "late afternoon"]; _ht = 0; }
	else                 { _hp = ["midday", "noon", "high sun"]; _ht = 0; }
	array_push(_out, { k : "time", v : _pick(_rg.seed, _slot + 7, _hp), t : _ht });
	// FLORA: what grows, off the wild kinds the terrain gave the region
	var _wk = _rg[$ "wild"] ?? [], _lush = 0, _dry = 0;
	for (var _i = 0; _i < array_length(_wk); _i++) {
		var _w = _wk[_i];
		if (_w == "field" || _w == "forest" || _w == "marsh" || _w == "isle" || _w == "coast") _lush++;
		if (_w == "desert" || _w == "tundra" || _w == "mountains" || _w == "ruin" || _w == "mine") _dry++;
	}
	var _fp, _ft;
	if (_bi == "ice")                 { _fp = ["sparse", "lichen", "frozen scrub"]; _ft = 2; }
	else if (_lush >= 2 && _dry <= 1) { _fp = ["bountiful", "lush", "verdant", "thick"]; _ft = 0; }
	else if (_lush >= 1)              { _fp = ["fair", "modest", "patchy", "scattered"]; _ft = 1; }
	else if (_dry >= 1)               { _fp = ["sparse", "hardy", "scrub"]; _ft = 2; }
	else                              { _fp = ["barren", "bare", "dead"]; _ft = 3; }
	array_push(_out, { k : "flora", v : _pick(_rg.seed, 13, _fp), t : _ft });
	// FAUNA: the region's rung (lv +0 / +2 / +4), a step worse where the dead walk
	var _fa = clamp((_rg[$ "ri"] ?? 0) + (((_rg[$ "ndun"] ?? 0) >= 3) ? 1 : 0), 0, 3);
	var _ap = [["passive", "timid", "docile", "shy"], ["restless", "wary", "hungry", "prowling"], ["hostile", "savage", "aggressive", "vicious"], ["feral", "monstrous", "ravenous", "deadly"]][_fa];
	array_push(_out, { k : "fauna", v : _pick(_rg.seed, 17, _ap), t : _fa });
	// CIVILIZATION: the biggest place there is
	var _top = 0;
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		switch (_rg.nodes[_i].kind) {
			case "settlement": _top = max(_top, 1); break;
			case "village":    _top = max(_top, 2); break;
			case "town":       _top = max(_top, 3); break;
			case "city":       _top = max(_top, 4); break;
		}
	}
	var _cp = [["wilderness", "none", "empty"], ["farmlands", "homesteads", "hamlets", "crofts"], ["villages", "parishes", "a village or two"], ["towns", "market towns", "townships"], ["a city", "a walled city", "cities"]][_top];
	array_push(_out, { k : "civilization", v : _pick(_rg.seed, 19, _cp), t : (_top == 0) ? 2 : 0 });
	return _out;
}
