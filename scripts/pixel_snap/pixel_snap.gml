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
/// SOFT EDGES, the optional second half (his ask 2026-09-06: "how will
/// it look with a good blur applied to the pixelation"). Blurring a
/// pixelation is NOT a better blur - decimation has already thrown the
/// other pixels away, so a blur afterwards is smoothing data that is
/// gone. What it IS good for is the look, and for one practical thing:
/// it softens the STEP he disliked, because the backdrop's edge snaps
/// to whole texels and a stepping edge is far less visible when it is
/// not a hard line.
/// `soft` is the trick, and it is cheap: re-render the blocks POINT
/// sampled into a surface `soft` times bigger, so every block becomes a
/// soft x soft patch of identical texels. draw_pixel_region then draws
/// THAT with bilinear - which can only ever smear across one texel, ie
/// a 1/soft fraction of a block. So bigger soft = crisper blocks,
/// 2 = very soft, 0 = the hard-edged original. It also divides the
/// edge-snapping by `soft`, since the texel grid got that much finer.
/// @param cell
/// @param soft
function pixel_snap(_cell = 3, _soft = 0) {
	if (!surface_exists(application_surface)) return false;
	var _aw = surface_get_width(application_surface);
	var _ah = surface_get_height(application_surface);
	if (_aw < 2 || _ah < 2) return false;

	// room pixels per block -> surface pixels per block
	var _ratio = _ah / max(1, room_height);
	var _f = max(2, round(_cell * _ratio));
	var _w = max(1, _aw div _f);
	var _h = max(1, _ah div _f);

	if (!variable_global_exists("pix_raw")) {
		g.pix_raw = -1; g.pix_snap = -1; g.pix_key = ""; g.pix_soft = 0;
	}
	_soft = (_soft >= 2) ? floor(_soft) : 0;
	var _key = string(_w) + "x" + string(_h) + "s" + string(_soft);

	// SURFACES ARE VOLATILE - an alt-tab, a resolution change or a device
	// loss frees them - so the handle from last frame is never trusted
	var _ok = (g.pix_key == _key) && surface_exists(g.pix_raw)
		&& (_soft == 0 || surface_exists(g.pix_snap));
	if (!_ok) {
		// free the upscale FIRST and on its own terms: when soft is
		// switched OFF, the new _soft is 0 but the OLD surface is still
		// out there, and a condition on the new value would strand it.
		// pix_snap aliases pix_raw while soft is off, so the identity
		// check is what stops a double free.
		if (surface_exists(g.pix_snap) && g.pix_snap != g.pix_raw)
			surface_free(g.pix_snap);
		if (surface_exists(g.pix_raw)) surface_free(g.pix_raw);
		show("[surface] pixel_snap rebuilt " + _key + " at " + string(current_time));   // (the flicker hunt, 2026-09-13)
		g.pix_raw  = surface_create(_w, _h);
		g.pix_snap = (_soft > 0)
			? surface_create(_w * _soft, _h * _soft) : g.pix_raw;
		g.pix_key  = _key;
	}
	g.pix_soft = _soft;

	// ONE EXACT TEXEL PER BLOCK - the filter stays off, house law
	gpu_set_tex_filter(false);
	surface_set_target(g.pix_raw);
	draw_clear_alpha(c_black, 0);
	draw_surface_ext(application_surface, 0, 0, _w / _aw, _h / _ah, 0, c_white, 1);
	surface_reset_target();

	// and, if asked, blow those blocks up POINT sampled so each becomes
	// a patch of identical texels for the draw side to soften the rim of
	if (_soft > 0) {
		surface_set_target(g.pix_snap);
		draw_clear_alpha(c_black, 0);
		draw_surface_ext(g.pix_raw, 0, 0, _soft, _soft, 0, c_white, 1);
		surface_reset_target();
	}
	return true;
}
