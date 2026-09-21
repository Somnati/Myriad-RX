/// @description cbt_skills() -> the library: the six class / kind skills
/// (the tech demo's, ported 2026-09-14). A skill is a struct with the
/// same shape a generated one has (cbt_skill_gen): name, cost, targ,
/// magic, elem (fire / water / nature or ""), school (light / dark or ""),
/// can_use, ai_score, effect. THE ELEMENTS PASS (2026-09-17): bolt is
/// lightning - nature; drain is dark and MARKS its target (the leech
/// ailment) as well as feeding on the hit; mend and reform are light,
/// mend easing one ailment with the heal.
function cbt_skills() {
	if (variable_global_exists("cskills")) return g.cskills;
	g.cskills = {
		strike : {
			name : "strike", cost : 3, targ : "enemy", mult : 1.6, magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _s = 55 + _t.def * 2;                      // a heavy hit: shines into tanks, finishes the low
				if (_t.hp < _t.maxhp * .35) _s += 25;
				return _s;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		},
		reform : {
			name : "reform", cost : 4, targ : "self", magic : false, healp : .4, elem : "", school : "light",
			can_use  : function(_f, _u) { return _u.hp < _u.maxhp; },
			ai_score : function(_f, _u, _t) { return (_u.hp > _u.maxhp * .35) ? 0 : 85; },   // the emergency button
			effect : function(_f, _u, _t) { cbt_heal(_f, _u, _u.maxhp * healp, "reform", _u); },
		},
		drain : {
			name : "drain", cost : 3, targ : "enemy", mult : .8, magic : true, leech : .6, elem : "", school : "dark",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 40 + (1 - _u.hp / _u.maxhp) * 45; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem, "leech");
				if (_d > 0) cbt_heal(_f, _u, _d * leech, "");
			},
		},
		mend : {
			name : "mend", cost : 4, targ : "ally", magic : true, healp : .35, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _s = (1 - _t.hp / _t.maxhp) * 95;   // triage: the score IS the missing health
				if (is_struct(_t[$ "ail"]) && (_t.ail.poison > 0 || _t.ail.slow > 0 || _t.ail.leech > 0)) _s += 20;   // (an ailment to ease)
				return _s;
			},
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, "mend", _u); cbt_purge(_f, _t, "light", true); },
		},
		concuss : {
			name : "concuss", cost : 3, targ : "enemy", mult : .7, magic : false, stag : .45, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 35 + _t.spd * 4 + (_t.tic / _f.thr) * 25; },   // tempo: best on a fast foe mid-charge
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem);
				if (_d > 0) _t.tic -= _f.thr * stag;
			},
		},
		bolt : {
			name : "bolt", cost : 3, targ : "enemy", mult : 1.5, magic : true, elem : "nature", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _s = 50 + _t.def * 2 - _t.mdef;                // the caster's strike: hits where armour is not
				if (_t.hp < _t.maxhp * .35) _s += 20;
				if (is_struct(_t[$ "res"])) _s -= (_t.res[$ elem] ?? 0) * .5;   // (a soft target is worth more, a hard one less)
				return _s;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		},
		// THE THIRTEEN (q312, his ask: "way more classes"): a class skill each for the new roster - the same shapes the
		// templates roll (cbt_skill_gen), the numbers fixed
		bulwark : {   // the knight: its own barrier
			name : "bulwark", cost : 3, targ : "self", magic : false, elem : "", school : "light",
			can_use  : function(_f, _u) { return !(is_struct(_u[$ "bf"]) && (_u.bf[$ "pres"] ?? 0) > 0); },
			ai_score : function(_f, _u, _t) { var _ph = 0; for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp > 0 && _p.team != _u.team && !_p.magic) _ph++; } return (_ph > 0) ? 34 + _ph * 8 + (1 - _u.hp / _u.maxhp) * 20 : 0; },
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _u, "barrier"); },
		},
		rage : {   // the berserker: atk up, def down
			name : "rage", cost : 3, targ : "self", magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return !(is_struct(_u[$ "bf"]) && _u.bf.atk > 0); },
			ai_score : function(_f, _u, _t) { return 32 + (_u.hp / _u.maxhp) * 25; },
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _u, "buf_atk"); cbt_status(_f, _u, _u, "nerf_def"); },
		},
		lunge : {   // the valkyrie: the spear through the armour
			name : "lunge", cost : 3, targ : "enemy", mult : 1.25, pierce : .5, magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 44 + _t.def * 3 + ((_t.hp < _t.maxhp * .35) ? 15 : 0); },
			effect : function(_f, _u, _t) { _u.sk_pierce = pierce; cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); _u.sk_pierce = 0; },
		},
		iai : {   // the samurai: one draw, one cut - a crit far likelier
			name : "iai", cost : 3, targ : "enemy", mult : 1.3, magic : false, elem : "", school : "", crit : 30,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 46 + _u.crit_multi * 8 + ((_t.hp < _t.maxhp * .4) ? 20 : 0); },
			effect : function(_f, _u, _t) { _u.sk_crit = crit; cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); _u.sk_crit = 0; },
		},
		flurry : {   // the brawler: two blows
			name : "flurry", cost : 3, targ : "enemy", mult : .65, magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 46 - _t.def + ((_t.hp < _t.maxhp * .35) ? 20 : 0); },
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); if (_t.hp > 0) cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); },
		},
		smoke : {   // the ninja: out of sight
			name : "smoke", cost : 2, targ : "self", magic : false, elem : "", school : "",
			can_use  : function(_f, _u) { return (_u[$ "evade"] ?? 0) <= 0; },
			ai_score : function(_f, _u, _t) { var _up = 0; for (var _i = 0; _i < array_length(_f.all); _i++) if (_f.all[_i].hp > 0 && _f.all[_i].team != _u.team) _up++; return 24 + (1 - _u.hp / _u.maxhp) * 35 + _up * 6; },
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _u, "evade"); },
		},
		pilfer : {   // the thief: a quick hand in the enemy's reserve
			name : "pilfer", cost : 2, targ : "enemy", mult : .9, drainmp : 3, magic : false, elem : "", school : "dark",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 28 + ((_t.mp >= drainmp) ? 22 : 0) + (1 - _u.mp / max(1, _u.maxmp)) * 30; },
			effect : function(_f, _u, _t) { var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); if (_d > 0) { var _take = min(_t.mp, drainmp); _t.mp -= _take; _u.mp = min(_u.maxmp, _u.mp + _take); if (_take > 0) cbt_log(_f, _u.name + " lifts " + string(_take) + " mp off " + _t.name); } },
		},
		hex : {   // the witch: a curse on the arm
			name : "hex", cost : 3, targ : "enemy", mult : .5, magic : true, elem : "", school : "dark", nerf : "nerf_atk",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { if (is_struct(_t[$ "nf"]) && _t.nf.atk > 0) return 10; return 40 + _t.atk * 2 + ((is_struct(_t[$ "bf"]) && _t.bf.atk > 0) ? 25 : 0); },
			effect : function(_f, _u, _t) { var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic, elem); if (_d > 0) cbt_status(_f, _u, _t, nerf); },
		},
		barrier : {   // the sage: ff7's barrier - an ally takes blows at barrier_pct less
			name : "barrier", cost : 4, targ : "ally", magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { if (is_struct(_t[$ "bf"]) && (_t.bf[$ "pres"] ?? 0) > 0) return 0; var _ph = 0, _all = 0; for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team == _t.team) continue; _all++; if (!_p.magic) _ph++; } if (_all == 0) return 0; return 28 + 34 * (_ph / _all) + (1 - _t.hp / _t.maxhp) * 25 + ((is_struct(_t[$ "nf"]) && (_t.nf[$ "pres"] ?? 0) > 0) ? 25 : 0); },
			effect : function(_f, _u, _t) { cbt_status(_f, _u, _t, "barrier"); },
		},
		manaward : {   // the priest: ff7's manaward - an ally takes spells at barrier_pct less
			name : "manaward", cost : 4, targ : "ally", healp : .12, magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { if (is_struct(_t[$ "bf"]) && (_t.bf[$ "mres"] ?? 0) > 0) return 0; var _mg = 0, _all = 0; for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team == _t.team) continue; _all++; if (_p.magic) _mg++; } if (_all == 0) return 0; return 28 + 34 * (_mg / _all) + (1 - _t.hp / _t.maxhp) * 45 + ((is_struct(_t[$ "nf"]) && (_t.nf[$ "mres"] ?? 0) > 0) ? 25 : 0); },
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name, _u); cbt_status(_f, _u, _t, "manaward"); },   // (a small mending with the ward - the priest)
		},
		smite : {   // the paladin: light's own blow, half again on the undead
			name : "smite", cost : 3, targ : "enemy", mult : 1.4, magic : false, elem : "", school : "light",   // (the paladin: a physical blow in light school - its arm, not a book; tuned on the twin)
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { var _und = is_array(_t[$ "tags"]) && array_contains(_t.tags, "undead"); return 44 + _t.def * 2 - _t.mdef + (_und ? 30 : 0) + ((_t.hp < _t.maxhp * .35) ? 15 : 0); },
			effect : function(_f, _u, _t) { var _und = is_array(_t[$ "tags"]) && array_contains(_t.tags, "undead"); cbt_hit(_f, _u, _t, mult * (_und ? 1.5 : 1), name, 0, magic, elem); },
		},
		song : {   // the bard: haste AND heart on every ally (the two blessings at once - the bard's whole trade; tuned on the twin)
			name : "song", cost : 2, targ : "ally", magic : true, elem : "", school : "light", buf : "haste", aoe : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { var _want = 0, _n = 0; for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp <= 0 || _p.team != _u.team) continue; _n++; if (!(is_struct(_p[$ "bf"]) && _p.bf.spd > 0)) _want++; } return (_want >= 1 && (_n >= 2 || _want == 1)) ? 20 * _want + 8 : 0; },
			effect : function(_f, _u, _t) { for (var _i = 0; _i < array_length(_f.all); _i++) { var _p = _f.all[_i]; if (_p.hp > 0 && _p.team == _u.team) { cbt_status(_f, _u, _p, buf); cbt_status(_f, _u, _p, "buf_atk"); } } },
		},
		regrowth : {   // the druid: a little now, and a mending each turn
			name : "regrowth", cost : 4, targ : "ally", healp : .2, magic : true, elem : "", school : "light",
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { if ((_t[$ "regen"] ?? 0) > 0) return 0; return 20 + (1 - _t.hp / _t.maxhp) * 60; },
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, name, _u); cbt_status(_f, _u, _t, "regen"); },
		},
	};
	return g.cskills;
}
