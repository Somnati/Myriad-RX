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
function foe_gen(_lv, _seed, _kind = "") {
	var _b = cbt_balance();
	cbt_skills();
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	static _ros = [
		{ name : "goblin",   shape : { hp : 5, mp : 3, atk : 6, mag : 2, def : 5, mdef : 3, spd : 7, hit : 7 }, crit : 8,  cmulti : 1.6, cnt : 8,  erode : 1,   magic : false, skill : "concuss", gear : .3, col : rgb(120, 160, 70) },
		{ name : "bandit",   shape : { hp : 6, mp : 3, atk : 7, mag : 1, def : 6, mdef : 3, spd : 5, hit : 7 }, crit : 7,  cmulti : 1.6, cnt : 7,  erode : 1,   magic : false, skill : "strike",  gear : .8, col : rgb(170, 120, 90) },
		{ name : "wolf",     shape : { hp : 6, mp : 2, atk : 7, mag : 1, def : 3, mdef : 2, spd : 8, hit : 7 }, crit : 10, cmulti : 1.7, cnt : 5,  erode : 1,   magic : false, skill : "",        gear : 0,  col : rgb(150, 150, 160) },
		{ name : "slime",    shape : { hp : 8, mp : 6, atk : 3, mag : 3, def : 6, mdef : 6, spd : 2, hit : 4 }, crit : 5, cmulti : 1.5, cnt : 4,  erode : .25, magic : false, skill : "reform",  gear : 0,  col : c_seagreen },
		{ name : "skeleton", shape : { hp : 6, mp : 4, atk : 8, mag : 1, def : 6, mdef : 4, spd : 3, hit : 6 }, crit : 8,  cmulti : 1.8, cnt : 6,  erode : 1,   magic : false, skill : "strike",  gear : .5, col : rgb(205, 205, 210) },
		{ name : "wisp",     shape : { hp : 3, mp : 6, atk : 2, mag : 8, def : 2, mdef : 6, spd : 5, hit : 6 }, crit : 6,  cmulti : 1.8, cnt : 2,  erode : 1,   magic : true,  skill : "drain",   gear : 0,  col : rgb(150, 110, 220) },
		{ name : "rat",      shape : { hp : 5, mp : 4, atk : 6, mag : 1, def : 4, mdef : 2, spd : 7, hit : 8 }, crit : 10, cmulti : 1.6, cnt : 12, erode : 1,  magic : false, skill : "concuss", gear : .1, col : rgb(180, 145, 110) },
	];
	var _r = _ros[irandom(array_length(_ros) - 1)];
	if (_kind != "") for (var _ri = 0; _ri < array_length(_ros); _ri++) if (_ros[_ri].name == _kind) _r = _ros[_ri];   // a kind asked for (a quest's, a camp's)
	var _boss = (random(1) < 1 / 12);
	var _budget = sprite_par_pts(_lv) * SPRITE_FOE_BUDGET * (_boss ? 1.4 : 1);
	var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit"];
	var _pts = {};
	var _total = 0;
	for (var _k = 0; _k < 8; _k++) { _pts[$ _keys[_k]] = _r.shape[$ _keys[_k]] * _budget / 40; _total += _pts[$ _keys[_k]]; }
	// the arms: a weapon and maybe armour, at their level, common or uncommon
	var _worn = [];
	if (random(1) < _r.gear) {
		array_push(_worn, gear_gen("w1", _lv, (random(1) < .25) ? 1 : 0, irandom($7fffffff)));
		if (random(1) < .6) array_push(_worn, gear_gen("armor", _lv, (random(1) < .25) ? 1 : 0, irandom($7fffffff)));
	}
	for (var _w = 0; _w < array_length(_worn); _w++) {
		var _lk = variable_struct_get_names(_worn[_w].pts);
		for (var _i = 0; _i < array_length(_lk); _i++) { _pts[$ _lk[_i]] += _worn[_w].pts[$ _lk[_i]]; _total += _worn[_w].pts[$ _lk[_i]]; }
	}
	var _name = _r.name;
	if (array_length(_worn) > 0 && random(1) < .6) _name = "armed " + _r.name;
	if (_boss) _name = _r.name + " " + choose("chief", "elder", "king", "of unusual size", "with a hat", "the second");
	var _maxhp = round((_pts.hp * _b.hp_per_point + _b.hp_flat_add) * 10) / 10;
	var _maxmp = max(1, round(_pts.mp));
	var _sk = [];
	if (_r.skill != "") array_push(_sk, g.cskills[$ _r.skill]);
	rng_release(_old);
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
