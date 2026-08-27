
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
			y + random_range(-3, 3), -90, obj_bezier_bit);
		_o.col = col;
		// hand this mote its cut and stop owing it
		_o.amt = share;
		if (amt > 0) amt = (amt > share) ? do_subtract(amt, share) : 0;
		_o.tx = tx + random_range(-2, 2);
		_o.ty = ty + random_range(-1, 1);
		_o.aim();
	}
}
if (count <= 0) kill;
