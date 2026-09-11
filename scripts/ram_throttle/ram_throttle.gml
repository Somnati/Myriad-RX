/// @description ram_throttle() - the speed every automation clock runs
/// at: 1 inside the budget, cap/used over it. NEVER ZERO - an idle game
/// that switches a player's automation off is an idle game they stop
/// playing (the genre's oldest complaint); over budget everything they
/// set up keeps running, visibly slower, and the squeeze is what sells
/// the next capacity level.
function ram_throttle() {
	var _u = ram_used();
	if (_u <= 0) return 1;
	var _c = ram_cap();
	return (_u <= _c) ? 1 : _c / _u;
}
