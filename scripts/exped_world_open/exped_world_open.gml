/// @description exped_world_open(star, pi) -> the board index of that world, opened (or already open); -1 when it will not open (a gas world)
/// A world clicked on the star map joins g.exped.worlds (saved
/// "ex_worlds": star:pi|...) and the board is rebuilt with it in - it
/// STAYS until let go, so its memory, leaders, villain and boards are
/// its own trip after trip (2026-09-16).
function exped_world_open(_star, _pi) {
	exped_init();
	var _e = g.exped;
	if (!is_array(_e[$ "worlds"])) _e.worlds = [];
	var _w = galaxy_world(_star, _pi);
	if (is_undefined(_w)) return -1;
	var _have = false;
	for (var _i = 0; _i < array_length(_e.worlds); _i++) if (_e.worlds[_i].star == _star && _e.worlds[_i].pl == _pi) _have = true;
	var _hm = galaxy_home();
	if (!_have && !(_star == _hm.star && _pi == _hm.planet)) { array_push(_e.worlds, { star : _star, pl : _pi }); exped_stat("worlds"); }
	exped_board_roll();
	for (var _i = 0; _i < array_length(_e.board); _i++) if (_e.board[_i].seed == _w.seed) { save_mark_dirty(); return _i; }
	return -1;
}
