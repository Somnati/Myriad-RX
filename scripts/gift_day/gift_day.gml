/// @description gift_day() -> today's CALENDAR day stamp: GM datetimes
/// are fractional days, so the floor is the local date as one integer.
/// The daily gift turns on the WALL calendar (a login mechanic), not
/// on playtime - deliberate: the gift is the reason to open the game.
function gift_day() {
	return floor(date_current_datetime());
}
