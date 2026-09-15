/// @description planet_pick(pn, mx, my, cx, cy, pr, m) -> { hit, u, v, lat, lon, biome, tx, ty, tz }
/// The tech demo's scr_planet_pick: the render step run backwards for one
/// screen point - ray-sphere intersect the pixel, rotate the hit into
/// texture space with the SAME matrix the shader uses (m = texture from
/// view), read the terrain arrays at that texel. tx/ty/tz = the texture-
/// space unit vector, re-rotated forward each frame to pin a marker.
function planet_pick(_pn, _mx, _my, _cx, _cy, _pr, _m) {
	var _px = (_mx - _cx) / _pr, _py = (_my - _cy) / _pr;
	var _r2 = _px * _px + _py * _py;
	if (_r2 > 1) return { hit : false };
	var _z = sqrt(1 - _r2);
	var _t = mat3_apply(_m, _px, _py, _z);
	var _v = arccos(clamp(_t[1], -1, 1)) / pi;
	var _u = arctan2(_t[2], _t[0]) / (2 * pi) + .5;
	var _tx = clamp(floor(_u * _pn.tw), 0, _pn.tw - 1), _ty = clamp(floor(_v * _pn.th), 0, _pn.th - 1);
	var _i = _tx + _ty * _pn.tw;
	return { hit : true, u : _u, v : _v, lat : 90 - _v * 180, lon : _u * 360 - 180,
	         elev : (_pn.row >= _pn.th) ? _pn.elev[_i] : 0, biome : (_pn.row >= _pn.th) ? _pn.biome[_i] : 0,
	         tx : _t[0], ty : _t[1], tz : _t[2] };
}
