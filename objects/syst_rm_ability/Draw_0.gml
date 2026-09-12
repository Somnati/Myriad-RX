/// the deck room's chrome: top strip (ap / units / collection),
/// info panel with the native crossfade, discover button, reveal
/// flash. the list itself is drawn by the slots.

// THE GROUND (the overlay, 2026-09-12): the room it was had a black
// background; the panel paints one from the header down, fading in on
// the open ease (the slots draw over it in their own slot, a step up)
// ...and the whole panel dissolves through ui_fade_set (the shader in
// front of every draw below - all stamps and text here), so the ground
// and the chrome leave together instead of the chrome vanishing whole
var _ea0 = ui_anim_in(oa, 0);
if (_ea0 < .001) exit;
ui_fade_set(_ea0);
draw_set_alpha(1);
var _bby0 = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 27;
draw_sprite_ext(spr_pixel_1x1, 0, 0, _bby0, room_width, room_height - _bby0, 0, c_black, .94);

draw_set_font(fnt);

// ---- top strip, under the header: the status BAR stays high, the
// text sits a touch lower, clear of the header band ----
draw_sprite_ext(spr_pixel_1x1, 0, 6, 29, 70, 2, 0, c_black, .7);
if (g.maxap > 0) draw_sprite_ext(spr_pixel_1x1, 0, 6, 29,
	70 * clamp(g.ap / g.maxap, 0, 1), 2, 0, c_ap, .9);

draw_set_halign(fa_left);
draw_set_color(c_ap);
draw_set_alpha(.95);
draw_text(6, 34, "ap " + string(g.ap) + "/" + string(g.maxap));

draw_set_color(c_seagreen);
draw_text(90, 34, "units " + crunch_arb(g.units));

draw_set_color(rgb(170, 190, 230));
draw_set_alpha(.7);
draw_text(170, 34, "abilities " + string(g.new_abilities_unlocked)
	+ "/" + string(g.unlockable_abilities)
	+ " (" + string(floor(100 * g.new_abilities_unlocked
		/ max(1, g.unlockable_abilities))) + "%)");

// ---- info panel, right column ----
// the deck's rarity ladder (matches unlock_ability + the slots)
var _rcol = [c_white, rgb(60, 255, 69), rgb(65, 122, 255),
	rgb(255, 167, 10), rgb(160, 32, 255)];

var _ih = 136;
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, info_x, info_y, info_w, _ih, 0, c_black, .8);
var _fc = (i_rarity >= 0) ? _rcol[clamp(i_rarity, 0, 4)] : rgb(170, 190, 230);
draw_px_rect(info_x, info_y, info_w, _ih, _fc, .9);

// both crossfade states render; tos slides them, alpha blends them
for (var _s = 0; _s < 2; _s++) {
	var _nm2, _tx2, _ra2, _ap2, _fl2, _to2, _al2;
	if (_s == 0) { _nm2 = o_name; _tx2 = o_text; _ra2 = o_rarity; _ap2 = o_apreq; _fl2 = o_flavor; _to2 = o_tos; _al2 = o_alpha; }
	else         { _nm2 = i_name; _tx2 = i_text; _ra2 = i_rarity; _ap2 = i_apreq; _fl2 = i_flavor; _to2 = i_tos; _al2 = i_alpha; }
	if (_al2 <= .02 || _nm2 == "") continue;

	var _ty = info_y + 5 + _to2;
	var _nc = (_ra2 >= 0) ? _rcol[clamp(_ra2, 0, 4)] : c_white;
	draw_set_alpha(_al2);
	draw_set_color(_nc);
	draw_set_font(fnt_large);
	draw_text(info_x + 6, _ty, _nm2);
	draw_set_font(fnt);
	// rarity word + ap cost line
	if (_ra2 >= 0) {
		var _rw = "common";
		if (_ra2 == 1) _rw = "uncommon";
		if (_ra2 == 2) _rw = "rare";
		if (_ra2 == 3) _rw = "legendary";
		if (_ra2 == 4) _rw = "epic";
		draw_set_alpha(_al2 * .7);
		draw_text(info_x + 6, _ty + 12, _rw);
		if (_ap2 > 0) {
			draw_set_color(c_ap);
			draw_set_halign(fa_right);
			draw_text(info_x + info_w - 6, _ty + 12, "ap " + string(_ap2));
			draw_set_halign(fa_left);
		}
	}
	// description
	draw_set_alpha(_al2 * .9);
	draw_set_color(c_white);
	draw_text(info_x + 6, _ty + 26, _tx2);
	// flavor lines
	for (var _f2 = 0; _f2 < _fl2; _f2++) {
		draw_set_color((_s == 0) ? o_flavor_color[_f2] : i_flavor_color[_f2]);
		draw_text(info_x + 6, _ty + 62 + _f2 * 10,
			(_s == 0) ? o_flavor_text[_f2] : i_flavor_text[_f2]);
	}
}

// ---- empty-panel default (spec screen 6): a fresh deck showed a
// blank box - explain the schools instead, until a card has ever
// been hovered. the list side gets a pointer at the discover button
if (o_name == "" && i_name == "") {
	draw_set_halign(fa_left);
	draw_set_color(rgb(170, 190, 230));
	draw_set_alpha(.9);
	draw_text(info_x + 6, info_y + 5, "the ability deck");
	var _schools = [
		["survey",  "faster probes & scanning"],
		["fleet",   "travel & warp tuning"],
		["tiles",   "the tile bench, automated"],
		["colony",  "city & planet boons"],
		["combat",  "openers for the war room"],
		["support", "ap, luck & bargains"]];
	for (var _l2 = 0; _l2 < array_length(_schools); _l2++) {
		draw_set_color(c_white);
		draw_set_alpha(.75);
		draw_text(info_x + 6, info_y + 22 + _l2 * 11, _schools[_l2][0]);
		draw_set_color(sett_ink);
		draw_set_alpha(.5);
		draw_text(info_x + 58, info_y + 22 + _l2 * 11, _schools[_l2][1]);
	}
	draw_set_color(c_gold);
	draw_set_alpha(.6);
	draw_text(info_x + 6, info_y + 22 + 6 * 11 + 4,
		"discovered abilities are passive - hover one for details.");
}
if (g.new_abilities_unlocked == 0 && view == 0) { // deck view only
	draw_set_halign(fa_left);
	draw_set_color(c_gray);
	draw_set_alpha(.5 + .2 * abs(dsin(current_time * .3)));
	draw_text(10, 60, "no abilities yet - discover your first on the right >");
	draw_set_alpha(1);
}

// ---- discover button ----
var _can = (g.unlockable_abilities > g.new_abilities_unlocked
	&& g.units >= g.new_ability_cost);
var _done = (g.new_abilities_unlocked >= g.unlockable_abilities);
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, info_x, 200, info_w, 24, 0, c_black, .8);
draw_px_rect(info_x, 200, info_w, 24, _can ? c_gold : c_white, _can ? .8 : .3);
draw_set_halign(fa_center);
draw_set_color(_can ? c_gold : c_white);
draw_set_alpha(_can ? .95 : .5);
if (_done) draw_text(info_x + info_w * .5, 208, "all abilities discovered");
else draw_text(info_x + info_w * .5, 208,
	"discover  -  " + crunch_arb(g.new_ability_cost) + " units");

// debug: grant units
draw_sprite_ext(spr_pixel_1x1, 0, info_x, 230, 70, 14, 0, c_black, .6);
draw_px_rect(info_x, 230, 70, 14, c_seagreen, .4);
draw_set_color(c_seagreen);
draw_set_alpha(.85);
draw_text(info_x + 35, 232, "+units");

// ---- debug row, bottom left + the collection toggle ----
draw_sprite_ext(spr_pixel_1x1, 0, 6, 250, 70, 14, 0, c_black, .6);
draw_px_rect(6, 250, 70, 14, c_seagreen, .4);
draw_set_color(c_seagreen);
draw_text(41, 252, "unlock all");

draw_sprite_ext(spr_pixel_1x1, 0, 82, 250, 70, 14, 0, c_black, .6);
draw_px_rect(82, 250, 70, 14, c_seagreen, .4);
draw_text(117, 252, "enable all");

draw_sprite_ext(spr_pixel_1x1, 0, 158, 250, 70, 14, 0, c_black, .6);
draw_px_rect(158, 250, 70, 14, g.abi_free ? c_gold : c_white, g.abi_free ? .7 : .3);
draw_set_color(g.abi_free ? c_gold : c_white);
draw_text(193, 252, g.abi_free ? "free: on" : "free: off");

draw_sprite_ext(spr_pixel_1x1, 0, 234, 250, 70, 14, 0, c_black, .6);
draw_px_rect(234, 250, 70, 14, view ? c_gold : c_white, view ? .6 : .3);
draw_set_color(view ? c_gold : c_white);
draw_set_alpha(.9);
draw_text(269, 252, view ? "deck" : "collection");

// ---- loadout presets, above the info panel (right of the counters,
// left of the back button) ----
draw_set_halign(fa_center);
for (var _l = 0; _l < 3; _l++) {
	var _lx = 296 + _l * 22;
	var _has = is_array(g.abi_loadout[_l]);
	draw_sprite_ext(spr_pixel_1x1, 0, _lx, 30, 16, 14, 0, c_black, .7);
	draw_px_rect(_lx, 30, 16, 14, _has ? c_ap : c_white, _has ? .7 : .25);
	draw_set_color(_has ? c_ap : c_white);
	draw_set_alpha(_has ? .95 : .5);
	draw_text(_lx + 8, 32, string(_l + 1));
}
draw_sprite_ext(spr_pixel_1x1, 0, 362, 30, 28, 14, 0, c_black, .7);
draw_px_rect(362, 30, 28, 14, lo_set ? c_gold : c_white,
	lo_set ? (.6 + .35 * dsin(current_time * .4)) : .3);
draw_set_color(lo_set ? c_gold : c_white);
draw_set_alpha(.9);
draw_text(376, 32, "set");
draw_set_halign(fa_left);

// ---- collection view: every card in deck order, ??? until found.
// the deck slots exit in this mode, so the list band is ours ----
if (view == 1) {
	var _p3 = round(g.ability_page);
	var _yos3 = row_h * (_p3 - g.ability_page);
	var _band_b2 = list_y + visible_rows * row_h - 4;
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	for (var _r3 = 0; _r3 < array_length(coll_rows); _r3++) {
		var _ry3 = list_y + (_r3 - _p3) * row_h + _yos3;
		var _fade2 = 1;
		if (_ry3 < list_y) _fade2 = 1 - (list_y - _ry3) / 12;
		if (_ry3 + 11 > _band_b2) _fade2 = 1 - ((_ry3 + 11) - _band_b2) / 12;
		_fade2 = clamp(_fade2, 0, 1);
		if (_fade2 <= 0) continue;
		var _row3 = coll_rows[_r3];

		if (_row3.key == "") {
			// section divider (the collection always shows them)
			draw_set_alpha(.5 * _fade2);
			draw_sprite_ext(spr_pixel_1x1, 0, list_x, _ry3 + 9,
				list_w - 40, 1, 0, title_color, .5 * _fade2);
			draw_set_halign(fa_right);
			draw_set_color(title_color);
			draw_set_alpha(.85 * _fade2);
			draw_text(list_x + list_w, _ry3 + 1, _row3.title);
			draw_set_halign(fa_left);
			continue;
		}

		var _v3 = variable_global_get(_row3.key);
		var _ci3 = deck_card_info(_row3.key);
		var _known = (_v3 != -1);
		var _cc3 = _known ? _rcol[clamp(_ci3.rarity, 0, 4)] : rgb(70, 80, 95);
		var _cl3 = merge_colour(_cc3, c_black, _known ? .6 : .8);
		var _cr3 = merge_colour(_cc3, c_black, .94);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			list_x + 3, _ry3, list_w - 6, 11, 0, _cl3, _cr3, _cr3, _cl3, _fade2);
		draw_sprite_ext(spr_dial_endcaps, 0, list_x, _ry3, 1, 1, 0, _cl3, _fade2);
		draw_sprite_ext(spr_dial_endcaps, 1, list_x + list_w - 3, _ry3, 1, 1, 0, _cr3, _fade2);
		draw_set_color(_known ? _cc3 : rgb(110, 120, 135));
		draw_set_alpha(.9 * _fade2);
		draw_text(list_x + 9, _ry3 + 2, _known ? _ci3.name : "???");
		if (_v3 == 1) {
			draw_set_halign(fa_right);
			draw_set_color(merge_colour(_cc3, c_white, .3));
			draw_text(list_x + list_w - 8, _ry3 + 2, "on");
			draw_set_halign(fa_left);
		}
	}
}

// (no back button - the burger is the X, the overlay's rule)

// ---- discovery reveal: the fanfare card, fading out ----
if (reveal_t > 0) {
	var _ra = clamp(reveal_t / 40, 0, 1);
	draw_set_font(fnt_large);
	var _rw2 = max(string_width(reveal_name),
		string_width(reveal_rtxt + " ability discovered")) + 16;
	var _rx = 240 - _rw2 * .5;
	var _ry = 120;
	draw_set_alpha(.92 * _ra);
	draw_sprite_ext(spr_pixel_1x1, 0, _rx, _ry, _rw2, 34, 0, c_black, .92 * _ra);
	draw_px_rect(_rx, _ry, _rw2, 34, reveal_col, _ra);
	draw_set_halign(fa_center);
	draw_set_font(fnt);
	draw_set_color(reveal_col);
	draw_set_alpha(.9 * _ra);
	var _lbl = (reveal_rtxt == "") ? "ability discovered" : reveal_rtxt + " ability discovered";
	draw_text(240, _ry + 6, _lbl);
	draw_set_font(fnt_large);
	draw_set_color(c_white);
	draw_set_alpha(_ra);
	draw_text(240, _ry + 17, reveal_name);
}

// ---- the discovery DRAFT: modal backdrop + header. the cards
// themselves are obj_card instances at depth -50 (above this),
// spawned and driven by the Step - real 2.5D flips, not flats ----
if (array_length(g.abi_draft) > 0) {
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .78);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(c_gold);
	draw_set_alpha(.95);
	draw_text(240, 42, "choose an ability");
	draw_set_halign(fa_left);
}

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
ui_fade_set(1);   // never leave the shader on for the next drawer
