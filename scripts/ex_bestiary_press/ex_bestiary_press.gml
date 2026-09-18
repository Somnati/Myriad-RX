/// @description ex_bestiary_press() -> true when the press is taken: THE BESTIARY's presses (syst_exped_panel's Step, after its press gate, q220; self = the panel)
function ex_bestiary_press() {
	var _nk = array_length(foe_roster());
	for (var _i = 0; _i < _nk; _i++) {
		var _cr = __bs_cell_r(_i);
		if (point_in_rectangle(mouse_x, mouse_y, _cr.x, _cr.y, _cr.x + _cr.w, _cr.y + _cr.h)) { bs_sel = _i; play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1); return true; }
	}
	return true;
	return false;
}
