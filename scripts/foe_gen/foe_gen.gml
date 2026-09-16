/// @description foe_gen(lv, seed, [kind]) -> an enemy pawn at that level ("" = the roster's roll)
/// The roster: shapes on the sprites' budget (EFFECTIVE 40, the tech
/// demo's rule - a point past six costs two), scaled by level like them
/// (sprite_par_pts) x SPRITE_FOE_BUDGET - a foe stands a little under a
/// sprite of its level, so at par a crew mostly wins (the twin:
/// datafiles/sprite_twin.py) - the garnish, a
/// library skill, some ARMED (a weapon and armour rolled at their
/// level - the stat total climbs and so does their xp, his law), and
/// one in twelve a BOSS: the name gets a title and the budget x1.4.
/// pts_total is what the kill pays (foe_xp).
/// bossf (2026-09-15): true / false forces the boss roll (the roll is still made - the stream holds)
function foe_gen(_lv, _seed, _kind = "", _bossf = undefined) {
	var _b = cbt_balance();
	cbt_skills();
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _ros = foe_roster();   // (the foes pass, 2026-09-15: thirty kinds, each with its lands)
	var _r = _ros[irandom(array_length(_ros) - 1)];
	if (_kind != "") for (var _ri = 0; _ri < array_length(_ros); _ri++) if (_ros[_ri].name == _kind) _r = _ros[_ri];   // a kind asked for (a quest's, a camp's)
	var _boss = (random(1) < 1 / 12);
	if (!is_undefined(_bossf)) _boss = _bossf;
	var _budget = sprite_par_pts(_lv) * SPRITE_FOE_BUDGET * (_boss ? 1.4 : 1);
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _pts = {};
	var _total = 0;
	for (var _k = 0; _k < 8; _k++) { _pts[$ _keys[_k]] = _r.shape[$ _keys[_k]] * _budget / 40; _total += _pts[$ _keys[_k]]; }
	// the arms: a weapon and maybe armour, at their level, common or uncommon.
	// EVERY ROLL FIRST, the gear after (bug hunt 2026-09-15): gear_gen is a
	// seeded section of its own and its release re-seeds the stream, so a
	// roll made after it would not be this foe's - the seed would not
	// reproduce the foe
	var _armed = (random(1) < _r.gear);
	var _wr1 = (random(1) < .25) ? 1 : 0, _ws1 = irandom($7fffffff);
	var _arm2 = (random(1) < .6);
	var _wr2 = (random(1) < .25) ? 1 : 0, _ws2 = irandom($7fffffff);
	var _armed_name = (random(1) < .6);
	var _title = choose("chief", "elder", "king", "of unusual size", "with a hat", "the second");
	rng_release(_old);
	var _worn = [];
	if (_armed) {
		array_push(_worn, gear_gen("w1", _lv, _wr1, _ws1));
		if (_arm2) array_push(_worn, gear_gen("armor", _lv, _wr2, _ws2));
	}
	for (var _w = 0; _w < array_length(_worn); _w++) {
		var _lk = variable_struct_get_names(_worn[_w].pts);
		for (var _i = 0; _i < array_length(_lk); _i++) { _pts[$ _lk[_i]] += _worn[_w].pts[$ _lk[_i]]; _total += _worn[_w].pts[$ _lk[_i]]; }
	}
	var _name = _r.name;
	if (array_length(_worn) > 0 && _armed_name) _name = "armed " + _r.name;
	if (_boss) _name = _r.name + " " + _title;
	var _maxhp = floor(_pts.hp * _b.hp_per_point + _b.hp_flat_add);   // (whole hp, like the sprites')
	var _maxmp = max(1, round(_pts.mp));
	var _sk = [];
	if (_r.skill != "") array_push(_sk, g.cskills[$ _r.skill]);
	return {
		name : _name, col : _r.col, kind : _r.name, lv : _lv, boss : _boss, worn : _worn,
		team : 1, k : 0,
		maxhp_real : _maxhp, maxhp : _maxhp, hpmax : _maxhp, hp : _maxhp,
		maxmp : _maxmp, mp : ceil(_maxmp * _b.mp_start_frac),
		atk : _pts.atk, def : _pts.def, mag : _pts.mag, mdef : _pts.mdef, spd : _pts.spd, hit : _pts.hit,
		eva : _pts.spd * _b.spd_to_eva,
		crit_rate : _r.crit, crit_multi : _r.cmulti, cnt : _r.cnt, erode : _r.erode,
		magic : _r.magic, skills : _sk,
		tic : random(.3), tic_spd : _b.tic_spd_base + sqrt(max(0, _pts.spd)) / _b.tic_spd_div,
		pts_total : _total,
		dd : 0, dt : 0, cc : 0,
	};
}
