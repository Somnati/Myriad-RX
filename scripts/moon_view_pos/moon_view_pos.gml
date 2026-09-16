/// @description moon_view_pos(pn, mo, cam) -> [x, y, z, size] the moon's position in VIEW space (planet radii) now, and its radius - the shadow caster (planet_draw's msh)
/// The same orbit maths as moon_draw: the world's tilt, the moon's own
/// inclination, its phase on the universal clock, the camera's transpose.
function moon_view_pos(_pn, _mo, _cam) {
	var _ang = (_mo.ang + _mo.spd * 60 * universal_now()) mod 360;
	var _om = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(1, 0, 0, _mo.incl));
	var _lw = mat3_apply(_om, dcos(_ang) * _mo.dist, 0, dsin(_ang) * _mo.dist);
	var _mv = mat3_apply(mat3_transpose(_cam), _lw[0], _lw[1], _lw[2]);
	return [_mv[0], _mv[1], _mv[2], _mo.size];
}
