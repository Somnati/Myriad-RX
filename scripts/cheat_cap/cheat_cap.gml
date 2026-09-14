/// @description cheat_cap() -> the total the rows may add up to. Base
/// 100 a row, and NOTHING FREE on top (his call, 2026-09-14 - the
/// milestone / rebirth track was "a free +30%"): the deck's Cheat Points
/// I / II / III add +20 / +30 / +50 to spend, and that is all
function cheat_cap() {
	var _n = array_length(cheat_config().rows);
	var _cap = _n * 100;
	if (abi_on("ad_cheatpool1")) _cap += 20;
	if (abi_on("ad_cheatpool2")) _cap += 30;
	if (abi_on("ad_cheatpool3")) _cap += 50;
	return _cap;
}
