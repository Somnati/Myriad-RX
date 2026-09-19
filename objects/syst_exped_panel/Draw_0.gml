/// the expeditions' face - hub / trip / haul by `view`. Everything is
/// stamps and text under the fade; the portraits are sh_planet_lite on
/// a square quad (a shader of its own, reset before the text).
var _e   = g.exped;
var _dim = dim;
var _ink = sett_ink;
var _ea  = ui_anim_in(oa, 0);
if (_ea < .001) exit;
ui_fade_set(_ea);
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br = abs(dsin(current_time * .3));

// the ground + the strip
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, room_height - hh, 0, c_black, .94);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y + 15, room_width, 1, 0, _ink, .25);
// THE LOADING VEIL (2026-09-17): the page's chrome - a plain title, [back] -
// and the boot's spinner bottom right; nothing that would touch the galaxy
var _ldd = __loading();
if (is_struct(_ldd)) {
	draw_set_color(c_steelblue); draw_set_alpha(.95);
	var _lt1 = (land && is_struct(pl_dest)) ? "expedition  -  " : "expeditions";
	draw_text(6, strip_y + 5, _lt1);
	if (_lt1 == "expedition  -  ") { draw_set_color(exped_world_col(pl_dest)); draw_text(6 + string_width(_lt1), strip_y + 5, pl_dest.name); }
	__draw_back();
	loading_draw(room_width - (land ? 14 : 4) - 16, room_height - 22, 1, _ldd.txt, ld_v, c_steelblue);
	ui_fade_set(1);
	exit;
}
// THE TITLE SAYS THE PAGE (his ask, 2026-09-15): three parts - a prefix,
// the WORLD'S NAME in its seeded colour, a suffix - so every page reads
// "expedition - Mudra IV / the landing reach" or the like
var _t1 = "expeditions", _t2 = "", _t3 = "", _td = undefined;
switch (view) {
	case "planet": if (is_struct(pl_dest)) { _td = pl_dest; _t3 = "  /  " + exped_biomes()[pl_dest.biome].name + " world" + ((pv_mode == "region") ? ("  /  " + region_get(pl_dest, rg_sel).name) : ""); } break;   // (guarded: the board's world may be a frame away - the veil holds it, this is the belt)
	case "depart": if (is_struct(pl_dest)) { _td = pl_dest; _t3 = "  /  preparation"; } break;
	case "trip":   { var _ttr = __trip(); if (!is_undefined(_ttr)) { _td = _ttr.dest; _t3 = "  /  " + exped_region(_ttr).name; } break; }
	case "haul":   { var _thi = __haul_i(); if (_thi >= 0) { _td = _e.hauls[_thi].dest; _t3 = "  /  home"; } break; }
	case "map":    if (is_struct(map_dest)) { _td = map_dest; _t3 = "  /  " + region_get(map_dest, map_rgi).name + " map"; } break;
	case "crew":   _t1 = (mode == "sprites") ? ("sprites  -  " + string(array_length(g.sprites)) + " of " + string(SPRITE_CAP)) : "expedition  -  the crew"; break;
	case "galaxy": _t1 = "expedition  -  the galaxy"; break;
	case "system": _t1 = "expedition  -  a star system"; break;
	case "station": _t1 = (st_sel >= 0 && st_sel < array_length(sy_stns)) ? ("expedition  -  " + sy_stns[st_sel].name + "  /  " + sy_stns[st_sel].kind) : "expedition  -  a station"; break;
	case "bestiary": _t1 = "expedition  -  the bestiary"; break;
}
if (is_struct(_td)) { _t1 = land ? "expedition  -  " : ""; _t2 = _td.name; if (!land) _t3 = ""; }
var _ttl = _t1 + _t2 + _t3;
draw_set_color(c_steelblue);
draw_set_alpha(.95);
draw_text(6, strip_y + 5, _t1);
if (_t2 != "") {
	draw_set_color(exped_world_col(_td));
	draw_text(6 + string_width(_t1), strip_y + 5, _t2);
	draw_set_color(c_steelblue);
	draw_text(6 + string_width(_t1 + _t2), strip_y + 5, _t3);
}
if (land) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(6 + string_width(_ttl) + 8, strip_y + 5,
		(array_length(_e.trips) == 0) ? "" : (string(array_length(_e.trips)) + " out"));
}
// the debug clock (not on the sprite menu - nothing there runs on it)
if (mode != "sprites")
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	var _on = (_e.spd == [1, 10, 100][_k]);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .8);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _on ? c_lavender : rgb(170, 190, 230), _on ? .9 : .4);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_lavender : _dim);
	draw_set_alpha(.9);
	draw_text(_r.x + _r.w * .5, _r.y + 3, "x" + string([1, 10, 100][_k]));
}
draw_set_halign(fa_left);

// [back] (and [crew]) on a page
__draw_back();

// ======================= THE HAUL =======================
if ((view == "haul")) { if (ex_haul_draw(_e, _ea, _ink, _dim)) exit; }   // (ex_haul_draw - q220)

// ======================= THE MAP (round three, 2026-09-15) =======================
// the region's circle in the rect; the roads along their bent lines with
// the hours at the middle; icons by kind (a flag, houses, tents,
// doorways); labels placed clear of the roads; the crews walking the
// bent roads; [legend] lists the kinds
if ((view == "map")) { if (ex_map_draw(_e, _br, _ink, _dim)) exit; }   // (ex_map_draw - q220)

// ======================= THE CREW MENU (his ask, 2026-09-14: tabs left, the sheet right) =======================
// ======================= THE BESTIARY (his ask, 2026-09-16: grid based) =======================
if ((view == "bestiary")) { if (ex_bestiary_draw(_ink, _dim)) exit; }   // (ex_bestiary_draw - q220)

if ((view == "crew" || view == "sheet")) { if (ex_crew_draw(_ink, _dim)) exit; }   // (ex_crew_draw - q220)

// ======================= THE TRIP =======================
if ((view == "trip")) { if (ex_trip_draw(_e, _ea, _br, _ink, _dim)) exit; }   // (ex_trip_draw - q220)

// ======================= THE PLANET PAGE (2026-09-15): the orbit view =======================
// the tech demo's rm_planet in the panel: the whole page is the sky (the
// real neighbourhood, the milky way, the system's sun) with the world in
// the middle, the camera orbiting it by drag; the regions' spots are on
// the globe (tap one), the drawer on the right lists them
if (view == "planet") { if (ex_planet_draw(_e, _ea, _dim)) exit; }   // (ex_planet_draw - q219)

// ======================= THE GALAXY (2026-09-15): the star map =======================
// the tech demo's rm_starmap as a page: the parallax backdrop, the stars
// off the draw grid with their depth parallax, the nebula fog sheet
// (baked once a galaxy, dithered), the home star ringed. Drag pans,
// ======================= THE STATION PAGE (2026-09-17): a star's station, close up =======================
if (view == "station") { if (ex_station_draw(_ea, _ink, _dim)) exit; }   // (ex_station_draw - q217)

// ======================= THE STAR SYSTEM (the tech demo's 3d view, ported 2026-09-16) =======================
if (view == "system") { if (ex_system_draw(_e, _ea, _ink, _dim)) exit; }   // (ex_system_draw - q217)

if (view == "galaxy") { if (ex_galaxy_draw(_ea, _dim)) exit; }   // (ex_galaxy_draw - q218)

// (the region window is gone - the planet page's region mode, 2026-09-15)

// ======================= THE DEPARTURE: the crew, the brief, [depart] =======================
if ((view == "depart")) { if (ex_depart_draw(_e, _ink, _dim)) exit; }   // (ex_depart_draw - q220)

// ======================= THE HUB (went 2026-09-16 - the code stays behind this gate) =======================
if (view != "hub") { ui_fade_set(1); exit; }
// THE WORLD CARD: the world big, its name, its kind and level, then its
// regions as rows, the flight and who is out at the foot. Tap = its page
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, card_y - 10, "the world  -  tap it");
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _wc = exped_world_col(_d);
	var _out = 0;
	for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed) _out++;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .85);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, _wc, .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, 2, _c.h, 0, _wc, .9);
	// the world, big, at the top; its name under it
	var _pr = land ? 22 : 20;   // (a little smaller - the third region row was cut by the card's foot, 2026-09-16)
	ui_fade_set(1);
	__world_small(_d, _c.x + _c.w * .5, _c.y + 8 + _pr, _pr);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(_wc); draw_set_alpha(.95);
	draw_text(_c.x + _c.w * .5, _c.y + 8 + _pr * 2 + 6, str_cap(_d.name));
	draw_set_font(fnt);
	draw_set_color(merge_colour(_b.col2, c_white, .3)); draw_set_alpha(.85);
	draw_text(_c.x + _c.w * .5, _c.y + 8 + _pr * 2 + 20, _b.name + " world  -  lv " + string(exped_world_lv(_d)));
	draw_set_halign(fa_left);
	var _ry = _c.y + 8 + _pr * 2 + 34;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x + 8, _ry, _c.w - 16, 1, 0, _ink, .25);
	_ry += 6;
	// the regions: a row each - the name, the level in its colour, the mood under
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_c.x + 8, _ry, "regions");
	_ry += 11;
	var _lvc = [c_sgreen, c_gold, c_hred];
	for (var _ri = 0; _ri < EXPED_REGIONS; _ri++) {
		if (_ry + 10 > _c.y + _c.h - 24) break;
		var _rg = region_get(_d, _ri);
		var _rout = 0;
		for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed && (_e.trips[_t][$ "rgi"] ?? 0) == _ri) _rout++;
		draw_set_color(c_white); draw_set_alpha(.9);
		draw_text(_c.x + 8, _ry, string_copy(str_cap(_rg.name), 1, land ? 18 : 16));
		draw_set_halign(fa_right);
		draw_set_color(_lvc[clamp(_ri, 0, 2)]); draw_set_alpha(.9);
		draw_text(_c.x + _c.w - 8, _ry, "lv " + string(_rg.lv));
		draw_set_halign(fa_left);
		draw_set_color(_dim); draw_set_alpha(.6);
		draw_text(_c.x + 8, _ry + 9, (_rg[$ "mood"] ?? "quiet") + ((_rout > 0) ? ("  -  " + string(_rout) + " out") : ""));
		_ry += 18;
	}
	// (the world's words live in the planet page's world box - they never fit here, 2026-09-16)
	// the foot: the flight, and who is out
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(_c.x + 8, _c.y + _c.h - 12, crunch_time_long(_d.dist * EXPED_TRAVEL * 60 / max(1, _e.spd)) + " flight");
	if (_out > 0) { draw_set_halign(fa_right); draw_set_color(c_steelblue); draw_set_alpha(.9); draw_text(_c.x + _c.w - 8, _c.y + _c.h - 12, string(_out) + " out"); draw_set_halign(fa_left); }
}
// [crew]: the roster; [galaxy]: the star map
if (array_length(g.sprites) > 0) {
	var _shr = __crewbtn_r();
	draw_ui_button(_shr.x, _shr.y, _shr.w, _shr.h, "crew", c_steelblue, true, false);
}
var _hgl = __hub_gal_r();
draw_ui_button(_hgl.x, _hgl.y, _hgl.w, _hgl.h, "galaxy", c_steelblue, true, false);
var _hbs = __hub_best_r();
draw_ui_button(_hbs.x, _hbs.y, _hbs.w, _hbs.h, "bestiary", c_steelblue, true, false);

// THE LIST: hauls waiting, then trips out - an island each
var _ly0 = __list_y0();
var _nh = array_length(_e.hauls), _nt = array_length(_e.trips);
draw_set_color(_ink); draw_set_alpha(.6);
draw_text(list_x, _ly0 + 2, "expeditions");
if (_nh + _nt > 0) {
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(list_x + string_width("expeditions") + 8, _ly0 + 2, ((_nt > 0) ? (string(_nt) + " out") : "") + ((_nt > 0 && _nh > 0) ? ", " : "") + ((_nh > 0) ? (string(_nh) + " home") : ""));
}
var _rows = _nh + _nt;
if (_rows == 0) {
	var _er = __row_r(0);
	draw_sprite_ext(spr_pixel_1x1, 0, _er.x, _er.y, _er.w, 16, 0, c_black, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _er.x, _er.y, 2, 16, 0, _dim, .5);
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(_er.x + 8, _er.y + 4, "nothing out  -  tap the world, pick a region, a quest, a crew");
}
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (_rr.y + _rr.h > room_height - 4) break;
	var _ish = (_i < _nh);
	var _r  = _ish ? _e.hauls[_i] : _e.trips[_i - _nh];
	var _rg2 = region_get(_r.dest, _r[$ "rgi"] ?? 0);
	var _fight = (!_ish && !is_undefined(_r.fight));
	var _acc = _ish ? (_r.routed ? c_horange : c_gold) : (_fight ? c_hred : c_steelblue);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_black, .8);
	draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, _acc, .25);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, 2, _rr.h, 0, _acc, .9);
	// the world, facing the region
	ui_fade_set(1);
	__world_small(_r.dest, _rr.x + 20, _rr.y + _rr.h * .5, 12, _rg2);
	ui_fade_set(_ea);
	var _tx = _rr.x + 40, _tw = _rr.w - 48;
	// line one: the crew's dots and names; the state on the right
	for (var _k = 0; _k < array_length(_r.sids); _k++) __dot(_tx + 3 + _k * 8, _rr.y + 8, 3, _r.cols[_k], (_ish || _r.hp[_k] > 0) ? .95 : .3);
	draw_set_color(c_white); draw_set_alpha(.95);
	var _crn = str_cap(exped_crew_txt(_r.names));
	draw_text(_tx + array_length(_r.sids) * 8 + 4, _rr.y + 4, string_copy(_crn, 1, land ? 30 : 20));
	draw_set_halign(fa_right);
	if (_ish) { draw_set_color(_acc); draw_set_alpha(.95); draw_text(_rr.x + _rr.w - 6, _rr.y + 4, _r.routed ? "limped home" : "home"); }
	else {
		var _mode = ((_r[$ "mode"] ?? "quest") == "explore") ? ((is_struct(_r[$ "ex"]) && _r.ex.kind == "ramble") ? "roaming" : ((is_struct(_r[$ "ex"]) && _r.ex.kind == "survey") ? "surveying" : "exploring")) : "on a quest";
		draw_set_color(_fight ? c_hred : _dim); draw_set_alpha(.85);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 4, _fight ? "in a fight" : _mode);
	}
	draw_set_halign(fa_left);
	// line two: the world (its colour) / the region
	draw_set_color(exped_world_col(_r.dest)); draw_set_alpha(.95);
	draw_text(_tx, _rr.y + 14, _r.dest.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_tx + string_width(_r.dest.name), _rr.y + 14, "  /  " + _rg2.name);
	if (_ish) {
		// a haul: its finds, and the ask
		var _nf = array_length(_r.finds);
		draw_set_color(_acc); draw_set_alpha(.9);
		draw_text(_tx, _rr.y + 25, string(_r[$ "wins"] ?? 0) + ((_r[$ "wins"] ?? 0) == 1 ? " fight won" : " fights won") + "  -  " + string(_nf) + ((_nf == 1) ? " find" : " finds"));
		draw_set_color(c_gold); draw_set_alpha(.7 + .25 * _br);
		draw_text(_tx, _rr.y + 34, "tap to collect the haul");
	} else {
		// line three: the leg, as a labelled bar; line four: where they are
		var _leg = (_r.stage == 0) ? "flying out" : ((_r.stage == 2) ? "flying home" : "on the world");
		var _tf = 0;
		if (_r.stage == 0) _tf = clamp(_r.t / max(1, _r.dur * EXPED_TRAVEL), 0, 1);
		else if (_r.stage == 2) _tf = clamp((_r.t - (_r[$ "leave_t"] ?? _r.t)) / max(1, _r.dur * EXPED_RETURN), 0, 1);
		else if (is_struct(_r[$ "road"])) _tf = clamp(_r.road.t / max(1, _r.road.d * EXPED_HOUR), 0, 1);
		draw_set_color(_dim); draw_set_alpha(.7);
		draw_text(_tx, _rr.y + 25, _leg);
		var _bx = _tx + 54, _bw = _tw - 54;
		draw_sprite_ext(spr_pixel_1x1, 0, _bx, _rr.y + 27, _bw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx, _rr.y + 27, _bw * _tf, 4, 0, _acc, .9);
		draw_px_rect(_bx, _rr.y + 27, _bw, 4, c_white, .1);
		draw_set_color(_dim); draw_set_alpha(.6);
		draw_text(_tx, _rr.y + 34, string_copy(exped_where(_r), 1, land ? 48 : 30));
	}
}
ui_fade_set(1);
draw_set_alpha(1);   // (the last row's .8 must not leak into the next draw - bug hunt, 2026-09-14)
