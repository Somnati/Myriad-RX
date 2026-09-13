if (!instance_exists(obj_puck)) { alpha = 0; exit; }
var _o = obj_puck;
// RIGHT OF THE PER-TAP COLUMN AND UP (his ask, 2026-09-13: "over to the
// right a bit away from the side... up a bit where its bottom text
// doesn't clip with the objective box"): its three rows now run
// 30..51 beside the per-tap figure; the objective card begins at 66
x = 66;
y = 30 + ui_wordline_h();

// DE's pop: the number's target size kicks up a step on every new bounce
// and the shown size springs after it
text_size = move_to(text_size, text_size_, 4);
if (_o.spd == 0 || alpha_tic <= 0) text_size_ = move_to(text_size_, 1, 10);
if (_o.spd > 0 && !_o.held) {
	if (bnc < _o.bounces) {
		text_size_ += lerp(.05, 0, clamp(text_size_ / 1.5, 0, 1));
		text_size  += .2;
	}
	bnc    = _o.bounces;
	profit = _o.cur_profit;
	spd    = _o.spd;
	alpha_tic = 60 * 5;
}

alpha_tic -= delta;
if (alpha_tic <= 0) {
	alpha = move_to(alpha, 0, 10);
	xos   = move_to(xos, -10, 10);
} else {
	alpha = move_to(alpha, 1, 4);
	xos   = move_to(xos, 0, 4);
}

// the string is rebuilt only when the number moves (DE)
if (p_profit != profit) {
	draw_profit = (profit >= arb(1)) ? crunch_arb(profit) : "0";
	p_profit = profit;
}
