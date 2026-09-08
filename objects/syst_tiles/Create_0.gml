/// the tile table's room VIEW (Myriad's merge modules, ported and
/// rebuilt on Techdemo rails). how the framework splits:
///  - the SIM runs globally: syst_tiletimer (persistent, lazy-spawned
///    by tiles_init) ticks fabrication / automerge / failsafe / the
///    gps total every step in every room, and pushes board events
///    onto g.tiles.ev
///  - THIS object is presentation + input only: it drains those
///    events into glow and sound, runs the drag (hovered slot is grid
///    math, not Myriad's nearest-candidate broker object), and shows
///    the offline welcome-back report
///  - input is arbitrated (input_free + g.click_owner region pattern)
///    instead of guard chains naming every popup in the game
///  - board state is g.tiles (tiles_init) and mutations are pure
///    scripts (tiles_merge / tiles_sort), so the table can be
///    reskinned anywhere later

tiles_init();

// per-mechanic welcome-back (round 2, his call): the report's window
// is "since the TILE ROOM was last opened", not since the game
// closed - the away ledger accumulated live fabrication/automerges
// (tiles_tick) AND the boot fastforward, so a 5-min boot gap plus 3
// live minutes elsewhere honestly reads 8. settling stamps + zeroes
// the ledger: the next window starts now
if (!variable_global_exists("away")) away_init();
var _aw = g.away.tiles;
var _anow = date_current_datetime();
var _aspn = date_second_span(_aw.dt, _anow);
if (_aspn >= 120 && (_aw.fab > 0 || _aw.merges > 0))
	g.tiles.report = {
		away    : _aspn,
		fabbed  : _aw.fab,
		merges  : _aw.merges,
		hi_from : _aw.hi,
		hi_to   : g.tiles.highest,
	};
else g.tiles.report = undefined;
_aw.dt = _anow;
_aw.fab = 0;
_aw.merges = 0;
_aw.hi = g.tiles.highest;
save_mark_dirty();

// ---- THE ROOM'S BANDS ----
// The header is 29 tall, then a TITLE STRIP like every other screen in
// the game (his ask - settings, statistics, upgrades and the time bank
// all have one, and the tiles were the odd room out). The fabricator
// bars sit SNUG under it: DE stacks its module meters immediately below
// the strip with no gap, and a gap is what made them read as floating
// debris here.
bby     = obj_ui_header.sprite_height;   // 29
strip_y = bby;
strip_h = 16;
bar_y   = strip_y + strip_h;             // snug, no gap
bar_h   = 3;                             // DE's module meter is 3px
// the two tones of DE's meter - see the Draw. bar_fast leads, bar_slow
// lags and is what you actually notice when a tile lands.
bar_fast = 0;
bar_slow = 0;

// the board's band: everything under the bars, above the bottom edge
board_top = bar_y + bar_h * 2 + 6;
board_bot = room_height - 8;

// board geometry: spr_tile at 1x (30x13) with a 4px gutter - the
// Myriad sizing exactly. the table is CENTERED in the play band
// between the fab/automerge bars (under the 29px header) and the
// bottom controls; info box right, toggles bottom-left (house layout)
tsc = 1;
tw = sprite_get_width(spr_tile) * tsc;
th = sprite_get_height(spr_tile) * tsc;
pw = tw + 4;
ph = th + 4;
var _rows = ceil(g.tiles.slots / g.tiles.cols);
// CENTRED IN THE ROOM (his ask). The upgrades are a drawer now, so
// nothing permanently occupies a side and the board can sit where a
// board should.
bx = (room_width - (g.tiles.cols * pw - 4)) * .5;
by = board_top + ((board_bot - board_top) - (_rows * ph - 4)) * .5;

// grab state: which slot rides the mouse and where its ghost floats.
// the struct mirror (g.tiles.grab) tells the ENGINE to keep its hands
// off the held slot - the sim itself runs in syst_tiletimer now, this
// object is pure presentation + input
grab_i = -1;
gx = 0; gy = 0;
z = 0; // the "lift" while held
g.tiles.grab = -1;

// where the held tile "aims" (round 2 toggle): the cursor, or the
// ghost's own center - Step's drop and Draw's assist pulse both read
// THIS, so the pulsing slot is always the one the drop will take
__aim = function() {
	if (grab_i != -1 && g.tiles.aim_center)
		return [gx + tw * .5, gy + th * .5];
	return [mouse_x, mouse_y];
};

// drop any events the engine queued while no view was around - the
// room should not open to a backlog glow/sound storm
g.tiles.ev = [];

// display refresh: the engine bumps g.tiles.rev on every board
// change; -1 forces the first build
last_rev = -1;

// per-slot merge/spawn flash (parallel to g.tiles.tier)
glow = array_create(g.tiles.slots, 0);

// display caches, rebuilt only when the engine bumps g.tiles.rev
// (arb math + string widths are not per-frame work - Myriad's
// discipline, kept). val_sc is Myriad's fit trick: values render in
// fnt_large and get draw_text_transformed-scaled when too wide
val_str = array_create(g.tiles.slots, "");
val_sc  = array_create(g.tiles.slots, 1);
col     = array_create(g.tiles.slots, c_white);
txtcol  = array_create(g.tiles.slots, c_white);
gps_str = "+0/s";
info_w  = 100;

// the empty socket: Myriad dark theme, frame 2 over the surface tint
slot_col = merge_colour(c_black, rgb(25, 51, 77), .4);

// slot -> screen and screen -> slot: these three functions replace
// the entire obj_module_mouse broker
// ---- THE UPGRADE DRAWER (his ask: out from the LEFT on a swipe
// right). It used to be a fixed column on the right, which cost the
// board 170px of room it needed and clipped everything into everything
// else. As a drawer it costs nothing until it is asked for.
dr_w    = 158;   // open width
dr_tab  = 9;     // the edge tab when closed
dr_open = 0;     // 0 closed .. 1 open, eased
dr_want = 0;
sw_x    = -1;    // a swipe in progress: where it started
sw_y    = -1;

upg_y = 0;       // seated below, once the strip is known
upg_h = 26;
upg_n = 4;
// ⚖️ THE FACE, AND IT WAS WRONG AT BOTH ENDS. -dr_w + (dr_w+tab)*open
// put the CLOSED drawer's right edge at 0 - so the tab was off screen -
// and the OPEN one's left edge at +9, leaving a strip of room showing
// down the side of a drawer that is supposed to be flush with it. The
// two positions are the only two facts here, so lerp between them and
// let nothing else be inferred.
__dr_face = function() { return lerp(dr_tab - dr_w, 0, dr_open); };
__upg_r = function(_k) {
	return { x : __dr_face() + 4, y : upg_y + _k * (upg_h + 4),
	         w : dr_w - 8, h : upg_h };
};
// the quote cache: tile_upg walks a log-space series and packs an arb,
// and the price only moves when something is bought
qtic = 0;
uq   = [];


// the drawer's rows start under the strip, and the board re-seats
// itself whenever the slot count changes (a board-size upgrade)
upg_y = bar_y + bar_h * 2 + 8;
__reseat = function() {
	var _rows2 = ceil(g.tiles.slots / g.tiles.cols);
	bx = (room_width - (g.tiles.cols * pw - 4)) * .5;
	by = board_top + ((board_bot - board_top) - (_rows2 * ph - 4)) * .5;
};

__slot_x = function(_i) { return bx + (_i % g.tiles.cols) * pw; };
__slot_y = function(_i) { return by + (_i div g.tiles.cols) * ph; };
__slot_at = function(_mx, _my) {
	var _cx = floor((_mx - bx) / pw);
	var _cy = floor((_my - by) / ph);
	if (_cx < 0 || _cx >= g.tiles.cols) return -1;
	if (_cy < 0) return -1;
	var _i = _cy * g.tiles.cols + _cx;
	if (_i >= g.tiles.slots) return -1;
	// the gutter between tiles is dead space
	if ((_mx - bx) - _cx * pw >= tw) return -1;
	if ((_my - by) - _cy * ph >= th) return -1;
	return _i;
};

// info box content in one place: [text, color] pairs. width fitting
// and drawing both read this
__info_lines = function() {
	var _t = g.tiles;
	var _used = 0;
	for (var _i = 0; _i < _t.slots; _i++) if (_t.tier[_i] != 0) _used++;
	var _l = [
		["tile table", c_aqua],
		[gps_str, c_gold],
		["tiles " + string(_used) + "/" + string(_t.slots), c_white],
		["highest tier " + string(_t.highest), c_white],
		["merges " + string(_t.merges), c_white],
		["stored " + string(_t.stored) + "/" + string(_t.stored_max),
			(_t.stored >= _t.stored_max) ? c_horange : c_white],
	];
	// the merger's power state, shown only while it's switched on
	// (it bills the battery pool now - this is where the bill shows).
	// strings stay short on purpose: info_w is fitted at recache and
	// these lines change live with the throttle
	if (_t.automerge) {
		var _mt = _t[$ "thr_am"] ?? 1;
		if (_mt >= .995)   array_push(_l, ["merger powered", c_white]);
		else if (_mt > 0)  array_push(_l, ["merger " + string(round(_mt * 100)) + "%", c_horange]);
		else               array_push(_l, ["merger stalled", c_hred]);
	}
	return _l;
};

// rebuild the display caches from the tier array. the TOTAL is the
// engine's job (g.tiles.gps is always current, tile room or not);
// this only builds the per-tile strings and colors
__recache = function() {
	var _t = g.tiles;
	draw_set_font(fnt_large); // values render in the Myriad tile font
	for (var _i = 0; _i < _t.slots; _i++) {
		if (_t.tier[_i] == 0) { val_str[_i] = ""; continue; }
		var _g = tile_gps(_t.tier[_i]);
		col[_i] = tile_color(_t.tier[_i]);
		// value text color, Myriad's update_mod_color recipe: the tier
		// hue with saturation floored at 100 and value floored at 190,
		// so the number always reads bright against the dark tile
		if (_t.tier[_i] <= 1) txtcol[_i] = c_white;
		else txtcol[_i] = make_colour_hsv(colour_get_hue(col[_i]),
			clamp(colour_get_saturation(col[_i]), 100, 255),
			clamp(colour_get_value(col[_i]), 190, 255));
		val_str[_i] = "+" + crunch_arb(_g);
		// Myriad's fit rule: bnd = sprite_width-1, scale down when the
		// string is wider (fractional scale - it's what the original did)
		var _sw = string_width(val_str[_i]);
		val_sc[_i] = (_sw > tw - 1) ? (tw - 1) / _sw : 1;
	}
	gps_str = "+" + crunch_arb(_t.gps) + "/s";

	// info box width rides its longest line (house rule; info stays fnt)
	draw_set_font(fnt);
	var _lines = __info_lines();
	info_w = 0;
	for (var _i = 0; _i < array_length(_lines); _i++)
		info_w = max(info_w, string_width(_lines[_i][0]));
	info_w += 10;
};

__recache();
