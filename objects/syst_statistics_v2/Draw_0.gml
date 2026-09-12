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

// backdrop: BLACK AND SLIGHTLY OPEN (his ask, 2026-09-08) so the
// menu_blur layer under it reads through. It was fully opaque because
// the screen was a room and there was nothing behind it worth seeing;
// as an overlay the softened room IS the thing behind it. The row
// panels stay opaque, so what shows through is the gaps between them -
// which is exactly where a blur wants to be seen.
// it is also the FIRST part to arrive (index 0): the ground lands, then
// the strip, then the list deals in behind them. Contents that arrive
// before their own background read as debris, not as a screen opening.
// (no ground of its own: obj_menu2_bck paints the plate + gradients UNDER the blur - his "menu blur" ask)

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
	// the row's own opacity, on the same stagger as its rise. ONE call
	// in front of the row rather than a multiply on each of the 56
	// alphas this event carries - see ui_fade_set for why
	ui_fade_set(ui_anim_in(oa, _r - floor(g.stats_page)));

	// ---- the panel surface (zebra + seams + indent guides) ----
	var _bh = row_h * _row.span;
	__row_panel(_r, _row, _ry, _bh);

	// hover wash on the tappable rows (settings has one; match it)
	if (_row.kind == 1 || _row.kind == 4 || _row.kind == 5)
	if (input_free(ui_layer_popup))
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
		// folder: the +/- chip (his call: the signs read better than
		// arrows) + the name, both on flat black - the section colour
		// is the gradient coming in from the right now (__row_panel),
		// so the left edge band this used to draw would be a second
		// answer to a question already answered, at the exact spot the
		// new look is trying to keep clean.
		// The chip's face lifts OFF black rather than filling with it:
		// black on black was only ever its frame.
		draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ry + 2, 9, 9, 0,
			merge_colour(_row.c1, c_black, .78), 1);
		draw_px_rect(_tx, _ry + 2, 9, 9, _row.c1, .55);
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
			// the "?" chip marks tappable explainers (draw_help_chip);
			// the whole row opens one here, so it lights with the row
			var _qx = _tx + string_width(_row.name) + 5;
			var _hot = (mouse_y >= list_y && mouse_x >= content_x
				&& point_in_rectangle(mouse_x, mouse_y, content_x, _ry, val_x, _ry + row_h - 1));
			draw_help_chip(_qx, _ry + 3, _row.c1, _hot);
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
				if (input_free(ui_layer_popup))
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
	if (_row.kind == 8) {
		// THE RARITY SPREAD (Techdemo II's rarity bar, in this room's
		// language). TWO strips - the odds above, what has actually been
		// rolled below - over an aligned list, because the interesting
		// half of any ladder is its tail and a tail needs columns.
		var _rx0 = _tx;
		var _rw0 = val_x - _rx0;
		var _ry0 = _ry + 4;
		var _rsh = 8;                 // the expected strip
		var _ren = _row.data;
		var _rn  = is_array(_ren) ? array_length(_ren) : 0;

		// the observed total, which decides whether the second strip
		// exists at all - nothing rolled yet is not a distribution
		var _rtot = 0;
		for (var _rg = 0; _rg < _rn; _rg++)
			_rtot += max(0, _ren[_rg][$ "seen"] ?? 0);

		draw_set_alpha(1);
		draw_sprite_ext(spr_pixel_1x1, 0, _rx0, _ry0, _rw0, _rsh, 0, c_black, .35);
		if (_rtot > 0)
			draw_sprite_ext(spr_pixel_1x1, 0, _rx0, _ry0 + _rsh + 1, _rw0, 4, 0,
				c_black, .35);

		// pass one finds the segment under the pointer, so pass two can
		// dim everything else - the hover has to be known before the
		// first segment is painted
		var _rhov = -1;
		var _rcx  = _rx0;
		for (var _rg = 0; _rg < _rn; _rg++) {
			var _rsw = clamp(_ren[_rg].p, 0, 1) * _rw0;
			var _rfx = floor(_rcx);
			var _rfw = max(1, floor(_rcx + _rsw) - _rfx);
			if (input_free(ui_layer_popup))
			if (point_in_rectangle(mouse_x, mouse_y, _rfx, _ry0, _rfx + _rfw,
				_ry0 + _rsh)) _rhov = _rg;
			_rcx += _rsw;
		}

		_rcx = _rx0;
		var _rcx2 = _rx0;
		for (var _rg = 0; _rg < _rn; _rg++) {
			var _re  = _ren[_rg];
			var _rc  = _re.col;
			var _lit = (_rhov == _rg || _rhov == -1);
			var _rsw = clamp(_re.p, 0, 1) * _rw0;
			var _rfx = floor(_rcx);
			var _rfw = max(1, floor(_rcx + _rsw) - _rfx);
			draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _rfx, _ry0, _rfw, _rsh, 0,
				merge_colour(_rc, c_white, .22), merge_colour(_rc, c_white, .22),
				merge_colour(_rc, c_black, .3), merge_colour(_rc, c_black, .3),
				_lit ? 1 : .3);
			// a hairline between neighbours, so two similar colours do
			// not read as one wider rung
			if (_rg > 0)
				draw_sprite_ext(spr_pixel_1x1, 0, _rfx, _ry0, 1, _rsh, 0, c_black, .55);
			_rcx += _rsw;

			// the rolled strip: the same colours, thinner and flat, so
			// it reads as a SAMPLE of the curve above it rather than as
			// a second statistic competing with it
			if (_rtot > 0) {
				var _rsn = max(0, _re[$ "seen"] ?? 0);
				var _rw2 = (_rsn / _rtot) * _rw0;
				var _rfx2 = floor(_rcx2);
				if (_rsn > 0)
					draw_sprite_ext(spr_pixel_1x1, 0, _rfx2, _ry0 + _rsh + 1,
						max(1, floor(_rcx2 + _rw2) - _rfx2), 4, 0, _rc, _lit ? .85 : .25);
				_rcx2 += _rw2;
			}
		}

		// ---- THE OVERALL RATE, above the list (DE's par_raritybar) ----
		// It is the cause of every rung below it, so it reads first and
		// it reads brighter. The rungs are a consequence; this is the
		// number the player actually moves.
		var _rly = _ry0 + _rsh + ((_rtot > 0) ? 7 : 3);
		if (_row.val != "") {
			draw_set_halign(fa_left);
			draw_set_color(c_horange);
			draw_set_alpha(.9);
			draw_text(_rx0, _rly, _row.val);
			_rly += 8;
		}

		// ---- the list, in fixed columns ----
		var _rcA = _rx0 + _rw0 * .46;   // chance,  right-aligned
		var _rcB = _rx0 + _rw0 * .66;   // 1 in N,  right-aligned
		var _rcC = _rx0 + _rw0;         // rolled,  right-aligned

		draw_set_halign(fa_right);
		draw_set_color(_row.c2);
		draw_set_alpha(.3);
		draw_text(_rcA, _rly, "chance");
		draw_text(_rcB, _rly, "1 in");
		if (_rtot > 0) draw_text(_rcC, _rly, "rolled");
		_rly += 8;

		for (var _rg = 0; _rg < _rn; _rg++) {
			if (_rly > _ry + _bh - 8) break;
			var _re  = _ren[_rg];
			var _lit = (_rhov == _rg || _rhov == -1);
			var _rpc = clamp(_re.p, 0, 1) * 100;

			// DECIMALS BY MAGNITUDE (Techdemo II's rule). A tail printed
			// at one decimal is a tail printed as zero, and the tail is
			// the only part of this list anybody reads twice.
			var _rdec = 2;
			if (_rpc >= 10)  _rdec = 1;
			if (_rpc < .1)   _rdec = 3;
			if (_rpc < .001) _rdec = 0;

			// "1 in N", rounded to clean figures by magnitude - an exact
			// 1 in 3127 says less than 1 in 3100 does
			var _rinv = (_re.p > 0) ? (1 / _re.p) : 0;
			var _rtxt = "-";
			if (_rinv > 0) {
				if (_rinv < 20)        _rinv = round(_rinv);
				else if (_rinv < 100)  _rinv = round(_rinv / 5) * 5;
				else if (_rinv < 1000) _rinv = round(_rinv / 10) * 10;
				else                   _rinv = round(_rinv / 100) * 100;
				_rtxt = string(_rinv);
			}

			draw_set_halign(fa_left);
			draw_sprite_ext(spr_pixel_1x1, 0, _rx0, _rly + 2, 4, 4, 0, _re.col,
				_lit ? .95 : .25);
			draw_set_color(_re.col);
			draw_set_alpha(_lit ? .9 : .25);
			draw_text(_rx0 + 8, _rly, _re.name);

			draw_set_halign(fa_right);
			draw_set_color(_row.c2);
			draw_set_alpha(_lit ? .8 : .25);
			draw_text(_rcA, _rly, string_format(_rpc, 1, _rdec) + "%");
			draw_set_alpha(_lit ? .45 : .18);
			draw_text(_rcB, _rly, _rtxt);
			if (_rtot > 0) {
				var _rsn = max(0, _re[$ "seen"] ?? 0);
				draw_set_color((_rsn > 0) ? _re.col : _row.c2);
				draw_set_alpha(_lit ? ((_rsn > 0) ? .85 : .35) : .22);
				draw_text(_rcC, _rly, string(_rsn));
			}
			_rly += 8;
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
			// ⚖️ THE X AXIS IS NOT ONE SAMPLE A SECOND ANY MORE. The
			// buffer halves itself as it fills and doubles its interval,
			// so the window grows to cover the account's whole lifetime -
			// and a graph that still printed "120s" under six weeks of
			// history would be the most confident kind of wrong. Every
			// duration below is samples x THIS series' step.
			var _hm = (variable_global_exists("hist_meta"))
				? g.hist_meta[$ _row.val] : -1;
			var _hs = is_struct(_hm) ? _hm.step : 1;
			// ...plus the seconds counted toward the NEXT sample (his
			// ask, 2026-09-10: "still tic its timer even though it's not
			// updating due to the size"). Once the buffer has halved a
			// few times a sample lands every 8, 16, 32 seconds, and a
			// window that only grew when one did sat frozen between
			// them. The push's own accumulator is that clock.
			var _hacc = is_struct(_hm) ? _hm.acc : 0;
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
			draw_text(_gx + _gw - 4, _gy + _gh - 10,
				crunch_time_long((_nn * _hs + _hacc) * 60));
			// THE LIVE VALUE at the value column, on the title line
			draw_set_color(_row.c1);
			draw_set_alpha(.95);
			draw_text(val_x, _ry + 4, crunch_arb(_arr[_nn - 1]));

			// hover scrub (display only - claims no clicks; hidden
			// while a menu/popup owns the input)
			if (input_free(ui_layer_popup))
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
				// how long ago in the SERIES' own time, not in samples -
				// crunch_time_long takes frames, hence the x60
				var _ago = round(((_nn - 1) - _sf2) * _hs + _hacc);
				var _stx = crunch_arb(_v2) + "  -"
					+ ((_ago <= 0) ? "now" : crunch_time_long(_ago * 60));
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
// the row loop is the only thing that fades per-row; put it back before
// anything else draws, whatever gets added between here and the rail
ui_fade_set(1);

// ---- THE CATEGORY RAIL, syst_settings' verbatim (his ask: make this
// room look like that one). Drawn AFTER the rows, which is what lets
// the favourite gutter slide out from behind it. menu2's colour
// language: identity pip at the left edge, active = solid fill + white,
// the rest sink toward black. ----
// IT SLIDES IN FROM ITS OWN EDGE - the left one, mirroring the menu
// drawer's rule on the right. One world matrix, so the tab loop below
// is untouched and its hit tests (read in the Step) keep their final
// geometry, which the input gate makes safe.
var _rp = ui_anim_in(oa, 1);
var _ro = -(1 - _rp) * (rail_w + UI_IN_SLIDE);
if (_ro != 0)
	matrix_set(matrix_world, matrix_build(_ro, 0, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_rp);   // it fades as it slides, like the rows

draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_hsv(169, 186, 7), .97);
draw_sprite_ext(spr_pixel_1x1, 0, rail_w - 1, list_y, 1, room_height - list_y, 0,
	c_black, .5);

// (the rail's scrollbar is sb_rail - the house bar, in the lane left
// of the tabs; it draws itself and hides when the tabs fit)
var _tb = __tabs();
for (var _i = 0; _i < array_length(_tb); _i++) {
	var _t = _tb[_i];
	// a tab scrolled under the strip or off the bottom is not drawn -
	// the strip proxy paints over the band's top anyway
	if (_t.y2 < list_y || _t.y1 > room_height) continue;
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
ui_fade_set(1);
if (_ro != 0) matrix_set(matrix_world, matrix_build_identity());

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
