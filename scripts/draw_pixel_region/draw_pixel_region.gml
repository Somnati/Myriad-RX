/// @description draw_pixel_region(x, y, w, h, [alpha]) - THE DRAW half
/// of the region pixelation: paints the chunky copy of whatever was
/// behind this rectangle back into it. Draw-only, house rules - it owns
/// no state and no hit region; the caller draws it and then paints its
/// own panel on top.
///
/// Needs pixel_snap() to have run this frame from a draw slot deeper
/// than the caller. If it has not, this draws nothing and returns
/// false, so a screen without a capture degrades to whatever the caller
/// draws next rather than breaking.
///
/// ⚖️ POINT SAMPLED: the filter stays OFF so the blocks come back with
/// hard edges. Turning it on here would soften exactly the thing the
/// snapshot went to the trouble of keeping sharp.
/// ⚖️ ROOM COORDS ARE NOT SURFACE COORDS - the app surface is the
/// WINDOW's size - so the rectangle scales through the snapshot's own
/// dimensions. No hardcoded scale belongs here.
/// @param x
/// @param y
/// @param w
/// @param h
/// @param alpha
function draw_pixel_region(_x, _y, _w, _h, _a = 1) {
	if (_w <= 0 || _h <= 0 || _a <= 0) return false;
	if (!variable_global_exists("pix_snap")) return false;
	if (!surface_exists(g.pix_snap)) return false;

	var _sw = surface_get_width(g.pix_snap);
	var _sh = surface_get_height(g.pix_snap);
	var _kx = _sw / max(1, room_width);
	var _ky = _sh / max(1, room_height);

	// SNAP THE SOURCE RECTANGLE TO WHOLE TEXELS. A fractional edge would
	// put a part-block at the seam, which is the one thing that makes
	// pixelation look like a mistake rather than a choice.
	var _l = clamp(floor(_x * _kx), 0, _sw - 1);
	var _t = clamp(floor(_y * _ky), 0, _sh - 1);
	var _r = clamp(ceil((_x + _w) * _kx), _l + 1, _sw);
	var _b = clamp(ceil((_y + _h) * _ky), _t + 1, _sh);

	gpu_set_tex_filter(false);
	draw_surface_part_ext(g.pix_snap, _l, _t, _r - _l, _b - _t,
		_l / _kx, _t / _ky, 1 / _kx, 1 / _ky, c_white, _a);
	return true;
}
