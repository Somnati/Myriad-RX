/// @description exped_bond_tier(v) -> 1 strangers (under 25) / 2 mates
/// (under 60) / 3 inseparable - the diary's party gates (exped_lines)
function exped_bond_tier(_v) {
	if (_v < 25) return 1;
	if (_v < 60) return 2;
	return 3;
}
