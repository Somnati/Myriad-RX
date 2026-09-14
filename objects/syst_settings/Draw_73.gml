/// DRAW END: ONLY the floating popups (help explainer + keep/revert
/// countdown) - they must cover the live widgets, which draw after
/// the controller. everything pinned (strip, rail) moved to Draw_0 in
/// v2 so the menu drawer can cover it; these popups just HIDE while
/// the menu is up instead (the confirm clock pauses with them).

if (variable_global_exists("input_block") && g.input_block >= ui_layer_menu) exit;
if (peek > .01) exit;   // (the peek: nothing floats over a live look at the visualiser)

draw_set_font(fnt);

// the tap-for-info explainer, floated near the tap, clamped in-room
if (help_txt != "") {
	var _w = 150;
	var _hh = string_height_ext(help_txt, 9, _w - 8);
	var _px = clamp(help_x - (_w >> 1), 4, room_width - _w - 4);
	var _py = clamp(help_y - _hh - 14, bby + 4, room_height - _hh - 12);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, _w, _hh + 8, 0, c_black, .92);
	draw_px_rect(_px, _py, _w, _hh + 8, c_gold, .6);
	draw_set_halign(fa_left);
	draw_set_color(rgb(220, 225, 245));
	draw_set_alpha(.95);
	draw_text_ext(_px + 4, _py + 4, help_txt, 9, _w - 8);
}

// the keep/revert countdown (geometry shared with the step's hit test)
if (confirm_active) {
	var _cb = __confirm_box();
	var _secs = string(ceil(confirm_tic / tsec));

	// dim the room so the question owns the eye
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .45);

	draw_sprite_ext(spr_pixel_1x1, 0, _cb.x, _cb.y, _cb.w, _cb.h, 0, c_black, .95);
	draw_px_rect(_cb.x, _cb.y, _cb.w, _cb.h, c_gold, .8);
	// the countdown drains along the popup's top edge
	draw_sprite_ext(spr_pixel_1x1, 0, _cb.x, _cb.y, _cb.w * (confirm_tic / confirm_frames),
		1, 0, c_gold, .9);

	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_cb.x + (_cb.w >> 1), _cb.y + 7, confirm_txt);

	// [keep] [revert (Ns)]
	draw_sprite_ext(spr_pixel_1x1, 0, _cb.kx1, _cb.ky1, _cb.kx2 - _cb.kx1,
		_cb.ky2 - _cb.ky1, 0, merge_colour(c_sgreen, c_black, .7), .95);
	draw_px_rect(_cb.kx1, _cb.ky1, _cb.kx2 - _cb.kx1, _cb.ky2 - _cb.ky1, c_sgreen, .8);
	draw_set_color(c_white);
	draw_text((_cb.kx1 + _cb.kx2) >> 1, _cb.ky1 + 4, "keep");

	draw_sprite_ext(spr_pixel_1x1, 0, _cb.rx1, _cb.ry1, _cb.rx2 - _cb.rx1,
		_cb.ry2 - _cb.ry1, 0, merge_colour(c_hred, c_black, .7), .95);
	draw_px_rect(_cb.rx1, _cb.ry1, _cb.rx2 - _cb.rx1, _cb.ry2 - _cb.ry1, c_hred, .8);
	draw_set_color(c_white);
	draw_text((_cb.rx1 + _cb.rx2) >> 1, _cb.ry1 + 4, "revert (" + _secs + ")");
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
