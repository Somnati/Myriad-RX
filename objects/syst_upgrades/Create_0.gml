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

bby    = obj_ui_header.sprite_height;
list_y = bby + 16;
row_h  = 16;
row_sp = 19;
row_x  = 8;
row_w  = room_width - 16;

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
hold_i    = -1;   // the slot filling, -1 = none
hold_hp   = 0;    // 0..100
hold_spd  = 1;    // DE's hp_spd: the repeat ramp, 1..7
hold_lock = false;  // set when a hold completes something that must not
                    // repeat (DE's `hp = -1`), cleared on release

__row_y = function(_i) { return list_y + 6 + _i * row_sp; };

// the row's one button, right-aligned so every row's action sits in the
// same column no matter how long its name is. An EMPTY row has none any
// more - see __roll_rect.
__btn = function(_i) {
	return { x : row_x + row_w - 56, y : __row_y(_i) + 2, w : 54, h : 13 };
};

// THE ONE ROLL BUTTON (his call), under the table. Eight identical
// [roll] buttons in a column was eight controls for a decision that has
// no per-row content: a roll does not care WHICH empty slot it lands
// in, so making the player pick one was asking a question with no
// answer. One button, and it fills the first slot that is free.
__roll_rect = function() {
	return { x : row_x, y : __row_y(upgrade_slots()) + 2, w : 118, h : 15 };
};

// the slot a roll would land in: the first free one, top down, so the
// table fills in reading order. -1 = the table is full.
__free_slot = function() {
	for (var _i = 0; _i < upgrade_slots(); _i++)
		if (!is_struct(g.upg.slot[_i])) return _i;
	return -1;
};

// the mode pills, in the title strip beside the screen's name
__mode_rect = function(_m) {
	return { x : 62 + _m * 38, y : bby + 3, w : 34, h : 11 };
};

__back_rect = function() {
	return { x1 : room_width - 62, y1 : bby + 6, x2 : room_width - 6, y2 : bby + 22 };
};

// the rarity's name and colour, both from upgrade_rarity_info - which
// is now the ONE ladder. These were a private pair of tables here, and
// the statistics screen needed the same two answers; a second copy of a
// ladder is a second order for it to be in, and this one had elite and
// legendary the wrong way round against DE's.
__rar_name = function(_r) { return upgrade_rarity_info(_r).name; };
__rar_col  = function(_r) { return upgrade_rarity_info(_r).col;  };

// a slot's effect, as the one string the row has room for
__eff_str = function(_s) {
	var _sfx = (_s.id == "crit_multi") ? "x" : "%";
	if (_s.tier > 0)
		return "+" + string_format(_s.val * _s.tier, 1, 2) + _sfx;
	return "+" + string_format(_s.val, 1, 2) + _sfx;
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
__dots = function(_i, _ry) {
	var _s = g.upg.slot[_i];
	if (!is_struct(_s)) return;
	var _cap = upgrade_cap(_i);
	if (_cap <= 1) return;
	if (_s.tier >= _cap) return;

	var _dx = row_x + 7;
	var _dy = _ry + row_h - 2;
	for (var _d = 0; _d < _cap; _d++) {
		var _on = (_s.tier > _d);
		draw_sprite_ext(spr_pixel_1x1, 0, _dx, _dy, 3, 3, 0,
			_on ? c_lavender : merge_colour(c_lavender, c_black, .72), 1);
		_dx += 4;
	}
};

upgrade_init();
