/// @description ex_system_step() -> true when the event is done (the old exit): THE STAR SYSTEM VIEW's step - orbit the camera, glide, the wheel's distance, the dive (syst_exped_panel's Step, q217; self = the panel)
function ex_system_step() {
	if (!(view == "system" && is_struct(sy_sys))) return false;
	var _ocf = starmap_config();
	__sy_lite_step();   // (the stamps, a slice a frame - q201)
	// the dive: an eased swell about the picked world (or station - 2026-09-17), then its page (behind the veil)
	if (sy_warp_pl >= 0 || sy_warp_st >= 0) {
		sy_warp_t = min(sy_warp_t + delta / 30, 1);
		var _we = sy_warp_t * sy_warp_t * (3 - 2 * sy_warp_t);
		sy_warp_s = power(15, _we);
		if (sy_warp_t >= 1) {
			if (sy_warp_st >= 0) {
				st_sel = sy_warp_st; st_yaw = 0; st_pitch = -20; st_cam = mat3_mul(mat3_rot(0, 1, 0, st_yaw), mat3_rot(1, 0, 0, st_pitch)); st_vx = 0; st_vy = 0; st_drag = false;
				sy_warp_st = -1; sy_warp_s = 1; sy_warp_t = 0;
				view = "station"; pg_a = 0; pg_dir = 1; view_last = view;
			} else {
				var _di = exped_world_open(sy_star, sy_warp_pl);
				sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0;
				if (_di >= 0) { sel_dest = _di; pl_dest = g.exped.board[_di]; rg_sel = 0; pl_focus = -1; pv_mode = "planet"; pv_zoom = 1; pv_zuser = 1; pv_cfade = 1; view = "planet"; pg_a = 0; pg_dir = 1; view_last = view; }
			}
		}
		return true;
	}
	var _svr = __sy_view_r();
	var _sdk = point_in_rectangle(mouse_x, mouse_y, __sy_dock_x(), list_y + 16, room_width, room_height - 8);   // (the drawer and its tab: no place to drag or wheel from)
	var _sin = point_in_rectangle(mouse_x, mouse_y, _svr.x, _svr.y, _svr.x + _svr.w, _svr.y + _svr.h) && !_sdk;
	if (_sin) { if (mouse_wheel_up()) sy_D = max(sy_D / 1.08, sy_Dmin); if (mouse_wheel_down()) sy_D = min(sy_D * 1.08, 430); }   // (in to the star's own scale - q265)
	var _bk0 = __back_r();
	var _onbk0 = point_in_rectangle(mouse_x, mouse_y, _bk0.x, _bk0.y, _bk0.x + _bk0.w, _bk0.y + _bk0.h);
	var _ser = __sy_enter_r(), _sgl0 = __galaxy_r();
	var _oner = (sy_dwa <= .3 && point_in_rectangle(mouse_x, mouse_y, _ser.x, _ser.y, _ser.x + _ser.w, _ser.y + _ser.h)) || point_in_rectangle(mouse_x, mouse_y, _sgl0.x, _sgl0.y, _sgl0.x + _sgl0.w, _sgl0.y + _sgl0.h);
	if (!sy_drag && mouse_check_button_pressed(mb_left) && _sin && !_onbk0 && !_oner) { sy_drag = true; sy_drag_px = 0; sy_dx = mouse_x; sy_dy = mouse_y; }
	if (sy_drag && mouse_check_button(mb_left)) {
		var _dx = mouse_x - sy_dx, _dy = mouse_y - sy_dy;
		sy_drag_px += abs(_dx) + abs(_dy);
		if (_dx != 0) sy_cam = mat3_mul(sy_cam, mat3_rot(0, 1, 0,  _dx * _ocf.orbit_sens));
		if (_dy != 0) sy_cam = mat3_mul(sy_cam, mat3_rot(1, 0, 0, -_dy * _ocf.orbit_sens));
		sy_vx = lerp(sy_vx, _dx, .5); sy_vy = lerp(sy_vy, _dy, .5);
		sy_dx = mouse_x; sy_dy = mouse_y;
	}
	if (!sy_drag) {
		if (abs(sy_vx) > .02 || abs(sy_vy) > .02) {
			sy_cam = mat3_mul(sy_cam, mat3_rot(0, 1, 0,  sy_vx * _ocf.orbit_sens * delta));
			sy_cam = mat3_mul(sy_cam, mat3_rot(1, 0, 0, -sy_vy * _ocf.orbit_sens * delta));
			var _dk = power(_ocf.orbit_glide, delta);
			sy_vx *= _dk; sy_vy *= _dk;
		} else { sy_vx = 0; sy_vy = 0; }
	}
	if (sy_drag && mouse_check_button_released(mb_left)) {
		sy_drag = false;
		if (sy_drag_px <= 4) {
			// a tap: the nearest world under it (the demo's reach), or space - nothing
			var _hit = -1, _pls2 = sy_sys.planets;
			for (var _i = 0; _i < array_length(_pls2); _i++) {
				var _pw2 = __sy_ppos(_pls2[_i]); var _pp2 = __sy_proj(_pw2[0], 0, _pw2[2]);
				if (is_undefined(_pp2)) continue;
				if (point_distance(mouse_x, mouse_y - list_y, _pp2[0], _pp2[1]) <= _pls2[_i].size * _pp2[2] * 1.6 + 5) { _hit = _i; break; }
			}
			// ...or the nearest station (2026-09-17): a station and a world are never both picked
			var _shit = -1;
			for (var _j = 0; _j < array_length(sy_stns); _j++) {
				var _sq2 = __st_ppos(sy_stns[_j]); var _sp2 = __sy_proj(_sq2[0], 0, _sq2[2]);
				if (is_undefined(_sp2)) continue;
				if (point_distance(mouse_x, mouse_y - list_y, _sp2[0], _sp2[1]) <= sy_stns[_j].size * _sp2[2] * 1.6 + 5) { _shit = _j; break; }
			}
			// ...or a belt's band (the polish, 2026-09-17): the nearest point of its ring within reach names it - nothing to enter
			var _bhit = -1;
			if (_hit < 0 && _shit < 0) for (var _b = 0; _b < array_length(sy_belts) && _bhit < 0; _b++) {
				var _bo = sy_belts[_b].orbit;
				for (var _ba = 0; _ba < 360; _ba += 4) { var _bq = __sy_proj(dcos(_ba) * _bo, 0, dsin(_ba) * _bo); if (is_undefined(_bq)) continue; if (point_distance(mouse_x, mouse_y - list_y, _bq[0], _bq[1]) <= max(5, sy_belts[_b].width * .5 * _bq[2]) + 2) { _bhit = _b; break; } }
			}
			if (_shit >= 0 && _hit < 0) { if (_shit != sy_ssel) play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); sy_ssel = _shit; sy_sel = -1; sy_bsel = -1; }
			else if (_bhit >= 0) { if (_bhit != sy_bsel) play_sound_ext(snd_softclick, 1, 1.1, .35, 1); sy_bsel = _bhit; sy_sel = -1; sy_ssel = -1; }
			else { if (_hit >= 0 && _hit != sy_sel) play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); sy_sel = _hit; sy_ssel = -1; sy_bsel = -1; }
		}
	}
	sy_dwa = move_to(sy_dwa, sy_dw ? 1 : 0, 6);   // the drawer's ease
	return false;
}
