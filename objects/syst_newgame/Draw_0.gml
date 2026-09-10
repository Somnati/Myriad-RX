/// black, and one centred list. The title above it, the rows in their
/// colours, the hovered row brightening and growing a bracket; a faint
/// step counter at the bottom so the three questions read as a short
/// walk rather than a wall.

draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, 1);

var _a = t * t;   // ease the fade
draw_set_font(fnt);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

// ---- the title ----
var _rows = __rows();
var _ty = _rows[0].y - 26;
draw_set_color(c_white);
draw_set_alpha(.9 * _a);
draw_text(room_width * .5, _ty, __title());

// ---- the list ----
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _r = _rows[_i];
	var _h = (hov == _i);
	// the plate, faint; the hovered one warms in its own colour
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
		merge_colour(c_black, _r.col, _h ? .22 : .08), _a);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _r.col, (_h ? .8 : .3) * _a);
	// the label, colour coded
	draw_set_color(_h ? merge_colour(_r.col, c_white, .35) : _r.col);
	draw_set_alpha((_h ? 1 : .85) * _a);
	draw_text(room_width * .5, _r.y + ((_r.sub != "") ? 3 : 7), _r.name);
	if (_r.sub != "") {
		draw_set_color(rgb(120, 130, 150));
		draw_set_alpha(.7 * _a);
		draw_text(room_width * .5, _r.y + 12, _r.sub);
	}
	// the bracket on the hovered row
	if (_h) {
		draw_set_color(_r.col);
		draw_set_alpha(.9 * _a);
		draw_text(_r.x - 8, _r.y + 7, ">");
		draw_text(_r.x + _r.w + 8, _r.y + 7, "<");
	}
}

// ---- the walk: where you are in the four screens ----
draw_set_color(rgb(120, 130, 150));
draw_set_alpha(.5 * _a);
var _dots = "";
for (var _k = 0; _k < 4; _k++) _dots += (_k == stage) ? "o " : ". ";
draw_text(room_width * .5, room_height - 22, _dots);
if (stage == 0) {
	draw_set_alpha(.35 * _a);
	draw_text(room_width * .5, room_height - 12, "escape - back to profiles");
}

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
