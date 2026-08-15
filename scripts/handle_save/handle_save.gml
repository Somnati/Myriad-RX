/// @description handle_save();
/// progress ONLY: display/options moved out to handle_settings()
/// (settings.ini), so an exported/imported savefile carries the run,
/// not the device setup.
/// MYRIAD RX (fresh foundation, 2026-08-14): stripped to the engine
/// sections. Every DE system rebuilt onto RX adds its own section
/// HERE as it lands - `handle(key, default)` is bidirectional
/// (driven by `action` + `section`), so one block serves save AND
/// load. The techdemo's handle_save is the shape reference for
/// section idioms (arrays, packed arbs, load-side clamps).

function handle_save(){

	//////////////////////////////////////////////////////////////////
	ini_open(file_to_handle);
	if system.debug = true or in_room(rm_gameload) show("opened > " + string(file_to_handle));
	//////////////////////////////////////////////////////////////////

	section = "system";
	last_datetime = handle("save_datetime",date_current_datetime());

	section = "player";
	// the profile's identity lives IN its savefile: until a save exists
	// the name and color are just this boot's setgame rolls, and the
	// first save locks them in
	g.profile_name[g.profile]  = handle("name",g.profile_name[g.profile]);
	g.profile_color[g.profile] = handle("color",g.profile_color[g.profile]);
	g.playtime = handle("playtime",g.playtime); // seconds, shown by slots
	// run difficulty (0 easy .. 3 critical), picked at new game.
	// stored only for now - future balance wiring reads it live
	g.difficulty = handle("difficulty", g.difficulty);

	// pinned statistics (favorites) ride the save as a pipe-joined
	// path list; the tree itself derives live
	section = "statistics";
	if (!variable_global_exists("stats_fav")) g.stats_fav = {};
	var _fav_keys = struct_get_names(g.stats_fav);
	var _fav_txt = "";
	for (var _i = 0; _i < array_length(_fav_keys); _i++)
		_fav_txt += ((_i > 0) ? "|" : "") + _fav_keys[_i];
	_fav_txt = handle("stats_fav", _fav_txt);
	if (action == sv_load) {
		g.stats_fav = {};
		var _fs = string_split(_fav_txt, "|", true);
		for (var _i = 0; _i < array_length(_fs); _i++)
			g.stats_fav[$ _fs[_i]] = true;
	}

	//////////////////////////////////////////////////////////////////
	ini_close();
	//////////////////////////////////////////////////////////////////


	show("filename_path = " + filename_path(file_to_handle));
	show("game_save_id = " + string(game_save_id));

	// measured absence, informative for now: the RX offline story
	// arrives with the DE parity rebuild (DE has rm_offline/rm_sleep;
	// the techdemo's budget-aware replay is the engine reference) -
	// nothing consumes this yet
	time_away = (date_second_span(last_datetime,date_current_datetime()));
	show("time away = " + crunch_time_long(time_away*60));

	// a load restarts the "session" as far as statistics deltas care
	if action = sv_load stats_session_base();
}
