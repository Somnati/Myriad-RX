/// @description grab_deck_fleet() - placeholder abilities for the
/// future ship/navigation layer (warp, fuel, autopilot).
function grab_deck_fleet() {

	ability(g.ad_title_fleet, "Fleet", 0, 0, "", false, false);

	ability(g.ad_warptune, "Warp Tuning", common, 2,
		"warp travel on the starmap\nis 20% quicker", false, false);
	ability_flavor("+20%", "warp speed", "", -1);

	ability(g.ad_fuelcells, "Fuel Cells", common, 2,
		"system dives burn 15%\nless fuel", false, false);
	ability_flavor("-15%", "fuel burn", "", -1);

	ability(g.ad_autopilot, "Autopilot", rare, 6,
		"the ship climbs back to\norbit on its own", false, false);

	ability(g.ad_deepspace, "Deep Space Antenna", epic, 9,
		"idle gains keep flowing\nwhile in warp", false, false);

	if (oo) if (a_ == -1) syst_rm_ability.batch_fleet = _a;
}
