/// the list body, ZEBRA edition (2026-07-12, his call: match what
/// rm_settings looks like - the raised-panel round-2 look retired).
/// the panel surface itself paints in __row_panel (Create), shared
/// with the close-anim ghosts; it stays OPAQUE because the unfurl
/// depends on it: the row loop runs TWO passes - emerging children
/// draw first (pass 0) at their TRUE sheet position, everything else
/// paints OVER them (pass 1) - so a child genuinely slides out from
/// under the folder row instead of popping in. (the old version
/// PINNED emerging children in a stack at the fold line; exposed at
/// the list bottom that read as rows stuck/popping - his report.)
/// the screen still stacks by DEPTH (settings' recipe): rows HERE ->
/// widgets (depth-1) -> the title strip proxy (depth-2) -> menu -520.

// backdrop: fully opaque - panels composite on a known surface
draw_sprite_ext(spr_pixel_1x1, 0, 0, obj_ui_header.sprite_height - 2,
	room_width, room_height, 0, c_hsv(169, 186, 5), 1);

draw_set_font(fnt);

// ---- closing: the removed children ride back UP under the fold as
// ghosts (frozen copies captured at the rebuild). they draw before
// BOTH passes, so every live row paints over them and they submerge
// under the folder row exactly the way opening children emerge ----
if (anim_t < 1 && anim_n < 0) {
	var _gy = __row_y(anim_row) + row_h - anim_t * (-anim_n) * row_h;
	for (var _k = 0; _k < array_length(anim_ghost); _k++) {
		var _gr2 = anim_ghost[_k];
		// entries are line-padded (kind 3 pads fill spans), one line each
		if (_gr2.kind != 3)
		if (_gy + row_h * _gr2.span > list_y && _gy < room_height)
			__ghost_paint(anim_row + 1 + _k, _gr2, _gy);
		_gy += row_h;
	}
}

// ---- the rows, windowed, two passes (emerging children UNDER) ----
var _n = array_length(view);
var _first = max(0, floor(g.stats_page));
var _lo = max(0, _first - span_max + 1);
// while an anim runs, rows beyond the window slide through view -
// reach that much further so neither edge ever gaps
var _reach = (anim_t < 1) ? abs(anim_n) : 0;
var _unfurl = (anim_t < 1 && anim_n > 0);

var _hi = min(_n, _first + visible_rows + 1 + _reach);
for (var _pass = 0; _pass < 2; _pass++) {
for (var _r = _lo; _r < _hi; _r++) {
	var _row = view[_r];
	if (_row.kind == 3) continue; // pads: their widget row drew the block
	var _emerging = (_unfurl && _r > anim_row && _r <= anim_row + anim_n);
	if ((_pass == 0) != _emerging) continue;
	// emerging children draw at their TRUE sheet position - the opaque
	// folder row and everything above (pass 1) covers them until they
	// clear the fold, so they emerge pixel by pixel, never pinned
	var _ry = __row_y(_r) + __anim_off(_r);
	if (_ry + row_h * _row.span < list_y) continue;
	if (_ry > room_height) { if (_pass == 1) break; continue; }

	// ---- the panel surface (zebra + seams + indent guides) ----
	var _bh = row_h * _row.span;
	__row_panel(_r, _row, _ry, _bh);

	// hover wash on the tappable rows (settings has one; match it)
	if (_row.kind == 1 || _row.kind == 4 || _row.kind == 5)
	if (input_free())
	if (mouse_y >= list_y)
	if (mouse_x >= rail_w)
	if (point_in_rectangle(mouse_x, mouse_y, rail_w, _ry, room_width, _ry + _bh - 1))
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, room_width - rail_w, _bh,
			0, c_white, .04);

	// THE NAME'S SEAT. Depth 0 is the rail now, so a tab's own rows sit
	// at depth 1 and the indent is measured from there. The whole column
	// steps RIGHT as the favourite gutter comes out (fav_t), which is
	// what makes room for the star without reflowing anything else.
	var _tx = content_x - 2 + fav_t * 10 + max(0, _row.fdep - 1) * 10;

	if (_row.kind == 1) {
		// folder: section band + the +/- chip (his call: the signs
		// read better than arrows) + tinted name
		draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _ry, 2, _bh, 0, _row.c1, .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ry + 2, 9, 9, 0, c_black, .45);
		draw_px_rect(_tx, _ry + 2, 9, 9, _row.c1, .5);
		draw_set_halign(fa_center);
		draw_set_color(_row.c1);
		draw_set_alpha(.95);
		draw_text(_tx + 5, _ry + 3, _row.open ? "-" : "+");
		draw_set_halign(fa_left);
		draw_text(_tx + 14, _ry + 4, _row.name);
		continue;
	}

	// the pin gutter: every named line carries a star pip at the far
	// left - lit gold when favorited, a dim socket otherwise. The [favs]
	// button in the title strip puts the whole gutter away; the row's
	// own indent does not move, so nothing reflows when it does.
	// it SLIDES OUT FROM BEHIND THE RAIL: the rail paints after the rows,
	// so a pip parked at rail_w - 6 is simply covered, and the same lerp
	// that walks it into the band walks the names right to meet it.
	if (fav_t > .01 && _row.kind == 0 && _row.name != "") {
		var _fx = lerp(rail_w - 6, content_x + 1, fav_t);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _ry + 5, 4, 4, 0,
			_row.fav ? c_gold : c_black, _row.fav ? .95 : .55);
		if (!_row.fav) draw_px_rect(_fx, _ry + 5, 4, 4, c_gray, .35);
	}

	// plain + widget + toggle + cycle + spark rows: name left
	if (_row.name != "") {
		draw_set_halign(fa_left);
		draw_set_color(_row.c1);
		draw_set_alpha(.9);
		draw_text(_tx, _ry + 4, _row.name);
		if (_row.kind == 0 && _row.help != "") {
			// a whisper of a "?" marks tappable explainers
			draw_set_alpha(.3);
			draw_text(_tx + string_width(_row.name) + 5, _ry + 4, "?");
		}
	}
	if (_row.kind == 0 && _row.val != "") {
		draw_set_halign(fa_right);
		draw_set_color(_row.c2);
		draw_set_alpha(.95);
		draw_text(val_x, _ry + 4, _row.val);
		// change pulse: a white flash decaying over the value when it
		// moved since the last rebuild that saw it
		var _pt = __pulse[$ _row.key] ?? -9999;
		var _age = __tick - _pt;
		if (_age >= 0 && _age < 45) {
			draw_set_color(c_white);
			draw_set_alpha(.9 * (1 - _age / 45));
			draw_text(val_x, _ry + 4, _row.val);
		}
	}
	if (_row.kind == 4) {
		// toggle: the house status pill (teal = on, gray = off)
		draw_status_pill(val_x, _ry + 2, _row.open ? "on" : "off",
			_row.open ? uist.positive : uist.neutral, fa_right);
	}
	if (_row.kind == 5) {
		// cycle: the current option between tap-me chevrons
		var _lbl = "";
		var _cn = array_length(_row.data);
		if (_cn > 0) {
			var _iv = 0;
			if (variable_global_exists(_row.val)) _iv = variable_global_get(_row.val);
			_lbl = string(_row.data[clamp(_iv, 0, _cn - 1)]);
		}
		draw_set_halign(fa_right);
		draw_set_color(c_gold);
		draw_set_alpha(.95);
		draw_text(val_x, _ry + 4, "< " + _lbl + " >");
	}
	if (_row.kind == 7) {
		// THE CONTRIBUTION BAR. One stacked strip, a segment per
		// contributor, width proportional to its share of the total.
		// Shares are SIGNED and the widths use their MAGNITUDE, so a
		// factor that takes away still occupies the strip - drawn dark
		// with a hatch so it reads as a tax rather than as a gap. That
		// is the point of the whole row: on a list of numbers a x0.8
		// ramp and a x2 milestone are two similar lines, and here you
		// can see which one is deciding the outcome.
		var _bx0 = _tx;
		var _bw0 = (val_x - 2) - _bx0;
		var _by0 = _ry + row_h - 2;
		var _bh0 = 9;
		var _sg  = _row.data;
		draw_set_alpha(1);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx0, _by0, _bw0, _bh0, 0, c_black, .35);
		if (is_array(_sg) && array_length(_sg) > 0) {
			// walk twice: the strip, then the legend under it
			var _cx0 = _bx0;
			var _hovi = -1;
			for (var _g = 0; _g < array_length(_sg); _g++) {
				var _sw = abs(_sg[_g].share) * _bw0;
				// a contributor worth drawing is worth seeing
				if (_sw < 1 && abs(_sg[_g].share) > 0) _sw = 1;
				var _neg = (_sg[_g].share < 0);
				var _sc0 = _sg[_g].col;
				var _fx0 = floor(_cx0);
				var _fw0 = max(1, floor(_cx0 + _sw) - _fx0);
				if (input_free())
				if (point_in_rectangle(mouse_x, mouse_y, _fx0, _by0,
					_fx0 + _fw0, _by0 + _bh0)) _hovi = _g;
				var _lit = (_hovi == _g);
				if (_neg) {
					draw_sprite_ext(spr_pixel_1x1, 0, _fx0, _by0, _fw0, _bh0, 0,
						merge_colour(_sc0, c_black, .62), _lit ? 1 : .9);
					// the hatch: every third column, so a penalty is
					// legible at a glance and at one pixel wide
					for (var _hx = 0; _hx < _fw0; _hx += 3)
						draw_sprite_ext(spr_pixel_1x1, 0, _fx0 + _hx, _by0, 1, _bh0,
							0, c_black, .35);
				} else
					draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
						_fx0, _by0, _fw0, _bh0, 0,
						merge_colour(_sc0, c_white, .22), merge_colour(_sc0, c_white, .22),
						merge_colour(_sc0, c_black, .3), merge_colour(_sc0, c_black, .3),
						_lit ? 1 : .92);
				// a hairline between segments, so neighbours of similar
				// colour do not read as one block
				if (_g > 0)
					draw_sprite_ext(spr_pixel_1x1, 0, _fx0, _by0, 1, _bh0, 0,
						c_black, .55);
				_cx0 += _sw;
			}
			// the legend: name and share, wrapped across the row's rest.
			// Hovering a segment promotes its entry instead of opening a
			// tooltip - the list is right there, a floating box over it
			// would be one layer too many.
			var _ly0 = _by0 + _bh0 + 3;
			var _lx0 = _bx0;
			draw_set_halign(fa_left);
			for (var _g = 0; _g < array_length(_sg); _g++) {
				var _txt = _sg[_g].name + " "
					+ string(round(abs(_sg[_g].share) * 100)) + "%";
				var _tw0 = string_width(_txt) + 12;
				if (_lx0 + _tw0 > _bx0 + _bw0) { _lx0 = _bx0; _ly0 += 9; }
				if (_ly0 > _ry + _bh - 8) break;
				var _on0 = (_hovi == _g || _hovi == -1);
				draw_sprite_ext(spr_pixel_1x1, 0, _lx0, _ly0 + 1, 4, 4, 0,
					_sg[_g].col, _on0 ? .95 : .3);
				draw_set_color(_sg[_g].share < 0 ? c_hred : sett_ink);
				draw_set_alpha(_on0 ? .8 : .28);
				draw_text(_lx0 + 7, _ly0 - 1, _txt);
				_lx0 += _tw0;
			}
		} else {
			draw_set_halign(fa_left);
			draw_set_color(_row.c2);
			draw_set_alpha(.35);
			draw_text(_bx0 + 6, _by0 + 1, "nothing to break down");
		}
		draw_set_halign(fa_left);
		draw_set_alpha(1);
	}
	if (_row.kind == 6) {
		// the history graph: a filled AREA under a bright line, quarter
		// gridlines, hi/lo labels in a right gutter and the live value
		// at the value column - samples are packed arbs, so crunch_arb
		// formats every label directly (and the packing is log scale,
		// exactly the axis an idle curve wants). hover to SCRUB: a
		// cursor line with the exact value + how many seconds ago.
		// THE GRAPH GETS THE WHOLE WIDTH. It used to give 52px to a
		// right-hand gutter holding "hi", "lo" and the window length -
		// three labels renting a fifth of the plot. They sit INSIDE the
		// pane now, dim and out of the way at the corners, which is
		// both less furniture and a wider curve.
		var _gx = _tx;
		var _gy = _ry + row_h;
		var _gh = _bh - row_h - 5;
		var _gw = (val_x - 2) - _gx;
		var _arr = g.stats_hist[$ _row.val] ?? -1;
		if (!is_array(_arr) || array_length(_arr) < 2) {
			draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, _gw, _gh, 0, c_black, .3);
			draw_set_halign(fa_left);
			draw_set_color(_row.c2);
			draw_set_alpha(.35);
			draw_text(_gx + 6, _gy + (_gh >> 1) - 3, "gathering samples...");
		}
		else {
			var _nn = array_length(_arr);
			var _vmn = _arr[0]; var _vmx = _arr[0];
			for (var _s = 1; _s < _nn; _s++) {
				_vmn = min(_vmn, _arr[_s]);
				_vmx = max(_vmx, _arr[_s]);
			}
			var _lmn = _vmn; var _lmx = _vmx; // label the TRUE window
			if (_vmx - _vmn < 0.0001) { _vmn -= .5; _vmx += .5; } // flat

			// the pane: no frame. A rectangle drawn around a graph that
			// already sits on its own darker field is a line doing
			// nothing, and four of them stacked read as a table.
			draw_set_alpha(1);
			draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, _gw, _gh, 0, c_black, .3);
			for (var _q = 1; _q < 4; _q++)
				draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + (_gh * _q) div 4,
					_gw - 2, 1, 0, c_white, .045);
			// a baseline, brighter than the gridlines: the curve needs
			// something to stand on or it floats in the pane
			draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1, _gy + _gh - 1, _gw - 2, 1, 0,
				merge_colour(_row.c1, c_black, .45), .8);

			// THE CURVE. One column per screen pixel, lerped between
			// samples. Two changes from the first cut, both about how
			// it reads rather than what it plots:
			//  - the fill is a VERTICAL GRADIENT, near the line and
			//    gone by the floor, instead of a flat 18% wash. Flat
			//    fills fight the gridlines for attention; a gradient
			//    puts the weight where the data is.
			//  - the line CONNECTS to the previous column instead of
			//    drawing a 2px stub at each height, so a steep slope is
			//    a line rather than a dotted staircase.
			var _cf_t = merge_colour(_row.c1, c_white, .12);
			var _cf_b = merge_colour(_row.c1, c_black, .82);
			var _lc   = merge_colour(_row.c1, c_white, .35);
			var _prev = -1;
			for (var _px = 0; _px < _gw - 2; _px++) {
				var _sf = (_px / max(1, _gw - 3)) * (_nn - 1);
				var _s0 = floor(_sf);
				var _v = lerp(_arr[_s0], _arr[min(_s0 + 1, _nn - 1)], frac(_sf));
				var _hh = clamp((_v - _vmn) / (_vmx - _vmn), 0, 1) * (_gh - 5);
				var _cx = _gx + 1 + _px;
				var _cy = _gy + _gh - 2 - _hh;
				var _fh = (_gy + _gh - 1) - _cy;
				if (_fh > 0)
					draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
						_cx, _cy, 1, _fh, 0, _cf_t, _cf_t, _cf_b, _cf_b, .55);
				// connect to the last column so slopes stay unbroken
				var _y1 = (_prev < 0) ? _cy : min(_prev, _cy);
				var _y2 = (_prev < 0) ? _cy : max(_prev, _cy);
				draw_sprite_ext(spr_pixel_1x1, 0, _cx, _y1, 1,
					max(1, _y2 - _y1) + 1, 0, _lc, .95);
				_prev = _cy;
			}

			// hi / lo / window, INSIDE the pane at the corners, dim
			// enough to read as axis furniture rather than as data.
			// Scale 1: fnt is a sprite font and the old .85 was
			// resampling every glyph (integer scale only, house rule).
			draw_set_halign(fa_left);
			draw_set_color(sett_ink);
			draw_set_alpha(.4);
			draw_text(_gx + 4, _gy + 2, crunch_arb(_lmx));
			draw_text(_gx + 4, _gy + _gh - 10, crunch_arb(_lmn));
			draw_set_halign(fa_right);
			draw_set_alpha(.3);
			draw_text(_gx + _gw - 4, _gy + _gh - 10, string(_nn) + "s");
			// THE LIVE VALUE at the value column, on the title line
			draw_set_color(_row.c1);
			draw_set_alpha(.95);
			draw_text(val_x, _ry + 4, crunch_arb(_arr[_nn - 1]));

			// hover scrub (display only - claims no clicks; hidden
			// while a menu/popup owns the input)
			if (input_free())
			if (point_in_rectangle(mouse_x, mouse_y, _gx, _gy, _gx + _gw, _gy + _gh)) {
				var _px2 = clamp(mouse_x - _gx - 1, 0, _gw - 3);
				var _sf2 = (_px2 / max(1, _gw - 3)) * (_nn - 1);
				var _v2 = lerp(_arr[floor(_sf2)],
					_arr[min(floor(_sf2) + 1, _nn - 1)], frac(_sf2));
				var _hh2 = clamp((_v2 - _vmn) / (_vmx - _vmn), 0, 1) * (_gh - 4);
				var _cy2 = _gy + _gh - 2 - _hh2;
				draw_sprite_ext(spr_pixel_1x1, 0, _gx + 1 + _px2, _gy + 1,
					1, _gh - 2, 0, c_white, .25);
				draw_sprite_ext(spr_pixel_1x1, 0, _gx + _px2 - 1, _cy2 - 1,
					4, 4, 0, c_white, .9);
				var _stx = crunch_arb(_v2) + "  -"
					+ string(round((_nn - 1) - _sf2)) + "s";
				var _stw = string_width(_stx) + 8;
				var _sx2 = clamp(_gx + _px2 + 8, _gx, _gx + _gw - _stw);
				draw_sprite_ext(spr_pixel_1x1, 0, _sx2, _gy + 2, _stw, 11, 0,
					c_black, .9);
				draw_px_rect(_sx2, _gy + 2, _stw, 11, _row.c1, .6);
				draw_set_halign(fa_left);
				draw_set_color(merge_colour(_row.c1, c_white, .4));
				draw_text(_sx2 + 4, _gy + 4, _stx);
			}
		}
	}
}
}

// ---- THE CATEGORY RAIL, syst_settings' verbatim (his ask: make this
// room look like that one). Drawn AFTER the rows, which is what lets
// the favourite gutter slide out from behind it. menu2's colour
// language: identity pip at the left edge, active = solid fill + white,
// the rest sink toward black. ----
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, rail_w - 1, list_y, 1, room_height - list_y, 0,
	c_black, .5);

var _tb = __tabs();
for (var _i = 0; _i < array_length(_tb); _i++) {
	var _t = _tb[_i];
	var _s = sections[_t.idx];
	var _on = (_i == g.stats_tab);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _t.x1, _t.y1, _t.x2, _t.y2);
	var _tw = _t.x2 - _t.x1;
	var _th = _t.y2 - _t.y1;
	draw_set_alpha(1);
	if (_on)
		draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _tw, _th, 0,
			merge_colour(_s.col, c_black, .6), .92);
	else
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _t.x1, _t.y1, _tw, _th, 0,
			c_black, merge_colour(_s.col, c_black, _hov ? .5 : .75),
			merge_colour(_s.col, c_black, _hov ? .5 : .75), c_black, .85);
	draw_sprite_ext(spr_pixel_1x1, 0, _t.x1, _t.y1, _hov || _on ? 3 : 2, _th, 0,
		merge_colour(_s.col, c_white, .2), 1);
	draw_set_halign(fa_left);
	draw_set_color(_on ? c_white : merge_colour(_s.col, c_white, _hov ? .7 : .45));
	draw_set_alpha(.95);
	draw_text(_t.x1 + 7, _t.y1 + ((_th - 7) div 2), _s.name);
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
