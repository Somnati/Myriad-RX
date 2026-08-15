/// @description draw_px_rect(x,y,w,h,color,alpha);
/// @param x
/// @param y
/// @param w
/// @param h
/// @param color
/// @param alpha
/// pixel-look rectangle OUTLINE: four spr_pixel_1x1 strips, instead of
/// gm's draw_rectangle. 1px thick, (x,y) top-left, w/h in px.
function draw_px_rect(_x, _y, _w, _h, _col, _a) {
	draw_sprite_ext(spr_pixel_1x1, 0, _x,          _y,          _w, 1,      0, _col, _a); // top
	draw_sprite_ext(spr_pixel_1x1, 0, _x,          _y + _h - 1, _w, 1,      0, _col, _a); // bottom
	draw_sprite_ext(spr_pixel_1x1, 0, _x,          _y + 1,      1,  _h - 2, 0, _col, _a); // left
	draw_sprite_ext(spr_pixel_1x1, 0, _x + _w - 1, _y + 1,      1,  _h - 2, 0, _col, _a); // right
}
