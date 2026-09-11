
// Myriad's pacing loop, lean: tic -1 dumps the whole burst this step;
// tic 0+ spits one bit each time the countdown lands (tic 0 = one per
// frame, the rapid back-to-back feel). the population cap gates each
// spawn - a capped spit is simply skipped, the burst still drains.
tic -= delta;
var _rep = 0;
if (tic_ < 0) _rep = count;                     // all at once
else if (tic <= 0 && count > 0) _rep = 1;       // back-to-back
repeat (_rep) {
	if (count <= 0) break;
	count -= 1;
	tic = tic_;
	if (g.bez_n < 48) {
		var _o = instance_create_depth(x + random_range(-3, 3),
			y + random_range(-3, 3), dep, obj_bezier_bit);
		_o.depth = dep;   // the mote's Create stamps -90; this lane's wins
		_o.col = col;
		// RAINBOW MOTES (settings > visuals, DE's "alt profit color"): the
		// profit lane's motes each roll their own hue
		if (lane == "profit" && variable_global_exists("random_profit_color") && g.random_profit_color)
			_o.col = make_colour_hsv(random(255), 210, 255);
		// hand this mote its cut and stop owing it; the LAST mote takes
		// whatever is left, so whole-unit shares never strand a remainder
		var _cut = (count <= 0) ? amt : share;
		if (amt > 0 && _cut > amt) _cut = amt;
		_o.amt = _cut;
		if (amt > 0) amt = (amt > _cut) ? do_subtract(amt, _cut) : 0;
		_o.tx = tx + random_range(-2, 2);
		_o.ty = ty + random_range(-1, 1);
		_o.swing = swing;
		_o.spdm  = spdm;
		_o.look  = bit_look(lane).id;   // the lane's pick, resolved per mote
		_o.aim();
	}
}
if (count <= 0) kill;
