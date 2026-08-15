/// kh-style save menu. the room is landscape, but the slot COLUMN is
/// sized to the mobile room width (144) and centered, so porting to a
/// portrait room is just a coordinate shift. page 0 lists the four
/// profiles; picking one slides in that profile's slots: autosave 1-3,
/// main save, rebirth save. rows peek their file through
/// save_slot_info() without loading anything.

page     = 0;   // 0 = profiles, 1 = slots of sel_prof
sel_prof = 0;
slide    = 0;   // eases toward page for the kh pull-over

// ---- new-game mode (2026-07-10, his overhaul) ----
// the title's "new game" routes HERE now (no game_restart, no file
// deletion up front): page 0 stays the profile list, but picking an
// occupied slot arms an overwrite confirm and page 1 becomes the
// DIFFICULTY picker. nothing is deleted until a difficulty is chosen
// on a chosen slot - backing out anywhere keeps every save intact.
// the flag is consumed so the load path stays a plain save menu
ng_mode = false;
if (variable_global_exists("saves_mode") && g.saves_mode == "newgame") {
	ng_mode = true;
	g.saves_mode = "";
}
ng_label = ["easy", "standard", "hard", "critical"];
ng_col   = [c_sblue, rgb(170, 190, 230), c_horange, c_hred];
// flavor only: difficulty is STORED on the save, nothing reads it yet
ng_sub   = ["a gentler pace", "the intended run",
	"numbers bite back", "no promises"];

col_w  = 144;                        // mobile room width
col_x  = (room_width - col_w) * .5;  // centered in the landscape room
row_x  = col_x + 8;
row_w  = col_w - 16;
row_h  = 30;
row_sp = 36;
row_y0 = 46;

// slot rows in display order (user spec: autosaves first, then main,
// then rebirth) and which save_slot_path slot each maps to
slot_of_row = [1, 2, 3, 0, 4];
slot_label  = ["autosave 1", "autosave 2", "autosave 3", "main save", "rebirth save"];

info = array_create(5, undefined); // slot cards, filled on profile pick

// profile cards: each profile row peeks its MAIN save for name, color,
// gold and playtime ("empty" when there is none). the saved name and
// color are the profile's real identity, so they override this boot's
// setgame rolls. refreshed whenever page 0 settles
prof_info = array_create(4, undefined);
for (var _i = 0; _i < 4; _i++) {
	prof_info[_i] = save_slot_info(save_slot_path(0, _i));
	if (prof_info[_i].valid) {
		if (prof_info[_i].name != "") g.profile_name[_i]  = prof_info[_i].name;
		if (prof_info[_i].color >= 0) g.profile_color[_i] = prof_info[_i].color;
	}
}
prof_fresh = true;

// framework back button, visible only on the slots page (it manages
// its own visibility off our slide). y 30: below the header bar, which
// draws over everything in the top ~29px
create_obj(row_x, 30, obj_button_back);

// ================= slot-click popup trees =================
// clicking a slot no longer acts directly: it opens the dialogue
// system with options. trees are methods BOUND to this instance
// (function literals bind self even though they don't capture
// locals), so they read sel_prof / info / dlg_row straight off us.
// an option with tree `undefined` just closes the box.

dlg_row = 0;   // row of the slot the open popup is about

// the profile's personal color, as a [color=...] tag for tree text
dlg_col = function() {
	return "[color=" + color_to_hex(g.profile_color[sel_prof]) + "]";
};

// single-line says here: with the text kept above the options, four
// choice rows + one line is exactly what the box height fits

dt_slot_main = function() {
	ds_say("", "main save > " + dlg_col() + g.profile_name[sel_prof] + "[/color]. what do you want to do?");
	ds_choice([
		"[color=gold]save[/color]", dt_act_save,
		"[color=sblue]load[/color]", dt_act_play,
		"[color=hred]delete profile[/color]", dt_ask_delete,
		"nevermind", undefined,
	]);
};

dt_slot_new = function() {
	ds_say("", "no save here yet > " + dlg_col() + g.profile_name[sel_prof] + "[/color].");
	ds_choice([
		"[color=gold]save to new file[/color]", dt_act_save,
		"[color=sblue]start fresh[/color]", dt_act_play,
		"nevermind", undefined,
	]);
};

dt_slot_auto = function() {
	ds_say("", "[color=steelblue]" + slot_label[dlg_row] + "[/color] > load this backup?\nit will overwrite the main save.");
	ds_choice([
		"load backup", dt_act_load_auto,
		"nevermind", undefined,
	]);
};

dt_slot_empty = function() {
	ds_say("", "this backup slot is empty.\nautosaves land here every minute of play.");
};

// ---- new-game trees (ng_mode only) ----

dt_ng_over = function() {
	ds_say("", "are you sure you want to overwrite " + dlg_col()
		+ g.profile_name[sel_prof] + "[/color]'s save with a new game?");
	ds_choice([
		"[color=hred]overwrite[/color]", dt_ng_confirm,
		"nevermind", undefined,
	]);
};

// same difficulty slide an empty slot gets (his call: one flow for
// every fresh save). the files survive until the difficulty pick
dt_ng_confirm = function() { page = 1; };

dt_ask_delete = function() {
	ds_say("", "are you sure you want to delete " + dlg_col() + g.profile_name[sel_prof]
		+ "[/color]'s save?\nmain, autosaves and rebirth all go. [shake]no undo.[/shake]");
	ds_choice([
		"[color=hred]delete[/color]", dt_act_delete,
		"nevermind", undefined,
	]);
};

// ---- actions: these run the moment their option is picked ----

dt_act_save = function() {
	// write the CURRENT run into this profile's main save, right now.
	// the slot keeps its own name/color: only the run's progress moves
	// in. saving onto another profile adopts it as the active one, so
	// autosaves keep landing where the player just saved
	g.profile = sel_prof;
	with (syst_handle_save) {
		file_to_handle = save_slot_path(0);
		action = sv_save;
		handle_save();
		handle_settings(action);
		action = -1;
	}
	g.save_dirty = false;
	for (var _j = 0; _j < 5; _j++)
		info[_j] = save_slot_info(save_slot_path(slot_of_row[_j], sel_prof));
	prof_fresh = false;
	ds_say("", "saved.");
};

dt_act_play = function() {
	// main exists: set_profile loads it. main missing: the save system
	// first-saves a fresh file next step, the "save to new file" flow
	set_profile(sel_prof);
	g.game_started = true; // playing a save IS starting a run - the
		// header menu ungates on it
	play_sound_ext(snd_matclick2, 1.2, 1.3, .5, 1);
	goto_room(rm_clicker);
};

dt_act_load_auto = function() {
	// restore the autosave over the main save, then play the result
	var _main = save_slot_path(0, sel_prof);
	if (file_exists(_main)) file_delete(_main);
	file_copy(save_slot_path(slot_of_row[dlg_row], sel_prof), _main);
	set_profile(sel_prof);
	g.game_started = true; // same ungate as dt_act_play
	play_sound_ext(snd_matclick2, 1.2, 1.3, .5, 1);
	goto_room(rm_clicker);
};

// ---- new game: the difficulty pick pulls the trigger ----
// wipe the slot's files (main + autosaves + rebirth: boot recovery
// would resurrect the run from any survivor), fresh identity, hard
// reset the run in memory (game_reset), first-save, play
ng_start = function(_diff) {
	for (var _s = 0; _s < 5; _s++) {
		var _f = save_slot_path(_s, sel_prof);
		if (file_exists(_f)) file_delete(_f);
	}
	g.profile = sel_prof;
	// a new run rolls a new identity (the old name/color belonged to
	// the save being overwritten; the first save locks these in)
	g.profile_name[sel_prof]  = gen_name_planet();
	g.profile_color[sel_prof] = color_set_random();
	game_reset(_diff);
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
};

dt_act_delete = function() {
	// EVERY file has to go, or boot recovery resurrects the profile
	// from a surviving autosave
	for (var _s = 0; _s < 5; _s++) {
		var _f = save_slot_path(_s, sel_prof);
		if (file_exists(_f)) file_delete(_f);
	}
	// deleting the ACTIVE profile: reset the live run too (set_profile
	// re-rolls it as fresh), or the next autosave writes it right back
	if (sel_prof == g.profile) set_profile(sel_prof);
	for (var _j = 0; _j < 5; _j++)
		info[_j] = save_slot_info(save_slot_path(slot_of_row[_j], sel_prof));
	prof_fresh = false;
	ds_say("", "profile wiped.");
};
