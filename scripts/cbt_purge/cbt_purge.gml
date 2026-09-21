/// @description cbt_purge(fight, target, school, [one]) -> how many effects went
/// Light's CLEANSE strips every dark effect (the nerfs, the leech mark,
/// the ailments); dark's DRAIN strips every light one (the buffs, haste,
/// regen). `one` = only the first ailment found (mend's small mercy).
function cbt_purge(_f, _t, _school, _one = false) {
	var _n = 0;
	if (!is_struct(_t[$ "ail"])) return 0;
	if (_school == "light") {
		if (_one) {
			if (_t.ail.poison > 0)     { _t.ail.poison = 0; _n++; }
			else if (_t.ail.slow > 0)  { _t.ail.slow = 0; _n++; }
			else if (_t.ail.leech > 0) { _t.ail.leech = 0; _t.leecher = undefined; _n++; }
			if (_n > 0) cbt_log(_f, _t.name + " is eased");
			return _n;
		}
		if (_t.ail.poison > 0) { _t.ail.poison = 0; _n++; }
		if (_t.ail.slow > 0)   { _t.ail.slow = 0; _n++; }
		if (_t.ail.leech > 0)  { _t.ail.leech = 0; _t.leecher = undefined; _n++; }
		if ((_t.ail[$ "silence"] ?? 0) > 0) { _t.ail.silence = 0; _n++; }
		if (is_struct(_t[$ "nf"])) { if (_t.nf.atk > 0) { _t.nf.atk = 0; _n++; } if (_t.nf.def > 0) { _t.nf.def = 0; _n++; } if (_t.nf.hit > 0) { _t.nf.hit = 0; _n++; } if ((_t.nf[$ "pres"] ?? 0) > 0) { _t.nf.pres = 0; _n++; } if ((_t.nf[$ "mres"] ?? 0) > 0) { _t.nf.mres = 0; _n++; } }
		if (_n > 0) { cbt_log(_f, _t.name + " is cleansed"); cbt_film(_f, _t, 0, _t.name + " is cleansed"); }
		return _n;
	}
	if (_school == "dark") {
		if (is_struct(_t[$ "bf"])) { if (_t.bf.atk > 0) { _t.bf.atk = 0; _n++; } if (_t.bf.def > 0) { _t.bf.def = 0; _n++; } if (_t.bf.hit > 0) { _t.bf.hit = 0; _n++; } if (_t.bf.spd > 0) { _t.bf.spd = 0; _n++; } if ((_t.bf[$ "pres"] ?? 0) > 0) { _t.bf.pres = 0; _n++; } if ((_t.bf[$ "mres"] ?? 0) > 0) { _t.bf.mres = 0; _n++; } }
		if ((_t[$ "regen"] ?? 0) > 0) { _t.regen = 0; _n++; }
		if ((_t[$ "evade"] ?? 0) > 0) { _t.evade = 0; _n++; }
		if (_n > 0) { cbt_log(_f, _t.name + "'s blessings are drained away"); cbt_film(_f, _t, 0, _t.name + " is drained"); }
		return _n;
	}
	return 0;
}
