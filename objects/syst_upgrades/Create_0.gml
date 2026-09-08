/// rm_upgrades' controller. The settings/statistics/saves shape again -
/// header, title strip, then rows - because this is the fourth menu
/// screen and a fourth layout would be a fourth thing to learn.
///
/// THE SCREEN IS THE SLOTS. One row per slot, and a row is in exactly
/// one of three states:
///   EMPTY   nothing here - [roll] draws an offer
///   OFFER   rolled, tier 0, not yet owned - [buy] takes it, [sell]
///           is dead because nothing was paid
///   OWNED   tier 1+ - [buy] levels it, [sell] refunds part and frees
///           the slot
/// That is Myriad DE's model kept whole. The scarcity of slots is what
/// makes any of it a decision; a shop with unlimited room to buy
/// everything is a list you work down.

bby    = obj_ui_header.sprite_height;
list_y = bby + 16;
row_h  = 34;
row_sp = 38;
row_x  = 8;
row_w  = room_width - 16;

sel = -1;      // the slot the pointer is over, for the hover wash

__row_y = function(_i) { return list_y + 6 + _i * row_sp; };

// the three buttons on a row, seated from the right edge so a row with
// two reads the same as a row with three
// x and width only - both callers supply their own row y, and a y here
// would be a second answer to a question they have already answered.
__btn = function(_i, _n) {
	var _w = 52, _g = 4;
	var _x = row_x + row_w - (_w + _g) * _n + _g;
	return { x : _x + (_w + _g) * _i, w : _w, h : 15 };
};

__back_rect = function() {
	return { x1 : room_width - 62, y1 : bby + 6, x2 : room_width - 6, y2 : bby + 22 };
};

// the rarity's name, for the row's label
__rar_name = function(_r) {
	var _t = ["common", "uncommon", "rare", "epic", "legendary", "elite", "ultimate"];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
};

// and its colour. RX already carries DE's whole rarity palette, so this
// is a lookup rather than a new set of colours to invent.
__rar_col = function(_r) {
	var _t = [c_rarity_common, c_rarity_uncommon, c_rarity_rare, c_rarity_epic,
		c_rarity_legendary, c_rarity_elite, c_rarity_ultimate];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
};

upgrade_init();
