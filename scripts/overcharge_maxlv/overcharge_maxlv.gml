/// @description overcharge_maxlv() -> the top level. OC_MAX_LV (5, so
/// x5), or five more with DE's charger-cap ability (g.ad_chargercap).
function overcharge_maxlv() {
	var _m = OC_MAX_LV;
	if (variable_global_exists("ad_chargercap") && g.ad_chargercap == 1) _m += 5;
	return _m;
}
