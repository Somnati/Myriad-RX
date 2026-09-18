/// @description ex_depart_list() - THE PREPARATION PAGE'S LIST: the wheel, or a drag on it (syst_exped_panel's Step, held input, q220; self = the panel)
function ex_depart_list() {
	var _dl = __dp_list_r();
	var _din = point_in_rectangle(mouse_x, mouse_y, _dl.x, _dl.y, _dl.x + _dl.w, _dl.y + _dl.h);
	if (_din && __dp_off_max() > 0) {
		if (mouse_wheel_up())   dp_off -= __dp_bh() + 4;
		if (mouse_wheel_down()) dp_off += __dp_bh() + 4;
	}
	if (!is_struct(dp_ldrag) && _din && mouse_check_button_pressed(mb_left) && __dp_off_max() > 0) dp_ldrag = { y0 : mouse_y, off0 : dp_off, moved : 0 };
	if (is_struct(dp_ldrag)) {
		if (mouse_check_button(mb_left)) { dp_off = dp_ldrag.off0 - (mouse_y - dp_ldrag.y0); dp_ldrag.moved = max(dp_ldrag.moved, abs(mouse_y - dp_ldrag.y0)); }
		else dp_ldrag = undefined;
	}
	dp_off = clamp(dp_off, 0, __dp_off_max());
}
