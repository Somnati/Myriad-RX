/// @description mat3_apply(m, x, y, z) -> [x, y, z]: m * v for a
/// row-major 3x3 (the tech demo's; mat3_rot / mat3_mul / mat3_transpose
/// are here already)
function mat3_apply(_m, _x, _y, _z) {
	return [
		_m[0] * _x + _m[1] * _y + _m[2] * _z,
		_m[3] * _x + _m[4] * _y + _m[5] * _z,
		_m[6] * _x + _m[7] * _y + _m[8] * _z,
	];
}
