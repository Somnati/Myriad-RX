


draw_sprite_ext(sprite_index,img+1,0,y,room_width,1,0,c_black,1);
draw_sprite_ext(sprite_index,img,0,y,room_width,1,0,col,1);

// ---- profit, top left: gliding arb counter + gain pops ----
if (variable_global_exists("profit")) {
	// target in log10 (arb_log10 = the one unpack site)
	var _pv  = g.profit;
	var _tlg = (_pv < arb(1)) ? -1 : arb_log10(_pv);

	// gain pop: profit LANDED (a sale) - spending only glides down
	if (_pv > prof_last)
		float_text(48, 16, "+" + crunch_arb(do_subtract(_pv, prof_last)), c_gold);
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
	draw_set_color(c_gold);
	draw_set_alpha(.95);
	draw_text(6, 14, (prof_lg == -1) ? "0" : crunch_arb(log_to_arb(prof_lg)));
	draw_set_alpha(1);
	draw_set_color(c_white);
}

