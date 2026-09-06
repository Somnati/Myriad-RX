/// @description blur_snap([down]) - THE CAPTURE half of the region blur.
/// Copies the application surface into g.blur_small at 1/down scale;
/// draw_blur_region() then draws pieces of it back wherever a panel
/// wants frosted glass behind it.
///
/// ⚖️ WHERE YOU CALL IT IS THE WHOLE DESIGN. Everything drawn BEFORE
/// this runs is in the blur; everything after is not. So it goes in a
/// DRAW SLOT (obj_draw_proxy) seated between the content and the UI -
/// in rm_clicker that is depth 0: after the room, the visualiser and
/// the whole fx stack, before the drawer at -20 and the header at
/// -1000. Put it any shallower and the UI starts frosting itself.
///
/// ⚖️ READING application_surface IS SAFE HERE, and this is the bit
/// that looks wrong but is not: surface_set_target() switches the
/// render target away from it and flushes the batch, so by the time we
/// draw it, it is an ordinary texture. GM's warning is about drawing a
/// surface ONTO ITSELF, which this never does.
///
/// THE BLUR IS THE FILTERING - there is no shader. Bilinear on the way
/// down averages down x down pixels into one, and bilinear on the way
/// back up (in draw_blur_region) smooths between those. Two passes of
/// hardware interpolation. Raise `down` for a softer, cheaper blur.
/// @param down
function blur_snap(_down = 4) {
	if (!surface_exists(application_surface)) return false;
	var _w = max(1, surface_get_width(application_surface) div _down);
	var _h = max(1, surface_get_height(application_surface) div _down);

	if (!variable_global_exists("blur_small")) g.blur_small = -1;
	// SURFACES ARE VOLATILE. Windows frees them on an alt-tab, a
	// resolution change or a device loss, so every single use re-checks
	// and rebuilds rather than trusting the handle it made last frame.
	if (!surface_exists(g.blur_small)
	|| surface_get_width(g.blur_small)  != _w
	|| surface_get_height(g.blur_small) != _h) {
		if (surface_exists(g.blur_small)) surface_free(g.blur_small);
		g.blur_small = surface_create(_w, _h);
	}

	surface_set_target(g.blur_small);
	draw_clear_alpha(c_black, 0);
	gpu_set_tex_filter(true);
	draw_surface_ext(application_surface, 0, 0, 1 / _down, 1 / _down, 0,
		c_white, 1);
	gpu_set_tex_filter(false);
	surface_reset_target();
	return true;
}
