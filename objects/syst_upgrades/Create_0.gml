/// rm_upgrades' controller. The settings/statistics/saves shape again -
/// header, title strip, then rows - because this is the fourth menu
/// screen and a fourth layout would be a fourth thing to learn.
///
/// THE SCREEN IS THE SLOTS. One row per slot, and a row is in exactly
/// one of three states:
///   EMPTY   nothing here - [roll] draws an offer
///   OFFER   rolled, tier 0, not yet owned
///   OWNED   tier 1+
///
/// ⚖️ ONE BUTTON A ROW, AND A MODE TOGGLE ABOVE (his call, DE's shape).
/// The first cut gave every row a buy button AND a sell button, which
/// is two controls competing for the same glance on every line of an
/// eight-line list - and the second one is used perhaps once an hour.
/// A [buy]/[sell] toggle moves that decision UP a level: the row shows
/// one price and does one thing, and the rare action is a mode you
/// enter deliberately rather than a button you can hit by accident next
/// to the one you meant.
///
/// AND A ROW IS ONE LINE. It was two, at 38px, which put eight slots
/// off the bottom of a 270-tall room; at 19px the whole table fits with
/// room under it. Everything that was on the second line - the help
/// text, the per-tier value - either fits on the first or was only ever
/// restating the name.
///
/// ⚖️ THE OVERHAUL (his ask, 2026-09-11: "clean, easy on the eyes and
/// polished with a well laid out minimal look"). TWO COLUMNS AND
/// NOTHING ELSE: the table on the left, the inspector on the right, the
/// bonus totals in a band under the table, the purse in the corner.
/// What went: the rarity gradient wash across every row (the 3px band
/// carries the rarity now, and the inspector names it), the rarity
/// name and the "3 / 5" text columns (the dots under the name say it),
/// the separate roll button (the FIRST EMPTY ROW is the roll row), the
/// status line under the table (messages live in the title strip and
/// fade), and the three-line footer (two tidy lines of six totals).
/// A row says four things: what, how much, how deep, and the price.

// AN OVERLAY, NOT A ROOM (his ask, 2026-09-12): spawned over whatever
// room you stand in by upgrades_open, on the contract every panel
// shares - oa / closing, ui_overlay lists it, ui_blur_tick softens the
// room behind, the burger's X and escape close it. No back button.
depth   = -510;   // over the room and its drawers, under the menu (-520) and the header (-1000)
oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by upgrades_close; the Step destroys at zero

bby    = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar
list_y = bby + 16;
row_h  = 18;    // name on the top line, the tier dots under it
row_sp = 21;
land   = (room_width > 300);   // the money room is both orientations
// ⚖️ ROUNDED CORNERS (his ask: like the ability deck slots). The deck
// caps its bars with spr_dial_endcaps, a 3x11 sprite built for one
// exact capsule height - these rows are 16 tall, and scaling that
// sprite 11->16 turns a circular cap into a stretched ellipse on a
// fractional pixel grid. So the corners are CUT instead, from a
// hand-authored inset table, which is the same way the puck's disc and
// the settings "?" button are built: house rule, hard pixels only.
//
// One entry per row in from the edge, mirrored top and bottom.
// ⚖️ THE DECK'S BEVEL (his ask, 2026-09-12: "the style of slots the
// abilities use where they have bevelled sides"). spr_dial_endcaps is
// [3, 1, 1] - the cap's top row sits three in, the next two one in,
// then full - and this table is that silhouette, so an 18-tall row
// ends the way an 11-tall deck capsule does. The fill is the deck's
// too: the rarity colour at the left edge fading to near-black at the
// right (see the Draw).
ROUND = capsule_bevel(row_h);   // [6, 4, 3, 2, 1, 1] at 18 - the round end

/// @func __rr(x, y, w, h, col, alpha)
/// @desc A rounded-corner filled rect. Three bands rather than one draw
///       per row: the corner rows are two 1px strips each and
///       everything between them is a single tall strip, so a rounded
///       row costs five draws instead of sixteen.
__rr = function(_x, _y, _w, _h, _col, _a) {
	var _n = array_length(ROUND);
	for (var _k = 0; _k < _n; _k++) {
		var _in = ROUND[_k];
		if (_w - _in * 2 <= 0) continue;
		draw_sprite_ext(spr_pixel_1x1, 0, _x + _in, _y + _k,
			_w - _in * 2, 1, 0, _col, _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _x + _in, _y + _h - 1 - _k,
			_w - _in * 2, 1, 0, _col, _a);
	}
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + _n, _w, _h - _n * 2, 0, _col, _a);
};

/// @func __rr_grad(x, y, w, h, c_left, c_right, alpha)
/// @desc The same shape as a horizontal gradient. The corner rows carry
///       the ramp too - a gradient that squares off at the corners is
///       worse than no rounding at all, because the eye reads the two
///       shapes as misaligned rather than as one plate.
__rr_grad = function(_x, _y, _w, _h, _c1, _c2, _a) {
	var _n = array_length(ROUND);
	for (var _k = 0; _k < _n; _k++) {
		var _in = ROUND[_k];
		if (_w - _in * 2 <= 0) continue;
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _k, _w - _in * 2, 1, 0, _c1, _c2, _c2, _c1, _a);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _h - 1 - _k, _w - _in * 2, 1, 0,
			_c1, _c2, _c2, _c1, _a);
	}
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_x, _y + _n, _w, _h - _n * 2, 0, _c1, _c2, _c2, _c1, _a);
};

// THE TWO COLUMNS. The table takes the left 292, the inspector the
// rest, an 8px gutter between and around - one grid, every edge on it.
// Portrait stacks them: the table full width, the inspector under it
row_x  = 8;
row_w  = land ? 292 : (room_width - 16);

/// @func __inner(x, y, w, h, [col])
/// @desc THE OUTLINE METHOD (his ask, 2026-09-12): over a gradient
///       capsule, a black one a pixel inside it on the LEFT, TOP and
///       BOTTOM - not the right, where the gradient is black anyway -
///       so what is left of the gradient is a rim, brightest at the
///       left, fading along the edges, and the middle where the words
///       sit is black. The inspector and every row wear it.
__inner = function(_x, _y, _w, _h, _col = c_black) {
	draw_capsule(_x + 1, _y + 1, _w - 1, _h - 2, _col, _col, 1, capsule_bevel(_h - 2));
};

mode = 0;      // 0 = buy, 1 = sell
sel  = -1;     // the slot under the pointer, for the hover wash

// ---- THE HOLD-TO-SELL BAR (Myriad DE's obj_upgrade_slot hp) ----
// DE fills a bar across the row while the pointer is held on the
// button, at 100 units per 40 frames, and trickles it back to zero the
// moment you let go or slide off. The action fires when it lands.
//
// BOTH MODES, as DE has it. The two fills differ exactly as DE's do:
//   BUY   green, linear, and REPEATS while you keep holding - each
//         landed buy raises hold_spd so the next one arrives sooner,
//         to a ceiling of 7x. That is DE's bulk purchase: hold the
//         row and watch the tiers stack, faster and faster.
//   SELL  red, SQUARED, and once. A squared fill crawls at the start,
//         so a tap that was not meant to be a hold barely moves it -
//         the commitment is legible before it is irreversible - and
//         the slot empties, so there is nothing left to repeat on.
// ---- THE DESCRIPTION PANEL, bottom right (his ask) ----
// A row is one line, which is the right shape for SCANNING a table and
// the wrong shape for understanding one entry: there is no room on it
// to say what the thing actually modifies, what it is worth now, or
// what the rest of your table already gives you for the same stat. So
// tapping a row PICKS it and this panel answers all three, once, in the
// space under the table where nothing was using the pixels.
pick    = -1;
// THE INSPECTOR IS THE RIGHT COLUMN, top to bottom (the overhaul): it
// used to sit under the table and cover the eighth slot (his report)
desc_x  = land ? (row_x + row_w + 8) : row_x;
desc_w  = land ? (room_width - desc_x - 8) : row_w;
desc_y  = 0;   // seated below, once __row_y exists
desc_h  = 0;
// THE MODIFIERS LIST (DE's "view modifiers", his ask 2026-09-12): the
// totals used to sit in a band under the table; now a button opens
// them as a list over the panel, so the roster can grow without the
// screen running out of room. mod_a eases it in and out
mod_open = false;
mod_a    = 0;

// THE RARITY GRADIENT. A rung's colour bleeds in from the left edge,
// and BOTH how far it reaches and how strong it is scale with the rung
// - so a common is a hint and an ultimate is unmistakable across the
// room. Returns { w, col } for a panel of width _w.
__rar_grad = function(_rar, _w, _base_col) {
	var _t = clamp(_rar / max(1, UPG_RARITY_N - 1), 0, 1);
	// ⚖️ DE'S PROPORTION (his report, 2026-09-12: a common's rim should
	// barely wrap the left bevel). DE drew the outline cs = w x rung/10
	// / 1.5 wide - nothing for a common, 46% of the slot for the top
	// rung. 6% here (the bevel and a breath past it) to 60%
	return {
		w   : _w * (.06 + .54 * _t),
		col : merge_colour(_base_col, __rar_col(_rar), .12 + .34 * _t),
	};
};

/// @func __rr_grad_l(x, y, w, h, c_left, c_right, alpha)
/// @desc A capsule rounded on the LEFT only - the right edge straight -
///       filled left-to-right with a gradient. It is the piece the
///       rarity reach is painted with: it starts at the plate's left
///       end and stops partway along, inside the plate, where a round
///       right end would read as a second capsule.
__rr_grad_l = function(_x, _y, _w, _h, _c1, _c2, _a) {
	var _n = array_length(ROUND);
	for (var _k = 0; _k < _n; _k++) {
		var _in = ROUND[_k];
		if (_w - _in <= 0) continue;
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _k, _w - _in, 1, 0, _c1, _c2, _c2, _c1, _a);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			_x + _in, _y + _h - 1 - _k, _w - _in, 1, 0, _c1, _c2, _c2, _c1, _a);
	}
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_x, _y + _n, _w, _h - _n * 2, 0, _c1, _c2, _c2, _c1, _a);
};

/// @func __plate(x, y, w, h, rar, c_left, [strength])
/// @desc THE RARITY PLATE, DE's way (his ask, 2026-09-12): the outline's
///       coloured stretch is as LONG as the rarity is high. DE drew its
///       slot's outline frame `cs` wide - cs off the rarity - with a
///       gradient from the rarity colour out to the plate; here the
///       plate is near-black end to end, the rarity's colour is painted
///       from the left edge to __rar_grad's reach (28% of the width for
///       a common, 90% for an ultimate) fading into the plate, and the
///       inner black capsule (__inner) leaves only the rim of it
///       showing - so a common's rim colours its left end and an
///       ultimate's runs nearly the whole way round.
//       ⚖️ NOTHING BEYOND THE REACH (his report): the plate under the
///       rim is the inner capsule's own black, so past the coloured
///       stretch there is no line at all - the near-black plate the
///       first cut used showed as a faint grey outline all the way
///       round, the exact thing DE's short outline frame never had.
__plate = function(_x, _y, _w, _h, _rar, _c1) {
	__rr(_x, _y, _w, _h, c_black, 1);
	__rr_grad_l(_x, _y, __rar_grad(_rar, _w, c_black).w, _h, _c1, c_black, 1);
	__inner(_x, _y, _w, _h);
};

// ---- THE STATUS LINE ----
// This screen used the house banner, which stacks down the RIGHT edge
// from the top - directly over the eight rows it was reporting on. Its
// messages are about one screen and belong on it (assign_banner now
// refuses in this room entirely).
msg     = "";
msg_col = c_white;
msg_hp  = 0;
__say = function(_t, _c) {
	msg = _t;
	msg_col = _c;
	msg_hp = 150;   // ~2.5 seconds, then it fades on its own
};

hold_i    = -1;   // the slot filling, -1 = none
hold_hp   = 0;    // 0..100
hold_spd  = 1;    // DE's hp_spd: the repeat ramp, 1..7
hold_lock = false;  // set when a hold completes something that must not
                    // repeat (DE's `hp = -1`), cleared on release

// THE PURSE RIDES THE STRIP'S BOTTOM LINE (his ask, 2026-09-12: "the
// top pixel of the credit banner rests over the bottom grey line of the
// title panel"), so the table starts under it - 12px lower than the
// strip's own edge
purse_y = list_y;   // obj_display_credits draws from y - 1 (the Step pins it here)
__row_y = function(_i) { return list_y + 16 + _i * row_sp; };

// the inspector shares the table's top edge and runs to the bottom
// margin - the two columns are one rectangle cut in two. Portrait: it
// sits under the table, above the [modifiers] button
// ...the inspector's top is the strip's edge again (the purse only
// takes the table's column, so it left an awkward gap up here - his
// report 2026-09-12) and its bottom leaves room for [modifiers], which
// sits under it as the column's last row
desc_y = land ? (list_y + 5) : (__row_y(UPG_SLOT_MAX) + 4);
desc_h = (room_height - 8 - 14 - 6) - desc_y;

// the row's one button, right-aligned so every row's action sits in the
// same column no matter how long its name is. An EMPTY row has none any
// more - see __roll_rect.
__btn = function(_i) {
	return { x : row_x + row_w - 54, y : __row_y(_i) + 2, w : 52, h : 14 };
};

// THE ROLL ROW (his call: ONE roll control, not one per slot - a roll
// does not care WHICH empty slot it lands in). It IS the first empty
// row: the plate wears a blue frame and says "roll a slot" and the
// stake, and a tap anywhere on it rolls. No free slot, no roll row
__roll_rect = function() {
	var _fs = __free_slot();
	if (_fs == -1) return { x : -1, y : -1, w : 0, h : 0 };
	return { x : row_x, y : __row_y(_fs), w : row_w, h : row_h };
};

// the row's body - everything left of its button. Tapping HERE picks
// the row for the panel; tapping the button acts on it. Two meanings on
// one row, told apart by geometry rather than by a mode, because
// reading about a thing should never be able to buy it.
__body = function(_i) {
	var _b = __btn(_i);
	return { x : row_x, y : __row_y(_i), w : _b.x - row_x - 2, h : row_h };
};

// the slot a roll would land in: the first free one, top down, so the
// table fills in reading order. -1 = the table is full.
__free_slot = function() {
	for (var _i = 0; _i < upgrade_slots(); _i++)
		if (!is_struct(g.upg.slot[_i])) return _i;
	return -1;
};

// the mode switch: ONE segmented pill in the title strip after the
// name - [buy|sell], the live half filled. Two halves of one shape
// rather than two buttons, because it is one choice
// ...seated over the price column (his ask, 2026-09-12: "so it sits
// above the slots' buy button") - the choice sits over the thing it
// changes. The column is 52 wide at row_x + row_w - 54; the pill is 60
__mode_rect = function(_m) {
	return { x : row_x + row_w - 58 + _m * 30, y : bby + 2, w : 30, h : 12 };
};

// the [modifiers] button: the inspector column's last row, bottom
// right (his call, 2026-09-12 - the strip's right end left the
// inspector floating under a gap)
__mod_rect = function() {
	return { x : desc_x, y : room_height - 8 - 14, w : desc_w, h : 14 };
};

// the rarity's name and colour, both from upgrade_rarity_info - which
// is now the ONE ladder. These were a private pair of tables here, and
// the statistics screen needed the same two answers; a second copy of a
// ladder is a second order for it to be in, and this one had elite and
// legendary the wrong way round against DE's.
__rar_name = function(_r) { return upgrade_rarity_info(_r).name; };
__rar_col  = function(_r) { return upgrade_rarity_info(_r).col;  };

// a slot's effect, as the one string the row has room for
__eff_str = function(_i) {
	var _s = g.upg.slot[_i];
	var _sfx = (_s.id == "crit_multi") ? "x" : ((_s.id == "luck") ? " luck" : "%");
	if (_s.tier > 0)
		return "+" + string_format(
			upgrade_tier_value(_s.val, _s.tier, upgrade_cap(_i)), 1, 2) + _sfx;
	return "+" + string_format(_s.val, 1, 2) + _sfx;
};

// what the NEXT tier would add - the marginal value, which is the
// number a buy button is actually offering. It is not _s.val any more:
// the ramp makes each tier worth more than the last and the final one
// worth a great deal more, so "a tier" is a moving quantity and the
// screen has to quote the one being sold.
__next_str = function(_i) {
	var _s = g.upg.slot[_i];
	var _c = upgrade_cap(_i);
	if (_s.tier >= _c) return "";
	var _d = upgrade_tier_value(_s.val, _s.tier + 1, _c)
	       - upgrade_tier_value(_s.val, _s.tier, _c);
	return "+" + string_format(_d, 1, 2)
		+ ((_s.id == "crit_multi") ? "x" : ((_s.id == "luck") ? " luck" : "%"))
		+ ((_s.tier + 1 >= _c) ? " to finish" : " next");
};

// THE TIER DOTS (Myriad DE's bubbles, obj_upgrade_slot's Draw). One per
// tier the offer can ever take, lit for the ones bought - so how deep a
// slot goes is a thing you SEE rather than a fraction you read. They sit
// on the row's bottom edge and spill a pixel into the gap below it,
// which is DE's seat (y + sprite_height - 3) and reads as belonging to
// the row without eating a line of it.
//
// DE hides them on a finished upgrade and on a one-tier one, and both
// rules earn their keep: a full row of lit dots says nothing the tier
// column has not already said, and the eye should be drawn to the slots
// with something left in them.
//
// THE OVERHAUL SEATS THEM INSIDE THE ROW, on its second line under the
// name, in the slot's rarity colour - the row is 18 tall now and has a
// second line for exactly this, so nothing spills into the gap
//
// THE BUBBLES ARE DE'S (his ask, 2026-09-12 - the 3px dots were "very
// faint"): spr_achieve_bubble's frame, stamped - a 4x4 round dot with
// a black ring, on a 5px pitch so the ring of one touches the next, lit
// in the rarity colour for the tiers bought and sunk toward black for
// the rest. They sit on the row's second line under the name.
__bubble = function(_x, _y, _col, _a) {
	// the ring
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y - 1, 2, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 4, 2, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x,     _y,     1, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y,     1, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x,     _y + 3, 1, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y + 3, 1, 1, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x - 1, _y + 1, 1, 2, 0, c_black, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 4, _y + 1, 1, 2, 0, c_black, .9);
	// the dot
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y,     2, 1, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x,     _y + 1, 4, 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 3, 2, 1, 0, _col, _a);
};
__dots = function(_i, _ry) {
	var _s = g.upg.slot[_i];
	if (!is_struct(_s)) return;
	var _cap = upgrade_cap(_i);
	if (_cap <= 1) return;
	if (_s.tier >= _cap) return;

	var _rc = __rar_col(_s.rar);
	var _dx = row_x + 11;
	var _dy = _ry + 12;
	for (var _d = 0; _d < _cap; _d++) {
		var _on = (_s.tier > _d);
		__bubble(_dx, _dy, _on ? merge_colour(_rc, c_white, .2) : merge_colour(_rc, c_black, .7), _on ? 1 : .9);
		_dx += 5;
	}
};

// THE BEVELLED BUTTON (his ask, 2026-09-12): draw_ui_button's chrome
// - black face, a one-pixel frame in the colour, the centred label,
// primary at full strength and secondary a step dimmer, disabled grey
// - on the capsule shape: the frame is a coloured capsule with a black
// one a pixel inside it, the same outline the inspector wears
__btn_draw = function(_x, _y, _w, _h, _label, _col, _enabled = true, _primary = true) {
	draw_capsule(_x, _y, _w, _h, _col, _col, !_enabled ? .25 : (_primary ? .85 : .45));
	draw_capsule(_x + 1, _y + 1, _w - 2, _h - 2, c_black, c_black, _primary ? .92 : .8, capsule_bevel(_h - 2));
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(!_enabled ? c_gray : merge_colour(_col, c_white, _primary ? .4 : .25));
	draw_set_alpha(_primary ? .95 : .85);
	draw_text(_x + (_w div 2) + 1, _y + (_h - 7) div 2, _label);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
};

upgrade_init();
