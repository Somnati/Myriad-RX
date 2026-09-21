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
	if (_tmpl < 0) _tmpl = irandom(23);   // (twenty-four templates since q312)
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
	} else if (_tmpl == 8) {
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
	} else if (_tmpl == 9 || _tmpl == 10) {
		// THE BARRIER / THE WARD (light, q312 - ff7 remake's pair): an ally takes blows (9) or spells (10) at barrier_pct less
		var _bw = (_tmpl == 9);
		_s = {
			name : _adj + " " + (_bw ? choose("wall", "bulwark", "shell", "bastion") : choose("veil", "aegis", "sigil", "hush")),
			cost : irandom_range(3, 5), targ : "ally", magic : true, elem : "", school : "light", buf : _bw ? "barrier" : "manaward", lane : _bw ? "pres" : "mres",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if (is_struct(_t[$ "bf"]) && (_t.bf[$ lane] ?? 0) > 0) return 0;
				var _kind = 0, _all = 0;
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team == _t.team) continue; _all++; if ((lane == "pres") ? !_p.magic : _p.magic) _kind++; }
				if (_all == 0) return 0;
				var _sc = 28 + 34 * (_kind / _all) + (1 - _t.hp / _t.maxhp) * 25;
				if (is_struct(_t[$ "nf"]) && (_t.nf[$ lane] ?? 0) > 0) _sc += 25;   // (it lifts the breach)
				return _sc;
			},
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _t, buf); },
		};
	} else if (_tmpl == 11 || _tmpl == 12) {
		// THE BREACH / THE UNWARDING (dark): a small hit, and the enemy takes blows (11) or spells (12) at barrier_pct more
		var _br = (_tmpl == 11);
		_s = {
			name : _adj + " " + (_br ? choose("rend", "cleave", "sunder", "crack") : choose("rift", "unmaking", "fray", "gloaming")),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(.45, .7), magic : !_br, elem : "", school : "dark", nerf : _br ? "breach" : "unward", lane : _br ? "pres" : "mres",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if (is_struct(_t[$ "nf"]) && (_t.nf[$ lane] ?? 0) > 0) return 10;
				var _sc = 36 + ((lane == "pres") ? _t.def : _t.mdef) * 2 + (_t.maxhp / max(1, _u.maxhp)) * 8;
				if (is_struct(_t[$ "bf"]) && (_t.bf[$ lane] ?? 0) > 0) _sc += 30;   // (it tears the barrier)
				return _sc;
			},
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) cbt_status(_f, _u, _t, nerf);
			},
		};
	} else if (_tmpl == 13) {
		// THE REGEN (light): a little now, and a mending each of the ally's turns
		_s = {
			name : _adj + " " + choose("bloom", "knitting", "dew", "sap"),
			cost : irandom_range(3, 5), targ : "ally", healp : random_range(.08, .16), magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if ((_t[$ "regen"] ?? 0) > 0) return 0;
				return 18 + (1 - _t.hp / _t.maxhp) * 60;
			},
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name, _u); cbt_status(_f, _u, _t, "regen"); },
		};
	} else if (_tmpl == 14) {
		// THE SMOKE: the user slips out of sight - half the chance to be hit while it lasts
		_s = {
			name : _adj + " " + choose("smoke", "mist", "blur", "shade"),
			cost : irandom_range(2, 4), targ : "self", magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if ((_u[$ "evade"] ?? 0) > 0) return 0;
				var _up = 0;
				for (var _i = 0; _i < array_length(_f.all); _i++) if (_f.all[_i].hp > 0 && _f.all[_i].team != _u.team) _up++;
				return 24 + (1 - _u.hp / _u.maxhp) * 35 + _up * 6;
			},
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _u, "evade"); },
		};
	} else if (_tmpl == 15) {
		// THE RAGE: the user's atk up and its def down, both for the buff's turns - a trade
		_s = {
			name : _adj + " " + choose("fury", "frenzy", "roar", "wrath"),
			cost : irandom_range(2, 4), targ : "self", magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if (is_struct(_u[$ "bf"]) && _u.bf.atk > 0) return 0;
				return 30 + (_u.hp / _u.maxhp) * 25;   // (a trade worth making while there is health to spend)
			},
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _u, "buf_atk"); cbt_status(_f, _u, _u, "nerf_def"); },
		};
	} else if (_tmpl == 16) {
		// THE LUNGE: a blow that ignores a share of the target's armour
		_s = {
			name : _adj + " " + choose("lunge", "thrust", "needle", "awl"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.1, 1.4), pierce : random_range(.4, .6), magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 42 + _t.def * 3 + ((_t.hp < _t.maxhp * .35) ? 15 : 0); },
			effect : function(_f, _u, _t) { _u.sk_pierce = pierce; cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); _u.sk_pierce = 0; },
		};
	} else if (_tmpl == 17) {
		// THE FLURRY: two blows, each a share of a full one
		_s = {
			name : _adj + " " + choose("flurry", "tempest", "barrage", "onslaught"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(.55, .75), magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 46 - _t.def + ((_t.hp < _t.maxhp * .35) ? 20 : 0); },
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); if (_t.hp > 0) cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		};
	} else if (_tmpl == 18) {
		// THE SIPHON (dark): a small hit, and the target's mp drawn into the user's
		_s = {
			name : _adj + " " + choose("siphon", "tithe", "gulp", "sup"),
			cost : irandom_range(2, 3), targ : "enemy", mult : random_range(.5, .7), drainmp : irandom_range(2, 4), magic : true, elem : "", school : "dark",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 26 + ((_t.mp >= drainmp) ? 22 : 0) + (1 - _u.mp / max(1, _u.maxmp)) * 30; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) { var _take = min(_t.mp, drainmp); _t.mp -= _take; _u.mp = min(_u.maxmp, _u.mp + _take); if (_take > 0) cbt_log(_f, _u.name + " draws " + string(_take) + " mp out of " + _t.name); }
			},
		};
	} else if (_tmpl == 19) {
		// THE BURST: an element on EVERY enemy, each at a share of a spell
		var _el19 = choose("fire", "water", "nature");
		var _nn19 = (_el19 == "fire") ? choose("blaze", "inferno", "firestorm", "flarewind") : ((_el19 == "water") ? choose("deluge", "squall", "hailstorm", "flood") : choose("gale", "bramblestorm", "thornwind", "sporeburst"));
		_s = {
			name : _adj + " " + _nn19,
			cost : irandom_range(5, 7), targ : "enemy", mult : random_range(.6, .85), magic : true, elem : _el19, school : "", aoe : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _up = 0, _res = 0;
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team == _u.team) continue; _up++; if (is_struct(_p[$ "res"])) _res += (_p.res[$ elem] ?? 0); }
				if (_up < 2) return 12;
				return 30 + 20 * (_up - 1) - _res * .3;
			},
			effect : function(_f, _u, _t) {
				var _ts = [];
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp > 0 && _p.team != _u.team) array_push(_ts, _p); }
				for (var _i = 0; _i < array_length(_ts); _i++) if (_ts[_i].hp > 0 && _u.hp > 0) cbt_hit(_f, _u, _ts[_i], mult, name, 0, magic, elem);
			},
		};
	} else if (_tmpl == 20) {
		// THE CHORUS (light): a heal on EVERY ally, each a share
		_s = {
			name : _adj + " " + choose("chorus", "canticle", "psalm", "round"),
			cost : irandom_range(5, 7), targ : "ally", healp : random_range(.14, .24), magic : true, elem : "", school : "light", aoe : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _miss = 0, _n = 0;
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team != _u.team) continue; _n++; _miss += 1 - _p.hp / _p.maxhp; }
				if (_n < 2) return 0;
				return _miss * 55;
			},
			effect : function(_f, _u, _t) {
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp > 0 && _p.team == _u.team) cbt_heal(_f, _p, _p.maxhp * healp, name, _u); }
			},
		};
	} else if (_tmpl == 21) {
		// THE SILENCE (dark): a small hit, and no magic skill from the target while it runs
		_s = {
			name : _adj + " " + choose("hush", "gag", "muffle", "quiet"),
			cost : irandom_range(3, 4), targ : "enemy", mult : random_range(.3, .5), magic : true, elem : "", school : "dark",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				if (is_struct(_t[$ "ail"]) && (_t.ail[$ "silence"] ?? 0) > 0) return 0;
				var _casts = 0;
				for (var _i = 0; _i < array_length(_t.skills); _i++) if (_t.skills[_i].magic) _casts++;
				return (_casts > 0) ? 40 + _casts * 12 + (_t.magic ? 12 : 0) : 6;
			},
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) cbt_status(_f, _u, _t, "silence");
			},
		};
	} else if (_tmpl == 22) {
		// THE ANTHEM (light): one blessing on EVERY ally - atk, def or haste
		var _bk22 = choose("buf_atk", "buf_def", "haste");
		_s = {
			name : _adj + " " + choose("anthem", "rally", "cadence", "banner"),
			cost : irandom_range(5, 7), targ : "ally", magic : true, elem : "", school : "light", buf : _bk22, aoe : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _want = 0, _n = 0, _k = (buf == "haste") ? "spd" : string_delete(buf, 1, 4);
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team != _u.team) continue; _n++; if (!(is_struct(_p[$ "bf"]) && (_p.bf[$ _k] ?? 0) > 0)) _want++; }
				if (_n < 2 || _want < 2) return 0;
				return 22 * _want;
			},
			effect : function(_f, _u, _t) {
				for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp > 0 && _p.team == _u.team) cbt_status(_f, _u, _p, buf); }
			},
		};
	} else {
		// THE SMITE (light's own damage, q312): a magic hit that reads no element, half again on the undead
		_s = {
			name : _adj + " " + choose("smite", "radiance", "judgement", "lance"),
			cost : irandom_range(3, 5), targ : "enemy", mult : random_range(1.1, 1.5), magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _und = is_array(_t[$ "tags"]) && array_contains(_t.tags, "undead");
				return 44 + _t.def * 2 - _t.mdef + (_und ? 30 : 0) + ((_t.hp < _t.maxhp * .35) ? 15 : 0);
			},
			effect : function(_f, _u, _t) {
				var _und = is_array(_t[$ "tags"]) && array_contains(_t.tags, "undead");
				cbt_hit(_f, _u, _t, mult * (_und ? 1.5 : 1), name, 0, magic, elem);
			},
		};
	}
	_s.tmpl = _tmpl;
	rng_release(_old);
	return _s;
}
