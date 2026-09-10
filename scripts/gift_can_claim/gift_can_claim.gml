/// @description gift_can_claim() -> is today's gift still on the
/// table? true when the last collect happened on a DIFFERENT calendar
/// day (gift_day). A clock rolled BACKWARD leaves last_day in the
/// future - that correctly refuses until the calendar catches up (the
/// cheap anti-rewind).
function gift_can_claim() {
	gift_init();
	return g.gift.last_day != gift_day();
}
