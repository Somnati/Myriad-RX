/// @description pixel_snap([cell]) - THE CAPTURE half of the region
/// PIXELATION: reduces the application surface so that one texel covers
/// `cell` ROOM pixels, then draw_pixel_region() blows it back up in
/// hard blocks wherever a panel wants a chunky backdrop.
///
/// ⚖️ POINT SAMPLED, BOTH WAYS, AND THAT IS THE WHOLE POINT. House law:
/// pixelation takes ONE EXACT SAMPLE PER CELL and never averages - it
/// is why GameMaker's own _filter_pixelate is banned here, it averages
/// and softens. Turning the filter OFF on the way down picks a single
/// real texel per block; off again on the way back up keeps the block
/// edges hard. A blur is the opposite operation and needs the opposite
/// setting; do not share this code with blur_snap.
///
/// ⚖️ THE CELL IS IN ROOM PIXELS. The application surface is the
/// WINDOW's size, so a surface-space cell would grow and shrink with
/// the monitor - blocks have to line up with the art, which is authored
/// in room pixels.
///
/// ⚖️ WHERE YOU CALL IT IS THE DESIGN, same as the blur: everything
/// drawn BEFORE this is in the snapshot, everything after is not. It
/// belongs in an obj_draw_proxy slot between the content and the UI.
///
/// Reading application_surface is safe here: surface_set_target() moves
/// the render target away from it and flushes first.
/// @param cell
function pixel_snap(_cell = 3) {
	if (!surface_exists(application_surface)) return false;
	var _aw = surface_get_width(application_surface);
	var _ah = surface_get_height(application_surface);
	if (_aw < 2 || _ah < 2) return false;

	// room pixels per block -> surface pixels per block
	var _ratio = _ah / max(1, room_height);
	var _f = max(2, round(_cell * _ratio));
	var _w = max(1, _aw div _f);
	var _h = max(1, _ah div _f);

	if (!variable_global_exists("pix_snap")) { g.pix_snap = -1; g.pix_key = ""; }
	var _key = string(_w) + "x" + string(_h);
	// SURFACES ARE VOLATILE - an alt-tab, a resolution change or a device
	// loss frees them - so the handle from last frame is never trusted
	if (!surface_exists(g.pix_snap) || g.pix_key != _key) {
		if (surface_exists(g.pix_snap)) surface_free(g.pix_snap);
		g.pix_snap = surface_create(_w, _h);
		g.pix_key = _key;
	}

	surface_set_target(g.pix_snap);
	draw_clear_alpha(c_black, 0);
	gpu_set_tex_filter(false);
	draw_surface_ext(application_surface, 0, 0, _w / _aw, _h / _ah, 0, c_white, 1);
	surface_reset_target();
	return true;
}
