/// @description milestone_next(level) - the next milestone level
/// above `level`, or -1 when the ladder is climbed. The "next" buy
/// mode targets this (Myriad DE's p_ms_req); the drawer tints a buy
/// that reaches it (DE's green button).
function milestone_next(_level) {
	return milestone_get(0, _level).next;
}
