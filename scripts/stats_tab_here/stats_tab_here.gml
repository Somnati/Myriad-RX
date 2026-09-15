/// @description stats_tab_here() -> the statistics folder that fits what is
/// on screen ("" = no opinion). The overlay up first (the panel you are
/// looking at), then the room. Folder names as stats_v2_content spells
/// them; a name that does not exist (a feature not yet unfolded) is
/// simply not found and the screen keeps its last tab.
function stats_tab_here() {
	var _ov = ui_overlay();
	if (_ov != noone) {
		switch (object_get_name(_ov.object_index)) {
			case "syst_exped_panel":      return "expeditions";
			case "syst_tiles":            return "tiles";
			case "syst_upgrades":         return "upgrades";
			case "syst_timebank_panel":   return "time bank";
			case "syst_automation_panel": return "automation";
			case "syst_ccore_panel":      return "credits";
			case "syst_battery_panel":    return "credits";
			case "syst_rebirth":          return "rebirth";
		}
	}
	switch (room) {
		case rm_tiles:             return "tiles";
		case rm_upgrades:          return "upgrades";
		case rm_clicker:
		case rm_clicker_landscape: return "tapping";
		case rm_abilitydeck:       return "rebirth";
	}
	return "";
}
