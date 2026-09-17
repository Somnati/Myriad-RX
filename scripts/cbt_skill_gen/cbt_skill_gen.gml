/// @description cbt_skill_gen(seed, [tmpl]) -> a brand-new skill struct
/// off a seed: a template, a name, numbers inside the template's band. A
/// sprite learns these (sprite_skill_learn) and keeps only the seed and
/// the template; the skill is rebuilt from them every time.
/// Templates: 0 heavy blow, 1 leech (dark: the hit heals and MARKS), 2
/// heal (light: mends and eases one ailment), 3 stagger, 4 spell (an
/// element: fire / water / nature), 5 venom or chill (a physical hit that
/// poisons - nature - or slows - water), 6 blessing (light: raises an
/// ally's atk / def / hit, or hastens), 7 hex (dark: a small hit that
/// lowers an enemy's atk / def / hit), 8 cleanse (light: a small heal
/// that strips every dark effect). tmpl -1 = any. THE ELEMENTS PASS
/// (2026-09-17): every damage skill names its element ("" = untyped),
/// every effect skill its school.
function cbt_skill_gen(_seed, _tmpl = -1) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _adj  = choose("burning", "void", "swift", "iron", "hollow", "lunar", "static", "grim", "gleam", "thorn",
	                   "soggy", "rude", "polite", "sideways", "tuesday", "loud");
	if (_tmpl < 0) _tmpl = irandom(8);
	var _s = undefined;
	if (_tmpl == 0) {
		// a heavy blow - one time in three it carries an element (the weapon's kind of thing)
		var _el0 = (random(1) < .34) ? choose("fire", "water", "nature") : "";
		_s = {
			name : _adj + " " + choose("fang", "edge", "brand", "breaker", "wallop"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.4, 2.1), magic : false, elem : _el0, school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = 50 + _t.def * 2 + (mult - 1.4) * 20;
				if (_t.hp < _t.maxhp * .35) _sc += 25;
				if (elem != "" && is_struct(_t[$ "res"])) _sc -= (_t.res[$ elem] ?? 0) * .5;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		};
	} else if (_tmpl == 1) {
		_s = {
			name : _adj + " " + choose("leech", "siphon", "thirst", "sip"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(.6, 1.0), leech : random_range(.4, .8), magic : true, elem : "", school : "dark",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 38 + (1 - _u.hp / _u.maxhp) * 50; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem, "leech");
				if (_d > 0) cbt_heal(_f, _u, _d * leech, "");
			},
		};
	} else if (_tmpl == 2) {
		_s = {
			name : _adj + " " + choose("verse", "balm", "light", "chorus", "hum"),
			cost : irandom_range(4, 6), targ : "ally", healp : random_range(.28, .5), magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = (1 - _t.hp / _t.maxhp) * (80 + healp * 40);
				if (is_struct(_t[$ "ail"]) && (_t.ail.poison > 0 || _t.ail.slow > 0 || _t.ail.leech > 0)) _sc += 20;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name, _u); cbt_purge(_f, _t, "light", true); },
		};
	} else if (_tmpl == 3) {
		_s = {
			name : _adj + " " + choose("howl", "pulse", "clap", "toll", "shove"),
			cost : irandom_range(2, 4), targ : "enemy", mult : random_range(.55, .8), stag : random_range(.3, .6), magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 32 + _t.spd * 4 + (_t.tic / _f.thr) * 25; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) _t.tic -= _f.thr * stag;
			},
		};
	} else if (_tmpl == 4) {
		// the spell: always an element, named for it
		var _el4 = choose("fire", "water", "nature");
		var _nn4 = (_el4 == "fire") ? choose("ember", "flare", "cinder", "pyre") : ((_el4 == "water") ? choose("frost", "tide", "drench", "hail") : choose("spark", "thorn", "bramble", "gust"));
		_s = {
			name : _adj + " " + _nn4,
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.3, 1.9), magic : true, elem : _el4, school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = 48 + _t.def * 2 - _t.mdef + (mult - 1.3) * 20;
				if (_t.hp < _t.maxhp * .35) _sc += 20;
				if (is_struct(_t[$ "res"])) _sc -= (_t.res[$ elem] ?? 0) * .5;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		};
	} else if (_tmpl == 5) {
		// venom (nature: poison) or chill (water: slow) - a physical hit that leaves something behind
		var _poison = (random(1) < .5);
		_s = {
			name : _adj + " " + (_poison ? choose("sting", "bite", "barb") : choose("chill", "soak", "sleet")),
			cost : irandom_range(3, 4), targ : "enemy", mult : random_range(.8, 1.1), magic : false,
			elem : _poison ? "nature" : "water", school : "", ail : _poison ? "poison" : "slow",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _sc = 40 + (_t.maxhp / max(1, _u.maxhp)) * 10;
				if (is_struct(_t[$ "ail"]) && (_t.ail[$ ail] ?? 0) > 0) _sc = 12;   // (already on it: little point)
				if (is_struct(_t[$ "res"])) _sc -= (_t.res[$ elem] ?? 0) * .5;
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem, ail); },
		};
	} else if (_tmpl == 6) {
		// the blessing (light): one stat up on an ally, or haste
		var _bk = choose("buf_atk", "buf_def", "buf_hit", "haste");
		_s = {
			name : _adj + " " + choose("hymn", "ward", "march", "vigil"),
			cost : irandom_range(3, 5), targ : "ally", magic : true, elem : "", school : "light", buf : _bk,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _on = false;
				if (buf == "haste") _on = is_struct(_t[$ "bf"]) && _t.bf.spd > 0;
				else _on = is_struct(_t[$ "bf"]) && (_t.bf[$ string_delete(buf, 1, 4)] ?? 0) > 0;
				if (_on) return 0;
				var _sc = 42 + (_t.hp / _t.maxhp) * 10;   // (a blessing on someone who will live to use it)
				if (buf != "haste" && is_struct(_t[$ "nf"]) && (_t.nf[$ string_delete(buf, 1, 4)] ?? 0) > 0) _sc += 25;   // (it lifts a nerf)
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _t, buf); },
		};
	} else if (_tmpl == 7) {
		// the hex (dark): a small hit, and one stat down on the enemy
		var _nk = choose("nerf_atk", "nerf_def", "nerf_hit");
		_s = {
			name : _adj + " " + choose("hex", "curse", "gloom", "murmur"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(.4, .6), magic : true, elem : "", school : "dark", nerf : _nk,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _k = string_delete(nerf, 1, 5);
				if (is_struct(_t[$ "nf"]) && (_t.nf[$ _k] ?? 0) > 0) return 10;
				var _sc = 40 + _t[$ _k] * 2;   // (the bigger the stat, the more there is to take)
				if (is_struct(_t[$ "bf"]) && (_t.bf[$ _k] ?? 0) > 0) _sc += 25;   // (it undoes a buff)
				return _sc;
			},
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) cbt_status(_f, _u, _t, nerf);
			},
		};
	} else {
		// the cleanse (light): a small heal and every dark effect stripped
		_s = {
			name : _adj + " " + choose("dawn", "rinse", "clarion", "bell"),
			cost : irandom_range(4, 6), targ : "ally", healp : random_range(.12, .2), magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _dark = 0;
				if (is_struct(_t[$ "ail"])) _dark += (_t.ail.poison > 0) + (_t.ail.slow > 0) + (_t.ail.leech > 0);
				if (is_struct(_t[$ "nf"])) _dark += (_t.nf.atk > 0) + (_t.nf.def > 0) + (_t.nf.hit > 0);
				if (_dark == 0) return 0;
				return 55 + _dark * 15 + (1 - _t.hp / _t.maxhp) * 20;
			},
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name, _u); cbt_purge(_f, _t, "light", false); },
		};
	}
	_s.tmpl = _tmpl;
	rng_release(_old);
	return _s;
}
