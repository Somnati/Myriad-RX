/// @description draw_blur_region(x, y, w, h, [alpha]) - THE DRAW half
/// of the region blur: paints the blurred copy of whatever was behind
/// this rectangle back into it. A DRAW-ONLY helper, house rules - it
/// owns no state and no hit region; the caller draws it and then paints
/// its own panel on top.
///
/// Needs blur_snap() to have run this frame from a draw slot deeper
/// than the caller. If it has not, this draws nothing and returns
/// false, so a screen without a capture degrades to whatever the
/// caller draws next rather than breaking.
///
/// ⚖️ ROOM COORDS ARE NOT SURFACE COORDS. The application surface is
/// the WINDOW's size, not the room's, so the rectangle is scaled into
/// it - and the snap is already reduced by its own factor, so one
/// ratio taken from the snap's actual size covers both. Never write a
/// hardcoded scale here.
/// @param x
/// @param y
/// @param w
/// @param h
/// @param alpha
function draw_blur_region(_x, _y, _w, _h, _a = 1) {
	if (_w <= 0 || _h <= 0 || _a <= 0) return false;
	if (!variable_global_exists("blur_small")) return false;
	if (!surface_exists(g.blur_small)) return false;

	var _kx = surface_get_width(g.blur_small)  / max(1, room_width);
	var _ky = surface_get_height(g.blur_small) / max(1, room_height);

	gpu_set_tex_filter(true);
	draw_surface_part_ext(g.blur_small,
		_x * _kx, _y * _ky, _w * _kx, _h * _ky,
		_x, _y, 1 / _kx, 1 / _ky, c_white, _a);
	gpu_set_tex_filter(false);
	return true;
}
