/// @description gear_unpack("slot,lv,rar,seed") -> the item, regenerated (undefined if malformed)
function gear_unpack(_s) {
	var _f = string_split(_s, ",");
	if (array_length(_f) < 4) return undefined;
	if (_f[0] != "w1" && _f[0] != "w2" && _f[0] != "armor" && _f[0] != "talis") return undefined;
	return gear_gen(_f[0], real(_f[1]), real(_f[2]), real(_f[3]));
}
