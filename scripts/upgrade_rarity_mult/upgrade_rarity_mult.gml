/// @description upgrade_rarity_mult(rarity) - what a rung multiplies an
/// upgrade's VALUE by, fourteen deep (2026-09-17). DE's eight ran x1 ..
/// x25 (2.5 / 5 / 10 / 15 / 20 / 25); stretched over the tech demo's
/// ladder with basic UNDER common - a basic roll is worse than a common
/// one for the same price, which is what trash means. The price climbs
/// by its own, flatter curve (upgrade_price_base), so a rung is a
/// jackpot. Bursts widen by the square root of this.
function upgrade_rarity_mult(_r) {
	var _t = [.7, 1, 1.6, 2.5, 4, 6, 8, 10, 13, 16, 20, 24, 28, 32];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
