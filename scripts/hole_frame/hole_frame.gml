/// @description hole_frame(dv, cam) -> [nx, ny, nz, ux, uy, uz] - a black hole's own frame from where we stand: the line of sight to it forward (dv = its direction in the view), screen-down its y; nx..nz = the disc's normal (the galactic up) in that frame - sh_hole's u_cam row 1 - and ux..uz = screen-up at the hole as a WORLD vector (the roll a frozen render is turned by, later)
/// His report (2026-09-17, q196): "black holes in the skybox are rotating
/// themselves as if they are the centre piece" - the disc took the VIEW's
/// forward for its line of sight; a hole at the page's edge is seen along
/// its own, and its disc lies as the galactic plane does from there
function hole_frame(_dv, _cam) {
	var _dl = max(.0001, sqrt(_dv[0] * _dv[0] + _dv[1] * _dv[1] + _dv[2] * _dv[2]));
	var _zx = -_dv[0] / _dl, _zy = -_dv[1] / _dl, _zz = -_dv[2] / _dl;   // toward the eye
	var _yx = -_zx * _zy, _yy = 1 - _zy * _zy, _yz = -_zz * _zy;          // screen-down, square to the line of sight
	var _yn = max(.0001, sqrt(_yx * _yx + _yy * _yy + _yz * _yz)); _yx /= _yn; _yy /= _yn; _yz /= _yn;
	var _xx = _yy * _zz - _yz * _zy, _xy = _yz * _zx - _yx * _zz, _xz = _yx * _zy - _yy * _zx;   // right = down x toward
	var _wx = _cam[3], _wy = _cam[4], _wz = _cam[5];   // the galactic up in the view (the camera's second row)
	var _uw = mat3_apply(_cam, -_yx, -_yy, -_yz);      // screen-up at the hole, into the world
	return [_wx * _xx + _wy * _xy + _wz * _xz, _wx * _yx + _wy * _yy + _wz * _yz, _wx * _zx + _wy * _zy + _wz * _zz, _uw[0], _uw[1], _uw[2]];
}
