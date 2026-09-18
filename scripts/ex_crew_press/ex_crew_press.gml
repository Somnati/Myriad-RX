/// @description ex_crew_press() -> true when the press is taken: THE CREW page's presses - the tabs, the sheet, the rail (syst_exped_panel's Step, q220; self = the panel)
function ex_crew_press() {
	// the ability picker up: a row picks, anywhere else folds (2026-09-17; vaulted behind SPRITE_AB_PICK - the tooltip folds like any popup)
	if (SPRITE_AB_PICK && is_struct(it_pop) && !is_undefined(it_pop[$ "ab"]) && it_pop.ab < 4) { __ab_pick_tap(); return true; }
	// a popup up: any press closes it
	if (is_struct(it_pop)) { it_pop = undefined; play_sound_ext(snd_softclick, .95, 1.05, .4, 1); return true; }
	var _cl = __crew_list();
	for (var _k = 0; _k < array_length(_cl); _k++) {
		var _tb = __tab_r(_k);
		if (point_in_rectangle(mouse_x, mouse_y, _tb.x, _tb.y, _tb.x + _tb.w, _tb.y + _tb.h)) {
			sheet_id = _cl[_k].id;
			play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
			return true;
		}
	}
	// an item row: its popup (the rects the Draw laid down - __sheet_tap, the one handler)
	__sheet_tap();
	return true;
	return false;
}
