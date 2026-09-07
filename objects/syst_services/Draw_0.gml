/// the bench: title strip, button column left, status + live log
/// panel right. all in the normal pass at this depth - the menu
/// drawer (-520) covers everything (the house draw rule).

draw_set_font(fnt);

// backdrop
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0,
	c_hsv(169, 186, 5), .95);

// ---- title strip ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_halign(fa_left);
draw_set_color(sett_ink);
draw_set_alpha(.85);
draw_text(6, bby + 4, "services (debug bench)");

// [back] - the one shape, shared by every menu screen
draw_ui_back(room_width - 62, bby + 1, 56, 13);

// ---- the button column ----
for (var _i = 0; _i < array_length(rows); _i++) {
	var _r = rows[_i];
	var _ry = __row_y(_i);

	if (_r.fn == -1) {
		// section header: name + a short line sinking away (house style)
		draw_set_halign(fa_left);
		draw_set_color(_r.col);
		draw_set_alpha(.9);
		draw_text(btn_x, _ry + 4, _r.name);
		var _lx = btn_x + string_width(_r.name) + 6;
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _lx, _ry + 7,
			max(4, btn_x + btn_w - _lx), 1, 0, _r.col, c_black, c_black, _r.col, .5);
		continue;
	}

	var _hov = point_in_rectangle(mouse_x, mouse_y, btn_x, _ry,
		btn_x + btn_w, _ry + btn_h - 1);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, btn_x, _ry, btn_w, btn_h - 1, 0,
		merge_colour(_r.col, c_black, _hov ? .65 : .8), .95);
	draw_sprite_ext(spr_pixel_1x1, 0, btn_x, _ry, 2, btn_h - 1, 0,
		merge_colour(_r.col, c_white, .2), 1);
	draw_set_halign(fa_left);
	draw_set_color(merge_colour(_r.col, c_white, _hov ? .8 : .6));
	draw_set_alpha(.95);
	draw_text(btn_x + 6, _ry + 3, _r.name);
}

// ---- status + live log panel ----
var _s = g.services;
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, log_x, bby + 20, room_width - log_x - 6,
	room_height - bby - 26, 0, c_black, .5);
draw_px_rect(log_x, bby + 20, room_width - log_x - 6,
	room_height - bby - 26, rgb(170, 190, 230), .25);

draw_set_halign(fa_left);
var _sy = bby + 24;
draw_set_color(_s.steam_on ? c_sgreen : c_gray);
draw_set_alpha(.9);
draw_text(log_x + 4, _sy, "steam: " + (_s.steam_on ? "live" : "stub"));
draw_set_color(_s.gpgs_on ? c_sgreen : c_gray);
draw_text(log_x + 4, _sy + 9, "gplay: " + (_s.gpgs_on ? "live" : "stub"));
draw_set_color(_s.signed_in ? c_gold : c_gray);
draw_text(log_x + 4, _sy + 18, "signed in: " + (_s.signed_in ? "yes" : "no"));
draw_set_color(sett_ink);
draw_text(log_x + 4, _sy + 27, "cloud: " + string(_s.cloud_stamp));
draw_sprite_ext(spr_pixel_1x1, 0, log_x + 2, _sy + 37,
	room_width - log_x - 10, 1, 0, rgb(170, 190, 230), .2);

// log lines, newest at the bottom, older ones dimming out
var _ly = room_height - 16;
for (var _i = array_length(_s.log) - 1; _i >= 0; _i--) {
	if (_ly < _sy + 41) break;
	draw_set_color(c_white);
	draw_set_alpha(clamp(.9 - (array_length(_s.log) - 1 - _i) * .05, .2, .9));
	draw_text(log_x + 4, _ly, _s.log[_i]);
	_ly -= 9;
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
