/// @description foe_kind_elem(kind) -> the kind's element ("" for a
/// neutral kind, or a kind the roster does not know)
function foe_kind_elem(_kind) {
	var _ros = foe_roster();
	for (var _i = 0; _i < array_length(_ros); _i++) if (_ros[_i].name == _kind) return _ros[_i][$ "elem"] ?? "";
	return "";
}
