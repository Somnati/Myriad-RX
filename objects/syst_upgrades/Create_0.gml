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

__row_y = function(_i) { return list_y + 6 + _i * row_sp; };

// the row's one button, right-aligned so every row's action sits in the
// same column no matter how long its name is
__btn = function(_i) {
	return { x : row_x + row_w - 56, y : __row_y(_i) + 2, w : 54, h : 13 };
};

// the mode pills, in the title strip beside the screen's name
__mode_rect = function(_m) {
	return { x : 62 + _m * 38, y : bby + 3, w : 34, h : 11 };
};

__back_rect = function() {
	return { x1 : room_width - 62, y1 : bby + 6, x2 : room_width - 6, y2 : bby + 22 };
};

// the rarity's name and colour. RX already carries DE's whole rarity
// palette, so both of these are lookups rather than new colours to
// invent for one screen.
__rar_name = function(_r) {
	var _t = ["common", "uncommon", "rare", "epic", "legendary", "elite", "ultimate"];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
};
__rar_col = function(_r) {
	var _t = [c_rarity_common, c_rarity_uncommon, c_rarity_rare, c_rarity_epic,
		c_rarity_legendary, c_rarity_elite, c_rarity_ultimate];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
};

// a slot's effect, as the one string the row has room for
__eff_str = function(_s) {
	var _sfx = (_s.id == "crit_multi") ? "x" : "%";
	if (_s.tier > 0)
		return "+" + string_format(_s.val * _s.tier, 1, 2) + _sfx;
	return "+" + string_format(_s.val, 1, 2) + _sfx + " / tier";
};

upgrade_init();
