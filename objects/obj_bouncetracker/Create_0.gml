/// obj_bouncetracker - DE's throw readout, ported (his ask, 2026-09-10:
/// "bring the puck's bounce UI over from DE... put it in the top left").
/// Three lines that fade in while a throw runs and slide out five
/// seconds after it stops:
///   bounces N   N in the large outline font, coloured by the tier
///               palette at N (DE: mod_get_gpscolor), and it POPS - the
///               size kicks on every new bounce and settles back
///   profit X    what this throw has earned (obj_puck.cur_profit, the
///               ledger puck_pay keeps), in the profit colour
///   spd N       the puck's live speed, aqua at rest through red at the
///               room's speed scale
/// obj_puck spawns it at (3, 50): under the per-tap figure, above the
/// offline pile's seat. It reads the puck and never writes it.

depth = -105;   // over the per-tap lane (-100), under the overcharger's ring (-110) - a corner of readouts

alpha     = 0;
alpha_tic = 0;    // frames of life left after the throw stops (DE: tsec x 5)
xos       = -10;  // the slide-in offset
bnc       = 0;
profit    = 0;
p_profit  = -1;
draw_profit = "0";
spd       = 0;
text_size  = 1;
text_size_ = 1;
str_w     = -1;
