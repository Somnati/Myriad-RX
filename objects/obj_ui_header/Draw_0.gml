


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

	// the target is the HELD-BACK figure, not the raw pile - Step
	// subtracts what is still in flight so the count arrives with the
	// motes (his ask, and DE's behaviour)
	var _pv  = prof_shown;
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

	// THE RESERVE, said out loud. Money you cannot spend and cannot see
	// is money the player thinks has gone missing - and the first thing
	// they will do is check whether the game is broken. It rides the
	// label's line, so it costs no room.
	var _res = profit_reserved();
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

