draw_set_font(fnt);
draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby - 2, room_width, room_height, 0, c_hsv(169, 186, 5), 1);
// the strip: the name, and the line of the moment
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, rgb(170, 190, 230), .25);
draw_set_color(c_sblue); draw_set_alpha(.95);
draw_text(6, bby + 4, "alluvium");
draw_set_color(sett_ink); draw_set_alpha(.75);
var _line = (note_t > 0) ? note : ((d.flood > 0) ? "THE FLOOD  -  the river is over its banks" : ((d.flood_t < 20) ? ("the river is rising  -  the flood in " + string(ceil(d.flood_t)) + "s") : "steer the river; the river builds the land"));
if (d.flood > 0) draw_set_color(c_hred); else if (d.flood_t < 20) draw_set_color(c_horange);
draw_text(6 + string_width("alluvium") + 12, bby + 4, _line);
var _bk = __back_r(); draw_ui_button(_bk.x, _bk.y, _bk.w, _bk.h, "back", rgb(170, 190, 230), true, false);

// THE GROUND: the sheet, scaled to the cells
var _gr = __grid_r();
if (surface_exists(gsurf)) draw_surface_ext(gsurf, _gr.x, _gr.y, cell, cell, 0, c_white, 1);
// the crops: a mark on every growing field - a green shoot, gold as it ripens
var _n = d.w * d.h, _sd = delta_seeds()[d.seed];
for (var _i = 0; _i < _n; _i++) {
	var _cr = d.crop[_i];
	if (_cr <= .08) continue;
	var _x = _gr.x + (_i mod d.w) * cell, _y = _gr.y + (_i div d.w) * cell;
	var _cc = merge_colour(rgb(60, 150, 60), rgb(230, 200, 70), clamp((_cr - .4) / .6, 0, 1));
	if (_cr < .5) draw_sprite_ext(spr_pixel_1x1, 0, _x + 2, _y + 3, 2, 2, 0, _cc, .9);
	else { draw_sprite_ext(spr_pixel_1x1, 0, _x + 1, _y + 1, 2, 4, 0, _cc, .9); draw_sprite_ext(spr_pixel_1x1, 0, _x + 3, _y + 2, 2, 3, 0, _cc, .9); }
}
// the springs
var _sp = delta_springs(d);
for (var _k = 0; _k < array_length(_sp); _k++) { var _sx = _gr.x + _sp[_k][0] * cell, _sy = _gr.y + _sp[_k][1] * cell; draw_sprite_ext(spr_pixel_1x1, 0, _sx - 2, _sy - 2, 4, 4, 0, c_white, .7 + .3 * dsin(current_time * .4)); }
// THE SPARKS: every droplet's path, fading - the river seen
for (var _k = 0; _k < array_length(d.drops); _k++) {
	var _dr = d.drops[_k], _pa = _dr.p, _al = clamp(_dr.t, 0, 1) * .8;
	for (var _j = 0; _j < array_length(_pa); _j++) {
		var _ci = _pa[_j], _x = _gr.x + (_ci mod d.w) * cell, _y = _gr.y + (_ci div d.w) * cell;
		draw_sprite_ext(spr_pixel_1x1, 0, _x + 2, _y + 2, 2, 2, 0, (d.flood > 0) ? rgb(220, 200, 150) : rgb(180, 230, 255), _al * (.4 + .6 * (_j / max(1, array_length(_pa)))));
	}
}
// the hovered cell, and the tool's mark
if (hover >= 0) {
	var _hx = _gr.x + (hover mod d.w) * cell, _hy = _gr.y + (hover div d.w) * cell;
	draw_px_rect(_hx - 1, _hy - 1, cell + 2, cell + 2, (tool == "levee") ? c_gold : ((tool == "channel") ? c_steelblue : c_white), .8);
}
draw_px_rect(_gr.x - 1, _gr.y - 1, _gr.w + 2, _gr.h + 2, rgb(170, 190, 230), .25);

// THE PANEL: the grain, its pace, the ledger's rows, the counts
var _st0 = delta_stats(d);
draw_set_color(c_gold); draw_set_alpha(.95);
draw_set_font(fnt_large);
draw_text(px, gy, delta_num(d.grain));
draw_set_font(fnt);
draw_set_color(sett_ink); draw_set_alpha(.7);
draw_text(px, gy + 14, "grain  " + ((d.rate > 0) ? ("+" + string_format(d.rate, 1, 1) + "/s") : ""));
for (var _i = 0; _i < array_length(rows); _i++) {
	var _r = __row_r(_i), _rw = rows[_i], _c = delta_cost(d, _rw.k), _tl = (_rw.k == "levee" || _rw.k == "channel");
	var _lbl = _rw.lbl;
	if (_rw.k == "rain") _lbl += " " + string(d.rain);
	else if (_rw.k == "springs") _lbl += " " + string(d.springs) + "/3";
	else if (_rw.k == "rich") _lbl += " " + string(d.rich);
	else if (_rw.k == "seed") _lbl = (d.seed < 3) ? ("seed: " + delta_seeds()[d.seed + 1].name) : "seed: saffron";
	var _on = _tl && (tool == _rw.k), _can = (_c >= 0 && d.grain >= _c);
	if (_rw.k == "valley" && _c < 0) _lbl += "  " + string(floor(_st0.newland / max(1, _st0.sea0n) * 100)) + "%";
	draw_ui_button(_r.x, _r.y, _r.w, _r.h, _lbl, _rw.col, (_c >= 0), _on || (!_tl && _can));
	if (_c >= 0) { draw_set_halign(fa_right); draw_set_color(_can ? c_gold : merge_colour(c_gold, c_black, .5)); draw_set_alpha(.9); draw_text(_r.x + _r.w - 3, _r.y + 2, delta_num(_c)); draw_set_halign(fa_left); }
	else { draw_set_halign(fa_right); draw_set_color(sett_ink); draw_set_alpha(.5); draw_text(_r.x + _r.w - 3, _r.y + 2, (_rw.k == "valley") ? "not yet" : "max"); draw_set_halign(fa_left); }
}
// the counts
var _st = _st0, _cy = gy + 30 + array_length(rows) * 15 + 4;
draw_set_color(sett_ink); draw_set_alpha(.7);
draw_text(px, _cy, "land " + string(_st.land) + "   delta " + string(_st.newland)); _cy += 10;
draw_text(px, _cy, "fields " + string(_st.fields) + "   wet " + string(_st.wet)); _cy += 10;
draw_text(px, _cy, "harvests " + delta_num(d.harvests) + "   valley " + string(d.valley)); _cy += 10;
draw_text(px, _cy, "silt laid " + delta_num(d.silted * 100)); _cy += 10;
draw_text(px, _cy, "crop: " + _sd.name + "  x" + string(_sd.yield)); _cy += 10;
draw_set_color((d.flood > 0) ? c_hred : sett_ink); draw_set_alpha(.7);
draw_text(px, _cy, (d.flood > 0) ? ("flood " + string(ceil(d.flood)) + "s") : ("flood in " + string(floor(d.flood_t / 60)) + "m " + string(floor(d.flood_t mod 60)) + "s"));
// the hovered row's word, in a box at the ground's foot
for (var _i = 0; _i < array_length(rows); _i++) if (__hit(__row_r(_i))) {
	var _th = string_height_ext(rows[_i].tip, 9, 300) + 6;
	draw_sprite_ext(spr_pixel_1x1, 0, _gr.x + 2, _gr.y + _gr.h - _th - 2, 306, _th, 0, c_black, .75);
	draw_set_color(c_white); draw_set_alpha(.9); draw_text_ext(_gr.x + 5, _gr.y + _gr.h - _th + 1, rows[_i].tip, 9, 300);
}
// THE FIRST WORDS, until the first grain
if (tut) {
	draw_set_color(c_white); draw_set_alpha(.85);
	draw_text_ext(_gr.x + 8, _gr.y + 8, "the spring is at the top. the rain runs down to the sea, cutting the land and dropping silt where it slows. crops grow on wet, silted ground - and everything the river still carries when it reaches the sea builds new land there. buy rain; dig channels; watch the delta grow.", 9, 220);
}
ui_fade_set(1);
