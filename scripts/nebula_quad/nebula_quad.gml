/// @description nebula_quad() -> a 2 x 2 white surface: the quad sh_nebula paints on (its texcoords run 0..1 whatever the scale)
/// (a sprite's texcoords are its place on a texture page; a surface's are
/// the whole surface - so a stretched surface is the one quad whose uv a
/// shader can trust. Filled through a buffer: no draw call in the making.)
function nebula_quad() {
	static _q = -1;
	if (surface_exists(_q)) return _q;
	_q = surface_create(2, 2);
	var _b = buffer_create(16, buffer_fixed, 1);
	repeat (16) buffer_write(_b, buffer_u8, 255);
	buffer_set_surface(_b, _q, 0);
	buffer_delete(_b);
	return _q;
}
