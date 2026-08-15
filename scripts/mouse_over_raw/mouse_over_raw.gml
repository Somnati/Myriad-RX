/// @description mouse_over_raw()
/// pure geometry: cursor inside the calling instance's bounding box.
/// this is what mouse_over() used to be. only syst_input's arbitration
/// sweep should need it; gameplay code wants mouse_over(), which also
/// answers "and am I the topmost eligible thing under the cursor?"
function mouse_over_raw() {
	return distance_to_point(mouse_x, mouse_y) <= 0;
}
