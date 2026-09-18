/// @description ex_log_bar(_under) - THE DIARY'S BAR: seated on the log's column while a diary shows, following the newest line (syst_exped_panel's Step, q220; self = the panel; under = a settings panel lies over)
function ex_log_bar(_under) {
	var _lr = __log_r();
	var _ll = __log_lines();
	// A RE-WRAP KEEPS YOUR PLACE (his ask, 2026-09-15): the band's width
	// changed (the trip page turned into the haul) - the line at the top of
	// the band before is the line at the top after
	if (is_array(_ll) && log_lay.w != _lr.w - 8 && log_lay.n == array_length(_ll) && array_length(log_lay.hs) > 0) {
		var _acc = 0, _top = array_length(log_lay.hs), _off = 0;
		for (var _li = 0; _li < array_length(log_lay.hs); _li++) { if (_acc + log_lay.hs[_li] > log_scroll) { _top = _li; _off = log_scroll - _acc; break; } _acc += log_lay.hs[_li]; }
		var _lay2 = __log_layout(_ll, _lr.w - 8);
		var _acc2 = 0;
		for (var _li = 0; _li < min(_top, array_length(_lay2.hs)); _li++) _acc2 += _lay2.hs[_li];
		log_scroll = _acc2 + ((_top < array_length(_lay2.hs)) ? min(_off, _lay2.hs[_top] - 1) : 0);
		if (instance_exists(sb)) { sb.ty = log_scroll; sb.input = log_scroll; sb.ty_speed_actual = 0; }
	}
	var _lmax = (_lr.h > 0) ? max(0, __log_content_h() - _lr.h) : 0;   // (no band, no bar: the haul's diary shut - bug hunt 2026-09-16)
	if (is_array(_ll)) {
		// THE FOLLOW: at the bottom, a new line pulls the band down with it;
		// scrolled up at all, the band holds still (the bar's own ty is the
		// scroll's truth every step, so the bar is told too - his report:
		// it never followed)
		if (log_n != array_length(_ll)) {
			if (log_follow) { log_scroll = _lmax; if (instance_exists(sb)) { sb.ty = _lmax; sb.input = _lmax; sb.ty_speed_actual = 0; } }
			log_n = array_length(_ll);
		}
		log_follow = (log_scroll >= _lmax - 2);
	}
	log_scroll = clamp(log_scroll, 0, _lmax);
	if (instance_exists(sb)) {
		sb.x = _lr.x + _lr.w - sprite_get_width(spr_scrollbar);
		sb.y = _lr.y;
		sb.image_yscale = _lr.h / max(1, sprite_get_height(spr_scrollbar));
		sb.wheel_x1 = _lr.x; sb.wheel_x2 = _lr.x + _lr.w;
		sb.visible = (oa >= .999 && !closing && _lmax > 0);
		sb.enabled = (oa >= .999 && !closing && !_under);
	}
}
