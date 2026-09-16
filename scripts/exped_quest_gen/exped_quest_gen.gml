/// @description exped_quest_gen(dest, [salt], [ri], [easy]) -> a quest { kind, node, from, at, nodes, who, foe, n, done, txt, mult, reward, hours, diff, diff_txt, lv, place, pi }
/// THE QUEST (his pitch: "travel to the cave of ordeals and slay 10
/// goblins"), rolled from the region and the board's deal. ELEVEN KINDS
/// (the mission-type pass, 2026-09-15):
///   slay    n foes of a kind at a dungeon / the wild                    (mult 3)
///   clear   a dungeon, its rooms                                        (mult 4)
///   rout    the bandits at a camp, two fights                           (mult 4)
///   scout   a far place - get there                                     (mult 2)
///   escort  a merchant town to town (bandits like a cart on the road)   (mult 3)
///   fetch   a thing from a ruin / shrine / mine / the wild to a town    (mult 3)
///   rescue  someone lost in a dungeon / the wild, room by room, home    (mult 4)
///   bounty  a NAMED boss at a dungeon / camp / the wild - one big fight (mult 4)
///   defend  a town against n waves, patched up between                  (mult 4)
///   survey  chart n places, nearest first                               (mult 3)
///   gather  n sacks of ore from a mine                                  (mult 3)
/// The two-stop kinds carry from -> node and `at` (the first stop done);
/// exped_quest_target says where the crew heads now. pi = the card's
/// place (the first stop). who = the merchant / the cargo / the lost one
/// / the boss / the ore. The deal weighs every kind the region can host
/// and ONE roll picks (the same salt deals the same quest). mult is the
/// quest's xp in par kills (his law: 2..5 - the top for the long ones:
/// +1 for every four hours out); reward = credits home ((2 + the
/// region's level) x mult). hours = the roads from the landing zone
/// nearest the first stop, through every stop. txt by exped_quest_txt.
/// Seeded by the region and the SALT alone (the offer's slot counter,
/// exped_region_quests - a quest holds still while trips leave). easy =
/// a short one on purpose (a scout or a small slay at the nearest wild):
/// the offer keeps one easy quest up at all times (his ask).
function exped_quest_gen(_d, _salt = 0, _ri = 0, _easy = false) {
	var _rg = region_get(_d, _ri);
	var _old = random_get_seed();
	random_set_seed((_rg.seed ^ (1237 + _salt * 104729) ^ 2654435) & $7fffffff);
	var _dung = [], _camp = [], _wild = [], _civ = [], _mine = [], _spec = [], _any = [];
	var _kk = region_kinds();
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) {
		var _k = _rg.nodes[_i].kind;
		if (_k == "landing") continue;
		array_push(_any, _i);
		if (_k == "dungeon" || _k == "crypt") array_push(_dung, _i);
		else if (_k == "camp") array_push(_camp, _i);
		else {
			var _kd = _kk[$ _k];
			if (is_struct(_kd) && _kd.civ) array_push(_civ, _i);
			else if (is_struct(_kd) && _kd.wild) {
				array_push(_wild, _i);
				if (_k == "mine") array_push(_mine, _i);
				if (_k == "ruin" || _k == "shrine" || _k == "mine") array_push(_spec, _i);
			}
		}
	}
	static _pick  = function(_a) { return _a[irandom(array_length(_a) - 1)]; };
	static _other = function(_a, _not) { if (array_length(_a) <= 1) return _a[0]; var _v; do { _v = _a[irandom(array_length(_a) - 1)]; } until (_v != _not); return _v; };
	static _hrs   = function(_rg2, _a, _b) { var _p = region_path(_rg2, _a, _b), _h = 0, _c = _a; for (var _k = 0; _k < array_length(_p); _k++) { _h += region_hours(_rg2, _c, _p[_k]); _c = _p[_k]; } return _h; };
	var _q = undefined;
	if (_easy && array_length(_wild) > 0) {
		// THE EASY ONE: the wild place with the shortest road from a landing zone
		var _ne = _wild[0], _neh = 999;
		for (var _wi = 0; _wi < array_length(_wild); _wi++) {
			var _wh = _hrs(_rg, region_nearest_landing(_rg, _wild[_wi]), _wild[_wi]);
			if (_wh < _neh) { _neh = _wh; _ne = _wild[_wi]; }
		}
		if (random(1) < .5) _q = { kind : "scout", node : _ne, foe : "", n : 1, mult : 2 };
		else _q = { kind : "slay", node : _ne, foe : choose("rat", "slime"), n : irandom_range(2, 3), mult : 3 };
	} else {
		// THE DEAL: every kind the region can host, weighted; one roll picks
		var _w = [];
		if (array_length(_dung) > 0) { array_push(_w, ["slay_d", 10]); array_push(_w, ["clear", 8]); }
		if (array_length(_camp) > 0) array_push(_w, ["rout", 8]);
		if (array_length(_dung) + array_length(_camp) + array_length(_wild) > 0) array_push(_w, ["bounty", 8]);
		if (array_length(_civ) >= 2) array_push(_w, ["escort", 8]);
		if (array_length(_civ) > 0 && array_length(_spec) + array_length(_wild) > 0) array_push(_w, ["fetch", 9]);
		if (array_length(_civ) > 0 && array_length(_dung) + array_length(_wild) > 0) array_push(_w, ["rescue", 8]);
		if (array_length(_civ) > 0) array_push(_w, ["defend", 8]);
		if (array_length(_any) >= 2) array_push(_w, ["survey", 8]);
		if (array_length(_mine) > 0) array_push(_w, ["gather", 6]);
		if (array_length(_wild) > 0) { array_push(_w, ["slay_w", 10]); array_push(_w, ["scout", 9]); }
		var _sum = 0;
		for (var _i = 0; _i < array_length(_w); _i++) _sum += _w[_i][1];
		var _r = random(max(1, _sum)), _kind = "scout";
		for (var _i = 0; _i < array_length(_w); _i++) { if (_r < _w[_i][1]) { _kind = _w[_i][0]; break; } _r -= _w[_i][1]; }
		switch (_kind) {
			case "slay_d": { var _nd = _pick(_dung); var _f = _pick(foe_kinds_at(_rg.nodes[_nd].kind)); _q = { kind : "slay", node : _nd, foe : _f, n : irandom_range(3, 8), mult : 3 }; break; }   // (the place's own kinds - the foes pass)
			case "clear":  { var _nd = _pick(_dung); var _n = irandom_range(3, 5); var _rm = _rg.nodes[_nd][$ "rooms"]; if (!is_undefined(_rm)) _n = _rm; _q = { kind : "clear", node : _nd, foe : "", n : _n, mult : 4 }; break; }
			case "rout":   _q = { kind : "rout", node : _pick(_camp), foe : "bandit", n : 2, mult : 4 }; break;
			case "bounty": {
				var _nd = _pick(array_concat(_dung, _camp, _wild)), _nk = _rg.nodes[_nd].kind;
				var _f = (_nk == "camp") ? "bandit" : _pick(foe_kinds_at(_nk));
				var _who = exped_npc_name() + " the " + _f + " " + choose("chief", "elder", "king", "of unusual size", "with a hat", "the second", "the unwashed", "who bites", "the loud");
				_q = { kind : "bounty", node : _nd, foe : _f, n : 1, mult : 4, who : _who };
				break;
			}
			case "escort": {
				var _a = _pick(_civ), _b = _other(_civ, _a);
				_q = { kind : "escort", node : _b, from : _a, foe : "bandit", n : 1, mult : 3, who : exped_npc_name() + " the merchant" };
				break;
			}
			case "fetch": {
				var _a = _pick(array_concat(_spec, _spec, _wild)), _b = _pick(_civ);
				var _cargo = choose("a letter", "a lost goat", "grandma's kettle", "a crate of something", "the key to nothing", "a jar of the good honey", "a very heavy book", "a spare wheel",
				                    "the miller's cat", "an urgent parcel (ticking)", "a bag of seed", "the good ladder", "a barrel of pickles", "somebody's hat", "a map of somewhere else", "one shoe");
				_q = { kind : "fetch", node : _b, from : _a, foe : "", n : 1, mult : 3, who : _cargo };
				break;
			}
			case "rescue": {
				var _a = _pick(array_concat(_dung, _dung, _wild)), _b = _pick(_civ);
				_q = { kind : "rescue", node : _b, from : _a, foe : "", n : 1, mult : 4, who : exped_npc_name() };
				break;
			}
			case "defend": _q = { kind : "defend", node : _pick(_civ), foe : choose("goblin", "bandit", "wolf", "rat", "kobold", "boar", "hornets"), n : irandom_range(2, 3), mult : 4 }; break;
			case "survey": {
				// n places, then walked nearest-first from the landing zone
				var _n = min(3, array_length(_any)), _left = array_concat(_any), _picked = [];
				repeat (_n) { var _pi2 = irandom(array_length(_left) - 1); array_push(_picked, _left[_pi2]); array_delete(_left, _pi2, 1); }
				var _ns = [], _c = _rg.landing;
				while (array_length(_picked) > 0) {
					var _bi = 0, _bh = 999999;
					for (var _i = 0; _i < array_length(_picked); _i++) { var _hh = _hrs(_rg, _c, _picked[_i]); if (_hh < _bh) { _bh = _hh; _bi = _i; } }
					_c = _picked[_bi]; array_push(_ns, _c); array_delete(_picked, _bi, 1);
				}
				_q = { kind : "survey", node : _ns[array_length(_ns) - 1], nodes : _ns, foe : "", n : array_length(_ns), mult : 3 };
				break;
			}
			case "gather": _q = { kind : "gather", node : _pick(_mine), foe : "", n : irandom_range(2, 4), mult : 3, who : ["ferrite", "bloom", "glass"][_d.biome mod 3] }; break;
			case "slay_w": { var _nw = _pick(_wild); _q = { kind : "slay", node : _nw, foe : _pick(foe_kinds_at(_rg.nodes[_nw].kind)), n : irandom_range(2, 5), mult : 3 }; break; }
			default:       _q = { kind : "scout", node : (array_length(_wild) > 0) ? _pick(_wild) : _pick(_any), foe : "", n : 1, mult : 2 }; break;
		}
	}
	_q.done = 0;
	if (is_undefined(_q[$ "from"])) _q.from = -1;
	_q.at = 0;
	if (is_undefined(_q[$ "who"])) _q.who = "";
	_q.pi = (_q.from >= 0) ? _q.from : (is_array(_q[$ "nodes"]) ? _q.nodes[0] : _q.node);
	// the length: hours by the roads from the landing zone nearest the first stop, through every stop
	var _stops = exped_quest_places(_q);
	var _home = region_nearest_landing(_rg, _stops[0]);
	var _h = 0, _c2 = _home;
	for (var _s = 0; _s < array_length(_stops); _s++) { _h += _hrs(_rg, _c2, _stops[_s]); _c2 = _stops[_s]; }
	_q.hours = _h;
	_q.home = _home;
	_q.ri = _ri;
	_q.lv = _rg.lv;
	_q.mult = clamp(_q.mult + floor(_h / 4), SPRITE_QUEST_XP_LO, SPRITE_QUEST_XP_HI);
	_q.reward = (2 + _rg.lv) * _q.mult;
	// the difficulty, in a word (the departure window): by the kind, the count, the hours
	var _df = 1;
	switch (_q.kind) {
		case "slay":  _df = (_q.n >= 6) ? 2 : ((_q.n <= 3) ? 0 : 1); break;   // (a small slay is easy - 2026-09-15)
		case "clear": case "rout": case "rescue": case "bounty": case "defend": _df = 2; break;
		case "scout": _df = 0; break;
		default:      _df = 1; break;   // escort, fetch, survey, gather
	}
	if (_h >= 6) _df += 1;
	if (_easy) _df = 0;
	_q.diff = _df;
	_q.place = _rg.nodes[_q.pi].name;   // (the card colours it by the place's kind)
	_q.diff_txt = ["easy", "fair", "hard", "grim"][clamp(_df, 0, 3)];
	_q.txt = exped_quest_txt(_q, _rg);
	rng_release(_old);
	return _q;
}
