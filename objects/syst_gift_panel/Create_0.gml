/// syst_gift_panel - THE DAILY GIFT, remodelled (his ask, 2026-09-12,
/// off his concept board: "a vibe not a copy"). ONE CARD. The reward
/// is the headline - the amount, big, in the one accent the card has
/// (THE REWARD'S colour: profit's, or credits' lavender - a common
/// gift is most days and a white card every day read as no card at
/// all, his screenshot); the rarity is the coloured WORD under it; the
/// fortnight is a ROW OF FOURTEEN MARKERS, collected ones ticked with
/// Myriad's check (spr_check), today's ringed and breathing, the days
/// ahead hollow with a pip in the rarity they will pay; the action is
/// one button across the foot of the card, and the level is a run of
/// small segments under it. Gold for the level, the rarity for its
/// word, and otherwise one colour.
///
/// The data lives in g.gift via gift_init/gift_config (THE file to
/// tune - board length, rarity ladder + odds, reward bases, level
/// curve); this is pure view. One collect per real day; missed days
/// wait. Collected, the card turns to TOMORROW's gift and the button
/// row becomes the countdown - the card always shows the next thing.
/// On the overlay contract every panel shares (oa / closing,
/// ui_overlay lists it, ui_blur_tick softens the room behind, the
/// burger's X and escape close it). Both orientations.

gift_init();
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by gift_close; the Step destroys at zero

bby = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar

// the board cache: stable within a cycle; the claim flow re-pulls it
// when slot 14 rolls a fresh cycle
board = gift_board();

// collect feedback: the card flushes in the accent and the punched
// marker flashes with it
flash = 0;
flash_col = c_white;
slot_flash = -1;

// ---- layout: one card, centred (the money room is 480x270 or 144x296) ----
// (round 2, his screenshot: the card was too wide for what it held -
// the headline sat alone on the left with nothing across from it -
// and the days ahead vanished into the plate. Tighter card, the
// income line ACROSS from the amount, hollow markers with pips)
land = (room_width > 300);
cw = land ? 226 : (room_width - 12);
ch = land ? 126 : 140;
cx = (room_width - cw) div 2;
cy = land ? (bby + 16 + ((room_height - bby - 16) - ch) div 2) : (bby + 30);
pad = land ? 12 : 8;

// the rows inside the card (from its top edge)
y_cap  = 8;                       // "gift 8 of 14 - tomorrow"
y_big  = land ? 20 : 22;          // the amount, tripled (doubled in portrait)
big_sc = land ? 3 : 2;
y_lab  = land ? 46 : 42;          // "profit - rare"
y_sub  = land ? 24 : 52;          // "4m of income / at the current rate" (across from the amount in landscape)
y_mark = land ? 64 : 68;          // the fourteen markers
mk     = land ? 11 : 8;           // a marker's size
mk_gap = land ? 4 : 1;
y_rule = land ? 84 : 88;          // the hairline
y_btn  = land ? 90 : 96;          // the action row
btn_h  = 18;
y_lv   = land ? 113 : 124;        // the level line

// the region law: the Step's hits and the Draw share these
__btn_r  = function() { return { x : cx + pad, y : cy + y_btn, w : cw - pad * 2, h : btn_h }; };
__card_r = function() { return { x : cx, y : cy, w : cw, h : ch }; };
__mark_x = function(_i) {
	var _n = g.gift_cfg.days;
	var _row = _n * mk + (_n - 1) * mk_gap;
	return cx + (cw - _row) div 2 + _i * (mk + mk_gap);
};

/// @func __part(i)
/// @desc Seat part i for the open animation: a slide up into place and
///       a fade, both off ui_anim_in(oa, i). Returns the ease so the
///       caller can skip a part that has not started. Pair with
///       __part_end().
__part = function(_i) {
	var _e = ui_anim_in(oa, _i);
	if (_e < .001) return 0;
	var _o = (1 - _e) * UI_IN_DEAL;
	if (_o != 0) matrix_set(matrix_world, matrix_build(0, _o, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_e);
	return _e;
};
__part_end = function() {
	ui_fade_set(1);
	matrix_set(matrix_world, matrix_build_identity());
};
