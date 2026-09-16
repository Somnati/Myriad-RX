/// @description gear_pack(item) -> "slot,lv,rar,seed,tag,own,gen" - enough to regenerate it (gear_gen)
/// (the proc-gear pass, 2026-09-15: the place it came from, a boss's
/// name, and the generation - a pre-pass item stays a pre-pass item)
function gear_pack(_it) {
	if ((_it[$ "slot"] ?? "") == "use") return "use," + _it.kind + "," + string(_it.size) + "," + string(_it.lv);   // (a consumable, 2026-09-16)
	return _it.slot + "," + string(_it.lv) + "," + string(_it.rar) + "," + string(_it.seed) + "," + string(_it[$ "tag"] ?? "") + "," + string(_it[$ "own"] ?? "") + "," + string(_it[$ "gen"] ?? 1);
}
