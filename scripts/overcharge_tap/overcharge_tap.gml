/// @description overcharge_tap(n) - n taps landed: refill the hold and
/// add the charge (tap_fire calls it for every counted tap, press and
/// hold alike). At the top level nothing fills - DE's guard, so a full
/// charger does not bank xp it cannot spend.
function overcharge_tap(_n) {
	if (!overcharge_live()) return;
	if (instance_exists(obj_overcharge)) obj_overcharge.hp = OC_HOLD;
	if (g.overcharge_lv < overcharge_maxlv())
		g.overcharge_xp += OC_XP_TAP * _n * (abi_on("ad_chargerate1") ? 2 : 1);   // charge rate+: twice as fast (DE's)
}
