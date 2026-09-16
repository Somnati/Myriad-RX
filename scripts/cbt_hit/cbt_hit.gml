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
function cbt_hit(_f, _u, _t, _mult = 1, _label = "", _cdepth = 0, _magic = false) {
	var _b = cbt_balance();
	var _lm = (_u.team == 0) ? luck_mod() : 1;

	// physical or magical lane: the same spectrum, a different stat pair
	var _apow = _magic ? _u.mag : _u.atk;
	var _dpow = _magic ? _t.mdef : _t.def;

	// hit chance: the attacker's hit vs the defender's EVASION
	var _sum = _u.hit + _t.eva;
	var _hc = 50;
	if (_sum > 0) {
		var _r = _u.hit / _sum;
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
	var _crit = (random(100) < (_u.crit_rate + ((_tk != "" && array_contains(_nu, _tk + ":crit")) ? 5 : 0)) * _lm);

	var _dmg = _apow * _mult;
	_dmg -= (_dpow * lerp(1, _b.def_lerp_low, _q)) / _b.def_div;
	if (_q < .97) _dmg = lerp(_dmg * _b.dmg_lerp_low, _dmg * _b.dmg_lerp_high, _q);
	else          _dmg = lerp(_dmg * _b.dmg_lerp_low, _dmg * _b.perf_lerp_high, _q);
	if (_crit) _dmg *= 1 + lerp((_u.crit_multi - 1) * _b.crit_lerp_low, (_u.crit_multi - 1) * _b.crit_lerp_high, _q);
	_dmg *= _b.ttk_multi;
	if (_tk != "" && array_contains(_nu, _tk + ":dmg")) _dmg *= 1.1;                       // (a note on a tank: where to hit it)
	if (_uk != "" && array_contains(_nt, _uk + (_magic ? ":mdef" : ":def"))) _dmg *= (_magic ? .85 : .9);   // (a note on what it does: not being where it lands)
	_dmg = max(.1, round(_dmg * 10) / 10);

	// stagger: quality (and crits) knock the target's ATB backward
	var _stag = (1 + _t.spd / 3) * lerp(.01, (_q >= .97 ? .085 : .05), _q);
	if (_crit) _stag += (1 + _t.spd / 3) * .03;
	_t.tic -= _stag * _f.thr;

	// apply: hp + the attrition erosion (scaled by the pawn's resist)
	_t.hp = max(0, _t.hp - _dmg);
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
	cbt_log(_f, _th);
	cbt_film(_f, _t, _dmg, _th);
	if (_t.hp <= 0) {
		cbt_log(_f, _t.name + " is down"); cbt_film(_f, undefined, 0, _t.name + " is down");
		if (_t.team == 0 && is_struct(_f[$ "tr"])) exped_drink(_f.tr, _t, _f, true);   // THE TOTEM (2026-09-16): a carrier stands up
	}

	// ---- the mp economy: landed BASIC attacks (not skills, not counters) ----
	if (_label == "" && _cdepth == 0) {
		var _gain = (_q >= .85 || _crit) ? _b.mp_gain_qual : _b.mp_gain;
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
