/// @description lane_dest(seed) -> the board world with that seed (a trip's or a haul's when it left the board), or undefined (q260)
/// The lanes, seats and scars key regions "seed:ri" and need the world
/// struct back to reach the region (region_get); a world nobody can
/// reach any more is left alone
function lane_dest(_seed) {
	exped_init();
	var _e = g.exped;
	for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == _seed) return _e.board[_i];
	for (var _i = 0; _i < array_length(_e.trips); _i++) if (is_struct(_e.trips[_i][$ "dest"]) && _e.trips[_i].dest.seed == _seed) return _e.trips[_i].dest;
	for (var _i = 0; _i < array_length(_e.hauls); _i++) if (is_struct(_e.hauls[_i][$ "dest"]) && _e.hauls[_i].dest.seed == _seed) return _e.hauls[_i].dest;
	return undefined;
}
