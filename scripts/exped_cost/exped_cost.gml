/// @description exped_cost(dest, crew_n) -> { fuel, pocket, total } credits to send a crew
/// His pitch: "it should cost credits to send them - fuel for the ship
/// as well as a little bit of credits to hold in their pocket". The
/// pocket comes home unspent (a credits find in the haul).
function exped_cost(_d, _n) {
	var _fuel = EXPED_FUEL * max(1, _d.tier);
	var _pocket = EXPED_POCKET * max(1, _n);
	return { fuel : _fuel, pocket : _pocket, total : _fuel + _pocket };
}
