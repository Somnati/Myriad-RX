/// THE IN-FLIGHT HOLD-BACK (Myriad DE's emit_gold, obj_ui_drawgold).
/// Profit is banked the instant it is earned - that must never depend
/// on a particle surviving - but the COUNTER holds back whatever is
/// still riding bezier motes, so the number climbs as they land rather
/// than jumping ahead of them. The visualiser reads the same figure,
/// so both tell the same story.
/// RECOMPUTED FROM SCRATCH every frame, never accumulated: a running
/// total would drift the moment a mote was culled by the population
/// cap, and the counter would sit permanently short.

if (!variable_global_exists("profit")) exit;

flight = 0;
with (obj_bezier_emit)
	if (amt > 0) obj_ui_header.flight = do_add(obj_ui_header.flight, amt);
with (obj_bezier_bit)
	if (amt > 0) obj_ui_header.flight = do_add(obj_ui_header.flight, amt);

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
