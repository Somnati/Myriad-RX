if (a < .01 && line_a < .01) exit;
draw_set_font(fnt);
draw_set_valign(fa_top);
var _br = .5 + .5 * dsin(current_time * .35);
var _hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
// ⚖️ A LINE WRAPS (the money room is 144 wide in portrait and every
// nudge is a sentence): it is laid out with draw_text_ext inside the
// room's width, and its plate is sized from the wrapped height
var _maxw = room_width - 14;

// ---- a panel's first line, at the foot of the room (drawn first: the
// nudge's line stacks above it when both are at the foot) ----
var _foot = room_height - 2;   // where the next foot plate's bottom goes
if (line_a > .01 && line_txt != "") {
	var _w2 = min(_maxw, string_width(line_txt)) + 10;
	var _h2 = string_height_ext(line_txt, 9, _maxw) + 4;
	var _x2 = floor(room_width * .5 - _w2 * .5);
	var _y2 = room_height - 3 - _h2;
	draw_sprite_ext(spr_pixel_1x1, 0, _x2, _y2, _w2, _h2, 0, c_black, line_a * .85);
	draw_px_rect(_x2, _y2, _w2, _h2, rgb(170, 190, 230), line_a * .4);
	draw_set_halign(fa_center);
	draw_set_color(rgb(195, 205, 235));
	draw_set_alpha(line_a * .9);
	draw_text_ext(floor(room_width * .5), _y2 + 2, line_txt, 9, _maxw);
	_foot = _y2 - 3;
}

// ---- the ring and its line ----
if (a > .01 && cur != "") {
	var _bw = min(_maxw, string_width(txt)) + 10;
	var _bh = string_height_ext(txt, 9, _maxw) + 4;
	// the default seat: the foot of the room (above a first line if one is up)
	var _lx = room_width * .5, _ly = _foot - _bh;
	if (!is_undefined(r) && r.w > 0) {
		// the ring: two rects, the outer breathing
		draw_px_rect(r.x - 2, r.y - 2, r.w + 4, r.h + 4, c_gold, a * (.55 + .4 * _br));
		draw_px_rect(r.x - 4, r.y - 4, r.w + 8, r.h + 8, c_gold, a * .18 * _br);
		// THE SEAT: under the thing; else above it, clear of the header;
		// else beside it (the docked dial strip is a sliver the full
		// height of the room - the line used to land on the header
		// there); else the foot. A ring the size of the room keeps the
		// foot. Always kept inside the room
		var _big = (r.w > room_width * .6 && r.h > room_height * .5);
		if (_big) { }
		else if (r.y + r.h + 6 + _bh <= room_height)  { _lx = r.x + r.w * .5; _ly = r.y + r.h + 6; }
		else if (r.y - 6 - _bh >= _hh)                { _lx = r.x + r.w * .5; _ly = r.y - 6 - _bh; }
		else if (r.x - 6 - _bw >= 0)                  { _lx = r.x - 6 - _bw * .5; _ly = r.y + r.h * .5 - _bh * .5; }
		else if (r.x + r.w + 6 + _bw <= room_width)   { _lx = r.x + r.w + 6 + _bw * .5; _ly = r.y + r.h * .5 - _bh * .5; }
	}
	_lx = floor(clamp(_lx, _bw * .5 + 2, room_width - _bw * .5 - 2));
	_ly = floor(clamp(_ly, _hh + 2, room_height - _bh - 2));
	var _bx = _lx - floor(_bw * .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ly, _bw, _bh, 0, c_black, a * .85);
	draw_px_rect(_bx, _ly, _bw, _bh, c_gold, a * .5);
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(a * .95);
	draw_text_ext(_lx, _ly + 2, txt, 9, _maxw);
}
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
