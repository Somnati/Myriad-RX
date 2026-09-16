/// @description foe_kinds_at(land) -> the kinds that haunt a place of that kind (foe_roster's lands); the road's four when none do
function foe_kinds_at(_land) {
	var _ros = foe_roster(), _out = [];
	for (var _i = 0; _i < array_length(_ros); _i++) if (array_contains(_ros[_i].lands, _land)) array_push(_out, _ros[_i].name);
	if (array_length(_out) == 0) _out = ["goblin", "bandit", "wolf", "rat"];
	return _out;
}
