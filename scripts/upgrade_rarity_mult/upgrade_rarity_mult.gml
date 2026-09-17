/// @description upgrade_rarity_mult(rarity) - what a rung multiplies an
/// upgrade's VALUE by. DE's own ladder (update_upgrade's `_add *= 2.5 /
/// 5 / 10 / 15 / 20 / 25`), ported whole on 2026-09-17 ("the output per
/// tier felt different from myriad... check DE") - it was a gentler
/// invented curve before (x1.6 .. x16) that also scaled the PRICE, so a
/// rung was never a jackpot. In DE it is one: the price climbs by its
/// own, much flatter curve (upgrade_price_base), so a rare rung is worth
/// several times its cost. Bursts widen by the square root of this.
function upgrade_rarity_mult(_r) {
	var _t = [1, 2.5, 5, 10, 15, 20, 25, 25];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
