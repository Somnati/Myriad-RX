/// @description cbt_skills() -> the hand-authored skill library (g.cskills)
/// The tech demo's combat_skills: every skill is ONE struct that answers
/// every consumer - can_use(f, u), ai_score(f, u, t) (0 = pointless now,
/// higher = better), effect(f, u, t). Damage routes through cbt_hit so
/// every skill inherits the hit-quality spectrum; nobody else knows
/// skill names. cbt_skill_gen rolls brand-new ones in the same shape.
///   targ  "enemy" / "ally" (includes self) / "self"
///   magic true = the hit resolves mag vs mdef
function cbt_skills() {
	if (variable_global_exists("cskills")) return g.cskills;
	g.cskills = {
		strike : {
			name : "strike", cost : 3, targ : "enemy", mult : 1.6, magic : false,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _s = 55 + _t.def * 2;                      // a heavy hit: shines into tanks, finishes the low
				if (_t.hp < _t.maxhp * .35) _s += 25;
				return _s;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic); },
		},
		reform : {
			name : "reform", cost : 4, targ : "self", magic : false, healp : .4,
			can_use  : function(_f, _u) { return _u.hp < _u.maxhp; },
			ai_score : function(_f, _u, _t) { return (_u.hp > _u.maxhp * .35) ? 0 : 85; },   // the emergency button
			effect : function(_f, _u, _t) { cbt_heal(_f, _u, _u.maxhp * healp, "reform"); },
		},
		drain : {
			name : "drain", cost : 3, targ : "enemy", mult : .8, magic : true, leech : .6,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 40 + (1 - _u.hp / _u.maxhp) * 45; },
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic);
				if (_d > 0) cbt_heal(_f, _u, _d * leech, "");
			},
		},
		mend : {
			name : "mend", cost : 4, targ : "ally", magic : true, healp : .35,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return (1 - _t.hp / _t.maxhp) * 95; },   // triage: the score IS the missing health
			effect : function(_f, _u, _t) { cbt_heal(_f, _t, _t.maxhp * healp, "mend"); },
		},
		concuss : {
			name : "concuss", cost : 3, targ : "enemy", mult : .7, magic : false, stag : .45,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) { return 35 + _t.spd * 4 + (_t.tic / _f.thr) * 25; },   // tempo: best on a fast foe mid-charge
			effect : function(_f, _u, _t) {
				var _d = cbt_hit(_f, _u, _t, mult, name, 0, magic);
				if (_d > 0) _t.tic -= _f.thr * stag;
			},
		},
		bolt : {
			name : "bolt", cost : 3, targ : "enemy", mult : 1.5, magic : true,
			can_use  : function(_f, _u) { return true; },
			ai_score : function(_f, _u, _t) {
				var _s = 50 + _t.def * 2 - _t.mdef;                // the caster's strike: hits where armour is not
				if (_t.hp < _t.maxhp * .35) _s += 20;
				return _s;
			},
			effect : function(_f, _u, _t) { cbt_hit(_f, _u, _t, mult, name, 0, magic); },
		},
	};
	return g.cskills;
}
