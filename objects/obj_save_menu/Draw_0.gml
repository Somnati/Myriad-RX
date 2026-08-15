/// two sliding pages: profiles, then the picked profile's slots with
/// playtime and gold, kh save-menu reading. all pixel-drawn.

draw_set_alpha(1);
draw_set_halign(fa_left);

var _ox0 = -slide * room_width;        // profiles page offset
var _ox1 = (1 - slide) * room_width;   // slots page offset

// ================= page 0: profiles =================
if (slide < 1) {
	draw_set_color(c_gold);
	draw_text(row_x + _ox0, 30, ng_mode ? "new game > pick a slot" : "select profile");

	for (var _i = 0; _i < 4; _i++) {
		var _rx = row_x + _ox0;
		var _ry = row_y0 + _i * row_sp;
		var _pi = prof_info[_i];

		// saved profiles frame + sign their card in their personal color
		var _has = !is_undefined(_pi) && _pi.valid;
		var _pc  = _has ? g.profile_color[_i] : rgb(120, 130, 150);

		draw_sprite_ext(spr_pixel_1x1, 0, _rx, _ry, row_w, row_h, 0, c_black, .55);
		draw_px_rect(_rx, _ry, row_w, row_h, _pc, .8);
		if (_i == g.profile) draw_px_rect(_rx - 1, _ry - 1, row_w + 2, row_h + 2, c_gold, .5);

		if (_has) {
			// name up top, then the main-save card: playtime + profit
			draw_set_color(_pc);
			draw_text(_rx + 5, _ry + 4, g.profile_name[_i]);
			draw_set_halign(fa_right);
			draw_set_color(rgb(170, 190, 230));
			draw_text(_rx + row_w - 5, _ry + 4, crunch_time_long(_pi.playtime * 60));
			draw_set_halign(fa_left);
			draw_set_color(c_gold);
			draw_text(_rx + 5, _ry + 16, "profit " + crunch_arb(_pi.profit));
		} else {
			// no save = no profile yet: nothing but "empty", centered
			// (its name isn't real until the first save locks it in)
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(rgb(120, 130, 150));
			draw_text(_rx + row_w * .5, _ry + row_h * .5, "empty");
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
	}
}

// ================= page 1: the profile's slots =================
// (new-game mode: the difficulty picker instead - same slide)
if (slide > 0 && ng_mode) {
	draw_set_color(c_gold);
	draw_text(row_x + _ox1 + 46, 33, "select difficulty");

	for (var _i = 0; _i < 4; _i++) {
		var _rx = row_x + _ox1;
		var _ry = row_y0 + _i * row_sp;

		draw_sprite_ext(spr_pixel_1x1, 0, _rx, _ry, row_w, row_h, 0, c_black, .55);
		draw_px_rect(_rx, _ry, row_w, row_h, ng_col[_i], .8);

		draw_set_color(ng_col[_i]);
		draw_text(_rx + 5, _ry + 4, ng_label[_i]);
		draw_set_color(rgb(120, 130, 150));
		draw_text(_rx + 5, _ry + 16, ng_sub[_i]);
	}
}
if (slide > 0 && !ng_mode) {
	// (back is the framework button at the column's top left)
	draw_set_color(g.profile_color[sel_prof]);
	draw_text(row_x + _ox1 + 46, 33, g.profile_name[sel_prof]);

	for (var _i = 0; _i < 5; _i++) {
		var _rx = row_x + _ox1;
		var _ry = row_y0 + _i * row_sp;
		var _slot = slot_of_row[_i];
		var _inf  = info[_i];

		// frame color: main gold, autosaves steel, rebirth purple
		var _fc = rgb(120, 130, 150);
		if (_slot == 0) _fc = c_gold;
		if (_slot == 4) _fc = c_hpurple;

		draw_sprite_ext(spr_pixel_1x1, 0, _rx, _ry, row_w, row_h, 0, c_black, .55);
		draw_px_rect(_rx, _ry, row_w, row_h, _fc, .8);

		draw_set_color(c_white);
		draw_text(_rx + 5, _ry + 4, slot_label[_i]);

		if (!is_undefined(_inf) && _inf.valid) {
			// playtime top-right, profit on the second line
			draw_set_halign(fa_right);
			draw_set_color(rgb(170, 190, 230));
			draw_text(_rx + row_w - 5, _ry + 4, crunch_time_long(_inf.playtime * 60));
			draw_set_halign(fa_left);
			draw_set_color(c_gold);
			draw_text(_rx + 5, _ry + 16, "profit " + crunch_arb(_inf.profit));
		} else {
			draw_set_color(rgb(120, 130, 150));
			if (_slot == 0)      draw_text(_rx + 5, _ry + 16, "save to new file.");
			else if (_slot == 4) draw_text(_rx + 5, _ry + 16, "reserved");
			else                 draw_text(_rx + 5, _ry + 16, "empty");
		}
	}
}

draw_set_color(c_white);

// back, top right (the title's load path needs a way home; the nav
// stack pops to wherever you actually came from)
draw_set_font(fnt);
draw_ui_button(room_width - 62, obj_ui_header.sprite_height + 1, 56, 13,
	"back", rgb(170, 190, 230), true, false);
