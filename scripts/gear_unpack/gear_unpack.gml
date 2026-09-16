/// @description gear_unpack("slot,lv,rar,seed[,tag,own,gen]") -> the item, regenerated (undefined if malformed)
/// A four-field record is a pre-pass item: generation 1 (the old family pools), no tag, no owner.
function gear_unpack(_s) {
	var _f = string_split(_s, ",");
	if (array_length(_f) < 4) return undefined;
	if (_f[0] == "use") return use_gen(_f[1], real(_f[2]), real(_f[3]));   // (a consumable, 2026-09-16)
	if (_f[0] != "w1" && _f[0] != "w2" && _f[0] != "armor" && _f[0] != "talis") return undefined;
	if (array_length(_f) >= 7) return gear_gen(_f[0], real(_f[1]), real(_f[2]), real(_f[3]), _f[4], _f[5], max(1, real(_f[6])));
	return gear_gen(_f[0], real(_f[1]), real(_f[2]), real(_f[3]), "", "", 1);
}
