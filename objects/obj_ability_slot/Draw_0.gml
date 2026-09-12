/// one deck row: a CAPSULE card (pixel stretch + the dial endcaps,
/// the same recipe as the pill buttons), rarity-tinted, toggle pip
/// on the RIGHT with the ap cost beside it, sub indent with a
/// connector, gold NEW badge, titles as right-aligned dividers

if (input == -1) exit; // nothing materialized here (past the deck end)

var _y = y + yos;
var _o = syst_rm_ability;
if (_o.view != 0) exit; // the collection view owns the list band
if (array_length(g.abi_draft) > 0) exit; // the draft owns the screen

// ---- edge fade: rows sliding past the list band melt into the
// black instead of blipping (Myriad's fade gradient, done as alpha
// since the backdrop IS black) ----
var _band_t = _o.list_y;
var _band_b = _o.list_y + _o.visible_rows * _o.row_h - 4;
var _fade = 1;
if (_y < _band_t) _fade = 1 - (_band_t - _y) / 12;
if (_y + 11 > _band_b) _fade = 1 - ((_y + 11) - _band_b) / 12;
_fade = clamp(_fade, 0, 1);
if (_fade <= 0) exit;
var _ea = alpha * _fade * ui_anim_in(_o.oa, 0); // every alpha below rides this - and the panel's ease

var _w = _o.list_w;
var _h = 11; // the capsule height the endcap sprites are built for

// the deck's rarity ladder (matches unlock_ability + the info panel)
var _rcol = [c_white, rgb(60, 255, 69), rgb(65, 122, 255),
	rgb(255, 167, 10), rgb(160, 32, 255)];

draw_set_font(fnt);

// ---- section title: a right-aligned divider ----
if (input == 3) {
	draw_set_alpha(.5 * _ea);
	draw_sprite_ext(spr_pixel_1x1, 0, x, _y + _h - 2, _w - 40, 1, 0, _o.title_color, .5 * _ea);
	draw_set_halign(fa_right);
	draw_set_color(_o.title_color);
	draw_set_alpha(.85 * _ea);
	draw_text(x + _w, _y + 1, name);
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	exit;
}

var _c = _rcol[clamp(rarity, 0, 4)];
var _on = (input == 1);
// dim what can't be afforded or whose parent is off
var _da = _ea;
if (!_on && apreq > g.ap) _da *= .45;
if (open == false) _da *= .45;

var _rx = x + (sub ? 10 : 0) + 3; // +3 clears the left endcap
var _rw = _w - (sub ? 10 : 0) - 6;

// sub connector
if (sub) draw_sprite_ext(spr_pixel_1x1, 0, x + 2, _y + _h * .5, 8, 1, 0,
	merge_colour(_c, c_black, .5), .6 * _da);

// ---- the capsule: LEFT-to-RIGHT fade to black (Myriad's
// draw_sprite_general corner-color trick), endcaps matching their
// side of the gradient ----
var _cl = merge_colour(_c, c_black, _on ? .45 : .72); // left: colored
var _cr = merge_colour(_c, c_black, .94);             // right: near black
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _rx, _y, _rw, _h, 0,
	_cl, _cr, _cr, _cl, _da);
draw_sprite_ext(spr_dial_endcaps, 0, _rx - 3, _y, 1, 1, 0, _cl, _da);
draw_sprite_ext(spr_dial_endcaps, 1, _rx + _rw, _y, 1, 1, 0, _cr, _da);

// selected: a soft white echo over the whole capsule
if (_o.a == a) {
	draw_sprite_ext(spr_pixel_1x1, 0, _rx, _y, _rw, _h, 0, c_white, .18 * _ea);
	draw_sprite_ext(spr_dial_endcaps, 0, _rx - 3, _y, 1, 1, 0, c_white, .18 * _ea);
	draw_sprite_ext(spr_dial_endcaps, 1, _rx + _rw, _y, 1, 1, 0, c_white, .18 * _ea);
}

// name, left
draw_set_color(_on ? merge_colour(_c, c_white, .5) : _c);
draw_set_alpha(.95 * _da);
draw_text(_rx + 6, _y + 2, name);

// ---- right side: NEW badge, ap cost, then the toggle pip ----
if (input >= 100) {
	draw_set_color(c_gold);
	draw_set_alpha((.5 + .45 * dsin(current_time * .4)) * _ea);
	draw_set_halign(fa_right);
	draw_text(_rx + _rw - 26, _y + 2, "new");
	draw_set_halign(fa_left);
}
if (apreq > 0) {
	draw_set_halign(fa_right);
	draw_set_color(c_ap);
	draw_set_alpha((_on ? .95 : .6) * _da);
	draw_text(_rx + _rw - 12, _y + 2, string(apreq));
	draw_set_halign(fa_left);
}

// the toggle pip (the click target)
draw_sprite_ext(spr_pixel_1x1, 0, _rx + _rw - 8, _y + _h * .5 - 2, 4, 4, 0,
	_on ? _c : c_black, (_on ? 1 : .8) * _da);
if (!_on) draw_px_rect(_rx + _rw - 8, _y + _h * .5 - 2, 4, 4, _c, .5 * _da);

draw_set_alpha(1);
draw_set_color(c_white);
