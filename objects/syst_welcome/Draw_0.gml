var _e = ui_anim_in(oa, 1);
if (_e < .001) exit;
var _eo = (1 - _e) * UI_IN_DEAL;
if (_eo != 0) matrix_set(matrix_world, matrix_build(0, _eo, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_e);
draw_set_font(fnt);
draw_set_valign(fa_top);

// the card
draw_sprite_ext(spr_pixel_1x1, 0, cx, cy, cw, ch, 0, c_black, .82);
draw_px_rect(cx, cy, cw, ch, c_gold, .5);
draw_sprite_ext(spr_pixel_1x1, 0, cx, cy, cw, 1, 0, c_gold, .8);
// the title
draw_set_halign(fa_center);
draw_set_color(c_gold);
draw_set_alpha(.95);
draw_text(cx + cw * .5, cy + 6, "welcome back");
draw_sprite_ext(spr_pixel_1x1, 0, cx + 8, cy + 18, cw - 16, 1, 0, sett_ink, .25);
// the rows
for (var _i = 0; _i < array_length(rows); _i++) {
	var _rw = rows[_i];
	var _ry = cy + 24 + _i * row_p;
	draw_set_halign(fa_left);
	draw_set_color(sett_ink);
	draw_set_alpha(.6);
	draw_text(cx + 8, _ry, _rw.l);
	draw_set_halign(fa_right);
	draw_set_color(_rw.c);
	draw_set_alpha(.95);
	draw_text(cx + cw - 8, _ry, _rw.v);
}
// the footer
draw_set_halign(fa_center);
draw_set_color(sett_ink);
draw_set_alpha(.45 + .2 * dsin(current_time * .25));
draw_text(cx + cw * .5, cy + ch - 12, "the profit is in the pile  -  tap to continue");
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
ui_fade_set(1);
if (_eo != 0) matrix_set(matrix_world, matrix_build_identity());
