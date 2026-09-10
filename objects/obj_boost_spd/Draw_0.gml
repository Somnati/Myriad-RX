if (alpha <= .002) exit;
if (!variable_global_exists("timebank")) exit;

// DE's three layers, verbatim: the plate in black, the walking chevrons
// in white, and the seagreen fill across the plate - DE's boost time
// left; here the bank against its cap
draw_sprite_ext(spr_boost_spd, 0, x, y, 1, 1, 0, c_black, .5 * alpha);
draw_sprite_ext(spr_boost_spd, ani + 1, x, y, 1, 1, 0, c_white, alpha);
var _cap = timebank_cap();
var _f = (_cap > 0) ? clamp(g.timebank.bank / _cap, 0, 1) : 0;
draw_sprite_general(spr_boost_spd, 0, 0, 0,
	sprite_get_width(spr_boost_spd) * _f, sprite_get_height(spr_boost_spd),
	x, y, 1, 1, 0, c_seagreen, c_seagreen, c_seagreen, c_seagreen, .3 * alpha);
