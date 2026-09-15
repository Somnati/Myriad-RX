/// @description cbt_skill_gen(seed, [tmpl]) -> a brand-new skill struct
/// PROCEDURAL SKILLS (the tech demo's skill_gen): the same shape as the
/// library's, so the ai, the sheet and the fight use it without knowing
/// it was rolled. Rolled constants are FIELDS (mult, leech, healp, stag)
/// and the methods read them through self, so every generated skill
/// carries its own tuning. Templates: 0 heavy strike, 1 drain, 2 heal,
/// 3 stagger, 4 heavy spell (mag). tmpl -1 = any. The sprite's class
/// says which templates it may roll (sprite_classes).
function cbt_skill_gen(_seed, _tmpl = -1) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _adj  = choose("burning", "void", "swift", "iron", "hollow", "lunar", "static", "grim", "gleam", "thorn",
	                   "soggy", "rude", "polite", "sideways", "tuesday", "loud");
	if (_tmpl < 0) _tmpl = irandom(4);
	var _s = undefined;
	if (_tmpl == 0) {
		_s = {
			name : _adj + " " + choose("fang", "edge", "brand", "breaker", "wallop"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.4, 2.1), magic : false,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = 50 + _t.def * 2 + (mult - 1.4) * 20;
				if (_t.hp < _t.maxhp * .35) _sc += 25;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic); },
		};
	} else if (_tmpl == 1) {
		_s = {
			name : _adj + " " + choose("leech", "siphon", "thirst", "sip"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(.6, 1.0), leech : random_range(.4, .8), magic : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 38 + (1 - _u.hp / _u.maxhp) * 50; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic);
				if (_d > 0) cbt_heal(_f, _u, _d * leech, "");
			},
		};
	} else if (_tmpl == 2) {
		_s = {
			name : _adj + " " + choose("verse", "balm", "light", "chorus", "hum"),
			cost : irandom_range(4, 6), targ : "ally", healp : random_range(.28, .5), magic : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return (1 - _t.hp / _t.maxhp) * (80 + healp * 40); },
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name); },
		};
	} else if (_tmpl == 3) {
		_s = {
			name : _adj + " " + choose("howl", "pulse", "clap", "toll", "shove"),
			cost : irandom_range(2, 4), targ : "enemy", mult : random_range(.55, .8), stag : random_range(.3, .6), magic : false,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 32 + _t.spd * 4 + (_t.tic / _f.thr) * 25; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic);
				if (_d > 0) _t.tic -= _f.thr * stag;
			},
		};
	} else {
		_s = {
			name : _adj + " " + choose("spark", "gust", "hex", "ember", "frost"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.3, 1.9), magic : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = 48 + _t.def * 2 - _t.mdef + (mult - 1.3) * 20;
				if (_t.hp < _t.maxhp * .35) _sc += 20;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic); },
		};
	}
	_s.tmpl = _tmpl;
	rng_release(_old);
	return _s;
}
