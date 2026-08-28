


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
	
	// DE's RATCHET: do_add and do_subtract round differently either side
	// of a decade boundary, so the held-back figure could read 999.9b for
	// a frame while the real pile had just crossed 1.00t. Never let the
	// shown target fall while the real profit has not - a genuine spend
	// lowers g.profit and releases it.
	if (g.profit >= ratchet_real && _tgt < ratchet_tgt) _tgt = ratchet_tgt;
	ratchet_real = g.profit;
	ratchet_tgt  = _tgt;
	
	prof_shown = _tgt;

	// the target is the HELD-BACK figure, not the raw pile - Step
	// subtracts what is still in flight so the count arrives with the
	// motes (his ask, and DE's behaviour)
	var _pv  = prof_shown;
	var _tlg = (_pv < arb(1)) ? -1 : arb_log10(_pv);

	// gain pop: profit LANDED (a sale) - spending only glides down
	if (_pv > prof_last)
		float_text(48, 16, "+" + crunch_arb(do_subtract(_pv, prof_last)),
			g.profit_color);
	prof_last = _pv;

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
	draw_set_color(g.profit_color);
	draw_set_alpha(.95);
	draw_text(6, 14, (prof_lg == -1) ? "0" : crunch_arb(log_to_arb(prof_lg)));
	draw_set_alpha(1);
	draw_set_color(c_white);
}

