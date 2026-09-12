/// @description draw_capsule(x, y, w, h, c_left, c_right, [alpha], [bevel])
/// THE DECK'S PLATE, as one helper: a rectangle with BEVELLED ENDS off
/// spr_dial_endcaps' silhouette (the cap's top row sits three in, the
/// next two one in, then full - mirrored at the bottom), filled with a
/// horizontal gradient from c_left at the left edge to c_right at the
/// right. obj_ability_slot paints its 11px capsules this way with the
/// endcap sprite; at any other height the sprite would stretch, so the
/// shape is stamped from an inset table instead (house rule, hard
/// pixels). Pass the same colour twice for a flat plate. Draw-only,
/// spr_pixel_1x1 stamps - safe under any shader.
/// @param x
/// @param y
/// @param w
/// @param h
/// @param c_left    the colour at the left edge
/// @param c_right   the colour at the right edge
/// @param [alpha]   1
/// @param [bevel]   the inset table, one entry per row in from the top
///                  and bottom edges (capsule_bevel(h) - a round end)
function draw_capsule(_x, _y, _w, _h, _c1, _c2, _a = 1, _bev = undefined) {
	if (_bev == undefined) _bev = capsule_bevel(_h);
	var _n = array_length(_bev);
	if (_h < _n * 2 + 1) _n = max(0, (_h - 1) div 2);
	for (var _k = 0; _k < _n; _k++) {
		var _in = _bev[_k];
		if (_w - _in * 2 <= 0) continue;
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _k, _w - _in * 2, 1, 0, _c1, _c2, _c2, _c1, _a);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _h - 1 - _k, _w - _in * 2, 1, 0, _c1, _c2, _c2, _c1, _a);
	}
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_x, _y + _n, _w, _h - _n * 2, 0, _c1, _c2, _c2, _c1, _a);
}
