/// @description exped_quest_gen(dest, [salt], [ri]) -> a quest { kind, node, foe, n, done, txt, mult, reward, hours, diff, diff_txt, lv }
/// THE QUEST (his pitch: "travel to the cave of ordeals and slay 10
/// goblins"), rolled from the region and the board's deal:
///   slay   n foes of a kind at a dungeon / camp / the wild   (mult 3)
///   clear  a dungeon, n rooms                                (mult 4)
///   rout   the bandits at a camp, two fights                 (mult 4)
///   scout  a far place - get there                           (mult 2)
/// mult is the quest's xp in par kills (his law: 2..5 - the top for
/// the long ones: +1 for every four hours out); reward = credits home
/// ((2 + the region's level) x mult). hours = the roads out from the
/// landing zone nearest the objective (that is where the crew lands).
function exped_quest_gen(_d, _salt = 0, _ri = 0) {
	var _rg = region_get(_d, _ri);
	var _old = random_get_seed();
	random_set_seed((_rg.seed ^ (g.exped.seq * 7919) ^ (1237 + _salt * 104729)) & $7fffffff);
	var _dung = [], _camp = [], _wild = [];
	var _kk = region_kinds();
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _k = _rg.nodes[_i].kind;
		if (_k == "dungeon" || _k == "crypt") array_push(_dung, _i);
		else if (_k == "camp") array_push(_camp, _i);
		else { var _kd = _kk[$ _k]; if (is_struct(_kd) && _kd.wild) array_push(_wild, _i); }
	}
	var _kinds = ["goblin", "wolf", "rat", "skeleton", "wisp", "slime"];
	var _r = random(100);
	var _q;
	if (_r < 45 && array_length(_dung) > 0) {
		var _nd = _dung[irandom(array_length(_dung) - 1)];
		if (random(1) < .6) {
			var _f = (_rg.nodes[_nd].kind == "crypt") ? choose("skeleton", "wisp") : _kinds[irandom(array_length(_kinds) - 1)];
			var _n = irandom_range(3, 8);
			_q = { kind : "slay", node : _nd, foe : _f, n : _n, done : 0, mult : 3,
			       txt : "travel to " + _rg.nodes[_nd].name + " and slay " + string(_n) + " " + _f + "s" };
		} else {
			var _n = irandom_range(3, 5);
			_q = { kind : "clear", node : _nd, foe : "", n : _n, done : 0, mult : 4,
			       txt : "clear " + _rg.nodes[_nd].name + " (" + string(_n) + " rooms)" };
		}
	} else if (_r < 70 && array_length(_camp) > 0) {
		var _nc = _camp[irandom(array_length(_camp) - 1)];
		_q = { kind : "rout", node : _nc, foe : "bandit", n : 2, done : 0, mult : 4,
		       txt : "rout the bandits at " + _rg.nodes[_nc].name };
	} else if (array_length(_wild) > 0) {
		var _nw = _wild[irandom(array_length(_wild) - 1)];
		var _f = _kinds[irandom(array_length(_kinds) - 1)];
		var _n = irandom_range(2, 5);
		if (random(1) < .5) _q = { kind : "slay", node : _nw, foe : _f, n : _n, done : 0, mult : 3,
		                           txt : "go to " + _rg.nodes[_nw].name + " and slay " + string(_n) + " " + _f + "s" };
		else _q = { kind : "scout", node : _nw, foe : "", n : 1, done : 0, mult : 2,
		            txt : "scout " + _rg.nodes[_nw].name + " and come back" };
	} else {
		var _nd2 = max(1, array_length(_rg.nodes) - 1);
		_q = { kind : "scout", node : _nd2, foe : "", n : 1, done : 0, mult : 2, txt : "scout " + _rg.nodes[_nd2].name };
	}
	// the length: hours out by the roads, from the landing zone nearest the objective
	var _home = region_nearest_landing(_rg, _q.node);
	var _p = region_path(_rg, _home, _q.node);
	var _h = 0, _c = _home;
	for (var _k = 0; _k < array_length(_p); _k++) { _h += region_hours(_rg, _c, _p[_k]); _c = _p[_k]; }
	_q.hours = _h;
	_q.home = _home;
	_q.ri = _ri;
	_q.lv = _rg.lv;
	_q.mult = clamp(_q.mult + floor(_h / 4), SPRITE_QUEST_XP_LO, SPRITE_QUEST_XP_HI);
	_q.reward = (2 + _rg.lv) * _q.mult;
	// the difficulty, in a word (the departure window): by the kind, the count, the hours
	var _df = 1;
	if (_q.kind == "slay") _df = (_q.n >= 6) ? 2 : 1;
	if (_q.kind == "clear") _df = 2;
	if (_q.kind == "rout") _df = 2;
	if (_q.kind == "scout") _df = 0;
	if (_h >= 6) _df += 1;
	_q.diff = _df;
	_q.diff_txt = ["easy", "fair", "hard", "grim"][clamp(_df, 0, 3)];
	rng_release(_old);
	return _q;
}
