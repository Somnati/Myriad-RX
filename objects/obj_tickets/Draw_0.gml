if (!variable_global_exists("game_started") || !g.game_started) exit;
ticket_init();
var _c = ticket_config();
var _pile = g.tickets.pile;
var _n = array_length(_pile);
var _show = unfold_has("tickets") && in_room(rm_clicker)
	&& !(instance_exists(obj_ui_menu2) && obj_ui_menu2.open)
	&& (ui_overlay() == noone);
if (!_show && oa < .05) exit;

// ---- the pile: up to four faces, the next one on top ----
var _p = __pile();
var _up = (oa > .05 && cur != undefined);   // the top ticket is the card
var _faces = min(_n - (_up ? 1 : 0), 4);
if (_faces > 0 && _show) {
	var _lift = (hot && !open) ? 1 : 0;
	for (var _i = _faces - 1; _i >= 0; _i--) {
		var _tk = _pile[_i + (_up ? 1 : 0)];
		var _rc = _c.rars[_tk.rar];
		var _fx = _p.x + _i, _fy = _p.y - _i - _lift;
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, PW, PH, 0, rgb(26, 28, 44), 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, PW, 1, 0, _rc.col, .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy + PH - 1, PW, 1, 0, _rc.col, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, 1, PH, 0, _rc.col, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + PW - 1, _fy, 1, PH, 0, _rc.col, .7);
		// a strip of foil
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + 5, PW - 8, 6, 0, _rc.foil, .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + 5, PW - 8, 1, 0, c_white, .35);
	}
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(.85);
	draw_text(_p.x + PW + 6, _p.y + 1, "x" + string(_n));
	draw_set_alpha(1);
}

// ---- the card ----
if (oa > .05 && cur != undefined) {
	var _r = __card();
	var _rc = _c.rars[cur.rar];
	var _e = clamp((oa - .7) / .3, 0, 1);   // the contents fade in as it arrives
	// body
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x + 2, _r.y + 3, _r.w, _r.h, 0, c_black, .45 * oa);   // shadow
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, rgb(26, 28, 44), 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, 1, 0, _rc.col, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y + _r.h - 1, _r.w, 1, 0, _rc.col, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 1, _r.h, 0, _rc.col, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x + _r.w - 1, _r.y, 1, _r.h, 0, _rc.col, .8);
	if (_e > 0) {
		// the header: rarity left, the printed odds right, the x
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x + 1, _r.y + 1, _r.w - 2, 10, 0, _rc.col, .18 * _e);
		draw_set_font(fnt);
		draw_set_valign(fa_top);
		draw_set_alpha(_e);
		draw_set_halign(fa_left);
		draw_set_color(_rc.col);
		draw_text(_r.x + 3, _r.y + 2, _rc.name);
		draw_set_halign(fa_right);
		draw_set_color(c_white);
		draw_text(_r.x + _r.w - 12, _r.y + 2, __odds(_rc.win));
		var _xr = __xrect(_r);
		var _xc = point_in_rectangle(mouse_x, mouse_y, _xr.x, _xr.y, _xr.x + _xr.w, _xr.y + _xr.h) ? c_white : merge_colour(_rc.col, c_white, .5);
		for (var _k = -2; _k <= 2; _k++) {
			draw_sprite_ext(spr_pixel_1x1, 0, _xr.x + 4 + _k, _xr.y + 4 + _k, 1, 1, 0, _xc, _e);
			draw_sprite_ext(spr_pixel_1x1, 0, _xr.x + 4 + _k, _xr.y + 4 - _k, 1, 1, 0, _xc, _e);
		}
		// the grid: nine cells, the symbols under the foil
		var _g = __grid(_r);
		for (var _i = 0; _i < 9; _i++) {
			var _cx = _g.x + (_i mod 3) * (CELL + GAP), _cy = _g.y + (_i div 3) * (CELL + GAP);
			var _win_cell = done && roll.win && roll.grid[_i] == roll.sym;
			draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, CELL, CELL, 0, _win_cell ? merge_colour(rgb(40, 44, 64), _rc.col, .35) : rgb(40, 44, 64), _e);
			draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, CELL, 1, 0, c_white, .08 * _e);
			__symbol(roll.grid[_i], _cx + CELL div 2, _cy + CELL div 2, _e * (done && roll.win && !_win_cell ? .35 : 1));
		}
		// the foil: every intact cell, a slow diagonal sheen across it
		var _base = _rc.foil;
		for (var _rr = 0; _rr < GN; _rr++)
		for (var _cc = 0; _cc < GN; _cc++) {
			if (cur.cells[_rr * GN + _cc] == 0) continue;
			var _sh = .5 + .5 * sin((_rr + _cc) * .42 - t * 2.4);
			var _col = merge_colour(_base, c_white, .38 * _sh);
			draw_sprite_ext(spr_pixel_1x1, 0, _g.x + _cc * CS, _g.y + _rr * CS, CS, CS, 0, _col, _e);
		}
		// the line under the grid: the rule, or the result
		draw_set_halign(fa_center);
		var _ly = _g.y + GW + 5;
		if (!done) {
			draw_set_color(c_white);
			draw_set_alpha(.5 * _e);
			draw_text(_r.x + _r.w * .5, _ly, "match three");
		} else if (prize != undefined) {
			var _pop = 1 + .5 * max(0, done_t - 1.6) / .3;
			draw_set_font(fnt_outline);
			draw_set_color(prize.col);
			draw_set_alpha(_e);
			draw_text_transformed(_r.x + _r.w * .5, _ly - (_pop - 1) * 3, prize.label, _pop, _pop, 0);
		} else {
			draw_set_color(rgb(150, 150, 165));
			draw_set_alpha(_e);
			draw_text(_r.x + _r.w * .5, _ly, "no luck");
		}
		draw_set_alpha(1);
	}
}

// ---- the flakes ----
for (var _i = 0; _i < array_length(flakes); _i++) {
	var _f = flakes[_i];
	draw_sprite_ext(spr_pixel_1x1, 0, _f.x, _f.y, 1, 1, 0, _f.col, clamp(_f.life * 1.5, 0, 1));
}
draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(fnt);   // (the prize line draws in the outline font; the next draw must not inherit it)
