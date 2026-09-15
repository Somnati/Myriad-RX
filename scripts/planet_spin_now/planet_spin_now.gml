/// @description planet_spin_now(pn) -> the world's own-axis angle NOW (degrees), off the universal clock
/// The tech demo's rule: wall seconds x 60 x spin (deg a step), so a world
/// is mid-day-cycle on arrival and remembers itself between sessions -
/// and the agent's day / night (exped_daylight) agrees with the render.
function planet_spin_now(_pn) {
	return ((date_current_datetime() * 86400) * 60 * _pn.spin) mod 360;
}
