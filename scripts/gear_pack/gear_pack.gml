/// @description gear_pack(item) -> "slot,lv,rar,seed" - enough to regenerate it (gear_gen)
function gear_pack(_it) {
	return _it.slot + "," + string(_it.lv) + "," + string(_it.rar) + "," + string(_it.seed);
}
