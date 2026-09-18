/// rm_dimensions - the antimatter-dimensions DEBUG BENCH (his ask):
/// 8 tiers where the 1st produces DARK MATTER and every tier above produces
/// the tier below, per-10 doubling on bought units, tickspeed as the
/// global compounding knob - the whole cascade advanced by dims_tick's
/// EXACT closed form off a wall-clock stamp, so leaving the room, the
/// game, or the planet costs nothing: offline == online is an identity
/// here, not an approximation (the point of the bench - his AD offline
/// accuracy question, answered by construction). the CANDIDATE resin
/// multiplier is displayed but NOT wired into the economy - that
/// decision is his, later. data: g.dims (dims_init), saved in section
/// "dimensions"; this room is pure view + shop.

dims_init();

bby = obj_ui_header.sprite_height;
list_y = bby + 38;
row_h = 20;

buy_q = 1; // buy quantity: 1 / 10 / 100 / "max" (dropdown below the strip)

// the room's own welcome-back line (his call: per-room reports) -
// Step fills it when the catch-up tick covers a real absence
report = undefined;
rep_t = 0;

// the buy-quantity dropdown owner (the house pillbox pattern)
pillbox_init();
pill_kind = "";

buy_w = 74;
buy_x = room_width - buy_w - 6;

// tier identities: a hue ramp, the original's rainbow ladder
tier_col = array_create(8);
for (var _i = 0; _i < 8; _i++)
	tier_col[_i] = make_colour_hsv((10 + _i * 27) mod 256, 170, 235);

// ordinals for the row names
tier_name = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"];

// LOG10 values in scientific dress (the whole bench lives in log
// space now - the float era drowned in inf/NaN past 1.8e308, his
// report; see dims_init). takes a log10 value, prints the number
__fmt = function(_lv) {
	if (_lv <= -8) return "0"; // the lz sentinel (and true dust)
	if (_lv < 3) {
		var _v = power(10, _lv);
		return string(round(_v * 10) / 10);
	}
	var _e = floor(_lv);
	var _m = round(power(10, _lv - _e) * 100) / 100;
	if (_m >= 10) { _m /= 10; _e++; } // 9.999 rounds up a decade
	return string(_m) + "e" + string(_e);
};

// the candidate multiplier, DISPLAY ONLY: a log lane so the cascade's
// explosion lands as a sane resin factor. dark matter IS its own log10 now
__cand = function() {
	return 1 + max(0, g.dims.dark) * .1;
};

__row_y = function(_i) { return list_y + _i * row_h; };

// seconds -> h:mm:ss for the run clock / best time
__hms = function(_s) {
	_s = max(0, floor(_s));
	var _m = string((_s div 60) mod 60);
	if (string_length(_m) < 2) _m = "0" + _m;
	var _c = string(_s mod 60);
	if (string_length(_c) < 2) _c = "0" + _c;
	return string(_s div 3600) + ":" + _m + ":" + _c;
};

// the infinity banner geometry - Step's crunch hit test and Draw's
// button MUST share these (region pattern: geometry matches owner)
inf_bx = room_width * .5 - 150;
inf_by = 104;
inf_bw = 300;
inf_bh = 66;
crunch_x = room_width * .5 - 50;
crunch_y = 146;
crunch_w = 100;
crunch_h = 16;
