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
	};
	return g.cskills;
}
