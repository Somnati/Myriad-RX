/// @description blur_snap([room_px]) - THE CAPTURE half of the region
/// blur. Reduces the application surface down a chain of half-size
/// surfaces; draw_blur_region() draws the smallest one back wherever a
/// panel wants frosted glass behind it.
///
/// ⚖️⚖️ WHY A CHAIN OF HALVES AND NOT ONE BIG DOWNSCALE. This is what
/// made the first version almost invisible (his report 2026-09-06).
/// Bilinear filtering samples FOUR TEXELS, no matter how far you scale:
/// drawing the surface at 1/4 in one step reads 2x2 and simply skips
/// the other twelve pixels, which is aliasing, not blur. Halving reads
/// exactly the 2x2 it should, so each pass is a true average and N
/// passes blur 2^N wide. Never replace this loop with a single scale.
///
/// ⚖️ AND THE RADIUS IS IN ROOM PIXELS, not surface pixels - the other
/// half of why it was invisible. The application surface is the
/// WINDOW's size, roughly 3x the room in the portrait clicker, so the
/// old 4x downscale came to barely one room pixel of blur. Asking for
/// room pixels and solving for the step count keeps the blur looking
/// the same on any monitor.
///
/// ⚖️ WHERE YOU CALL IT IS THE DESIGN: everything drawn BEFORE this is
/// in the blur, everything after is not. It belongs in a draw slot
/// (obj_draw_proxy) between the content and the UI - depth 0 in
/// rm_clicker.
///
/// ⚖️ READING application_surface IS SAFE: surface_set_target() moves
/// the render target away from it and flushes, so it is an ordinary
/// texture by then. The manual warns about drawing a surface ONTO
/// ITSELF, which this never does.
/// @param room_px
function blur_snap(_room_px = 6) {
	if (!surface_exists(application_surface)) return false;
	var _aw = surface_get_width(application_surface);
	var _ah = surface_get_height(application_surface);
	if (_aw < 2 || _ah < 2) return false;

	// room pixels -> halvings. One halving blurs about two surface
	// pixels, so the reach is 2^steps surface pixels = that over the
	// room-to-surface ratio in room pixels.
	var _ratio = _ah / max(1, room_height);
	var _steps = clamp(round(log2(max(2, _room_px * _ratio))), 1, 6);

	if (!variable_global_exists("blur_chain")) { g.blur_chain = []; g.blur_key = ""; }
	var _key = string(_aw) + "x" + string(_ah) + "s" + string(_steps);

	// SURFACES ARE VOLATILE: an alt-tab, a resolution change or a device
	// loss frees them. The chain is rebuilt when the window resizes, the
	// step count changes, OR any link has gone missing - never trust a
	// handle from last frame.
	var _ok = (g.blur_key == _key) && (array_length(g.blur_chain) == _steps);
	if (_ok)
		for (var _i = 0; _i < _steps; _i++)
			if (!surface_exists(g.blur_chain[_i])) { _ok = false; break; }
	if (!_ok) {
		for (var _i = 0; _i < array_length(g.blur_chain); _i++)
			if (surface_exists(g.blur_chain[_i])) surface_free(g.blur_chain[_i]);
		g.blur_chain = [];
		var _w = _aw, _h = _ah;
		for (var _i = 0; _i < _steps; _i++) {
			_w = max(1, _w div 2);
			_h = max(1, _h div 2);
			array_push(g.blur_chain, surface_create(_w, _h));
		}
		g.blur_key = _key;
	}

	gpu_set_tex_filter(true);
	var _src = application_surface;
	for (var _i = 0; _i < _steps; _i++) {
		var _d = g.blur_chain[_i];
		surface_set_target(_d);
		draw_clear_alpha(c_black, 0);
		draw_surface_ext(_src, 0, 0,
			surface_get_width(_d)  / surface_get_width(_src),
			surface_get_height(_d) / surface_get_height(_src),
			0, c_white, 1);
		surface_reset_target();
		_src = _d;
	}
	gpu_set_tex_filter(false);

	g.blur_small = g.blur_chain[_steps - 1];
	return true;
}
