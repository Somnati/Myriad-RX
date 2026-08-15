/// @description draw_px_line(x1,y1,x2,y2,color,alpha);
/// @param x1
/// @param y1
/// @param x2
/// @param y2
/// @param color
/// @param alpha
/// pixel-look line: one spr_pixel_1x1 stretched along the segment,
/// instead of gm's draw_line. 1px thick.
function draw_px_line(_x1, _y1, _x2, _y2, _col, _a) {
	var _len = point_distance(_x1, _y1, _x2, _y2);
	if (_len <= 0) return;
	var _dir = point_direction(_x1, _y1, _x2, _y2);
	draw_sprite_ext(spr_pixel_1x1, 0, _x1, _y1, _len, 1, _dir, _col, _a);
}
