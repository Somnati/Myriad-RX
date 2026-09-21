/// @description delta_num(x) -> a short number for the delta's page: 1234 -> 1.23k, whole under a thousand
function delta_num(_x) {
	if (_x < 1000) return string(floor(_x));
	if (_x < 1000000) return string_format(_x / 1000, 1, 2) + "k";
	if (_x < 1000000000) return string_format(_x / 1000000, 1, 2) + "m";
	return string_format(_x / 1000000000, 1, 2) + "b";
}
