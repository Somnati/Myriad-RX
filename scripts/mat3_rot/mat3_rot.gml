/// @description mat3_rot(ax, ay, az, deg);
/// @param ax
/// @param ay
/// @param az
/// @param deg
/// 3x3 rotation matrix (row-major 9-array) about an arbitrary axis.
/// deg 0 returns identity. axis need not be normalized.
function mat3_rot(_ax, _ay, _az, _deg) {

	var _l = sqrt(_ax * _ax + _ay * _ay + _az * _az);
	if (_l <= 0) return [1, 0, 0, 0, 1, 0, 0, 0, 1];
	_ax /= _l; _ay /= _l; _az /= _l;

	var _c = dcos(_deg);
	var _s = -dsin(_deg); // gm dsin is counter-clockwise; flip for screen-y-down
	var _t = 1 - _c;

	return [
		_t * _ax * _ax + _c,       _t * _ax * _ay - _s * _az, _t * _ax * _az + _s * _ay,
		_t * _ax * _ay + _s * _az, _t * _ay * _ay + _c,       _t * _ay * _az - _s * _ax,
		_t * _ax * _az - _s * _ay, _t * _ay * _az + _s * _ax, _t * _az * _az + _c,
	];
}
