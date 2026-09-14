/// syst_changelog - THE CHANGELOG, as a panel over whatever room you are
/// standing in (his ask, 2026-09-14: an in-game changelog for release,
/// "DE did something like this but it was a hassle for me to work
/// with"). The FAQ's frame without the rail: the header, a title strip,
/// then ONE column of release cards, newest first, that scrolls on the
/// house bar. On the overlay contract: changelog_open is the one door,
/// the burger's X and escape close it, syst_input holds the room quiet,
/// ui_blur_tick softens it behind.
///
/// THE CONTENT IS ONE FILE, changelog_content(): a release is a struct
/// of version / date / name / notes, a note is a kind and a line. Adding
/// a release is pushing a struct at the front of that array. This
/// object knows nothing about what the releases say - it measures and
/// paints whatever it is handed, so the panel never needs touching
/// again once it ships.
///
/// A card: the version large in gold with the date dim beside it and the
/// release's name under them, a rule, then the notes - each a small
/// TAG CHIP in its kind's colour (added / changed / fixed / balance /
/// note) and the line wrapped beside it. Opening it records the newest
/// version as seen (g.changelog_seen, settings.ini) so the settings row
/// can pip "new" the day a build ships with more.

depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by changelog_close; the Step destroys at zero

bby    = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
list_y = bby + 16;                      // the title strip, then the column
col_x  = 8;
col_w  = room_width - col_x - 14;       // the bar keeps the right edge
tag_w  = 44;                            // the kind chip
text_x = col_x + 8 + tag_w + 6;
text_w = col_x + col_w - text_x - 6;    // what a note wraps to
line_h = 9;                             // fnt is 7px + 2 leading

releases = changelog_content();
scroll   = 0;      // the column's scroll, px - the house bar writes it

// the newest version is SEEN the moment the panel opens (the settings
// row's "new" pip reads g.changelog_seen against changelog_content)
if (array_length(releases) > 0 && g.changelog_seen != releases[0].ver) {
	g.changelog_seen = releases[0].ver;
	// settings.ini carries it: a full save, once, the first time a build's
	// changelog is opened (settings' own debounce would not finish - the
	// panel that opened this one is folding away under it)
	if (instance_exists(syst_handle_save)) syst_handle_save.action = sv_save;
}

// THE HOUSE SCROLLBAR (his rule): pixel mode against the cards' stacked
// height; it owns the wheel and the touch drag and writes scroll
sb = create_obj(room_width - sprite_get_width(spr_scrollbar) - 1, list_y, obj_scrollbar);
sb.i = scrl_changelog;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.wheel_x1 = 0; sb.wheel_x2 = room_width;
sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
sb.col = c_gold;

/// @func __kind_col(kind) -> the tag chip's colour
__kind_col = function(_k) {
	switch (_k) {
		case "added":   return c_sgreen;
		case "changed": return c_sblue;
		case "fixed":   return c_horange;
		case "balance": return c_gold;
	}
	return rgb(170, 190, 230);   // "note", and anything unnamed
};

/// @func __cards()
/// @desc every release with its measured height: [{ r, h, lines[] }] -
///       the notes' wrapped heights are measured here so the draw and
///       the scroll range agree by construction
__cards = function() {
	var _out = [];
	draw_set_font(fnt);
	for (var _i = 0; _i < array_length(releases); _i++) {
		var _r = releases[_i];
		var _h = 30;   // the version line, the name, the rule
		var _ls = [];
		for (var _k = 0; _k < array_length(_r.notes); _k++) {
			var _nh = max(line_h, string_height_ext(_r.notes[_k].txt, line_h, text_w));
			array_push(_ls, _nh);
			_h += _nh + 4;
		}
		_h += 6;
		array_push(_out, { r : _r, h : _h, lines : _ls });
	}
	return _out;
};

__content_h = function() {
	var _c = __cards();
	var _t = 0;
	for (var _i = 0; _i < array_length(_c); _i++) _t += _c[_i].h + 4;
	return _t;
};

__scroll_max = function() {
	return max(0, __content_h() - (room_height - list_y - 4));
};
