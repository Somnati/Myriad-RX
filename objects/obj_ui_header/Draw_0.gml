


draw_sprite_ext(sprite_index,img+1,0,y,room_width,1,0,c_black,1);
draw_sprite_ext(sprite_index,img,0,y,room_width,1,0,col,1);

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

