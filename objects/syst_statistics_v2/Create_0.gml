/// statistics_v2: a fresh line-browser framework, built from what the
/// Myriad original and the techdemo test each got right:
///  - content is DECLARED (stats_v2_content replays stats_v2_line /
///    _folder / _widget / _toggle / _cycle / _spark calls) -
///    conditional lines, alive values
///  - folders NEST via the call pattern; open state persists in
///    g.stats_open keyed by full path, so revisits remember. the
///    build now always walks the WHOLE tree (closed folders just
///    emit no rows) so the favorites walk sees everything
///  - favorited lines pin into a synthetic folder on top (the star
///    gutter at the left edge toggles them; g.stats_fav saves)
///  - widget rows embed live instances (rarity bars, sliders) - the
///    framework chaperones position/parking, the widget stays its
///    own object
///  - VIRTUALIZED: only the visible window builds geometry, draws,
///    and hit-tests - and both use the SAME two functions, so click
///    boxes can never drift from pixels
///  - rebuilds are throttled (1/s) except structure clicks (instant)
///  - every dimension derives from the room + header, so portrait
///    mobile and landscape pc are the same code

// ---- persistent framework state (self-contained: no setgame edit) ----
if (!variable_global_exists("stats_open")) g.stats_open = {};
if (!variable_global_exists("stats_page")) g.stats_page = 0;
if (!variable_global_exists("stats_tab"))  g.stats_tab  = 0;
if (!variable_global_exists("stats_fav"))  g.stats_fav  = {};
if (!variable_global_exists("stats_hist")) g.stats_hist = {};
if (!variable_global_exists("stats_base")) stats_session_base();
// the pin section defaults OPEN (everything else defaults closed)
if (is_undefined(g.stats_open[$ "/favorites"])) g.stats_open[$ "/favorites"] = true;

// ---- layout: derived, not hardcoded ----
row_h  = 15; // th 7 + spc 8, the house rhythm
list_y = obj_ui_header.sprite_height + 29; // header + the title strip
// THE CATEGORY RAIL (his ask 2026-09-06: make this room look like the
// settings room). Same numbers syst_settings uses, so the two screens
// are the same screen with different content: an 80px rail of tabs on
// the left, rows in the band beside it. Top-level folders ARE the tabs,
// which is what got the five big colour bars off the list.
rail_w    = 80;
content_x = rail_w + 6;
visible_rows = ceil((room_height - list_y) / row_h);  // draw window
full_rows    = floor((room_height - list_y) / row_h); // scroll math:
	// only rows that FIT count, so max scroll lands the last row fully
	// on screen instead of leaving it clipped off the bottom edge
val_x = room_width - 10; // value column, clear of the scrollbar

// ---- builder state (the stats_v2_* scripts run in this scope) ----
rows        = [];  // the WHOLE build: every folder, open or not
view        = [];  // the active tab's slice - what the screen shows
sections    = [];  // {name, col, row} - the depth-0 folders, ie the rail
widgets     = []; // widgets in the CURRENT build (positioned)
widgets_all = []; // every widget ever registered (all get parked)
fav_rows    = []; // pinned-line copies captured during the walk
dump        = []; // the full tree as text rows. Still WRITTEN by the
	// content scripts, read by nobody since [copy] retired 2026-09-06 -
	// kept so bringing that button back is one draw and one hit test,
	// not a re-thread of four scripts
_fdepth  = 0;
_fpath   = "";
_fhid    = 0;  // >0 while inside any closed folder (rows suppressed)
_fstack  = []; // open-state per folder level, for folder_end
span_max = 1;  // tallest span this build - widens the draw window
	// upward so a bar scrolled half off the top keeps drawing
utic    = 0;      // rebuild throttle
rebuild = true;   // structure clicks force an immediate pass

// change pulses: previous value + flash timestamp per line key
__prev  = {};
__pulse = {};
__tick  = 0;

// SHOW THE STAR GUTTER? his ask 2026-09-06. Saved with the favourites
// themselves (save section "statistics"), because it is part of the same
// preference - which stats you pin, and whether you want the pinning
// controls on screen while you read.
// OFF BY DEFAULT (his call 2026-09-06): pinning is a thing you set up
// once, so the controls stay out of the way until asked for.
fav_show = variable_global_exists("stats_fav_show") ? g.stats_fav_show : false;
// the gutter SLIDES: names sit close to the left with it off, and step
// right as the star comes out from behind the rail. fav_t is the eased
// 0..1 the draw reads for both.
fav_t = fav_show ? 1 : 0;

// help state (search and the clipboard dump retired with their buttons;
// `search` stays as the rebuild's filter input, permanently empty)
search     = "";
search_on  = false;
help_txt   = "";
help_x     = 0;
help_y     = 0;

// widget instances, lazily spawned by the content script
w_tilebar    = noone;
w_luckbar    = noone;
w_tileslider = noone;
w_luckslider = noone;

// one geometry authority: draw and hit-test both call THESE.
// page_ofs is a VISUAL row offset (the fold-clamp glide, see Step):
// it rides __row_y so rows, widgets and the anim all shift together,
// while __row_at stays on final geometry (the unfurl's law)
__row_y = function(_i) {
	return list_y + (_i - floor(g.stats_page)) * row_h
		+ row_h * (floor(g.stats_page) - g.stats_page)
		+ page_ofs * row_h;
};
__row_at = function(_my) {
	var _yoff = row_h * (floor(g.stats_page) - g.stats_page);
	var _r = floor((_my - list_y - _yoff) / row_h) + floor(g.stats_page);
	if (_r < 0 || _r >= array_length(view)) return -1;
	return _r;
};

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

// THE ACTIVE TAB'S SLICE: the rows between its top-level folder marker
// and the next one. The marker row itself stays OUT - the rail is the
// label, exactly as settings does it. `rows` remains the whole build
// (favourites capture still needs to see everything); `view` is what
// the screen draws, scrolls and hit-tests.
__slice = function() {
	view = [];
	mx = 0;
	var _n = array_length(sections);
	if (_n == 0) return;
	g.stats_tab = clamp(g.stats_tab, 0, _n - 1);
	var _s = sections[g.stats_tab].row + 1;
	var _e = (g.stats_tab + 1 < _n) ? sections[g.stats_tab + 1].row
	                                : array_length(rows);
	for (var _i = _s; _i < _e; _i++) array_push(view, rows[_i]);
	mx = array_length(view);
};

__rebuild = function() {
	rows     = [];
	sections = [];
	widgets  = [];
	fav_rows = [];
	dump     = [];
	_fdepth  = 0;
	_fpath   = "";
	_fhid    = 0;
	_fstack  = [];
	span_max = 1;
	stats_v2_content();
	_fdepth = 0;
	_fpath  = "";
	_fhid   = 0;

	// pinned lines ride in a synthetic gold folder above everything
	if (search == "" && array_length(fav_rows) > 0) {
		var _fopen = g.stats_open[$ "/favorites"] ?? true;
		var _head = [{
			kind : 1, name : "favorites", val : "", c1 : c_gold,
			c2 : c_white, fdep : 0, path : "/favorites",
			key : "/favorites", help : "", fav : false, data : -1,
			open : _fopen, inst : noone, span : 1,
		}];
		if (_fopen) _head = array_concat(_head, fav_rows);
		rows = array_concat(_head, rows);
	}
	// the rail's tabs ARE the depth-0 folders, found by scanning the
	// finished build - so a new top-level folder in stats_v2_content
	// becomes a tab with no other edit, the same way a settings_section
	// does
	for (var _i = 0; _i < array_length(rows); _i++)
		if (rows[_i].kind == 1 && rows[_i].fdep == 0)
			array_push(sections, { name : rows[_i].name, col : rows[_i].c1,
				row : _i });
	__slice(); // sets mx from the slice - the scrollbar's range
};
mx = 0;

// ---- folder unfurl animation (ui overhaul; reworked 2026-07-12
// after his test pass): toggling a folder offsets everything below
// the fold line so it draws exactly where it was, then eases home.
// the block below the fold moves as ONE RIGID SHEET - opening slides
// it down and the new children ride it out from under the folder row
// (they draw in pass 0 at their TRUE offset position; the opaque
// folder row + rows above cover them until they clear - the old
// pinned-stack version left children visibly parked at the fold when
// nothing below covered them, "kinda stuck"). closing runs the same
// sheet in reverse with GHOSTS: copies of the removed rows captured
// at the rebuild slide back up under the fold (before, they just
// vanished - his last-folder report). page_ofs glides out the scroll
// clamp's yank when a close shrinks the list under the scroll.
// purely visual: hit tests stay on the final geometry throughout ----
anim_pend  = -1;  // display row of a JUST-toggled folder (Step captures)
anim_row   = -1;  // the fold line's row index in the NEW build
anim_n     = 0;   // rows inserted (+) or removed (-) by the toggle
anim_t     = 1;   // 0 -> 1 ease; 1 = at rest
anim_ghost = [];  // closing: the removed child rows (frozen copies)
page_ofs   = 0;   // visual row offset easing the scroll-clamp jump home
__anim_off = function(_r) {
	if (anim_t >= 1 || _r <= anim_row) return 0;
	return -(1 - anim_t) * anim_n * row_h;
};

// the row PANEL painter (zebra edition 2026-07-12: match rm_settings,
// his call - the raised-panel look retired). settings' exact zebra
// colors + gradient edge seams, but PRE-BLENDED against the backdrop
// and drawn OPAQUE: the unfurl's two passes depend on solid rows to
// cover and reveal. shared by live rows AND the close-anim ghosts, so
// the two can never drift apart visually.
__row_panel = function(_r, _row, _ry, _bh) {
	var _cw = room_width - rail_w;   // the content band
	var _back = c_hsv(169, 186, 5);
	// THE ZEBRA, quietened (his report 2026-09-06 - the screen "looked
	// bad"). It ran 18 against 4, a stripe strong enough to fight the
	// section colours for attention; 11 against 5 still separates the
	// rows without the list itself reading as banding.
	var _c  = (_r & 1) ? c_hsv(168, 158, 11) : c_hsv(168, 160, 5);
	var _cc = (_r & 1) ? c_hsv(168, 149, 67) : c_black;
	_c = merge_colour(_c, _back, .2); // == settings' .8-alpha wash, kept solid
	draw_set_alpha(1);
	if (_row.kind == 1) {
		// FOLDER: dark furniture, ONE living element - the house law the
		// dial rows already follow. The section colour used to wash 35%
		// of the way across the WHOLE row, which on a 480-wide row is a
		// big saturated field, and that is what he was looking at. The
		// colour now lives only where it carries meaning: the edge
		// accent, the +/- chip and the name. The panel keeps a whisper
		// of it - a tenth, spent by a third of the way across - enough
		// for the eye to group a section, not enough to shout.
		// Folder rows also sit a shade proud of their children, so the
		// hierarchy reads from brightness rather than from colour.
		var _fd = merge_colour(_c, c_white, .05);
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, _cw, _bh, 0, _fd, 1);
		var _gl = merge_colour(_fd, _row.c1, .10);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _ry,
			_cw * .33, _bh, 0, _gl, _fd, _fd, _gl, 1);
	} else
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, _cw, _bh, 0, _c, 1);
	// settings' gradient edge seams (top + bottom hairlines)
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _ry, _cw, 1, 0,
		_c, _cc, _cc, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _ry + _bh - 1,
		_cw, 1, 0, _cc, _c, _c, _cc, .52);
	// indent guides still carry the tree depth. Depth 0 is the rail now,
	// so a row inside a tab starts at depth 1 and its first guide would
	// sit under the text - the guides begin one notch in
	for (var _g2 = 2; _g2 <= _row.fdep; _g2++)
		draw_sprite_ext(spr_pixel_1x1, 0, content_x - 4 + _g2 * 10, _ry, 1, _bh, 0,
			merge_colour(_c, c_white, .14), 1);
};

// close-anim ghost: a removed row repainted compactly (panel + name +
// value; sparks skip their graph for the dozen frames of the slide).
// drawn BEFORE both passes, so every live row paints over it and it
// submerges under the folder row exactly the way children emerge.
__ghost_paint = function(_r, _row, _ry) {
	var _bh = row_h * _row.span;
	__row_panel(_r, _row, _ry, _bh);
	// same seat as the live rows: content band, depth measured from 1,
	// riding the favourite gutter's slide
	var _tx = content_x + 2 + fav_t * 10 + max(0, _row.fdep - 1) * 10;
	if (_row.kind == 1) {
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, 2, _bh, 0, _row.c1, .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ry + 2, 9, 9, 0, c_black, .45);
		draw_px_rect(_tx, _ry + 2, 9, 9, _row.c1, .5);
		draw_set_halign(fa_center);
		draw_set_color(_row.c1);
		draw_set_alpha(.95);
		draw_text(_tx + 5, _ry + 3, _row.open ? "-" : "+");
		draw_set_halign(fa_left);
		draw_text(_tx + 14, _ry + 4, _row.name);
		return;
	}
	if (_row.name != "") {
		draw_set_halign(fa_left);
		draw_set_color(_row.c1);
		draw_set_alpha(.9);
		draw_text(_tx, _ry + 4, _row.name);
	}
	if (_row.kind == 0 && _row.val != "") {
		draw_set_halign(fa_right);
		draw_set_color(_row.c2);
		draw_set_alpha(.95);
		draw_text(val_x, _ry + 4, _row.val);
	}
};

__rebuild();

// scroll memory: g.stats_page carries over between visits - just
// clamp it in case folders closed since (shorter list now)
g.stats_page = clamp(g.stats_page, 0, max(0, mx - full_rows));

// the scrollbar, hugging the right edge, sized to the list band.
// seed its touch position from the remembered page, or its first
// step would snap the list back to the top
var _sb = create_obj(room_width - sprite_get_width(spr_scrollbar) - 1, list_y, obj_scrollbar);
_sb.i = scrl_statistics;
_sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
_sb.ty = g.stats_page * row_h;

// ---- the title strip, drawn by a PROXY at depth-2 ----
// rows draw in this instance's Draw_0, widgets ride at depth-1, so
// the strip needs a THIRD depth to cover widgets sliding past the
// top while the menu (-520) still covers everything. draw end can't
// do it (runs after the menu, paints over the drawer) and draw begin
// can't either (the room's background layer paints over it) - so a
// proxy instance runs this method at exactly the right depth.
__draw_strip = function() {
	var _bby = obj_ui_header.sprite_height;
	draw_set_font(fnt);
	draw_set_alpha(1);
	// (starts AT the header's bottom edge, clear of its seam)
	draw_sprite_ext(spr_pixel_1x1, 0, 0, _bby, room_width, list_y - _bby, 0,
		c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0,
		rgb(170, 190, 230), .25);

	// title
	draw_set_halign(fa_left);
	draw_set_color(rgb(195, 205, 235));
	draw_set_alpha(.85);
	var _ttl = "statistics";
	if (variable_global_exists("stats_mode") && g.stats_mode == 1) _ttl += " (session)";
	draw_text(6, _bby + 8, _ttl);

	// [favs] [back]  (copy and find retired 2026-09-06, his call - he is
	// cleaning this screen up)
	// FAVS toggles whether the per-row star gutter is DRAWN at all.
	// Pinning is a thing you do rarely and then want out of the way, so
	// the pips can be put away without unpinning anything: the
	// favourites folder at the top stays either way.
	var _bx = room_width - 106;
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _bby + 6, 40, 16, 0, c_black, .8);
	draw_px_rect(_bx, _bby + 6, 40, 16, fav_show ? c_gold : rgb(170, 190, 230),
		fav_show ? .9 : .5);
	draw_set_halign(fa_center);
	draw_set_color(fav_show ? c_gold : c_white);
	draw_set_alpha(.9);
	draw_text(_bx + 20, _bby + 10, "favs");

	_bx = room_width - 62;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _bby + 6, 56, 16, 0, c_black, .8);
	draw_px_rect(_bx, _bby + 6, 56, 16, rgb(170, 190, 230), .9);
	draw_set_color(c_white);
	draw_text(_bx + 28, _bby + 10, "back");

	// the tap-for-info explainer, floated near the tap, clamped in-room
	if (help_txt != "") {
		var _w = 150;
		var _hh = string_height_ext(help_txt, 9, _w - 8);
		var _px = clamp(help_x - (_w >> 1), 4, room_width - _w - 4);
		var _py = clamp(help_y - _hh - 14, _bby + 4, room_height - _hh - 12);
		draw_sprite_ext(spr_pixel_1x1, 0, _px, _py, _w, _hh + 8, 0, c_black, .92);
		draw_px_rect(_px, _py, _w, _hh + 8, c_gold, .6);
		draw_set_halign(fa_left);
		draw_set_color(rgb(220, 225, 245));
		draw_set_alpha(.95);
		draw_text_ext(_px + 4, _py + 4, help_txt, 9, _w - 8);
	}

	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

var _px = create_obj(0, 0, obj_draw_proxy);
_px.owner = id;
_px.depth = depth - 2;
_px.fn    = __draw_strip;
