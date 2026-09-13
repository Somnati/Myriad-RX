if (a < .01 && line_a < .01) exit;
draw_set_font(fnt);
draw_set_valign(fa_top);
var _br = .5 + .5 * dsin(current_time * .35);

// ---- the ring and its line ----
if (a > .01 && cur != "") {
	var _lx = room_width * .5, _ly = room_height - 14, _al = fa_center;
	if (!is_undefined(r) && r.w > 0) {
		// the ring: two rects, the outer breathing
		draw_px_rect(r.x - 2, r.y - 2, r.w + 4, r.h + 4, c_gold, a * (.55 + .4 * _br));
		draw_px_rect(r.x - 4, r.y - 4, r.w + 8, r.h + 8, c_gold, a * .18 * _br);
		// the line: under the thing if there is room, else above; kept
		// inside the room
		var _tw = string_width(txt) + 10;
		_lx = clamp(r.x + r.w * .5, _tw * .5 + 2, room_width - _tw * .5 - 2);
		_ly = (r.y + r.h + 16 < room_height) ? (r.y + r.h + 6) : (r.y - 14);
		if (r.w > room_width * .6 && r.h > room_height * .5) { _lx = room_width * .5; _ly = room_height - 14; }
	}
	var _w = string_width(txt) + 10;
	draw_sprite_ext(spr_pixel_1x1, 0, _lx - _w * .5, _ly - 2, _w, 11, 0, c_black, a * .85);
	draw_px_rect(_lx - _w * .5, _ly - 2, _w, 11, c_gold, a * .5);
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(a * .95);
	draw_text(_lx, _ly + 1, txt);
}

// ---- a panel's first line, at the foot of the room ----
if (line_a > .01 && line_txt != "") {
	var _w2 = min(room_width - 8, string_width(line_txt) + 10);
	var _x2 = room_width * .5;
	draw_sprite_ext(spr_pixel_1x1, 0, _x2 - _w2 * .5, room_height - 15, _w2, 12, 0, c_black, line_a * .85);
	draw_px_rect(_x2 - _w2 * .5, room_height - 15, _w2, 12, rgb(170, 190, 230), line_a * .4);
	draw_set_halign(fa_center);
	draw_set_color(rgb(195, 205, 235));
	draw_set_alpha(line_a * .9);
	draw_text_ext(_x2, room_height - 12, line_txt, 9, room_width - 20);
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
