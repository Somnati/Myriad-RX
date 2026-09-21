/// @description delta_springs(d) -> [[x, y], ...] the springs: where the rain begins - the valley's head, then two more up the mountains as they are bought
function delta_springs(_d) {
	var _out = [[_d.w * .5, 1.5]];
	if (_d.springs >= 2) array_push(_out, [_d.w * .5 - 17, 1.5]);
	if (_d.springs >= 3) array_push(_out, [_d.w * .5 + 17, 1.5]);
	return _out;
}
