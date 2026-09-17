/// @description planet_lod_begin(pn, k) -> a ZOOM TIER's build: { k, w, h, row, tbuf, hbuf, tsurf, hsurf, ready }
/// THE ZOOM TIERS (his call, 2026-09-17: "LOD triggers based off zoom
/// distance, not camera movement... keep a large area"): a tier is the
/// WHOLE map at k times the base map's resolution, built once a world (rows
/// a frame through planet_lod_step, into buffers, then up as two textures
/// sh_planet reads instead of the map's). Nothing about the camera: zoom
/// in and it is there, pan anywhere. planet_lod_free drops one
function planet_lod_begin(_pn, _k) {
	var _w = _pn.tw * _k, _h = _pn.th * _k;
	return { k : _k, w : _w, h : _h, row : 0, col : 0, tbuf : buffer_create(_w * _h * 4, buffer_fixed, 1), hbuf : buffer_create(_w * _h * 4, buffer_fixed, 1), tsurf : -1, hsurf : -1, ready : false,
		u0 : 0, v0 : 0, uw : _pn.tw, vh : _pn.th };   // (the window planet_draw hands the shader: the whole map)
}
