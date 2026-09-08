// autopilot only: owners that drive the card themselves set auto = false
if (auto) {
	// click the card to flip
	if (mouse_check_button_pressed(mb_left) && mouse_over()) {
		flip_target += 180;
		debug_pro_log("flipped");
	}

	// ease toward the flip target
	rot_y += (flip_target - rot_y) * 0.15;

	// idle drift so it feels held rather than pinned
	rot_x = 7 * dsin(current_time / 1300);
	rot_z = 5 * dsin(current_time / 900);
}
