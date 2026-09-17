/// @description planet_lod_upload(l) - a zoom tier's two textures made from its buffers (fresh, or again after the gpu dropped them - the window going full screen and back, his report 2026-09-17)
function planet_lod_upload(_l) {
	if (!buffer_exists(_l.tbuf) || !buffer_exists(_l.hbuf)) return false;
	if (surface_exists(_l.tsurf)) surface_free(_l.tsurf);
	if (surface_exists(_l.hsurf)) surface_free(_l.hsurf);
	_l.tsurf = surface_create(_l.w, _l.h); _l.hsurf = surface_create(_l.w, _l.h);
	buffer_set_surface(_l.tbuf, _l.tsurf, 0); buffer_set_surface(_l.hbuf, _l.hsurf, 0);
	return true;
}
