/// THE SAVES SCREEN, rebuilt 2026-09-07 as the settings room's twin
/// (his call). It used to be a KH two-page pull-over: page 0 the four
/// profiles, page 1 the picked profile's slots, sliding between them.
/// Now the profiles are a LEFT RAIL and the slots are the content
/// band - the same shape settings and statistics settled on, so the
/// three menu screens read as one family, and you can compare
/// profiles without leaving the one you are reading.
///
/// WHAT THE REBUILD FIXED, beyond the shape:
///  - TIMESTAMPS. Every savefile has carried system/save_datetime
///    from the beginning (save_validate checks for it), but nothing
///    ever showed it. Three rotating autosaves are the SAME file at
///    three different ages, so a menu that hides the stamp cannot
///    answer the only question it exists to answer. Every row reads
///    "14 minutes ago" now (crunch_time_ago).
///  - THE SEVEN ORPHAN BUTTONS in the room's bottom-right corner
///    (save / load / delete / export / import / export+ / import+).
///    DE leftovers wired to syst_handle_save.file_to_handle - the
///    ACTIVE file, not the profile on screen - so exporting while
///    reading profile 3 exported profile 1, and `delete` wiped a save
///    with no confirmation at all while the popup two inches away did
///    the same job properly. Their instances are gone from rm_saves;
///    export/import live in the action band below, bound to the
///    SELECTED profile. They were also the reason this room could
///    never take a portrait twin (hard-placed at x336-432 of 480).
///  - THE REBIRTH ROW said "reserved" and refused the tap, even
///    though rebirth_do really does snapshot the pre-rebirth run into
///    slot 4 every single time. It is a real restore point now.
///  - DIFFICULTY, REBIRTH COUNT, CREDITS and the OFFLINE CLOCK were
///    all already on disk and never drawn. They are the header line
///    and the rows' second line now.
///
/// THE ONE FLOW THAT SURVIVED UNCHANGED: new game. The title routes
/// here with g.saves_mode == "newgame"; picking a profile that has a
/// save arms an overwrite confirm, and only choosing a difficulty
/// pulls the trigger. Nothing is deleted until that last tap, so
/// backing out anywhere keeps every file intact.

// page 0 = the profile's slots. (page 1, the difficulty picker, moved
// to rm_newgame - 2026-09-10, his new-game flow: a black screen with
// the list centred, then three questions, then the veiled money room.
// This screen only hands over the profile now.)
page     = 0;
sel_prof = variable_global_exists("profile") ? g.profile : 0;

// ---- new-game mode (2026-07-10, his overhaul) ----
// the flag is consumed so the load path stays a plain save menu
ng_mode = false;
if (variable_global_exists("saves_mode") && g.saves_mode == "newgame") {
	ng_mode = true;
	g.saves_mode = "";
}
// ⚖️ FROM THE TITLE THERE IS ONLY LOAD (his rule, 2026-09-13: "even if i
// already entered a game and went back to the title screen"). The title
// sets the flag on its way here; it is consumed so an in-game visit (the
// menu's saves line) is the save + load bench
from_title = variable_global_exists("saves_from_title") && g.saves_from_title;
g.saves_from_title = false;
can_save = !from_title && !ng_mode;

// THE SELECTED ROW (his ask: rows select, the big buttons act). Main to
// begin with; -1 = nothing picked
sel_row = 0;

// THE CONFIRM POPUP, in the middle of the screen (his ask: not the
// dialogue system) - "" / "save" / "load"; its ease; which button the
// pointer is on
confirm  = "";
conf_a   = 0;
conf_hot = 0;
// the difficulty's name and colour, for the profile header line (the
// pick itself lives in rm_newgame / syst_newgame now)
ng_label = ["easy", "standard", "hard", "critical", "custom"];
ng_col   = [c_sblue, rgb(170, 190, 230), c_horange, c_hred, c_hpurple];

// ================= layout: derived, never hard-placed =================
// settings' and statistics' exact frame, so the three screens line up
// pixel for pixel: header, a title strip, then rail + content.
bby       = obj_ui_header.bar_h;  // the header's BAR's bottom edge (its shadow is 2 more)
list_y    = bby + 16;                     // strip above, rail/content below
rail_w    = 80;                           // the profile rail
content_x = rail_w + 6;                   // text seat inside the content band
cw        = room_width - rail_w;          // the content band's width

tab_y0 = list_y + 3;   // profile tabs carry two lines each, so they are
tab_h  = 28;           // taller than settings' 17px category tabs
tab_sp = 31;

hdr_y  = list_y + 4;   // the selected profile's header line
row_y0 = list_y + 17;  // the slot rows
row_h  = 30;
row_sp = 34;

band_y = row_y0 + 5 * row_sp + 4;  // the action band, under the last row
band_h = 16;

// slot rows in display order. MAIN FIRST (2026-09-07): the old order
// was autosaves-first, but now that every row carries a stamp the
// important file should be where the eye lands, and the autosaves
// read as what they are - a ladder of ages descending from it.
slot_of_row = [0, 1, 2, 3, 4];
slot_label  = ["main save", "autosave 1", "autosave 2", "autosave 3",
	"rebirth backup"];

info      = array_create(5, undefined);  // sel_prof's slot cards
prof_info = array_create(4, undefined);  // each profile's MAIN save

// files change under us while the room is open (the autosave clock
// fires every 60s), so the cards re-peek on a slow tick rather than
// only when we act. nine small ini reads every second and a half is
// nothing, and it stops "2 minutes ago" from quietly becoming a lie
scan_tic = 0;

// AN OS FILE DIALOG IS NEVER OPENED FROM INSIDE AN EVENT CALLBACK.
// get_open_filename / get_save_filename are MODAL: they block the whole
// game loop, and on Windows they fight an exclusive-fullscreen window
// for the display. Firing one from inside the dialogue's option handler
// meant the box that launched it was still on screen, undrawn-over,
// when the OS took over - which is how he ended up looking at a file
// manager over a frozen game he could not get back to.
// So the button only ARMS a job here; the Step runs it once the
// dialogue has closed AND a few clean frames have been drawn. Whatever
// the OS then does, there is a live, correct game sitting behind it.
pending   = "";  // "" / "export" / "import"
pending_t = 0;   // frames of settled screen still owed

// ---- reading the files ----
// profile rows peek their MAIN save for name, colour, profit and
// playtime. the SAVED name and colour are the profile's real identity,
// so they override this boot's setgame rolls.
__refresh_prof = function() {
	for (var _i = 0; _i < 4; _i++) {
		prof_info[_i] = save_slot_info(save_slot_path(0, _i));
		if (prof_info[_i].valid) {
			if (prof_info[_i].name != "") g.profile_name[_i]  = prof_info[_i].name;
			if (prof_info[_i].color >= 0) g.profile_color[_i] = prof_info[_i].color;
		}
	}
};

__refresh_slots = function() {
	for (var _j = 0; _j < 5; _j++)
		info[_j] = save_slot_info(save_slot_path(slot_of_row[_j], sel_prof));
};

__refresh_prof();
__refresh_slots();

// the colour a profile signs its card in - gray until a save exists,
// because the rolled name is not real identity until a save locks it in
__pcol = function(_i) {
	var _pi = prof_info[_i];
	return (!is_undefined(_pi) && _pi.valid) ? g.profile_color[_i]
		: rgb(120, 130, 150);
};

__phas = function(_i) {
	return (!is_undefined(prof_info[_i]) && prof_info[_i].valid);
};

// ---- geometry shared by draw AND hit test, so the two cannot drift ----
__tabs = function() {
	var _out = [];
	for (var _i = 0; _i < 4; _i++)
		array_push(_out, { x1 : 2, y1 : tab_y0 + _i * tab_sp,
			x2 : rail_w - 4, y2 : tab_y0 + _i * tab_sp + tab_h, idx : _i });
	return _out;
};

__row_y = function(_i) { return row_y0 + _i * row_sp; };

// THE ROW SURFACE - statistics_v2's __row_panel distilled to what this
// screen needs. Opaque fill pre-blended against the backdrop (not an
// alpha wash), settings' gradient edge seams top and bottom, and a 2px
// identity band down the left edge in the row's own colour. There is no
// zebra here: five rows, each a different KIND of file, so the colour
// band already separates them and a stripe on top would just be noise.
__panel = function(_y, _h, _col, _a) {
	var _back = c_hsv(169, 186, 5);
	var _c    = merge_colour(c_hsv(168, 160, 5), _back, .2);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _y, cw, _h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _y, cw, 1, 0,
		_c, c_black, c_black, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, rail_w, _y + _h - 1, cw, 1, 0,
		c_black, _c, _c, c_black, .52);
	draw_sprite_ext(spr_pixel_1x1, 0, rail_w, _y, 2, _h, 0, _col, _a * .9);
};

// the action band. ANDROID takes the SAF (file picker) route for both
// transfers and every other platform takes the desktop dialog /
// clipboard route - which is why export+ and import+ are not two more
// buttons any more: the platform picks the road, not the player.
__band = function() {
	var _w = 60;   // (78: the big save / load buttons took the right of the band, 2026-09-13)
	var _g = 6;
	var _x = content_x - 6;
	return [
		{ x : _x,                 y : band_y, w : _w,      h : band_h, id : "export" },
		{ x : _x + (_w + _g),     y : band_y, w : _w,      h : band_h, id : "import" },
		{ x : _x + (_w + _g) * 2, y : band_y, w : _w + 24, h : band_h, id : "wipe" },
	];
};

// THE BIG BUTTONS, bottom right (his ask, 2026-09-13): [save] [load] in a
// game, [load] alone from the title. The transfer band keeps the left
__bigbtns = function() {
	var _h = 24, _w = 70, _g = 6;
	var _y = room_height - _h - 6;
	var _out = [];
	if (can_save) {
		array_push(_out, { x : room_width - 6 - _w * 2 - _g, y : _y, w : _w, h : _h, id : "save" });
		array_push(_out, { x : room_width - 6 - _w,          y : _y, w : _w, h : _h, id : "load" });
	} else {
		array_push(_out, { x : room_width - 6 - 100, y : _y, w : 100, h : _h, id : "load" });
	}
	return _out;
};

/// the popup's box and its two buttons
__conf_rect = function() {
	var _w = min(room_width - 16, 230), _h = 74;
	return { x : floor((room_width - _w) * .5), y : floor((room_height - _h) * .5), w : _w, h : _h };
};
__conf_btns = function() {
	var _r = __conf_rect();
	var _bw = 84, _bh = 18, _g = 8;
	var _x0 = _r.x + floor((_r.w - _bw * 2 - _g) * .5);
	return [ { x : _x0, y : _r.y + _r.h - _bh - 8, w : _bw, h : _bh, id : "ok" },
	         { x : _x0 + _bw + _g, y : _r.y + _r.h - _bh - 8, w : _bw, h : _bh, id : "cancel" } ];
};

/// @func __conf_go()
/// @desc the popup's yes: save writes this profile's main; load plays the
///       selected file (main straight, a backup restored over main first)
__conf_go = function() {
	var _what = confirm;
	confirm = "";
	if (_what == "save") { dt_act_save(); play_sound_ext(snd_matclick2, 1.2, 1.3, .5, 1); return; }
	if (_what == "load") {
		dlg_row = max(0, sel_row);
		if (slot_of_row[dlg_row] == 0) dt_act_play(); else dt_act_load_auto();
	}
};
// new game's one button, sitting where the transfer band would be
__ngbtn = function() {
	return { x : content_x - 6, y : band_y, w : 160, h : band_h };
};

// back, top right of the title strip (the title screen's load path
// needs a way home; back_room pops to wherever you actually came from)
__back_rect = function() {
	return { x1 : room_width - 62, y1 : bby + 6, x2 : room_width - 6, y2 : bby + 22 };
};

// ================= slot-click popup trees =================
// clicking a row never acts directly: it opens the dialogue system
// with options. trees are methods BOUND to this instance (function
// literals bind self even though they don't capture locals), so they
// read sel_prof / info / dlg_row straight off us. an option with tree
// `undefined` just closes the box.

dlg_row = 0;   // row of the slot the open popup is about

// the profile's personal color, as a [color=...] tag for tree text
dlg_col = function() {
	return "[color=" + color_to_hex(g.profile_color[sel_prof]) + "]";
};

dt_slot_main = function() {
	ds_say("", "main save > " + dlg_col() + g.profile_name[sel_prof] + "[/color]. what do you want to do?");
	ds_choice([
		"[color=gold]save[/color]", dt_act_save,
		"[color=sblue]load[/color]", dt_act_play,
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
	ds_say("", "[color=steelblue]" + slot_label[dlg_row] + "[/color] > written "
		+ crunch_time_ago(info[dlg_row].datetime)
		+ ".\nloading it overwrites the main save.");
	ds_choice([
		"load backup", dt_act_load_auto,
		"nevermind", undefined,
	]);
};

dt_slot_empty = function() {
	ds_say("", "this backup slot is empty.\nautosaves land here every minute of play.");
};

// ---- the rebirth backup: a real restore point (2026-09-07, his call) ----
// rebirth_do writes the live state to slot 4 BEFORE it awards, so the
// file is the run exactly as it stood the instant before the press. It
// used to sit here saying "reserved" and refuse the tap; it is the undo
// it was always quietly being kept as. The confirm is blunt on purpose:
// the run comes back, the units it bought do not, and the CURRENT run
// is what gets overwritten.
dt_slot_rebirth = function() {
	ds_say("", "[color=hpurple]rebirth backup[/color] > the run as it stood just before rebirth "
		+ string(info[dlg_row].rebirths + 1) + ", "
		+ crunch_time_ago(info[dlg_row].datetime)
		+ ".\nrestoring puts that run back and [shake]undoes the rebirth[/shake] - the units it paid out do not come with it.");
	ds_choice([
		"[color=hpurple]restore it[/color]", dt_act_load_auto,
		"nevermind", undefined,
	]);
};

dt_slot_rebirth_empty = function() {
	ds_say("", "no rebirth backup yet.\nthe run is saved here the moment before every rebirth, so a rebirth you regret can be taken back.");
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

// the same road an empty slot takes (his call: one flow for every
// fresh save). the files survive until rm_newgame pulls the trigger
dt_ng_confirm = function() { __ng_go(); };
__ng_go = function() {
	g.ng_prof = sel_prof;
	goto_room(rm_newgame);
};

dt_ask_delete = function() {
	ds_say("", "are you sure you want to delete " + dlg_col() + g.profile_name[sel_prof]
		+ "[/color]'s save?\nmain, autosaves and rebirth all go. [shake]no undo.[/shake]");
	ds_choice([
		"[color=hred]delete[/color]", dt_act_delete,
		"nevermind", undefined,
	]);
};

// ---- transfers name the profile they touch ----
// (the old corner buttons named nothing and acted on the active file)

dt_ask_import = function() {
	ds_say("", "import a savefile into " + dlg_col() + g.profile_name[sel_prof]
		+ "[/color]?" + (__phas(sel_prof)
			? "\nthe save already there is [shake]replaced[/shake]." : ""));
	ds_choice([
		"[color=sblue]pick a file[/color]", dt_act_import,
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
	__refresh_slots();
	__refresh_prof();
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
	// restore a backup (an autosave or the rebirth snapshot) over the
	// main save, then play the result
	var _main = save_slot_path(0, sel_prof);
	if (file_exists(_main)) file_delete(_main);
	file_copy(save_slot_path(slot_of_row[dlg_row], sel_prof), _main);
	set_profile(sel_prof);
	g.game_started = true; // same ungate as dt_act_play
	play_sound_ext(snd_matclick2, 1.2, 1.3, .5, 1);
	goto_room(rm_clicker);
};

// the two transfer buttons only ARM their job (see `pending` above);
// the Step opens the OS dialog on a clean frame
dt_act_export = function() { pending = "export"; pending_t = 3; };
dt_act_import = function() { pending = "import"; pending_t = 3; };

// EXPORT reads the SELECTED profile's file and never flushes the live
// run into it - save_export's `file` argument exists for exactly this,
// because the flush would overwrite the very save being backed up.
__do_export = function() {
	var _f = save_slot_path(0, sel_prof);
	if (!file_exists(_f)) { show("nothing to export > this profile has no save"); return; }
	if (os_type == os_android) save_export_saf(_f); else save_export(_f);
};

// IMPORT lands on the selected profile and ADOPTS it, the same rule
// dt_act_save follows: you are playing what you just imported.
// THE DESTINATION IS PASSED IN, never pre-assigned. The first cut of
// this pointed g.profile and file_to_handle at the target BEFORE
// opening the picker, so backing out of the dialog left the save system
// aimed somewhere else - and syst_handle_save's Step first-saves any
// file_to_handle that does not exist, which means a cancelled import
// could quietly copy the live run into an empty profile. Nothing is
// touched now until a file has actually been read and applied.
__do_import = function() {
	var _dest = save_slot_path(0, sel_prof);
	// android's picker is ASYNCHRONOUS: the file has not arrived yet,
	// so the apply AND the adoption happen in syst_handle_save's Async
	// Social handler off the profile stashed here
	if (os_type == os_android) { save_import_saf(sel_prof); return; }
	if (!save_import(_dest)) return;  // cancelled or rejected: nothing moved
	g.profile = sel_prof;
	g.game_started = true;
	__refresh_prof();
	__refresh_slots();
};

// (the new-game trigger is newgame_start, pulled by rm_newgame)

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
	__refresh_slots();
	__refresh_prof();
	ds_say("", "profile wiped.");
};
