/// syst_gift_panel - THE DAILY GIFT, as a panel over whatever room you
/// are standing in (Techdemo II's rm_dailygift / syst_rm_gift, ported
/// 2026-09-10 onto RX's overlay contract - settings, statistics and the
/// time bank's shape: gift_open is the one door, the burger's X and
/// escape close it through ui_overlay_close, syst_input holds the room
/// quiet, ui_blur_tick softens it behind).
///
/// The data lives in g.gift via gift_init/gift_config (THE file to tune
/// - board length, rarity ladder + odds, reward bases, level curve);
/// this panel is pure view. Top to bottom: the 14-slot fortnight board
/// (two rows of seven day cards, each wearing its rolled rarity
/// colour), the TODAY spotlight card (the next slot blown up: rarity
/// pill + the exact reward it pays), the COLLECT button under it (the
/// effects on the collect - motes into the header counter, a reward
/// float, the punched card flashes), and the footer (gift level +
/// progress bar + reward output, and the countdown to the next
/// calendar day). One collect per real day; missed days just wait (no
/// reset). Everything but the four saved numbers derives at read time
/// - the board itself re-rolls from (cycle, slot) seeds.
///
/// The parts deal in with the settings recipe (__part / __part_end -
/// ui_anim_in with an index each, ui_fade_set for the alpha).

gift_init();
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by gift_close; the Step destroys at zero

bby = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar

// the board cache: stable within a cycle; the claim flow re-pulls it
// when slot 14 rolls a fresh cycle
board = gift_board();

// collect feedback: the spotlight flushes in the reward's colour and
// the punched calendar card flashes with it
flash = 0;
flash_col = c_white;
slot_flash = -1;

// ---- layout (one screen, no scroll - and BOTH orientations: the
// panel opens over the money room, which is 480x270 or 144x296) ----
// ⚖️ THE OVERHAUL (his ask, 2026-09-12: "more polished, cleaner and
// easier on the eyes"). Three things, stacked, on one centre line: the
// fortnight BOARD (7 x 2 day cards - bevelled capsules in their
// rarity colour, the day number and a rarity mark, nothing else), the
// TODAY card (day, rarity, reward, and the collect button INSIDE it -
// the card is the action; collected, it carries the countdown
// instead), and one FOOTER line (the level, its progress, the output
// bonus). The strip carries the title alone.
land = (room_width > 300);
// fortnight grid: 7 x 2 day cards
card_w = land ? 58 : 18; card_h = land ? 26 : 18;
gap_x  = land ? 4 : 2;   gap_y = land ? 4 : 2;
cal_x = (room_width - (7 * card_w + 6 * gap_x)) div 2;
cal_y = bby + 22;

// the today card, with its collect button inside
spot_w = land ? 210 : 128; spot_h = land ? 96 : 100;
spot_x = (room_width - spot_w) div 2;
spot_y = cal_y + 2 * card_h + gap_y + 12;
btn_w = land ? 110 : 96; btn_h = 16;
btn_x = (room_width - btn_w) div 2;
btn_y = spot_y + spot_h - btn_h - 8;

// the footer line: the level bar and its two labels
foot_y = spot_y + spot_h + (land ? 12 : 10);
bar_w  = land ? 200 : 76;
bar_x  = (room_width - bar_w) div 2;

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
