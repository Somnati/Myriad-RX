pt += 2.2 * delta;

if (armed) {
	// the first tap, anywhere. Raw press, not the arbitrated kind: the
	// veil owns the whole screen and nothing else is allowed to answer.
	if (mouse_check_button_pressed(mb_left)) {
		armed = false;
		g.unfold = 1;
		save_mark_dirty();
		// THE TAP ITSELF - the press obj_clicker would have made
		if (variable_global_exists("click_gps"))
			tap_fire(1, mouse_x, mouse_y, true, false);
		if (instance_exists(obj_clicker)) {
			obj_clicker.pop = 1;
			array_push(obj_clicker.tap_log, TPS_WINDOW);
		}
	}
	exit;
}

// ---- the reveal: the black leaves, eased, and the room is there ----
veil -= veil * .07 * delta;
if (veil < .01) instance_destroy();
