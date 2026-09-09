/// settings v2 - the settings screen framework. rm_settings is only a
/// view: this controller + settings_content() are the whole system.
///
/// >>> TO ADD A SETTING: open settings_content() - the instructions
/// >>> live in its header. you should not need to touch THIS object.
///
/// how it works (statistics_v2's proven bones + the v2 layout notes):
///  - LEFT RAIL of category tabs (built from settings_section calls),
///    content isolated to the ACTIVE tab on the right - one category
///    at a time, no cross-section scrolling, mobile-friendly targets
///  - settings_content() replays settings_* calls in THIS scope every
///    step; the controller slices out the active tab's rows, so rows
///    can still appear conditionally (mobile-only, desktop-only)
///  - toggle/radio/slider rows carry LIVE widget instances (par_toggle
///    / par_toggle_single / par_slider children) - pooled once by key,
///    rebound each pass, chaperoned: placed while their row is fully
///    on screen, parked at -1000 while it isn't
///  - dropdown rows (settings_pill) ride the house pillbox framework;
///    the pick lands owner-side (_pselid / pill_kind, same as
///    syst_fidget) and routes to the row's pick fn
///  - risky display changes route through __confirm(): a keep/revert
///    popup with a countdown auto-reverts when the player can't see
///    or reach the screen anymore (a resolution the display rejects)
///  - widgets BIND through get/set functions, so this screen owns no
///    state at all: it can never disagree with the real globals
///  - any change arms dirty_tic; when it runs out the save system
///    writes settings.ini (debounced, so knob drags don't churn disk)
///  - drawing stacks by DEPTH in the normal pass (statistics_v2 uses
///    the same recipe): rows/rail in this Draw_0 -> widgets (depth-1)
///    -> title strip via obj_draw_proxy (depth-2) -> menu (-520) over
///    everything. two dead ends, learned the hard way: DRAW END runs
///    after the menu and paints over the open drawer; DRAW BEGIN runs
///    before the room's BACKGROUND layer and gets painted over. only
///    the help/confirm popups use draw end, hidden while the menu is
///    up (they must cover the scrollbar and pills).

if (!variable_global_exists("settings_page")) g.settings_page = 0;
if (!variable_global_exists("settings_tab"))  g.settings_tab  = 0;
// the "?" hint whispers, hidden by default (ui stays clean); the
// round ? button in the strip flips them all on/off at once.
// session-remembered, deliberately not saved to settings.ini
if (!variable_global_exists("settings_hints")) g.settings_hints = false;

// ---- layout: derived, not hardcoded ----
row_h  = 15; // th 7 + spc 8, the house rhythm
bby    = obj_ui_header.sprite_height;   // header's bottom edge
list_y = bby + 16;                      // title strip, then rail + content
rail_w = 80;                            // the category tab rail
content_x = rail_w + 6;                 // rows live right of the rail
visible_rows = ceil((room_height - list_y) / row_h);  // draw window
full_rows    = floor((room_height - list_y) / row_h); // scroll math
val_x = room_width - 10; // value column, clear of the scrollbar

// slider geometry: par_slider bakes its track at CREATE, so every
// slider spawns at THIS x with THIS xscale (readout text needs ~52px
// between track end and the value column: "240 fps" is the worst case)
sl_x     = clamp(content_x + 130, content_x + 60, room_width - 120);
sl_scale = max(4, ((val_x - 52) + 8 - sl_x) / sprite_get_width(spr_ui_dragger));

// ---- builder state (the settings_* scripts run in this scope) ----
rows     = []; // the FULL build, every tab (builders push here)
view     = []; // the active tab's slice - draw/hit/scroll use THIS
sections = []; // {name, col, row} - feeds the tab rail
pool     = {}; // widget key -> live instance (spawned once, rebound)
mx       = 0;  // view length, the scrollbar's range

dirty_tic   = 0; // >0 = change pending; reaching 0 fires the save
saved_flash = 0; // the "saved" whisper timer

help_txt = ""; // tap-for-info explainer
help_x   = 0;
help_y   = 0;

// pillbox ownership (the syst_fidget pattern: init, set_pill, do_
// pillbox on tap; the pick lands back on _pselid/_pselval)
pillbox_init();

/// @func __consumes(x, y)
/// @desc Does this screen own a press here? obj_clicker asks before it
///       pays, exactly as it asks syst_dials.
///
/// ⚖️ EVERYTHING UNDER THE HEADER, and the honesty is the point: this
/// room is a table of controls where every pixel does something, so
/// there is no tap surface in it to defend. The tapper still exists
/// here - it is persistent and live in every game room, which is his
/// rule - it simply cannot fire on a control any more.
///
/// His report (2026-09-08) was that tapping a pillbox played the tap
/// sound over the sound he was trying to audition. That is the general
/// case, not a pillbox case: a settings row is not a thing to tap for
/// money. obj_clicker's own Create names this gap and names the fix -
/// one __consumes per screen - and statistics, saves and upgrades still
/// want theirs.
__consumes = function(_x, _y) {
	return (_y >= bby);
};
pill_kind = "";

// keep/revert confirmation (display changes that can strand the
// player). while active, syst_input raises the popup block for us.
confirm_active = false;
confirm_txt    = "";
confirm_tic    = 0;   // counts down; 0 = auto-revert
confirm_revert = -1;  // method that undoes the change
confirm_frames = tsec * 10; // the 10s window

// arm the popup: txt is the question, revert undoes the change (the
// change itself must ALREADY be applied when this is called)
__confirm = function(_txt, _revert) {
	confirm_txt    = _txt;
	confirm_revert = _revert;
	confirm_tic    = confirm_frames;
	confirm_active = true;
	help_txt = "";
};

// popup geometry: one authority for draw + hit test
__confirm_box = function() {
	var _w = 190;
	var _h = 46;
	var _x = ((room_width - _w) >> 1);
	var _y = ((room_height - _h) >> 1);
	return { x : _x, y : _y, w : _w, h : _h,
		kx1 : _x + 10,      ky1 : _y + _h - 18, kx2 : _x + 88,      ky2 : _y + _h - 4,
		rx1 : _x + _w - 88, ry1 : _y + _h - 18, rx2 : _x + _w - 10, ry2 : _y + _h - 4 };
};

// one geometry authority: draw and hit-test both call THESE
__row_y = function(_i) {
	return list_y + (_i - floor(g.settings_page)) * row_h
		+ row_h * (floor(g.settings_page) - g.settings_page);
};
__row_at = function(_my) {
	var _yoff = row_h * (floor(g.settings_page) - g.settings_page);
	var _r = floor((_my - list_y - _yoff) / row_h) + floor(g.settings_page);
	if (_r < 0 || _r >= array_length(view)) return -1;
	return _r;
};

// widget pool: spawn once, rebind forever (settings_toggle/_radio use
// this; settings_slider pools itself - it needs spawn-time geometry)
__widget = function(_k, _obj) {
	var _i = pool[$ _k];
	if (_i == undefined || !instance_exists(_i)) {
		_i = create_obj(-1000, -1000, _obj);
		_i.depth = depth - 1; // above the rows, under the strip proxy
			// (depth-2) and the menu - see the header note
		pool[$ _k] = _i;
	}
	return _i;
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

// the active tab's slice: rows between its section marker and the
// next one (the marker row itself stays out - the rail is the label)
__slice = function() {
	view = [];
	mx = 0;
	var _n = array_length(sections);
	if (_n == 0) return;
	g.settings_tab = clamp(g.settings_tab, 0, _n - 1);
	var _s = sections[g.settings_tab].row + 1;
	var _e = (g.settings_tab + 1 < _n) ? sections[g.settings_tab + 1].row
	                                   : array_length(rows);
	for (var _i = _s; _i < _e; _i++) array_push(view, rows[_i]);
	mx = array_length(view);
};

__rebuild = function() {
	rows     = [];
	sections = [];
	settings_content();
	__slice();
};

draw_set_font(fnt);
__rebuild();

// scroll memory: tab + page carry over between visits
g.settings_page = clamp(g.settings_page, 0, max(0, mx - full_rows));

// the scrollbar, hugging the right edge, seeded from the remembered
// page (or its first step would snap the list back to the top)
sb = create_obj(room_width - sprite_get_width(spr_scrollbar) - 1, list_y, obj_scrollbar);
sb.i = scrl_settings;
sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
sb.ty = g.settings_page * row_h;

// ---- the title strip, drawn by a PROXY at depth-2 (see the header
// note: rows at 0, widgets -1, strip -2, menu -520 on top) ----
__draw_strip = function() {
	draw_set_font(fnt);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
		c_hsv(169, 186, 5), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0,
		rgb(170, 190, 230), .25);

	// title + the save-state whisper ("..." pending -> "saved")
	draw_set_halign(fa_left);
	draw_set_color(sett_ink);
	draw_set_alpha(.85);
	draw_text(6, bby + 4, "settings");
	if (dirty_tic > 0 || confirm_active) {
		draw_set_color(c_gray);
		draw_set_alpha(.6);
		draw_text(6 + string_width("settings") + 8, bby + 4, "...");
	}
	else if (saved_flash > 0) {
		draw_set_color(c_sgreen);
		draw_set_alpha(.8 * min(1, saved_flash / 30));
		draw_text(6 + string_width("settings") + 8, bby + 4, "saved");
	}

	// the round ? button: master switch for every hint whisper in the
	// list (gold while they're showing). drawn PER-PIXEL (midpoint
	// circle r=6 as spr_pixel_1x1 spans, 2026-07-12): draw_circle's
	// smooth vector ring was the one non-chunky shape on the screen
	// (his report) - house rule, hard pixels only
	var _hx = room_width - 74;
	var _hy = bby + 7;
	var _cf = g.settings_hints ? merge_colour(c_gold, c_black, .6) : c_black;
	var _cr = g.settings_hints ? c_gold : rgb(170, 190, 230);
	var _ar = g.settings_hints ? .9 : .5;
	var _hw = [6, 6, 6, 5, 4, 3, 2]; // half-width per |dy| (midpoint r=6)
	draw_set_alpha(1);
	for (var _dy = -6; _dy <= 6; _dy++) {
		var _w2 = _hw[abs(_dy)];
		// fill span, then the ring: the row's outermost pixels (the
		// cap rows at |dy| 6 wear their whole span as ring)
		draw_sprite_ext(spr_pixel_1x1, 0, _hx - _w2, _hy + _dy,
			_w2 * 2 + 1, 1, 0, _cf, 1);
		if (abs(_dy) == 6)
			draw_sprite_ext(spr_pixel_1x1, 0, _hx - _w2, _hy + _dy,
				_w2 * 2 + 1, 1, 0, _cr, _ar);
		else {
			draw_sprite_ext(spr_pixel_1x1, 0, _hx - _w2, _hy + _dy, 1, 1, 0, _cr, _ar);
			draw_sprite_ext(spr_pixel_1x1, 0, _hx + _w2, _hy + _dy, 1, 1, 0, _cr, _ar);
		}
	}
	draw_set_halign(fa_center);
	draw_set_color(g.settings_hints ? c_gold : sett_ink);
	draw_set_alpha(g.settings_hints ? .95 : .6);
	draw_text(_hx + 1, _hy - 3, "?");

	// [back] - the one shape, shared by every menu screen
	draw_ui_back(room_width - 62, bby + 1, 56, 13);

	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

var _px = create_obj(0, 0, obj_draw_proxy);
_px.owner = id;
_px.depth = depth - 2;
_px.fn    = __draw_strip;
