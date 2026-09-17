/// @description cbt_hit(fight, user, target, [mult], [label], [cdepth], [magic]) -> damage (0 = miss)
/// THE HIT-QUALITY SPECTRUM, the tech demo's combat_hit (DnD GPT's kit)
/// ported headless: ONE roll's margin under the hit curve drives
/// everything - the damage lerp, def piercing, the ATB knockback
/// (stagger), the crit interplay, the log flavour. On top, the demo's
/// two additions: the mp economy (landed BASIC attacks build mp, +2 on
/// a clean / perfect / crit) and counters (the struck pawn rolls cnt%,
/// halving per chain link, capped). What the demo drew - floats, the
/// lunge, the sounds - is a film frame here (cbt_film); the combat
/// window makes the pictures.
/// Luck (luck_mod, DE's) leans the CREW's hit and crit rolls.
/// @param mult   damage multiplier (skills pass theirs; a basic = 1)
/// @param label  the skill's name ("" = a basic attack)
/// @param cdepth counter chain depth (counters pass depth + 1)
/// @param magic  true = mag vs mdef instead of atk vs def
function cbt_hit(_f, _u, _t, _mult = 1, _label = "", _cdepth = 0, _magic = false, _elem = undefined, _ail = "") {
	var _b = cbt_balance();
	var _lm = (_u.team == 0) ? luck_mod() : 1;

	// THE ELEMENT (his design, 2026-09-17): a skill names its own (or ""); a
	// basic attack carries the pawn's - a foe kind's, a sprite's weapon's.
	// The ailment likewise: a skill's, or a kind's own bite on its basics
	var _basic = (_label == "" && _cdepth == 0);
	if (is_undefined(_elem)) _elem = _u[$ "elem"] ?? "";
	if (_ail == "" && _basic) _ail = _u[$ "ail_k"] ?? "";

	// physical or magical lane: the same spectrum, a different stat pair
	// - through the light / dark lanes: a raised or lowered stat is
	// +-buff_pct while its clock runs (cbt_status)
	var _bfu = _u[$ "bf"], _nfu = _u[$ "nf"], _bft = _t[$ "bf"], _nft = _t[$ "nf"];
	var _m_atk = 1, _m_def = 1, _m_hit = 1;
	if (is_struct(_bfu)) { if (_bfu.atk > 0) _m_atk += _b.buff_pct; if (_bfu.hit > 0) _m_hit += _b.buff_pct; }
	if (is_struct(_nfu)) { if (_nfu.atk > 0) _m_atk -= _b.buff_pct; if (_nfu.hit > 0) _m_hit -= _b.buff_pct; }
	if (is_struct(_bft) && _bft.def > 0) _m_def += _b.buff_pct;
	if (is_struct(_nft) && _nft.def > 0) _m_def -= _b.buff_pct;
	// the abilities' lanes (2026-09-17; the big roster the same day): adrenaline
	// under a third of hp, first blood on the first action, the underdog's
	// edge, the turtle's and the dragonscale's def, the piercer's bite
	var _abu = _u[$ "ab"], _abt = _t[$ "ab"];
	var _hp0 = _t.hp;   // (the target's hp BEFORE the blow - once more reads it)
	var _tfull = (_t.hp >= _t.maxhp - .01), _thalf = (_t.hp < _t.maxhp * .5);
	var _tail = is_struct(_t[$ "ail"]) && (_t.ail.poison > 0 || _t.ail.slow > 0 || _t.ail.leech > 0);
	var _ttags = is_array(_t[$ "tags"]) ? _t.tags : [];
	var _uacts = _u[$ "acts"] ?? 0, _usk = _u[$ "sk_used"] ?? 0, _ustk = _u[$ "streak"] ?? 0, _usch = _u[$ "cur_school"] ?? "";
	if (is_struct(_abu)) {
		if (_abu.low_atk > 0 && _u.hp < _u.maxhp * .35) _m_atk += _abu.low_atk / 100;
		if (_abu.first > 0 && _uacts == 0) _m_atk += _abu.first / 100;
		if (_abu.underdog > 0 && (_t[$ "lv"] ?? 0) > (_u[$ "lv"] ?? 0)) _m_atk += _abu.underdog / 100;
	}
	if (is_struct(_abt)) {
		if (_abt.low_def > 0 && _t.hp < _t.maxhp * .35) _m_def += _abt.low_def / 100;
		if (_abt.hi_def > 0 && _t.hp >= _t.maxhp * .8) _m_def += _abt.hi_def / 100;
	}
	var _apow = (_magic ? _u.mag : _u.atk) * _m_atk;
	var _dpow = (_magic ? _t.mdef : _t.def) * _m_def;
	if (is_struct(_abu) && _abu.pierce > 0) _dpow *= 1 - _abu.pierce / 100;   // (the piercer)
	var _uhit = _u.hit * _m_hit;

	// hit chance: the attacker's hit vs the defender's EVASION (nimble's flat points, cornered's under a quarter)
	var _teva = _t.eva;
	if (is_struct(_abt)) { _teva += _abt.eva; if (_abt.low_eva > 0 && _t.hp < _t.maxhp * .25) _teva *= 1 + _abt.low_eva / 100; }
	var _sum = _uhit + _teva;
	var _hc = 50;
	if (_sum > 0) {
		var _r = _uhit / _sum;
		_hc = clamp(_b.hitcurve_a * _r * _r + _b.hitcurve_b * _r, 1, 99);
	}
	_hc = clamp(_hc * _lm, 1, 99);
	// THE NOTEPAD'S BITE: a foe kind the attacker has a note on is a little
	// easier to hit ("goblins are quick. swing early." - sprite_note)
	// THE NOTES' FACETS (2026-09-16): what was noticed is what helps - hit / crit / damage on the attacker's side, evasion / defence on the target's
	var _tk = is_string(_t[$ "kind"]) ? _t.kind : "", _uk = is_string(_u[$ "kind"]) ? _u.kind : "";
	var _nu = is_array(_u[$ "studied"]) ? _u.studied : [], _nt = is_array(_t[$ "studied"]) ? _t.studied : [];
	if (_tk != "" && array_contains(_nu, _tk + ":hit")) _hc = clamp(_hc + SPRITE_NOTE_HIT, 1, 99);
	if (_uk != "" && array_contains(_nt, _uk + ":eva")) _hc = clamp(_hc - 6, 1, 99);
	var _roll = random(100);

	// ---- miss ----
	if (_roll >= _hc) {
		_u.streak = 0;   // (momentum resets on a miss)
		var _near = (_roll < _hc + 5);
		var _vb = _near ? choose(" barely missed ", " almost hit ")
			: choose(" missed ", " swings past ", " failed to hit ", " overshot ");
		var _tm = _u.name + _vb + _t.name;
		cbt_log(_f, _tm);
		cbt_film(_f, _t, 0, _tm);
		return 0;
	}

	// ---- hit: quality = how far under the curve the roll landed ----
	var _q = (_hc - _roll) / _hc;   // 0 graze .. 1 perfect
	if (is_struct(_abu) && _abu.graze > 0 && random(100) < _abu.graze) _q = 0;   // (the gambler's cost: a graze)
	var _cr = _u.crit_rate + ((_tk != "" && array_contains(_nu, _tk + ":crit")) ? 5 : 0);
	var _cm = _u.crit_multi - 1;   // (the extra a crit deals)
	if (is_struct(_abu)) {
		if (_cdepth > 0) _cr += _abu.cnt_crit;                                   // vendetta
		if (_abu.low_crit > 0 && _u.hp < _u.maxhp * .25) _cr += _abu.low_crit;   // grand slam
		_cm *= 1 + _abu.crit_dmg / 100;                                          // vital strike, the gambler
		if (_abu.low_crit_dmg > 0 && _u.hp < _u.maxhp * .25) _cm *= 1 + _abu.low_crit_dmg / 100;   // death wind
	}
	var _crit = (random(100) < _cr * _lm);
	if (_crit && array_contains(_ttags, "immune_crit")) _crit = false;   // (safe: hits on it never crit)

	var _dmg = _apow * _mult;
	_dmg -= (_dpow * lerp(1, _b.def_lerp_low, _q)) / _b.def_div;
	if (_q < .97) _dmg = lerp(_dmg * _b.dmg_lerp_low, _dmg * _b.dmg_lerp_high, _q);
	else          _dmg = lerp(_dmg * _b.dmg_lerp_low, _dmg * _b.perf_lerp_high, _q);
	if (_crit) _dmg *= 1 + lerp(_cm * _b.crit_lerp_low, _cm * _b.crit_lerp_high, _q);
	_dmg *= _b.ttk_multi;
	// THE RESISTANCE (his design): the target's own signed table for the
	// element carried - minus takes more, plus takes less. Fire carries no
	// ailment, so it hits a little harder instead. Light and dark: flat
	var _ei = cbt_elem_info(_elem);
	var _rs = 0;
	if (_ei.beats != "" && is_struct(_t[$ "res"])) {
		_rs = clamp(_t.res[$ _elem] ?? 0, _b.res_min, _b.res_max);
		_dmg *= 1 - _rs / 100;
	}
	if (_elem == "fire") _dmg *= _b.fire_bonus;
	// ...bane against a boss, the elementalist's skills
	if (is_struct(_abu)) {
		if (_abu.boss > 0 && (_t[$ "boss"] ?? false)) _dmg *= 1 + _abu.boss / 100;
		if (_abu.elemdmg > 0 && _ei.beats != "" && !_basic) _dmg *= 1 + _abu.elemdmg / 100;
		// ...the big roster (2026-09-17): the situational lanes
		if (_abu.vs_full > 0 && _tfull) _dmg *= 1 + _abu.vs_full / 100;               // ambusher
		if (_abu.vs_low > 0 && _thalf) _dmg *= 1 + _abu.vs_low / 100;                 // butcher
		if (_abu.vs_ail > 0 && _tail) _dmg *= 1 + _abu.vs_ail / 100;                  // opportunist
		if (_abu.vs_undead > 0 && array_contains(_ttags, "undead")) _dmg *= 1 + _abu.vs_undead / 100;   // grave-robber
		if (_abu.vs_slime > 0 && array_contains(_ttags, "slime")) _dmg *= 1 + _abu.vs_slime / 100;      // slime-squasher
		if (_abu.dark_pow > 0 && _label != "" && _usch == "dark") _dmg *= 1 + _abu.dark_pow / 100;      // dark-touched
		if (_abu.cnt_pow > 0 && _cdepth > 0) _dmg *= 1 + _abu.cnt_pow / 100;         // retaliator
		if (_abu.salvo > 0 && _label != "" && _usk == 0) _dmg *= 1 + _abu.salvo / 100;   // opening salvo
		if (_abu.momentum > 0) _dmg *= 1 + _abu.momentum / 100 * min(5, _ustk);       // momentum
	}
	if (is_struct(_abt)) {
		_dmg *= (1 + _abt.taken / 100) * (1 - _abt.guard / 100);                                   // to the death's cost, stoneskin
		if (_abt.low_guard > 0 && _t.hp < _t.maxhp * .25) _dmg *= 1 - _abt.low_guard / 100;   // damage control
	}
	if (_tk != "" && array_contains(_nu, _tk + ":dmg")) _dmg *= 1.1;                       // (a note on a tank: where to hit it)
	if (_uk != "" && array_contains(_nt, _uk + (_magic ? ":mdef" : ":def"))) _dmg *= (_magic ? .85 : .9);   // (a note on what it does: not being where it lands)
	_dmg = max(.1, round(_dmg * 10) / 10);
	// THICK HIDE: a hit under its share of max hp does nothing at all
	if (is_struct(_abt) && _abt.thick > 0 && _dmg <= _t.maxhp * _abt.thick / 100) {
		_u.streak = 0;
		var _tsh = _t.name + " shrugs " + _u.name + "'s blow off";
		cbt_log(_f, _tsh); cbt_film(_f, _t, 0, _tsh);
		return 0;
	}

	// stagger: quality (and crits) knock the target's ATB backward
	var _stag = (1 + _t.spd / 3) * lerp(.01, (_q >= .97 ? .085 : .05), _q);
	if (_crit) _stag += (1 + _t.spd / 3) * .03;
	if (is_struct(_abu) && _abu.stagger > 0) _stag *= 1 + _abu.stagger / 100;   // heavy hand
	if (is_struct(_abt) && _abt.steady > 0) _stag *= 1 - _abt.steady / 100;     // unshakable
	_t.tic -= _stag * _f.thr;

	// apply: hp + the attrition erosion (scaled by the pawn's resist)
	_t.hp = max(0, _t.hp - _dmg);
	// ONCE MORE (2026-09-17, Kingdom Hearts' rule - his ask): an action that
	// would down it leaves it at 1 hp, as long as it had more than 1 going in
	if (_t.hp <= 0 && is_struct(_abt) && _abt.once_more && _hp0 > 1) { _t.hp = 1; cbt_log(_f, _t.name + " holds on at 1 hp"); }
	// TWO-EDGED's cost: the striker bleeds a sliver on every blow it lands
	if (is_struct(_abu) && _abu.bleed > 0 && _u.hp > 1) _u.hp = max(1, _u.hp - _u.maxhp * _abu.bleed / 100);
	_u.streak = _ustk + 1;   // (momentum)
	_t.maxhp = max(1, _t.maxhp - _dmg * _b.dmg_to_maxhp * _t.erode);
	if (_t.hp > _t.maxhp) _t.hp = _t.maxhp;
	_t.hpmax = _t.maxhp;   // (the combat window's name for it)
	_u.dd += _dmg;
	_t.dt += _dmg;

	// the log's flavour, tiered by the same quality
	var _vb = choose(" attacked ", " struck ", " landed a blow on ", " cut ");
	if (_label != "")   _vb = " used " + _label + " on ";
	else if (_q < .08)  _vb = choose(" grazes ", " nicked ", " scraped ", " barely clipped ");
	else if (_q >= .97) _vb = choose(" landed a PERFECT strike on ", " FLAWLESSLY struck ");
	else if (_q >= .85) _vb = choose(" landed a CLEAN strike on ", " NAILED ", " PIERCED ");
	if (_crit) _vb = choose(" landed a CRITICAL strike on ", " CRITICALLY struck ");
	var _th = _u.name + _vb + _t.name + " for " + string(_dmg);
	if (_rs < 0) _th += " - " + _ei.burn;          // (the log says the weakness, 2026-09-17)
	else if (_rs > 0) _th += " - " + _ei.shrug;
	cbt_log(_f, _th);
	cbt_film(_f, _t, _dmg, _th);
	// VAMPIRIC (2026-09-17): the ability heals off what it deals
	if (is_struct(_abu) && _abu.life > 0 && _u.hp > 0) cbt_heal(_f, _u, _dmg * _abu.life / 100, "");
	// THE LEECH MARK (dark): the marker feeds on every hit it lands on the marked
	if (is_struct(_t[$ "ail"]) && _t.ail.leech > 0 && _t[$ "leecher"] == _u && _u.hp > 0)
		cbt_heal(_f, _u, _dmg * _b.leech_pct, "the mark");
	// RESILIENT / MP RAGE (2026-09-17): the struck pawn heals a share of the blow, or draws mp off it
	if (is_struct(_abt) && _t.hp > 0) {
		if (_abt.absorb > 0) cbt_heal(_f, _t, _dmg * _abt.absorb / 100, "");
		if (_abt.mp_rage > 0) _t.mp = min(_t.maxmp, _t.mp + _t.maxmp * (_abt.mp_rage / 100) * clamp(_dmg / max(1, _t.maxhp) * 3, .25, 1));
	}
	if (_t.hp <= 0) {
		cbt_log(_f, _t.name + " is down"); cbt_film(_f, undefined, 0, _t.name + " is down");
		// GRIM HARVEST / SOUL-EATER (2026-09-17): the kill feeds the killer
		if (is_struct(_abu) && _u.hp > 0) {
			if (_abu.kill_heal > 0) cbt_heal(_f, _u, _u.maxhp * _abu.kill_heal / 100, "the harvest");
			if (_abu.kill_mp > 0) _u.mp = min(_u.maxmp, _u.mp + _u.maxmp * _abu.kill_mp / 100);
		}
		// DEATH THROES: the fallen lowers the attack of every foe still standing
		if (is_struct(_abt) && _abt.throes > 0) {
			cbt_log(_f, _t.name + "'s death throes");
			for (var _di = 0; _di < array_length(_f.all); _di++) { var _dp = _f.all[_di]; if (_dp.team != _t.team && _dp.hp > 0) cbt_status(_f, _t, _dp, "nerf_atk"); }
		}
		if (_t.team == 0 && is_struct(_f[$ "tr"])) exped_drink(_f.tr, _t, _f, true);   // THE TOTEM (2026-09-16): a carrier stands up
	}

	// ---- THE AILMENT: a skill's on a landed hit, a kind's own on its bite ----
	if (_ail != "" && _t.hp > 0) {
		var _ach = (_basic ? _b.ail_basic : _b.ail_skill) * ((_u.team == 0) ? _lm : 1);
		if (_basic && (_u[$ "ail_c"] ?? 0) > 0) _ach = _u.ail_c * ((_u.team == 0) ? _lm : 1);   // (an ability's own bite has its own chance)
		if (is_struct(_abt) && _abt.vaccine > 0) _ach *= 1 - _abt.vaccine / 100;   // (vaccinated: it lands less often)
		if (random(100) < _ach) cbt_status(_f, _u, _t, _ail);
	}

	// ---- the mp economy: landed BASIC attacks (not skills, not counters) ----
	if (_label == "" && _cdepth == 0) {
		var _gain = (_q >= .85 || _crit) ? _b.mp_gain_qual : _b.mp_gain;
		if (is_struct(_abu) && _abu.mp_gain > 0) _gain *= 1 + _abu.mp_gain / 100;   // (battery)
		_u.mp = min(_u.maxmp, _u.mp + _gain);
	}

	// ---- the counter: the struck pawn may strike straight back ----
	if (_t.hp > 0 && _cdepth < _b.cnt_chain) {
		var _cc = _t.cnt * power(_b.cnt_falloff, _cdepth) * ((_t.team == 0) ? _lm : 1);
		if (random(100) < _cc) {
			cbt_log(_f, _t.name + " counters");
			_t.cc++;
			cbt_hit(_f, _t, _u, _b.cnt_mult, "", _cdepth + 1, false);
		}
	}
	return _dmg;
}
