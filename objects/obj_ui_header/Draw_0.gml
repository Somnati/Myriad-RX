


draw_sprite_ext(sprite_index,img+1,0,y,room_width,1,0,c_black,1);
draw_sprite_ext(sprite_index,img,0,y,room_width,1,0,col,1);

if (title_mode) exit;   // the bar alone (see the Create)

// ---- profit, top left: gliding arb counter + gain pops ----
if (variable_global_exists("profit")) {

	// THE IN-FLIGHT HOLD-BACK (Myriad DE's emit_gold). Profit is banked
	// the instant it is earned - that must never depend on a particle
	// surviving - but the COUNTER holds back whatever is still riding
	// bezier motes, so the number climbs as they land.
	// COMPUTED IN DRAW, NOT STEP, and that is load-bearing: the dials
	// spawn their motes during syst_dials' Step, and this object is
	// created first in the room, so a Step-time sum ran BEFORE the
	// motes existed - the ratchet below then latched the un-held-back
	// figure and dial payouts jumped. Every Step finishes before any
	// Draw, so here the motes are always already there.
	// RECOMPUTED FROM SCRATCH, never accumulated: a running total
	// drifts permanently short the first time a mote is culled by the
	// population cap.
	// SELF-HEAL: with nothing in the air, nothing can be owed. This
	// covers a spawn the population cap swallowed, a room with no
	// spitter in it at all, and leaving the room mid-flight.
	if (!instance_exists(obj_bezier_bit) && !instance_exists(obj_bezier_emit))
		g.profit_flight = 0;
	flight = g.profit_flight;

	var _tgt = (g.profit > flight) ? do_subtract(g.profit, flight) : 0;
	if (_tgt >= arb(1)) _tgt = do_floor(_tgt);   // profit is whole units; so is the shown figure
	
	// DE's RATCHET: do_add and do_subtract round differently either side
	// of a decade boundary, so the held-back figure could read 999.9b for
	// a frame while the real pile had just crossed 1.00t. Never let the
	// shown target fall while the real profit has not - a genuine spend
	// lowers g.profit and releases it.
	if (g.profit >= ratchet_real && _tgt < ratchet_tgt) _tgt = ratchet_tgt;
	ratchet_real = g.profit;
	ratchet_tgt  = _tgt;
	
	prof_shown = _tgt;

	// ⚖️ THE BIG NUMBER IS WHAT YOU CAN SPEND (his ask, 2026-09-08). It
	// used to be the whole pile with the free figure in a small chip
	// beside it, which put the number he could ACT on in the smaller
	// type and left the headline reading 23.8m while 2.39m was
	// purchasable. The counter is the wallet; the reserve is what the
	// wallet is not.
	//
	// prof_shown stays the WHOLE pile, untouched - obj_bignum5 rides it
	// and the blocks deliberately draw everything you own, reserve
	// included (his earlier call). So the header and the visualiser now
	// say two different true things on purpose: how much you can spend,
	// and how much you have.
	//
	// Measured against prof_shown rather than g.profit so the split is
	// of the SAME money the header is already withholding for motes in
	// flight - and through profit_spendable's own pile argument, so
	// there is still exactly one rule about where the line falls.
	// ...against the SHOWN pile's own high point (see the Create): the
	// real watermark already holds the payout in flight, and a floor
	// that rises before the money lands is a counter that dips on every
	// cycle at a 90% reserve
	if (prof_shown > shown_peak) shown_peak = prof_shown;
	if (variable_global_exists("autom") && shown_peak > g.autom.lock_peak)
		shown_peak = g.autom.lock_peak;
	var _pv  = profit_spendable(prof_shown, shown_peak);
	var _tlg = (_pv < arb(1)) ? -1 : arb_log10(_pv);

	// the glide (move_to in log space; 12 ~ a fifth of a second)
	if (_tlg == -1) prof_lg = -1;
	else {
		if (prof_lg == -1) prof_lg = 0; // waking from zero: run up from 1
		prof_lg = move_to(prof_lg, _tlg, 12);
		if (abs(prof_lg - _tlg) < .0004) prof_lg = _tlg; // settle exact
	}

	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_color(sett_ink);
	draw_set_alpha(.55);
	draw_text(6, 4, "profit");

	// THE RESERVE, said out loud - as the number you can ACT on.
	//
	// ⚖️ IT USED TO PRINT THE HELD FIGURE, and that reads as a second
	// pile sitting beside the first. It is not one: the reserve is a
	// PERCENTAGE OF the pile, so "121M" over "109M held" means 12M
	// spendable, not 230M owned. He read his own header the additive way
	// and went to the visualiser looking for a second hundred-million
	// square (2026-09-08). When the person who designed the feature
	// misreads the readout, the readout is what is wrong.
	//
	// So the chip states the FREE figure - the only one a purchase is
	// ever measured against - and the big number stays the whole pile,
	// which is also exactly what the blocks draw. Nothing can be read as
	// two totals any more. The held amount keeps its own line in
	// statistics, where there is room to say what it is.
	// The chip is now the COMPLEMENT of the big number, so the two add
	// up to the pile and neither can be read as a rival total: what you
	// can spend, in the headline, and what is held back, beside it.
	var _res = profit_reserved(prof_shown, shown_peak);
	if (_res >= arb(1)) {
		draw_set_color(c_gold);
		draw_set_alpha(.6);
		draw_text(6 + string_width("profit ") + 3, 4,
			crunch_arb(_res) + " held");
		draw_set_color(sett_ink);
		draw_set_alpha(.55);
	}

	// DIGITS WHILE THEY MEAN SOMETHING, crunched after (DE's, see
	// crunch_arb_full)
	var _ptxt = (prof_lg == -1) ? "0" : crunch_arb_full(log_to_arb(prof_lg));
	draw_set_color(g.profit_color);
	draw_set_alpha(.95);
	draw_text(6, 14, _ptxt);

	// THE WORD LINE (ui_wordline): under the words format the pile's
	// full name sits on its own line just under the bar - "quadrillion"
	// under 5.43qa - dim, in the profit colour. The readouts below the
	// header step down by ui_wordline_h() to make room.
	var _wl = ui_wordline(log_to_arb(max(0, prof_lg)));
	if (prof_lg != -1 && _wl != "") {
		draw_set_alpha(.6);
		draw_text(6, bar_h + 1, _wl);
		draw_set_alpha(.95);
	}

	// ---- the gain float: profit LANDED (spending only glides down) ----
	// It seats itself just past the counter, so it never lands on the
	// number it is describing however wide that number has grown.
	// ABOVE THE HEADER by necessity: it spawns at y 16, inside the
	// header's own opaque bar, so at the float band's -100 against the
	// header's -1000 it was drawn and painted straight over - invisible
	// (his audit, 2026-09-06). The short rise keeps it in the header's
	// neighbourhood instead of sailing up over the room.
	if (_pv > prof_last) {
		var _gain = do_subtract(_pv, prof_last);
		if (instance_exists(gain_f)) {
			// STACK: one float, counting up (see the Create)
			gain_val = do_add(gain_val, _gain);
			with (gain_f) {
				text = "+" + crunch_arb(other.gain_val);
				life = life_;                 // it earned another turn
				if (fnt_use != -1) draw_set_font(fnt_use);
				sw = string_width(text);      // width is cached at spawn
				if (fnt_use != -1) draw_set_font(fnt);
			}
		} else {
			gain_val = _gain;
			gain_f = float_text(6 + string_width(_ptxt) + 8, 16,
				"+" + crunch_arb(gain_val), g.profit_color, fnt_outline,
				depth - 10);
			gain_f.rise *= .5;
		}
	}
	prof_last = _pv;

	draw_set_alpha(1);
	draw_set_color(c_white);
}

// ---- THE BURST CHIPS (his spec, 2026-09-16): one 8x8 icon per running
// burst, top right, a 1px bar a pixel under it that DRAINS TOWARD THE
// LEFT with the time left - a health bar, his first pick. Bursts of one
// kind add up but keep their own clocks (his rule), so every one gets a
// chip: tap chips first, then dial chips, right to left. Under the
// pointer a chip says its number and its clock. upgrade_burst_mult
// prunes what has run out as it reads, so the row empties itself. ----
// Left of the window buttons (room_width-48.., y 0..11) on a wide room;
// under them on a portrait one, clear of the counter.
var _bl = variable_global_exists("upg") ? g.upg[$ "bursts"] : undefined;
if (is_array(_bl) && array_length(_bl) > 0) {
	upgrade_burst_mult("tap");   // the prune
	var _now   = universal_now();
	var _wide  = (room_width >= 300);
	var _cxr   = _wide ? (room_width - 54) : (room_width - 6);   // the row's right edge
	var _cx    = _cxr;
	var _cy    = _wide ? 4 : 15;
	var _kinds = ["tap", "dial"];
	var _hov   = -1;
	for (var _k = 0; _k < 2; _k++) {
		var _kind = _kinds[_k];
		var _col  = burst_col[$ _kind];
		var _px   = burst_px[$ _kind];
		for (var _i = 0; _i < array_length(_bl); _i++) {
			var _b = _bl[_i];
			if (_b.kind != _kind) continue;
			var _left = _b.ends - _now;
			if (_left <= 0) continue;
			var _x0 = _cx - 8;
			// the icon
			for (var _p = 0; _p < array_length(_px); _p++)
				draw_sprite_ext(spr_pixel_1x1, 0, _x0 + _px[_p][0], _cy + _px[_p][1], 1, 1, 0, _col, .9);
			// the bar, a pixel under it: what is left, anchored left so
			// its end walks leftward as the clock runs
			var _f = clamp(_left / max(1, _b.dur), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _x0, _cy + 9, 8, 1, 0, c_black, .6);
			draw_sprite_ext(spr_pixel_1x1, 0, _x0, _cy + 9, max(1, round(8 * _f)), 1, 0, _col, .95);
			if (point_in_rectangle(mouse_x, mouse_y, _x0 - 1, _cy - 1, _x0 + 8, _cy + 10)) _hov = _i;
			_cx -= 11;
		}
	}
	// under the pointer: the number and the clock, right-aligned to the row
	if (_hov >= 0) {
		var _hb = _bl[_hov];
		var _hl = max(0, round(_hb.ends - _now));
		var _ss = _hl mod 60;
		draw_set_halign(fa_right);
		draw_set_color(burst_col[$ _hb.kind]);
		draw_set_alpha(.95);
		draw_text(_cxr, _cy + 12, "x" + string_format(_hb.mult, 1, 2) + "  "
			+ string(floor(_hl / 60)) + ":" + ((_ss < 10) ? "0" : "") + string(_ss));
		draw_set_halign(fa_left);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}
