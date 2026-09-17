/// @description planet_lod_free(l) -> undefined; frees a zoom tier's buffers and textures (planet_lod_begin's struct)
function planet_lod_free(_l) {
	if (is_struct(_l)) {
		if (surface_exists(_l.tsurf)) surface_free(_l.tsurf);
		if (surface_exists(_l.hsurf)) surface_free(_l.hsurf);
		if (buffer_exists(_l.tbuf)) buffer_delete(_l.tbuf);
		if (buffer_exists(_l.hbuf)) buffer_delete(_l.hbuf);
	}
	return undefined;
}
