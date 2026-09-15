/// @description universal_now() -> wall-clock seconds, SMOOTH
/// date_current_datetime() ticks in whole seconds - a world spun off it
/// jumps once a second (his report, 2026-09-15: "a stutter"). This pins
/// the wall clock once (the first call) and runs it forward on
/// current_time's milliseconds, so the phase is the universal clock's and
/// the motion is the frame's. Every planet spin, orbit and weather slot
/// reads this.
function universal_now() {
	if (!variable_global_exists("clock0")) g.clock0 = date_current_datetime() * 86400 - current_time / 1000;
	return g.clock0 + current_time / 1000;
}
