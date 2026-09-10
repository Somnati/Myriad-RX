/// @description newgame_start(prof, diff, persona) - pull the new-game
/// trigger. Wipes the profile's files (main + autosaves + rebirth: boot
/// recovery would resurrect the run from any survivor), rolls a fresh
/// identity, hard-resets the run in memory (game_reset), stamps the
/// difficulty and the three personality answers, first-saves so the
/// fresh file exists before play begins, and goes to the money room -
/// which opens VEILED (g.unfold 0, syst_unfold): a black screen that
/// says "tap", and the first tap fades the room in.
/// @param prof     the profile index picked in rm_saves
/// @param diff     0 easy / 1 standard / 2 hard / 3 critical / 4 custom
/// @param persona  [a, b, c] - the three answers (indices), -1 unanswered
///
/// ⚖️ LIFTED OUT OF obj_save_menu (2026-09-10, his new-game flow): the
/// difficulty pick used to live on a second page of the saves screen
/// and pull this trigger itself. Now the pick is rm_newgame's - a black
/// screen with the list centred, then three questions - and the saves
/// screen only hands over the profile. One trigger, one place.
function newgame_start(_prof, _diff, _persona) {
	for (var _s = 0; _s < 5; _s++) {
		var _f = save_slot_path(_s, _prof);
		if (file_exists(_f)) file_delete(_f);
	}
	g.profile = _prof;
	// a new run rolls a new identity (the old name/color belonged to
	// the save being overwritten; the first save locks these in)
	g.profile_name[_prof]  = gen_name_planet();
	g.profile_color[_prof] = color_set_random();
	game_reset(_diff);
	g.persona = _persona;
	// first save: the fresh file exists before play begins, so boot
	// recovery / continue / autosaves all see a real run
	with (syst_handle_save) {
		file_to_handle = save_slot_path(0);
		action = sv_save;
		handle_save();
		handle_settings(action);
		action = -1;
	}
	g.game_started = true;
	g.room_hist = [];
	play_sound_ext(snd_matclick2, 1.2, 1.3, .5, 1);
	goto_room(rm_clicker);
}
