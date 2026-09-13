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
// AN OVERLAY, NOT A ROOM (his ask, 2026-09-12: "port the tiles to a
// standalone layer thing instead of its own room"): spawned over
// whatever room you stand in by tiles_open, on the contract every
// panel shares - oa / closing, ui_overlay lists it, the burger's X and
// escape close it. It paints its own black ground (the room it was is
// black) and it is OPAQUE: the tapper does not fire through it. The
// three draw slots keep their order a step under the panel's depth.
// The table itself never lived here - syst_tiletimer runs tiles_tick
// everywhere - so nothing about the sim changes. (The layout is the
// 480x270 room's.)
depth   = -510;   // over the room and its drawers, under the menu (-520) and the header (-1000)
oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by tiles_close; the Step destroys at zero
opaque  = true;   // obj_clicker reads this: no paid taps under the board
/// is the panel here and unblocked - the gate every press below asks
__in = function() { return oa >= .999 && !closing && input_free(ui_layer_overlay); };

bby     = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 27;   // the bar, not its 2px shadow (his call: flush)
strip_y = bby;
strip_h = 16;
bar_y   = strip_y + strip_h;             // snug, no gap
bar_h   = 3;                             // DE's module meter is 3px
// the two tones of DE's meter - see the Draw. bar_fast leads, bar_slow
// lags and is what you actually notice when a tile lands.
bar_fast = 0;
bar_slow = 0;
// DE's merge charge on the meter (syst_rm_modules' adj): a charge sets
// bar_adj to 30 and it decays to 1, so the fast tone GROWS to the new
// fill over half a second instead of jumping - and the same divisor
// carries a fill that wrapped past the top out the right end and back
// in from the left. bar_glow is the flash on the bar itself
bar_adj  = 1;
bar_glow = 0;
am_glow  = 0;

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

/// @func __grow()
/// @desc THE VIEW ARRAYS FOLLOW THE BOARD (the slots row, 2026-09-10).
///       They are sized here at Create, and a slot bought from the
///       drawer grows g.tiles.tier the same frame - a read of glow[12]
///       on a twelve-long array is a crash, so the Step and the Draw
///       both ask this first. Writes would auto-extend; the READS are
///       why this exists. Shrinks are left alone: the loops run to
///       slots, and a longer array costs nothing.
__grow = function() {
	var _n = g.tiles.slots;
	if (array_length(glow) >= _n) return;
	var _n0 = array_length(glow);
	array_resize(glow, _n); array_resize(val_str, _n); array_resize(val_sc, _n);
	array_resize(col, _n);  array_resize(txtcol, _n);
	for (var _i = _n0; _i < _n; _i++) {
		glow[_i] = 0; val_str[_i] = ""; val_sc[_i] = 1;
		col[_i] = c_white; txtcol[_i] = c_white;
	}
};

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
// ⚖️ A SWIPE ONLY COUNTS IF IT STARTED AT THIS DRAWER'S EDGE (his
// report: dragging tiles around kept opening it). A drawer that any
// horizontal movement anywhere can open is a drawer that fights the
// thing it shares the room with - and on a board whose whole verb is
// dragging, that is most of what you do. The edge band is where the
// drawer actually lives, so a pull from there reads as pulling IT.
sw_edge = 64;
// ⚖️ AND ONLY IF IT STARTED ON THE DRAWER TO CLOSE IT (his second
// report, 2026-09-10: "i keep accidentally closing the upgrade menu
// when im just trying to merge tiles"). While open, ANY press anywhere
// armed a close - and a tile dragged two columns right travels 68px,
// which is a swipe by the old rule. Now a press on the board never
// arms one, full stop, and while the drawer is open only a press ON
// THE DRAWER can push it shut. See the Step for the gate itself.
//
// THE GATE IS DE's (his list: "swipe speed limits... initial touch
// bounds... a limit on how long i need to touch the screen before it
// cancels the swipe") - the same five conditions the dial drawer runs
// off syst_touchscreen: a distance floor, a distance CEILING, a time
// ceiling, a speed floor, a direction cone. The house macros
// (touch_dragdist_min 50 / touch_time_min 45 / touch_dragspd_min 7)
// are the ceiling, the time and the speed; these two are the drawer's
// own, the dial drawer's values.
SW_DIST_MIN = 12;   // a twitch is not a swipe
SW_COOL     = 12;   // frames before another swipe can land
sw_tic      = 0;
// THE CLOSE CHIP: a [>] at the head of the title row, because a drawer
// that can only be swiped shut is a drawer people learn to fear
// swiping near. A tap is a tap.
__cx_r = function() {
	return { x : __dr_face() + 5, y : upg_y - 14, w : 11, h : 11 };
};

// WHERE THE PER-SECOND EARNINGS FLOAT (his ask). Published rather than
// computed by the caller: syst_tiletimer spawns the float - it is the
// object that knows what a second was worth - and it has no business
// knowing where this room puts its board. Seated below, with the rest
// of the layout.
float_x = 0;
float_y = 0;
spark_x = 0;   // where the shard count sits - and where the bits fly
spark_y = 0;

// frames left on the table-rebirth confirm (see the Step)
// ⚖️ THE MERGE COMBO (his ask, 2026-09-10): the merge sound climbs a
// step in pitch for every merge that lands at or above the tier the
// combo is on, and drops back to the base pitch the first time a merge
// lands LOWER. So a run up the ladder rises, and turning back to tidy
// small pairs resets it. combo_tier is the tier the last merge made,
// combo_n how many steps up the sound has climbed.
combo_tier = 0;
combo_n    = 0;
__merge_pitch = function(_tier) {
	if (_tier >= combo_tier) combo_n = min(combo_n + 1, 14);
	else combo_n = 0;
	combo_tier = _tier;
	return power(1.0595, combo_n);   // a semitone a step
};
// THE TIER-UP CEREMONY (DE's, his ask): a float over the tile and a
// spark burst out of it, in the tile's colour - the +2 sound already
// rings; this is the part you SEE
__tierup_fx = function(_i) {
	if (_i < 0 || _i >= g.tiles.slots) return;
	var _cx = __slot_x(_i) + tw * .5, _cy = __slot_y(_i) + th * .5;
	float_text(_cx, _cy - 10, "tier up!", tile_color(g.tiles.tier[_i]), fnt_outline);
	spark_burst(_cx, _cy, 6, tile_color(g.tiles.tier[_i]));
};
arm_rb = 0;
// ⚖️ THE DEBUG DRAWER (his ask, 2026-09-10): the board's five controls
// - auto merge, sort, aim, reset, reset upgrades - used to sit in a row
// along the bottom edge. They live in a drawer on the LEFT now, opened
// by an arrow chip in the bottom-left corner: a CLICK, not a swipe (the
// right-hand drawer is the swipe; two swipe drawers on one board is a
// board that fights its own gestures). The chip stays out; the panel
// slides in from the left edge over the info box and closes the same
// way. Every hit reads __dbg_r, the same rectangles the draw paints.
dbg_open = 0;
dbg_want = 0;
dbg_w    = 112;
dbg_rows = ["auto merge", "sort", "aim", "reset", "reset upgrades"];
__dbg_chip = function() { return { x : 4, y : room_height - 18, w : 14, h : 14 }; };
__dbg_x    = function() { return lerp(-dbg_w, 0, dbg_open); };
__dbg_r    = function(_k) {
	return { x : __dbg_x() + 6, y : dr_top + 10 + _k * 20, w : dbg_w - 12, h : 14 };
};
// ⚖️ A DROPPED TILE GLIDES HOME (his ask, 2026-09-10: "instead of it
// snapping back into its OG position it lerps to it"). On release the
// ghost does not vanish: ret_i is the slot it belongs to now (its old
// one on a bounce, the new one on a move) and ret_x/ret_y trickle from
// where the hand let go to that slot; the slot shows the dim echo until
// the ghost lands. The engine keeps its hands off the slot meanwhile
// (g.tiles.grab), the same lock a held tile has.
ret_i = -1;
ret_x = 0; ret_y = 0;
ret_x0 = 0; ret_y0 = 0;   // where the hand let go
ret_t  = 1;               // the glide's clock, 0..1 (eased in the Step)
ret_n  = 12;              // its length in frames (set on release, off the distance)
hov_mute = -1;   // the slot a released tile sits in: no hover glow until the pointer leaves it
// THE SORT BUTTON (his ask, 2026-09-10: DE's sort button sprite,
// "somewhere it fits outside the debug dock"): DE's spr_button_small at
// DE's 1.2 scale, dark blue with "sort" in aqua, under the info box on
// the board's left. It flashes on a press (DE's glow) and tints on hover.
sort_glow = 0;
sort_hov  = 0;
__sort_r = function() {
	// under the info box: the box sits at (6, 100) and is __info_lines
	// tall (11 a line + 8) - see the Draw
	var _n = array_length(__info_lines());
	return { x : 6, y : 100 + _n * 11 + 8 + 4,
	         w : round(sprite_get_width(spr_button_small) * 1.2),
	         h : round(sprite_get_height(spr_button_small) * 1.2) };
};
// ⚖️ THE AUTOMERGE'S APPROACH (his ask, 2026-09-10 - an older DE
// branch's trick): the tile that is about to fold (am_ib) sits still
// until the last stretch of the automerge bar, then slides onto the
// tile it folds into (am_ia) so the two are on top of each other the
// instant the merge lands. Driven by the bar's own progress, so the
// two can never disagree about when the merge is.
// ⚖️ A FIXED SLIDE TIME, NOT A FIXED FRACTION (his correction): the
// slide takes AM_MOVE_TIME ticks whatever the interval is - the start
// mark on the bar is 1 - time/interval, so a ten-second merger slides
// in its last third of a second exactly like a two-second one. Only
// when the interval itself is SHORTER than the slide does the mark hit
// zero and the slide compress to the whole bar - that is the one case
// it speeds up, and it is the case where the merger is faster than
// the vanilla slide. And it EASES IN: slow off its slot, fastest as it
// lands (he had it the other way round and it read as arriving early).
AM_MOVE_TIME = 18;   // ticks of slide (60 = a second at x1)
__am_move_from = function() {
	var _t = g.tiles;
	return (_t.am_tic_ > 0) ? max(0, 1 - AM_MOVE_TIME / _t.am_tic_) : 1;
};
arm_rs = 0;   // the board's RESET button's own confirm window - it
              // wipes the shards and the upgrades too now, and a
              // misclick beside [sort] must not cost thirteen levels
arm_ru = 0;   // and [reset upgrades]' - same rule, same reason
// ⚖️ THE DRAWER'S TAPS LAND ON RELEASE, UNDER A DRAG BUDGET (his report,
// 2026-09-10: "im accidentally clicking on the upgrade buttons when i
// try to close the tile dock"). The rows bought on PRESS, and a swipe
// to close the drawer starts with a press - on whatever row the finger
// happened to land on, which bought it before the gate had seen a
// single pixel of travel. menu2's rule, the dial drawer's BUDGET: a
// press is only a tap once the finger comes up within a few px of
// where it went down, and a press the swipe gate consumed is not a
// tap at all.
dp_x = -1;      // where the press landed on the drawer; -1 = no press live
dp_y = -1;
DR_BUDGET = 6;

upg_y = 0;       // seated below, once the strip is known
dr_top = 0;      // the drawer's top edge - under the title banner (below)
upg_h = 22;   // ⚖️ CONDENSED (his ask, 2026-09-10): the name + level line,
              // then the buy bar - the bonus line moved INTO the bar
              // (bonus right, cost left), so a row is exactly a header
              // and a button. Was 36 with the bonus on its own line,
              // then 25 + 3 for six rows; the slots row made it seven,
              // and seven at 22 + 2 (168px) still clear the rebirth
              // box at 241 from a top of 68.
upg_g = 2;    // the gap between rows
/// THE DRAWER'S ROWS - ONE TAB AT A TIME (his ask, 2026-09-13: nine rows
/// in one list "condensed and overlapping"). upg_tab 0 = the shard
/// roster (the engine, wiped by a reset), 1 = the flux ladder (the
/// export, permanent). Each row carries its currency so the layout,
/// the quotes, the draw and the hit test walk the same array
upg_tab = 0;
__rows = function() {
	var _o = [];
	if (upg_tab == 0) {
		var _uc = tile_upg_config();
		for (var _k = 0; _k < array_length(_uc); _k++) array_push(_o, { cfg : _uc[_k], cur : "shards" });
	} else {
		var _fc = tile_flux_config();
		for (var _k = 0; _k < array_length(_fc); _k++) array_push(_o, { cfg : _fc[_k], cur : "flux" });
	}
	return _o;
};
upg_n = array_length(__rows());
UPG_DIV_H = 12;   // the currency line above the rows (what this tab spends)
// the two tab chips in the drawer's header, after the close chip
__tab_r = function(_k) {
	return { x : __dr_face() + 5 + 11 + 5 + _k * 42, y : upg_y - 14, w : 40, h : 11 };
};
/// a tab switch: the rows change under every per-row array, so they
/// start over (the quotes requote at once)
__tab_set = function(_k) {
	if (upg_tab == _k) return;
	upg_tab = _k;
	uq = []; ufold = []; uflash = []; upop = []; urow_y = []; urow_h = [];
	upg_n = array_length(__rows());
	qtic = 0;
};
// ⚖️ THE FACE, AND IT WAS WRONG AT BOTH ENDS. -dr_w + (dr_w+tab)*open
// put the CLOSED drawer's right edge at 0 - so the tab was off screen -
// and the OPEN one's left edge at +9, leaving a strip of room showing
// down the side of a drawer that is supposed to be flush with it. The
// two positions are the only two facts here, so lerp between them and
// let nothing else be inferred.
// ⚖️ THE DRAWER IS ON THE RIGHT NOW (his ask, 2026-09-08) and the info
// box swapped to the left with it. The face is still the drawer's INNER
// edge, so everything downstream reads the same way - only the sums
// changed: closed leaves dr_tab poking in from the room's right edge,
// open puts the face dr_w in from it.
__dr_face = function() {
	return lerp(room_width - dr_tab, room_width - dr_w, dr_open);
};
// ---- THE BUY-AMOUNT BUTTON (his ask, 2026-09-10) ----
// The dial drawer's spr_buylv, in this drawer's header, cycling
// g.tile_buy_lv through x1 / x10 / x100 / max. No "next" - DE's "next"
// snaps to a round dial level, and a tile ladder capped at 50 has no
// round number worth snapping to.
__bb_r = function() {
	return { x : __dr_face() + dr_w - 8 - sprite_get_width(spr_buylv),
	         y : upg_y - 13,   // down a px (his ask), level with the chip
	         w : sprite_get_width(spr_buylv), h : sprite_get_height(spr_buylv) };
};
bb_down = false;   // the pressed face while the finger is on it
__bb_frame = function() {                    // spr_buylv's glyph frames
	if (g.tile_buy_lv == 10)    return 3;
	if (g.tile_buy_lv == 100)   return 4;
	if (g.tile_buy_lv == "max") return 7;
	return 2;
};
__bb_color = function() {                    // the dial drawer's tints
	if (g.tile_buy_lv == 10)    return c_rarity_uncommon;
	if (g.tile_buy_lv == 100)   return c_rarity_rare;
	if (g.tile_buy_lv == "max") return c_gold;
	return c_white;
};
__bb_cycle = function() {
	var _seq = [1, 10, 100, "max"];
	var _ix = 0;
	for (var _k = 0; _k < array_length(_seq); _k++)
		if (g.tile_buy_lv == _seq[_k]) _ix = _k;
	g.tile_buy_lv = _seq[(_ix + 1) mod array_length(_seq)];
};

/// @func __rb_r()
/// @desc The tile-rebirth button, under the last upgrade row. It sits
///       with the upgrades because it IS one - the most expensive thing
///       the drawer sells, paid in progress instead of shards.
__rb_r = function() {
	// SNUG TO THE BOTTOM, a couple of px up (his ask, 2026-09-10) - it
	// used to hang under the last row, wherever that fell. Half height
	// while it cannot fire (a whisper), full when it can
	var _h = tile_rebirth_calc().can ? 26 : 12;
	return { x : __dr_face() + 4, y : room_height - _h - 3,
	         w : dr_w - 8 - 4, h : _h };
};

// ⚖️ THE ROWS FOLD (his report, 2026-09-11: the drawer "feels noisy,
// claustrophobic"). Seven full rows competed equally whether or not a
// row was anywhere near buyable, and early on four of them are a
// thousand times out of reach. A row whose price is more than 100x the
// shards in hand folds to a half-height whisper - name and price, dim
// - and unfolds as you approach it, on an ease so the list breathes
// rather than jumps. The hierarchy the drawer was missing is
// AFFORDABILITY: the rows you can buy are the only bright ones, the
// near ones are quiet, the far ones are whispers. Heights are laid out
// cumulatively once a frame (__upg_layout) and both the Draw and the
// Step read the result, so a tap can never land on a row the fold has
// moved.
UPG_H_FULL = 22;
UPG_H_FOLD = 11;
UPG_FOLD_OOM = 2;     // fold past this many decades from affordable
ufold  = [];          // 0 full .. 1 folded, eased, one per row
uflash = [];          // frames of the buy flash left, one per row
upop   = [];          // the level's pop scale on a buy, eased to 1
urow_y = [];          // this frame's row seats (top) ...
urow_h = [];          // ... and heights
__upg_layout = function() {
	var _n = upg_n;
	var _y = upg_y;
	// which rows want to fold - and THE NEXT TARGET NEVER DOES: the
	// cheapest row you cannot yet afford stays open however far off it
	// is, so a fresh table (no shards, everything a hundred times away)
	// still shows one full row to save toward rather than seven whispers
	var _rows = __rows();
	_n = array_length(_rows);
	var _wants = array_create(_n, 0);
	var _next = -1, _fnext = -1;
	for (var _k = 0; _k < _n; _k++) {
		if (_k >= array_length(uq)) continue;
		var _q = uq[_k];
		if (_q.max) continue;
		if (_rows[_k].cur == "shards") {
			if (!(_q.cost >= arb(1))) continue;
			var _sh = g.tiles.shards;
			var _gap = (_sh >= arb(1)) ? (arb_log10(_q.cost) - arb_log10(_sh)) : arb_log10(_q.cost);
			if (_gap > UPG_FOLD_OOM) _wants[_k] = 1;
			if (!_q.ok && (_next == -1 || _q.cost < uq[_next].cost)) _next = _k;
		} else {
			// a flux row: the gap against the flux in hand, plain reals
			var _fl = max(1, g.tiles[$ "flux"] ?? 0);
			var _gap = log10(max(1, _q.cost)) - log10(_fl);
			if (_gap > UPG_FOLD_OOM) _wants[_k] = 1;
			if (!_q.ok && (_fnext == -1 || _q.cost < uq[_fnext].cost)) _fnext = _k;
		}
	}
	if (_next >= 0) _wants[_next] = 0;
	if (_fnext >= 0) _wants[_fnext] = 0;
	for (var _k = 0; _k < _n; _k++) {
		while (array_length(ufold)  <= _k) array_push(ufold, 0);
		while (array_length(uflash) <= _k) array_push(uflash, 0);
		while (array_length(upop)   <= _k) array_push(upop, 1);
		ufold[_k] = trickle(ufold[_k], _wants[_k], 6, 0);
		uflash[_k] = max(0, uflash[_k] - delta);
		upop[_k]  = trickle(upop[_k], 1, 5, 0);
		var _h = round(lerp(UPG_H_FULL, UPG_H_FOLD, ufold[_k]));
		if (_k == 0) _y += UPG_DIV_H;   // the currency line above the rows
		urow_y[_k] = _y;
		urow_h[_k] = _h;
		_y += _h + upg_g;
	}
};
__upg_r = function(_k) {
	var _y = (_k < array_length(urow_y)) ? urow_y[_k] : upg_y + _k * (upg_h + upg_g);
	var _h = (_k < array_length(urow_h)) ? urow_h[_k] : upg_h;
	return { x : __dr_face() + 4, y : _y, w : dr_w - 8 - 4, h : _h };
};
/// is row _k unfolded enough to sell? (the fold's midpoint)
__upg_live = function(_k) {
	return (_k >= array_length(ufold)) || (ufold[_k] < .5);
};
/// the row's colour family: what the upgrade is ABOUT, so seven rows
/// scan without reading - one accent per meaning, on the tab and the
/// lit price only
__upg_col = function(_id) {
	switch (_id) {
		case "profit": return c_gold;
		case "floor":  return c_hred;
		case "fab":    return c_sgreen;
		case "rarity": return c_lavender;
		case "dup":
		case "tierup": return c_steelblue;
	}
	return rgb(170, 180, 200);   // the board's own rows: slots, hopper
};
// THE BUY BUTTON inside a row - the cost bar. It is the row's tap
// target now (his ask, 2026-09-10: "make the tap position for the tile
// upgrades be that bar that shows the cost, not the whole thing"); the
// name, the level and the now > next line are readouts, and a readout
// that sells something when touched is a trap. The draw uses the same
// rectangle, so the target is exactly the thing that looks like one.
__upg_btn_r = function(_k) {
	var _r = __upg_r(_k);
	return { x : _r.x + 6, y : _r.y + 11, w : _r.w - 12, h : 10 };
};
// the quote cache: tile_upg walks a log-space series and packs an arb,
// and the price only moves when something is bought
qtic = 0;
uq   = [];
// the buy buttons' fill: shards held over the quoted cost, one 0..1 a
// row, eased so a requote steps and the fill glides (his ask: a soft
// progress bar to the next purchase). Sized lazily in the draw.
ufill = [];

// ==================================================================
// THE DRAWER, ITS OWN DRAW SLOT
// ==================================================================
// ⚖️ IT CANNOT LIVE IN Draw_0 WITH THE BOARD, and the reason is
// draw_pixel_region's contract: it needs pixel_snap to have run from a
// draw slot DEEPER than the caller. Called inline in one event that is
// impossible - the snapshot and the panel are the same slot - so the
// region drew nothing at all and left only the dim. Which is exactly
// what the bottom buttons' text was showing through (his report): it
// was never above the blur, there was no blur.
//
// So the room draws in three slots, the house recipe:
//   depth  0   the board, bars, strip, controls   (Draw_0)
//   depth -25  pixel_snap                          (snap proxy)
//   depth -50  the drawer and its tab              (this)
/// @func __btn_a(x1, x2)
/// @desc How visible a bottom-row button is, given where the drawer is.
///
/// ⚖️ THE DRAWER COVERS THEM, SO THEY LEAVE (his report: their text was
/// still drawing over the blur). The layering was already right - the
/// board draws at depth 0, the snapshot at -25, the drawer at -50 - and
/// I could not make the order fail on paper. What I could do is remove
/// the possibility: a button the drawer reaches fades out as it opens,
/// so there is nothing of theirs left to appear over anything. It is
/// also the better behaviour on its own terms. With the drawer out you
/// are in the upgrades, not on the board, and a control you cannot
/// reach should not be sitting there looking pressable.
///
/// Buttons entirely clear of the drawer's travel keep full alpha.
__btn_a = function(_x1, _x2) {
	if (dr_open <= .001) return 1;
	if (_x2 <= __dr_face()) return 1;   // entirely LEFT of the drawer now
	return clamp(1 - dr_open, 0, 1);
};

__draw_drawer = function() {
	// the drawer dissolves with the panel (the proxy is its own draw
	// slot, so it sets the fade itself and takes it off at the end)
	ui_fade_set(ui_anim_in(oa, 0));
	// THE DRAWER'S BACKDROP (his ask: the dial drawer's treatment).
	// pixel_snap grabs the screen as it stands and draw_pixel_region paints
	// the chunky copy back under the panel, so the board reads as being
	// behind frosted glass rather than simply covered.
	//
	// CAPTURED HERE, not from a draw proxy. The dial drawer can use a proxy
	// because the room it covers is drawn by OTHER objects; here the board
	// and the drawer are the same Draw event, so a proxy at any depth would
	// fire before the board existed and pixelate an empty room.
	if (dr_open > .001) pixel_snap(3, 4);

	// ================= THE UPGRADE DRAWER =================
	// Out from the LEFT on a swipe right (his ask). Drawn LAST so it slides
	// OVER the board rather than under it - a drawer that the thing it
	// covers draws through is not a drawer.
	if (dr_open > .001) {
		var _fx = __dr_face();
		var _tt = g.tiles;
		draw_set_font(fnt);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);

		// the body: the PIXELATED copy of what is behind it - the dial
		// drawer's treatment (his ask) - under a plate dark enough to be
		// flat where the rows sit. ⚖️ .72, not .45 (his report,
		// 2026-09-11: "noisy"): the pixelation is the drawer's edge
		// treatment, and text over texture was most of the noise
		draw_pixel_region(_fx, dr_top, dr_w, room_height - dr_top, dr_open);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, dr_top, dr_w, room_height - dr_top,
			0, c_black, .72 * dr_open);
		// the accent runs down the drawer's INNER edge, which is its left
		// one now that it comes from the right - and along its top, now
		// that the top is an edge in the room rather than the header's
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, dr_top, 1,
			room_height - dr_top, 0, c_aqua, .35);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, dr_top, dr_w, 1, 0, c_aqua, .35);

		// ⚖️ THE TITLE SITS WITH WHAT IT TITLES (his ask, 2026-09-09:
		// move it down above the upgrades). It was up in the room's
		// title strip, sharing a 16px band with the shard count and the
		// rate - three unrelated readouts on one line, and in the
		// portrait room they had nowhere near the width for it, so they
		// simply overlapped. A heading belongs directly above its list;
		// up there it was competing with the room's own name.
		// the close chip, then the title beside it
		var _cx = __cx_r();
		draw_sprite_ext(spr_pixel_1x1, 0, _cx.x, _cx.y, _cx.w, _cx.h, 0,
			c_black, .6 * dr_open);
		draw_px_rect(_cx.x, _cx.y, _cx.w, _cx.h, c_aqua, .45 * dr_open);
		draw_set_halign(fa_center);
		draw_set_color(c_aqua);
		draw_set_alpha(.8 * dr_open);
		draw_text(_cx.x + _cx.w * .5 + 1, _cx.y + 2, ">");
		draw_set_halign(fa_left);
		// THE TWO TABS, after the close chip: shards (the engine) and flux
		// (the export) - the drawer shows one ladder at a time
		for (var _tk = 0; _tk < 2; _tk++) {
			var _tr = __tab_r(_tk);
			var _tc = (_tk == 0) ? c_aqua : c_hred;
			var _ton = (upg_tab == _tk);
			draw_sprite_ext(spr_pixel_1x1, 0, _tr.x, _tr.y, _tr.w, _tr.h, 0,
				_ton ? merge_colour(_tc, c_black, .6) : c_black, (_ton ? .95 : .6) * dr_open);
			draw_px_rect(_tr.x, _tr.y, _tr.w, _tr.h, _tc, (_ton ? .9 : .3) * dr_open);
			draw_set_halign(fa_center);
			draw_set_color(_ton ? c_white : merge_colour(_tc, c_white, .3));
			draw_set_alpha((_ton ? .95 : .6) * dr_open);
			draw_text(_tr.x + _tr.w * .5 + 1, _tr.y + 2, (_tk == 0) ? "shards" : "flux");
		}
		draw_set_halign(fa_left);

		// the buy-amount button, right of the title - THE DIAL ROOM'S
		// LOOK (his ask): DE's obj_ui_buylv face tinted by the mode
		// (frame 0, or 1 pressed) with the mode glyph on top, not the
		// bare glyph this drew before
		if (upg_tab == 0) {   // (a flux rung is one level a buy - no amount to pick)
			var _bb = __bb_r();
			var _bbc = __bb_color();
			draw_sprite_ext(spr_buylv, bb_down ? 1 : 0, _bb.x, _bb.y, 1, 1, 0,
				_bbc, .95 * dr_open);
			draw_sprite_ext(spr_buylv, __bb_frame(), _bb.x, _bb.y + (bb_down ? 1 : 0),
				1, 1, 0, merge_colour(_bbc, c_white, .5), .95 * dr_open);
		}

		__upg_layout();
		var _rows = __rows();
		var _dimc = rgb(110, 120, 140);
		for (var _k = 0; _k < array_length(_rows); _k++) {
			var _ur = __upg_r(_k);
			var _uq = (_k < array_length(uq)) ? uq[_k]
				: { ok : false, cost : arb(1), lv : 0, txt : "-", max : false, n : 0 };
			var _uc = _rows[_k].cfg;
			var _isf = (_rows[_k].cur == "flux");
			var _ua = dr_open;
			var _rc = _isf ? merge_colour(c_hred, c_white, .25) : __upg_col(_uc.id);
			var _ucap = _uc[$ "max"] ?? -1;

			// THE CURRENCY LINE above the tab's rows: what this ladder is,
			// and what you hold to spend on it
			if (_k == 0) {
				var _dvy = _ur.y - UPG_DIV_H;
				var _lc = _isf ? c_hred : c_aqua;
				draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _dvy + 5, _ur.w, 1, 0, _lc, .35 * _ua);
				draw_set_halign(fa_left);
				draw_set_color(_lc);
				draw_set_alpha(.85 * _ua);
				draw_text(_ur.x + 2, _dvy - 1, _isf ? "flux  -  permanent" : "shards  -  the engine, a reset wipes it");
				draw_set_halign(fa_right);
				draw_set_color(merge_colour(_lc, c_white, .4));
				if (_isf) {
					var _fl2 = g.tiles[$ "flux"] ?? 0;
					draw_text(_ur.x + _ur.w - 2, _dvy - 1, crunch_arb(arb(max(0, floor(_fl2)))) + " held  x"
						+ string_format(tile_rebirth_boost(), 1, 2));
				}
				draw_set_halign(fa_left);
			}

			// ---- a folded row: the whisper ----
			if (!__upg_live(_k)) {
				draw_row_collapsed(_ur.x, _ur.y, _ur.w, _ur.h, _uc.name, _uq.txt, _rc);
				continue;
			}

			// ---- a live row. THE HIERARCHY IS AFFORDABILITY: a row you
			// can buy is bright in its own colour; one you cannot is one
			// quiet grey, tab to price ----
			var _ok = _uq.ok;
			var _ucol = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
			draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _ur.y, _ur.w, _ur.h, 0, _ucol, _ua);
			draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _ur.x, _ur.y,
				_ur.w, 1, 0, _ucol, c_black, c_black, _ucol, .5 * _ua);
			draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _ur.y, 2, _ur.h, 0,
				_ok ? _rc : _dimc, (_ok ? .95 : .25) * _ua);
			// the buy flash: the row goes white and fades
			if (uflash[_k] > 0)
				draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _ur.y, _ur.w, _ur.h, 0,
					_rc, .45 * (uflash[_k] / 14) * _ua);

			// the name, and the level right - popping on a buy
			draw_set_color(_ok ? c_white : _dimc);
			draw_set_alpha((_ok ? .95 : .6) * _ua);
			draw_text(_ur.x + 7, _ur.y + 2, _uc.name);
			draw_set_halign(fa_right);
			var _lvt = "lv " + string(_uq.lv) + ((_ucap > 0) ? ("/" + string(_ucap)) : "");
			if (!_uq.max && _uq.n > 1) _lvt += "  +" + string(_uq.n);
			draw_set_color(_ok ? merge_colour(_rc, c_white, .4) : _dimc);
			draw_set_alpha((_ok ? .85 : .5) * _ua);
			draw_text_transformed(_ur.x + _ur.w - 6, _ur.y + 2 - (upop[_k] - 1) * 3,
				_lvt, upop[_k], upop[_k], 0);
			draw_set_halign(fa_left);

			// ---- THE BAR: the tap target. the cost left, WHAT IT BUYS
			// right - only the next value, an arrow before it (the
			// current value is on the board and beside the level;
			// printing it a third time was the noise) ----
			var _ubr = __upg_btn_r(_k);
			var _bx2 = _ubr.x, _by2 = _ubr.y, _bw2 = _ubr.w, _bh2 = _ubr.h;
			draw_sprite_ext(spr_pixel_1x1, 0, _bx2, _by2, _bw2, _bh2, 0,
				_ok ? merge_colour(c_black, _rc, .2) : c_black, .85 * _ua);
			// THE SOFT FILL: how much of the quoted cost the shards in hand
			// cover, linear ("based off current currency" is a ratio), off
			// the LIVE pile against the cached quote, eased so a requote
			// glides. Nothing to fill toward at the cap
			var _ft = 0;
			if (!_uq.max) {
				if (_isf) _ft = clamp((g.tiles[$ "flux"] ?? 0) / max(1, _uq.cost), 0, 1);
				else if (_uq.cost >= arb(1)) {
					var _sh2 = g.tiles.shards;
					_ft = (_sh2 >= arb(1))
						? clamp(power(10, arb_log10(_sh2) - arb_log10(_uq.cost)), 0, 1)
						: 0;
				}
			}
			while (array_length(ufill) <= _k) array_push(ufill, 0);
			ufill[_k] = trickle(ufill[_k], _ft, 6, 0);
			if (ufill[_k] > .002)
				draw_sprite_ext(spr_pixel_1x1, 0, _bx2, _by2,
					floor(_bw2 * ufill[_k]), _bh2, 0, _ok ? _rc : _dimc, (_ok ? .18 : .10) * _ua);
			draw_px_rect(_bx2, _by2, _bw2, _bh2, _ok ? _rc : _dimc, (_ok ? .85 : .25) * _ua);

			// the cost, tied to the left
			draw_set_halign(fa_left);
			draw_set_color(_ok ? c_white : _dimc);
			draw_set_alpha((_ok ? .95 : .55) * _ua);
			draw_text(_bx2 + 4, _by2 + 2, _uq.txt);

			// what it buys, tied to the right
			if (variable_struct_exists(_uc, "fmt")) {
				draw_set_halign(fa_right);
				if (!_uq.max) {
					var _nxt = "> " + _uc.fmt(_uq.lv + max(1, _uq.n));
					draw_set_color(_ok ? merge_colour(_rc, c_white, .3) : _dimc);
					draw_set_alpha((_ok ? .95 : .5) * _ua);
					draw_text(_bx2 + _bw2 - 4, _by2 + 2, _nxt);
				} else {
					draw_set_color(_dimc);
					draw_set_alpha(.6 * _ua);
					draw_text(_bx2 + _bw2 - 4, _by2 + 2, _uc.fmt(_uq.lv));
				}
				draw_set_halign(fa_left);
			}
		}

		// ---- THE TABLE'S OWN REBIRTH ----
		// Under the upgrades, because it is the most expensive thing
		// this drawer sells - it just charges progress instead of
		// shards. The readout is EARNED, not held: that is what it
		// prices off. ⚖️ ONE DIM LINE until it can fire (his report,
		// 2026-09-11): two lines of red arithmetic under a list you are
		// trying to read were the loudest thing in the drawer. Ready, it
		// is the full box, lit, with the two-press confirm.
		var _rr = __rb_r();
		var _rc = tile_rebirth_calc();
		var _rf = g.tiles[$ "flux"] ?? 0;
		if (!_rc.can) {
			draw_row_collapsed(_rr.x, _rr.y, _rr.w, _rr.h,
				"table rebirth  -  " + string(_rc.lack_oom) + " decades to go",
				(_rf > 0) ? (crunch_arb(arb(_rf)) + " flux") : "", c_hred);
		} else {
			draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0,
				merge_colour(c_black, c_hred, .15), .85 * dr_open);
			draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, c_hred, .85 * dr_open);
			draw_set_halign(fa_left);
			draw_set_color(c_hred);
			draw_set_alpha(.95 * dr_open);
			draw_text(_rr.x + 6, _rr.y + 3, "table rebirth");
			draw_set_halign(fa_right);
			draw_set_alpha(.7 * dr_open);
			draw_text(_rr.x + _rr.w - 6, _rr.y + 3,
				(_rf > 0) ? (crunch_arb(arb(_rf)) + " flux  x"
				             + string_format(tile_rebirth_boost(), 1, 2)) : "no flux");
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_set_alpha(.9 * dr_open);
			draw_text(_rr.x + 6, _rr.y + 14, (arm_rb > 0) ? "press again to confirm"
				: ("reset for +" + crunch_arb(arb(_rc.flux)) + " flux"));
		}
		draw_set_halign(fa_left);

		// (the per-second rate lives in the title strip now - see above)
		if (!TILES_LIVE) {
			draw_set_color(c_horange);
			draw_set_alpha(.7 * dr_open);
			draw_text(_fx + 6, upg_y + UPG_DIV_H + upg_n * (upg_h + upg_g) + 6, "preview - the board");
			draw_text(_fx + 6, upg_y + UPG_DIV_H + upg_n * (upg_h + upg_g) + 15, "is not saved yet");
		}
	}

	// THE EDGE TAB - only while the drawer is SHUT. It was drawing at every
	// open state, and the open drawer's own right-edge hairline sits one
	// pixel from where the tab's line lands - which is the second, shorter
	// aqua line (his report). One handle, one edge, never both.
	if (dr_open < .999) {
		// the tab hangs off the room's RIGHT edge now, and its accent is
		// the INNER side - which is where the open drawer's own hairline
		// lands, so the two are still one edge rather than two
		var _tabx = room_width - dr_tab;
		var _any = false;
		for (var _k = 0; _k < array_length(uq); _k++) if (uq[_k].ok) _any = true;
		var _ta = 1 - dr_open;
		draw_sprite_ext(spr_pixel_1x1, 0, _tabx, strip_y + strip_h + 24,
			dr_tab, 60, 0, c_black, .8 * _ta);
		draw_sprite_ext(spr_pixel_1x1, 0, _tabx, strip_y + strip_h + 24,
			2, 60, 0, c_aqua,
			(_any ? (.55 + .35 * dsin(current_time * .25)) : .35) * _ta);
	}

	// THE CURRENCY, LAST OF ALL. It is the one readout that has to be
	// legible while the drawer is open, because it is what the drawer
	// spends - so it is drawn after the panel rather than behind it.
	__draw_shards();

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	ui_fade_set(1);
};

/// @func __draw_shards()
/// @desc THE SPARK: the shard count, centred above the board, with the
///       board's rate under it (his ask, 2026-09-09 - middle of the
///       screen above the table, p/s below). Called from the END of
///       __draw_drawer so it lands over the panel - see there.
///
///       It is also THE TARGET: every bit the tiles emit flies here
///       (spark_x / spark_y, seated with the board in __reseat), so the
///       counter is visibly where the money goes rather than a number
///       that happens to be nearby. The per-second float spawns on it
///       too and rises off it - the header's own gain-pop pattern.
__draw_shards = function() {
	var _t = g.tiles;
	draw_set_font(fnt);
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);

	var _sh = ((_t.shards >= arb(1)) ? crunch_arb(_t.shards) : "0") + " shards";
	var _rt = "+" + ((_t.gps >= arb(1)) ? crunch_arb(_t.gps) : "0") + "/s";

	// a soft ground under the pair, so the count reads over whatever the
	// visualiser behind it is doing
	var _gw = sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, spark_x, spark_y + 6,
		90 / _gw, 40 / _gw, 0, c_black, .35);

	draw_set_font(fnt_large);
	draw_set_color(c_aqua);
	draw_set_alpha(.95);
	draw_text(spark_x, spark_y, _sh);

	draw_set_font(fnt);
	draw_set_color(merge_colour(c_aqua, c_white, .35));
	draw_set_alpha(.7);
	draw_text(spark_x, spark_y + 13, _rt);

	draw_set_halign(fa_left);
	draw_set_alpha(1);
};

// the two extra slots. obj_draw_proxy exists for exactly this: one
// instance, more than one depth.
snap_px = create_obj(0, 0, obj_draw_proxy);
snap_px.owner = id;
snap_px.depth = depth - 1;   // (was -25 under the board's 0: the same order, a step under the panel)
snap_px.fn    = function() { if (dr_open > .001) pixel_snap(3, 4); };

draw_px = create_obj(0, 0, obj_draw_proxy);
draw_px.owner = id;
draw_px.depth = depth - 2;
draw_px.fn    = __draw_drawer;


// ⚖️ THE DRAWER STARTS UNDER THE TITLE BANNER (his ask, 2026-09-10:
// "move it down below the tile title banner"). It used to rise from the
// header's foot and cover the room's title strip and the fabricator
// bars; now those stay in view and the drawer is the panel under them.
// The rows start a title row below its top edge.
dr_top = bar_y + bar_h * 2 + 2;
upg_y  = dr_top + 17;

// the float's seat: centred over the board, a little ABOVE its top row,
// so a rising number leaves the tiles rather than crossing them. The
// board's own geometry decides it, so a board that moves takes the
// float with it.
// THE SPARK'S SEAT, and the float's: centred over the board, in the
// headroom between the fabricator bars and the top row. The float
// spawns ON the count and rises off it, so a second's earnings visibly
// arrive at the number they are adding to.
// spark_lift: how far above the board's top row the count sits. 30 put
// it a line over the tiles; he wanted it higher (2026-09-10), and 44
// keeps the float's rise clear of the fabricator bars.
// (the bits leave from each tile, under it - syst_tiletimer reads the
// slot geometry through `with`; there is no separate spawn seat)
spark_lift = 60;   // (44 before; his ask 2026-09-10: nearer the top)
spark_x = bx + (g.tiles.cols * pw - 4) * .5;
// ...floored at the band's top: a 32-slot board is eight rows and its
// top row sits where the lift would put the count over the fab bars
spark_y = max(board_top, by - spark_lift);
float_x = spark_x;
float_y = spark_y - 2;
__reseat = function() {
	var _rows2 = ceil(g.tiles.slots / g.tiles.cols);
	bx = (room_width - (g.tiles.cols * pw - 4)) * .5;
	by = board_top + ((board_bot - board_top) - (_rows2 * ph - 4)) * .5;
	// the spark and the float ride the board - a board-size upgrade
	// must not leave either hanging where the old board was
	spark_x = bx + (g.tiles.cols * pw - 4) * .5;
	spark_y = max(board_top, by - spark_lift);
	float_x = spark_x;
	float_y = spark_y - 2;
};

// ⚖️ WHERE A TILE'S VALUE SITS, and it is worth being deliberate about
// because two guesses have already missed. fnt_large is a SPRITE font
// on a 9x11 cell, drawn at FRACTIONAL scales to fit a 13px tile, and
// neither fa_middle nor string_height(the whole string) centres that
// reliably: valign against a fractional scale drifts, and a measured
// string can carry line spacing the glyphs do not use.
//
// One glyph is the honest measure - every value is a single line, so
// the tallest thing in it is one character. Centre THAT in the tile.
// TILE_TEXT_NUDGE is the last word: sprite-font glyph art rarely fills
// its cell evenly top and bottom, and no arithmetic can know by how
// much. One number, and it is a pixel.
__val_y = function(_y, _sc) {
	return _y + (th - string_height("0") * _sc) * .5 + TILE_TEXT_NUDGE;
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
		// the LIVE figure - base x flux, floored - so the face is what
		// the tile pays (tile_out; the tick sums the same)
		var _g = tile_out(_t.tier[_i]);
		col[_i] = tile_color(_t.tier[_i]);
		// value text color, Myriad's update_mod_color recipe: the tier
		// hue with saturation floored at 100 and value floored at 190,
		// so the number always reads bright against the dark tile
		if (_t.tier[_i] <= 1) txtcol[_i] = c_white;
		else txtcol[_i] = make_colour_hsv(colour_get_hue(col[_i]),
			clamp(colour_get_saturation(col[_i]), 100, 255),
			clamp(colour_get_value(col[_i]), 190, 255));
		val_str[_i] = "+" + crunch_arb(_g);
		// Myriad's fit rule: scale down when the string is wider than
		// the tile (fractional scale - it's what the original did).
		//
		// ⚖️ AGAINST THE FOOTPRINT, NOT THE BOX (2026-09-09). A diamond
		// is a full tile wide only along its centre line; a number set
		// to the box's width spills past its points, which is what the
		// screenshot showed. So each shape declares how much of the
		// width is usable at the number's height, and the fit uses
		// that. The rectangle keeps the old rule exactly.
		var _sw = string_width(val_str[_i]);
		var _fit = tw - 1;
		// (the accretion scheme keeps the rectangle's footprint - the
		// details live in the 2px margins the number never reaches)
		if (TILE_SHAPES)
		switch ((_t.tier[_i] - 1) % 6) {
			case 2: _fit = tw * .62; break;   // diamond
			case 3: _fit = tw * .84; break;   // ellipse
			case 4: _fit = tw * .80; break;   // hexagon
			case 5: _fit = tw * .86; break;   // octagon
		}
		val_sc[_i] = (_sw > _fit) ? _fit / _sw : 1;
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
