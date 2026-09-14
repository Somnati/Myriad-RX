/// menu v2: the navigation drawer. spawned by obj_ui_menu2 (the
/// morphing trigger), mirrors its `open` flag, folds away when it
/// clears.
///
///  - content is DECLARED: menu2_content() replays menu2_section /
///    menu2_button calls - adding a destination is one line
///  - side drawer sliding in from the right: pinned profile/gold
///    header, sectioned list (drag-scroll + wheel when it outgrows
///    the room), pinned "time played" foot
///  - the menu blur is PERSISTENT: rooms without a "menu_blur" fx
///    layer get one built at runtime, so every room now and forever
///    blurs behind the menu
///  - pc + mobile: taps register on RELEASE with a small drag budget
///    (touch-list semantics), escape closes on pc
///  - one geometry authority (__layout) feeds both the draw and the
///    hit tests, so clicks can never drift from pixels
///
/// the old obj_ui_menu/_handler system is untouched; the header
/// spawns this one, swap its create line back to return.

depth = -520; // above the blur layer (-500): the panel stays sharp

// THE DIAL DRAWER'S GLASS (his ask, 2026-09-13: "give the menu buttons the
// back shader the dial drawer has"): the room behind the panel PIXELATED
// (pixel_snap 3 room px a block, rims softened 4x) under a light dim. The
// capture is an obj_draw_proxy slot placed JUST BEFORE the blur layer
// (-499, the blur is -500) so the blocks are cut from the SHARP room - the
// dial drawer's own look, not blocks of a blur; with an overlay up it
// moves to -514, after the overlay (-510) and before its blur (-515), so
// the glass shows the panel you are standing in front of. Room-scoped;
// the Step keeps it alive and seated. The plate stands in on any frame
// without a shot.
snap_px = noone;
snap_ok = false;
__snap_cap = function() {
	snap_ok = (am > .002) ? pixel_snap(3, 4) : false;
};
open = true;
am = 0; // fold, 0..1

// (the blur is ui_blur_tick's now, off system's Begin Step: three
// things sit over the room and only one of them was building it here)

// ---- the real scrollbar (his ask, 2026-09-08) ----
// The drawer used to scroll with its own drag maths and draw a 2px
// whisper for a bar, which snapped: no inertia, no grab, and nothing
// telling you how much list there was. obj_scrollbar already does all
// three for settings and statistics, so it does them here too - lane
// scrl_menu2, pixel mode.
//
// It has to live above the menu's own input block (the drawer raises
// one) and ride panel_x, because unlike every other bar in the game
// this one's owner MOVES.
sb = create_obj(0, 0, obj_scrollbar);
sb.i        = scrl_menu2;
sb.in_menu  = true;
sb.ui_layer = ui_layer_menu;
sb.depth    = depth - 1;
// THE DRAWER DOES ITS OWN LIST DRAGGING, so the bar keeps the grab and
// gives up the rest: two drag paths writing one scroll value is double
// speed at best, and its touch bounds are screen-wide, which over a
// right-edge panel is the whole room.
sb.touch_scroll = false;

// the dark backing lives BEHIND the blur so the gaussian smooths it
// (ui_blur_tick spawns it too - one is enough, two is double the plate)
if (!instance_exists(obj_menu2_bck)) create_obj(0, 0, obj_menu2_bck);

// ---- the registry ----
btns = [];
secs = [];
cur_sec = "";
menu2_content();

// ---- interaction state ----
tic = 0;
scr = 0;          // list scroll
scr_max = 0;
pressed = false;
lmy = 0;          // last mouse y (drag-scroll delta)
panel_x = room_width;
pw = 148;         // panel width. EVERYTHING in the drawer anchors to
	// panel_x + offset within this width (never to room_width): the
	// drawer slides as one RIGID unit, so the close animation carries
	// rows, foot text and scrollbar off-room together. right-edge
	// anchoring made rows shrink into the room edge mid-slide and the
	// time text sit still (his 2026-07-12 report)
hdr_h = 44;       // pinned header band
foot_h = 20;      // pinned time-played band. It held profit AND the
                  // clock side by side; profit is gone (his call - the
                  // header carries it everywhere anyway) so the band
                  // needs one line less and the list gets the 6px.

// THE ROW WIDTH (his ask, 2026-09-04): nav rows are only as wide as the
// LONGEST menu label plus room, and they sit against the panel's RIGHT
// edge - the menu then reads as a column of names instead of a stack of
// full-width slabs.
// Measured ONCE and cached: menu2_content is static, and __layout runs
// in BOTH Step (hit tests) and Draw (pixels). Measuring under whatever
// font the previous event happened to leave set would let those two
// disagree, which the one-geometry-authority rule exists to prevent - so
// the measure sets the house font itself and puts back what was there.
// what the scrollbar lane reads (pixel mode): the content height and
// the height of the band it scrolls through. Published from __layout,
// which is the only thing that knows either.
scr_ch   = 0;
scr_band = 1;

// per-BUTTON hover ease, indexed by the button's own index so it
// survives the list being rebuilt every frame. The gradient wipe reads
// off it (see the Draw) - one number, eased, rather than a boolean that
// snaps the colour on the frame the pointer arrives (his report).
hov = array_create(array_length(btns), 0);

btn_w = -1;       // -1 = not measured yet
__btn_w = function() {
	if (btn_w > 0) return btn_w;
	var _f = draw_get_font();
	draw_set_font(fnt);
	var _m = 0;
	for (var _i = 0; _i < array_length(btns); _i++)
		_m = max(_m, string_width(btns[_i].name) + ((btns[_i][$ "key"] ?? "") != "" ? string_width(" new") + 4 : 0));
	// ⚖️ THE CLOCK IS PART OF THE MEASURE. The panel derives from this
	// number, and the foot band has to hold "00d 00h 00m 00s +00h" - so
	// if only the labels were measured, a short roster would shrink the
	// drawer until the time played clipped off its own edge. Measured
	// against the WIDEST form the string can take rather than today's
	// value, which is two digits shorter and would clip on day 100.
	_m = max(_m, string_width("00d 00h 00m 00s +00h") - 12);
	draw_set_font(_f);
	// 9px text inset + the label + room past it: the "you are here"
	// pip lives in the row's last 7px and must not touch the text
	// ⚖️ NO PANEL CAP ANY MORE. This used to be min(pw - 12, ...): the
	// rows fitted a 148px panel that had been picked by hand. The panel
	// derives from the ROWS now (see __layout), so the measure is free
	// to be exactly what the longest label needs - a drawer this wide
	// was mobile thinking on a control that is only ever used with a
	// mouse (his call, 2026-09-08).
	btn_w = ceil(_m) + 20;
	return btn_w;
};

__ease = function(_v) {
	return _v * _v * (3 - 2 * _v);
};

// rooms may pin a side rail beside the drawer (pool's left panel,
// round 4): a tap inside the registered guard rect is the rail's
// business, never "outside, close". the guard carries its room so a
// stale registration can't leak into other rooms
__guarded = function() {
	if (!variable_global_exists("menu2_guard")) return false;
	var _g2 = g.menu2_guard;
	if (_g2 == undefined || !in_room(_g2.rm)) return false;
	return point_in_rectangle(mousex, mousey, _g2.x1, _g2.y1, _g2.x2, _g2.y2);
};

// current room's display name (falls back to the raw room name)
__here_name = function() {
	for (var _i = 0; _i < array_length(btns); _i++)
		if (!is_method(btns[_i].rm) && btns[_i].rm == room)
			return btns[_i].name;
	return room_get_name(room);
};

// playtime as "00d 00h 00m 00s"
__playtime_str = function() {
	var _t = variable_global_exists("time_played_active") ? floor(g.time_played_active) : 0;
	var _dd = _t div 86400;
	var _hh = (_t div 3600) mod 24;
	var _mm = (_t div 60) mod 60;
	var _ss = _t mod 60;
	// ONLY THE UNITS THAT HAVE A VALUE (his call 2026-09-06): a save
	// three hours old reads "03h 12m 40s", not "00d 03h 12m 40s". Once
	// a unit is in, every smaller one follows it in - "01d 00h 05m" is
	// right, because the zero hours are real there.
	var _o = "";
	if (_dd > 0) _o += ((_dd < 10) ? "0" : "") + string(_dd) + "d ";
	if (_o != "" || _hh > 0) _o += ((_hh < 10) ? "0" : "") + string(_hh) + "h ";
	if (_o != "" || _mm > 0) _o += ((_mm < 10) ? "0" : "") + string(_mm) + "m ";
	return _o + ((_ss < 10) ? "0" : "") + string(_ss) + "s";
};

// ONE geometry authority: items = {kind, idx, name, col, x1,y1,x2,y2}
// kind 0 = nav button, 2 = section label. draw and hit-test both call
// this, so they can never disagree
__layout = function() {
	var _it = [];
	var _n = array_length(btns);
	// ⚖️ THE PANEL DERIVES FROM THE ROWS (his call): width = the longest
	// label's row plus a 1px gap on each side. It was a hand-picked
	// 148px, which is a phone's drawer on a control that is only ever
	// driven with a mouse - and a wide panel with narrow rows in it left
	// a column of dead teal doing nothing but taking the room away.
	//
	// Set HERE rather than in the Create because __layout runs in both
	// Step and Draw every frame, so pw can never be stale, and because
	// __btn_w needs the font measured before there is a width to derive.
	// +3 for the gaps: 2px on the LEFT of the rows (his measure) and 1px
	// on the right. Plus the scrollbar's own width, because the bar is
	// tied to the drawer's right edge (his call) and the rows must not
	// run under it - so the panel grows by exactly the bar rather than
	// the rows shrinking to make room.
	pw = __btn_w() + 3 + sprite_get_width(spr_scrollbar);
	var _pw = pw;
	panel_x = room_width - _pw * __ease(am);
	var _top = hdr_h + 2;
	var _bot = room_height - foot_h - 2;
	var _bh = 14;   // ROW HEIGHT IS NOT NEGOTIABLE: the room scales
	                // wholesale, so 14px lands around 56 real px on a
	                // 1080p phone - over the 44px touch minimum. The
	                // overhaul (2026-09-08) changed what is drawn inside
	                // these boxes, never the boxes.
	var _gap = 2;
	var _sh = 17;   // section labels. GROUPING IS WHITESPACE, not rules:
	                // with fourteen destinations at one weight nothing is
	                // findable, and six extra pixels above each heading
	                // chunks the list without adding a single line of
	                // chrome. The label draws at the BOTTOM of this band
	                // so the space lands above it, where it groups.
	var _lh = 10; // info label rows (menu2_label) run tighter
	// content height, for the scroll clamp (labels count separately)
	var _nl = 0;
	for (var _i = 0; _i < _n; _i++)
		if (btns[_i][$ "lbl"] ?? false) _nl++;
	var _ch = (_n - _nl) * (_bh + _gap) + _nl * (_lh + _gap)
		+ array_length(secs) * _sh;
	scr_ch   = _ch;         // the scrollbar lane reads both of these
	scr_band = max(1, _bot - _top);
	scr_max = max(0, _ch - (_bot - _top));
	scr = clamp(scr, 0, scr_max);
	var _y = _top - scr;
	var _sec = "";
	// ONE left edge for the whole column - buttons, info labels and the
	// section headers above them - so the group holds together when it
	// moves right. The section's rule still runs out to the panel edge.
	var _bw  = __btn_w();
	// the rows stop short of the bar, which owns the panel's right edge
	var _rx2 = panel_x + _pw - 1 - sprite_get_width(spr_scrollbar);
	// ⚖️ THE ROOM YOU ARE IN IS WIDER (his ask). Every other row gives up
	// HERE_TRIM px from its left edge, and the current one keeps the full
	// width - so "here" is a shape you can find without reading, and the
	// panel does not have to grow to hold the difference. Sections and
	// info labels stay on the short edge with the rows they head.
	var _rx1 = _rx2 - (_bw - MENU_HERE_TRIM);
	for (var _i = 0; _i < _n; _i++) {
		// x2 anchors to panel_x + _pw (== room_width when fully open,
		// identical geometry) so rows RIDE the slide instead of
		// shrinking against the room edge while closing
		if (btns[_i].sec != _sec) {
			_sec = btns[_i].sec;
			array_push(_it, { kind : 2, idx : -1, name : _sec, col : c_white,
				x1 : _rx1, y1 : _y, x2 : _rx2, y2 : _y + _sh });
			_y += _sh;
		}
		// kind 3 = info label (menu2_label): dim text, never a tap
		if (btns[_i][$ "lbl"] ?? false) {
			array_push(_it, { kind : 3, idx : _i, name : btns[_i].name, col : btns[_i].col,
				x1 : _rx1 + 3, y1 : _y, x2 : _rx2, y2 : _y + _lh });
			_y += _lh + _gap;
			continue;
		}
		// the current room's row reaches further left than its neighbours
		var _hx1 = _rx1;
		if (!is_method(btns[_i].rm) && in_room(btns[_i].rm)) _hx1 = _rx2 - _bw;
		array_push(_it, { kind : 0, idx : _i, name : btns[_i].name, col : btns[_i].col,
			x1 : _hx1, y1 : _y, x2 : _rx2, y2 : _y + _bh });
		_y += _bh + _gap;
	}
	return _it;
};
