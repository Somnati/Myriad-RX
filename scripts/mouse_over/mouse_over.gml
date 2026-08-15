/// @description mouse_over()
/// ARBITRATED hover: true only while this instance owns the pointer,
/// i.e. it's the topmost eligible clickable under the cursor this
/// frame AND no blocker (dialogue, menu) outranks it. syst_input
/// computes the owner once per frame in its begin step, so overlapping
/// buttons can never both fire and modal ui blocks everything below it
/// with zero per-object checks. raw geometry moved to mouse_over_raw().
function mouse_over() {
	// bare-room testing without syst_input: fall back to pure geometry
	if (!variable_global_exists("click_owner")) return mouse_over_raw();
	return g.click_owner == id;
}
