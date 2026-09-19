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
	static _pick = function(_seed, _salt, _pool) { return _pool[hash_mix(_seed, _salt) mod array_length(_pool)]; };   // (static: no closure built a call - twice a frame)
	static _sp = [["spring", "early spring", "the thaw", "a green spring", "lambing time", "a wet spring"], ["summer", "high summer", "midsummer", "the long days", "haymaking", "a dry summer"],
	              ["autumn", "the fall of the leaf", "harvest", "late autumn", "the first frosts", "a golden autumn"], ["winter", "deep winter", "midwinter", "the dead of winter", "the short days", "a hard winter"]];
	var _ss = region_season(_d, _rg);   // THE SEASON (2026-09-16): the temperature feels it, and it has a row of its own
	// the level and the mood (region_gen's word and rating)
	array_push(_out, { k : "level " + string(_rg.lv), v : _rg[$ "mood"] ?? "quiet", t : _rg[$ "mood_t"] ?? 0 });
	// REGION LANES (q259): what the crews have changed here, while it lasts (lane_words: the strongest three)
	var _lws = lane_words(_d, _rg[$ "ri"] ?? 0);
	for (var _i = 0; _i < array_length(_lws); _i++) array_push(_out, { k : (_i == 0) ? "lately" : "", v : _lws[_i].v, t : _lws[_i].t, col : _lws[_i].col });
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
	static _plu = function(_w) { if (_w == "marsh") return "marshes"; if (_w == "hills" || _w == "mountains" || _w == "tundra") return _w; return _w + "s"; };
	var _btxt = (_b1 == "") ? "the wild" : (_plu(_b1) + ((_b2 != "" && _n2 >= _n1 * .6) ? (" and " + _plu(_b2)) : ""));
	var _bcol = (_b1 != "" && is_struct(_kk[$ _b1])) ? _kk[$ _b1].col : c_gold;
	array_push(_out, { k : "biome", v : _btxt, t : 0, col : _bcol });
	// TEMPERATURE: the world's climate (0 hot .. 1 frozen) cooled toward the poles
	var _tc = clamp(_pn.clim + abs(_rg.spot.lat) / 90 * .25 - .06 - _ss.warm, 0, 1);   // (the season's shift: summer warmer, winter colder - more on a world tilted far)
	var _tp, _tt;
	// (the pools grown 2026-09-15 - his ask: more words for the properties there are)
	if (_tc < .18)      { _tp = ["scorching", "blistering", "searing", "sun-hammered", "a furnace", "white-hot", "airless heat"]; _tt = 3; }
	else if (_tc < .32) { _tp = ["hot", "sweltering", "baking", "close", "stifling", "sun-baked", "heavy heat"]; _tt = 2; }
	else if (_tc < .45) { _tp = ["warm", "balmy", "sultry", "kindly", "summery", "soft", "warm as bread"]; _tt = 0; }
	else if (_tc < .58) { _tp = ["mild", "temperate", "fair", "gentle", "even", "clement", "spring-like", "easy"]; _tt = 0; }
	else if (_tc < .70) { _tp = ["cool", "brisk", "fresh", "crisp", "sharp", "autumnal", "nippy"]; _tt = 1; }
	else if (_tc < .84) { _tp = ["cold", "chill", "raw", "bleak", "frosty", "biting", "hard"]; _tt = 2; }
	else                { _tp = ["freezing", "bitter", "arctic", "iron-cold", "a deep freeze", "killing cold", "glacial"]; _tt = 3; }
	array_push(_out, { k : "temperature", v : _pick(_rg.seed, 11, _tp), t : _tt });
	// WEATHER, live (his ask: "a current weather somewhere")
	var _slot = floor(universal_now() / 600);
	var _wx = region_weather(_d, _rg);
	var _wp, _wt;
	switch (_wx) {
		case "rain":  _wp = ["rain", "drizzle", "showers", "wet", "a downpour", "steady rain", "thin rain", "sheets of it"]; _wt = 1; break;
		case "snow":  _wp = ["snow", "flurries", "snowfall", "sleet", "a whiteout", "soft snow", "driving snow"]; _wt = 1; break;
		case "wind":  _wp = ["wind", "gusts", "blustery", "a stiff breeze", "squally", "a headwind", "wind off the hills"]; _wt = 1; break;
		case "fog":   _wp = ["fog", "mist", "murk", "haze", "a thick fog", "low cloud", "pea soup"]; _wt = 2; break;
		case "storm": _wp = ["storm", "thunder", "a gale", "lightning", "a tempest", "a squall", "wild weather"]; _wt = 3; break;
		default:      _wp = ["calm", "clear", "still", "fair", "bright", "sunny", "a blue sky", "quiet skies"]; _wt = 0; break;
	}
	array_push(_out, { k : "weather", v : _pick(_rg.seed, _slot, _wp), t : _wt });
	// TIME, live (his ask: "a current time"): the sun over the spot now, and
	// whether it is rising or setting (a look a minute ahead)
	var _dl = region_daylight(_d, _rg), _dl2 = region_daylight(_d, _rg, 60);
	var _rising = (_dl2 > _dl);
	var _hp, _ht;
	// (the bands follow the render's light: sh_planet's lightband runs
	// -.22 dark to .30 full, so anything under .3 reads dusky on the world)
	if (_dl < -.3)       { _hp = ["night", "deep night", "the small hours", "dead of night", "the middle of the night", "full dark", "the long dark"]; _ht = 2; }
	else if (_dl < -.1)  { _hp = _rising ? ["before dawn", "the grey hour", "late night", "the last of the night", "cockcrow", "the wolf hour"] : ["nightfall", "early night", "after dark", "lamplight", "the first stars", "past sundown"]; _ht = 2; }
	else if (_dl < .1)   { _hp = _rising ? ["dawn", "first light", "daybreak", "sunrise", "the grey light", "cold dawn"] : ["dusk", "sundown", "twilight", "the gloaming", "sunset", "the dimming"]; _ht = 1; }
	else if (_dl < .3)   { _hp = _rising ? ["early morning", "the low sun", "morning light", "breakfast time", "the fresh of the day", "a slanting sun"] : ["evening", "the last light", "late evening", "the golden hour", "supper time", "the long shadows"]; _ht = 1; }
	else if (_dl < .55)  { _hp = _rising ? ["morning", "mid-morning", "forenoon", "the working morning", "late morning", "a climbing sun"] : ["afternoon", "late day", "late afternoon", "the slow afternoon", "the sinking sun", "mid-afternoon"]; _ht = 0; }
	else                 { _hp = ["midday", "noon", "high sun", "the middle of the day", "full sun", "the top of the day"]; _ht = 0; }
	array_push(_out, { k : "time", v : _pick(_rg.seed, _slot + 7, _hp), t : _ht });
	// THE ECLIPSE (2026-09-16): a moon's shadow over the region by day
	if (_dl > 0) {
		var _ec = planet_eclipse(_d);
		if (is_struct(_ec)) {
			var _epn = planet_get(_d.seed, exped_planet_hint(_d));
			var _et = [dcos(_rg.spot.lat) * dcos(_rg.spot.lon), dsin(_rg.spot.lat), dcos(_rg.spot.lat) * dsin(_rg.spot.lon)];
			var _ew = mat3_apply(mat3_mul(mat3_rot(0, 0, 1, _epn.tilt), mat3_rot(0, 1, 0, planet_spin_now(_epn))), _et[0], _et[1], _et[2]);
			if (_ew[0] * _ec.dir[0] + _ew[1] * _ec.dir[1] + _ew[2] * _ec.dir[2] > cos(_ec.ang * 1.6)) array_push(_out, { k : "sky", v : "eclipse", t : 1, col : c_lavender });
		}
	}
	// SEASON (2026-09-16): where the region stands, the world's lean toward its sun (region_season); a world with no tilt has none
	if (_ss.on) array_push(_out, { k : "season", v : _pick(_rg.seed, 13 + _ss.idx, _sp[_ss.idx]), t : (_ss.idx == 3) ? 2 : ((_ss.idx == 2) ? 1 : 0) });
	// THE EVENT (2026-09-16): what is on in the region now (region_event), and THE VILLAIN and where the thread stands
	var _ev = region_event(_d, _rg[$ "ri"] ?? 0);
	if (is_struct(_ev)) array_push(_out, { k : "event", v : _ev.txt, t : (_ev.kind == "fair") ? 0 : ((_ev.kind == "rats") ? 1 : 2) });
	var _vil = region_villain(_d, _rg);
	var _seat = seat_get(_d, _rg[$ "ri"] ?? 0);   // (an empty seat - q260)
	if (!is_struct(_vil) && is_struct(_seat) && _seat.left > 0) array_push(_out, { k : "villain", v : "nobody, for now - " + string(max(1, ceil(_seat.left / (24 * EXPED_HOUR)))) + " days until someone", t : 0 });
	// LEADERLESS (q262): the kinds without their chief here, and for how long
	if (is_struct(g.exped[$ "seat"])) {
		var _lk0 = lane_key(_d, _rg[$ "ri"] ?? 0) + ":", _lks = variable_struct_get_names(g.exped.seat), _lrow = "";
		for (var _i = 0; _i < array_length(_lks); _i++) {
			if (string_pos(_lk0, _lks[_i]) != 1) continue;
			var _ls = g.exped.seat[$ _lks[_i]];
			if (_ls.left <= 0) continue;
			_lrow += ((_lrow != "") ? ", " : "") + string_delete(_lks[_i], 1, string_length(_lk0)) + "s (" + string(max(1, ceil(_ls.left / (24 * EXPED_HOUR)))) + "d)";
		}
		if (_lrow != "") array_push(_out, { k : "leaderless", v : _lrow, t : 0, col : c_seagreen });
	}
	var _scs = scar_get(_d, _rg[$ "ri"] ?? 0);   // (the changes that do not fade - q260)
	for (var _i = 0; _i < array_length(_scs); _i++) if (_scs[_i].n >= 0 && _scs[_i].n < array_length(_rg.nodes)) array_push(_out, { k : (_i == 0) ? "changed" : "", v : _rg.nodes[_scs[_i].n].name + ": " + ((_scs[_i][$ "was"] ?? "") != "" ? _scs[_i].was + " -> " : "") + _scs[_i].k, t : 0, col : c_gold });
	if (is_struct(_vil)) {
		var _vm = g.exped[$ "vil"], _vst = 0;
		if (is_struct(_vm)) _vst = _vm[$ string(_d.seed) + ":" + string(_rg[$ "ri"] ?? 0)] ?? 0;
		array_push(_out, { k : "villain", v : _vil.name + " - " + ["at large", "a thread cut", "cornered", "ended"][clamp(_vst, 0, 3)], t : (_vst >= 3) ? 0 : 2 });
	}
	// FLORA: what grows, off the wild kinds the terrain gave the region
	var _wk = _rg[$ "wild"] ?? [], _lush = 0, _dry = 0;
	for (var _i = 0; _i < array_length(_wk); _i++) {
		var _w = _wk[_i];
		if (_w == "field" || _w == "forest" || _w == "marsh" || _w == "isle" || _w == "coast") _lush++;
		if (_w == "desert" || _w == "tundra" || _w == "mountains" || _w == "ruin" || _w == "mine") _dry++;
	}
	var _fp, _ft;
	if (_bi == "ice")                 { _fp = ["sparse", "lichen", "frozen scrub", "moss and ice", "stunted", "wind-bent", "a few hardy things"]; _ft = 2; }
	else if (_bi == "ash")            { _fp = ["ash-grey scrub", "charred", "a few black thorns", "cinder moss", "nothing green", "smoke-bent"]; _ft = 3; }
	else if (_bi == "fungal")         { _fp = ["fungal", "mushroom groves", "spore-thick", "glowing caps", "soft and purple", "toadstools the size of houses"]; _ft = 0; }
	else if (_lush >= 2 && _dry <= 1) { _fp = ["bountiful", "lush", "verdant", "thick", "rampant", "green and deep", "overgrown", "rich"]; _ft = 0; }
	else if (_lush >= 1)              { _fp = ["fair", "modest", "patchy", "scattered", "thin in places", "middling", "hedgerows and copses"]; _ft = 1; }
	else if (_dry >= 1)               { _fp = ["sparse", "hardy", "scrub", "thorn and grit", "tough", "dust and thistle", "clinging"]; _ft = 2; }
	else                              { _fp = ["barren", "bare", "dead", "stone and nothing", "lifeless", "scoured"]; _ft = 3; }
	array_push(_out, { k : "flora", v : _pick(_rg.seed, 13, _fp), t : _ft });
	// FAUNA: the region's rung (lv +0 / +2 / +4), a step worse where the dead walk
	var _fa = clamp((_rg[$ "ri"] ?? 0) + (((_rg[$ "ndun"] ?? 0) >= 3) ? 1 : 0), 0, 3);
	var _ap = [["passive", "timid", "docile", "shy", "meek", "harmless", "grazing", "sleepy"], ["restless", "wary", "hungry", "prowling", "skittish", "watchful", "nosing about", "unsettled"], ["hostile", "savage", "aggressive", "vicious", "snarling", "territorial", "sharp-toothed", "spoiling for it"], ["feral", "monstrous", "ravenous", "deadly", "murderous", "red in tooth", "man-eating", "bloody-minded"]][_fa];
	array_push(_out, { k : "fauna", v : _pick(_rg.seed, 17, _ap), t : _fa });
	// HAZARDS (2026-09-15): what its places do to a bare crew (cbt_hazards)
	var _rh = region_hazards(_rg, _d), _rht = "";   // (the season's hazards too, 2026-09-16)
	for (var _i = 0; _i < array_length(_rh); _i++) _rht += ((_i > 0) ? ", " : "") + _rh[_i].name;
	array_push(_out, { k : "hazards", v : (_rht == "") ? "none" : _rht, t : min(2, array_length(_rh)), col : (array_length(_rh) > 0) ? _rh[0].col : undefined });
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
	var _cp = [["wilderness", "none", "empty", "nobody's land", "unpeopled", "the back of beyond"], ["farmlands", "homesteads", "hamlets", "crofts", "smallholdings", "a few chimneys", "scattered farms"], ["villages", "parishes", "a village or two", "village greens", "steeples and inns", "a scatter of villages"], ["towns", "market towns", "townships", "a fair-sized town", "walls and markets", "a busy town"], ["a city", "a walled city", "cities", "a city and its sprawl", "spires and gates", "a proper city"]][_top];
	array_push(_out, { k : "civilization", v : _pick(_rg.seed, 19, _cp), t : (_top == 0) ? 2 : 0 });
	return _out;
}
