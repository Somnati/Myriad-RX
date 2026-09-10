/// syst_faq - THE FAQ, as a panel over whatever room you are standing in
/// (his ask, 2026-09-10: DE had one he never used; "build it like how
/// statistics are with the tabs" and "include visual sprites from
/// throughout the game so it's not just walls of text"). Settings'
/// and statistics' exact frame - the header, a title strip, an 80px
/// rail of tabs on the left, the content band - on the overlay
/// contract (faq_open is the one door, the burger's X and escape close
/// it, syst_input holds the room quiet, ui_blur_tick softens it).
///
/// CONTENT IS DECLARED in faq_content(): faq_section(name, col) makes a
/// tab, faq_entry(title, body, art) a card under it. A card is a
/// coloured title, a body that wraps to the card's width, and an ART
/// BOX on the right that draws either a game sprite or a painter - a
/// little function handed the box, so a card about tiles shows tiles
/// drawn by tile_shape_draw, a card about the buy button shows
/// spr_buylv, and the pictures can never drift from the game because
/// they ARE the game's draw calls.
///
/// Cards scroll in pixels (wheel, or drag on touch) inside the band;
/// the strip and the rail draw OVER them, so a card sliding under the
/// strip simply disappears into it.

depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by faq_close; the Step destroys at zero

bby    = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
list_y = bby + 16;                      // title strip, then rail + content
rail_w = 80;
content_x = rail_w + 6;
content_w = room_width - content_x - 6;
art_w  = 64;                            // the art box, right of the body
art_h  = 44;
text_w = content_w - art_w - 10;        // what the body wraps to
line_h = 9;                             // fnt is 7px + 2 leading

// ---- the declared content ----
sections = [];   // { name, col }
entries  = [];   // { sec, title, body, art }
cur_sec  = -1;   // faq_section sets it; faq_entry files under it
faq_content();

tab    = 0;      // the active rail tab
scroll = 0;      // the content band's scroll, px - the house bar writes it

// THE HOUSE SCROLLBAR (his rule, 2026-09-10: every scrollbar is the
// framework's). Pixel mode against the cards' stacked height; it owns
// the wheel (fenced to the band) and the touch drag, and writes scroll
// through its output lane.
sb = create_obj(room_width - sprite_get_width(spr_scrollbar) - 1, list_y, obj_scrollbar);
sb.i = scrl_faq;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.wheel_x1 = rail_w; sb.wheel_x2 = room_width;
sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
sb.col = c_gold;

// tab rail geometry: shared by draw and hit test - no drift possible
__tabs = function() {
	var _out = [];
	var _ty = list_y + 3;
	for (var _i = 0; _i < array_length(sections); _i++) {
		array_push(_out, { x1 : 2, y1 : _ty, x2 : rail_w - 4, y2 : _ty + 17, idx : _i });
		_ty += 19;
	}
	return _out;
};

/// @func __cards()
/// @desc the active tab's cards with their heights: [{ e, h }]. The
///       body's wrapped height is measured here so the draw and the
///       scroll range agree by construction.
__cards = function() {
	var _out = [];
	draw_set_font(fnt);
	for (var _i = 0; _i < array_length(entries); _i++) {
		var _e = entries[_i];
		if (_e.sec != tab) continue;
		var _bh = string_height_ext(_e.body, line_h, text_w);
		var _h = max(_bh + 18, art_h + 8) + 4;   // title line + body, or the art, + pad
		array_push(_out, { e : _e, h : _h });
	}
	return _out;
};

__content_h = function() {
	var _c = __cards();
	var _t = 0;
	for (var _i = 0; _i < array_length(_c); _i++) _t += _c[_i].h + 3;
	return _t;
};

__scroll_max = function() {
	return max(0, __content_h() - (room_height - list_y - 4));
};
