/// @description ex_station_step() -> true when the event is done (the old exit): THE STATION PAGE's step - drag to look round, a glide on release (syst_exped_panel's Step, q217; self = the panel)
function ex_station_step() {
	if (!(view == "station" && st_sel >= 0 && st_sel < array_length(sy_stns))) return false;
	var _ocs = starmap_config();
	var _stvr = __sy_view_r();
	var _bks = __back_r();
	var _stin = point_in_rectangle(mouse_x, mouse_y, _stvr.x, _stvr.y, _stvr.x + _stvr.w, _stvr.y + _stvr.h) && !point_in_rectangle(mouse_x, mouse_y, _bks.x, _bks.y, _bks.x + _bks.w, _bks.y + _bks.h);
	if (!st_drag && mouse_check_button_pressed(mb_left) && _stin) { st_drag = true; st_drag_px = 0; st_dx = mouse_x; st_dy = mouse_y; }
	if (st_drag && mouse_check_button(mb_left)) {
		var _sdx = mouse_x - st_dx, _sdy = mouse_y - st_dy;
		st_drag_px += abs(_sdx) + abs(_sdy);
		st_yaw += _sdx * _ocs.orbit_sens; st_pitch = clamp(st_pitch - _sdy * _ocs.orbit_sens, -80, 80);
		st_vx = lerp(st_vx, _sdx, .5); st_vy = lerp(st_vy, _sdy, .5);
		st_dx = mouse_x; st_dy = mouse_y;
	}
	if (!st_drag) {
		if (abs(st_vx) > .02 || abs(st_vy) > .02) {
			st_yaw += st_vx * _ocs.orbit_sens * delta; st_pitch = clamp(st_pitch - st_vy * _ocs.orbit_sens * delta, -80, 80);
			var _sdk = power(_ocs.orbit_glide, delta);
			st_vx *= _sdk; st_vy *= _sdk;
		} else { st_vx = 0; st_vy = 0; }
	}
	st_cam = mat3_mul(mat3_rot(0, 1, 0, st_yaw), mat3_rot(1, 0, 0, st_pitch));   // (the turntable: yaw about the world's up, pitch about the view's side - it never rolls)
	if (st_drag && mouse_check_button_released(mb_left)) st_drag = false;
	return false;
}
