/// @description unfold_overlay_key() -> the unfold key of the overlay
/// that is up, or "" (the first-open lines and the nudges read it)
function unfold_overlay_key() {
	var _o = ui_overlay();
	if (_o == noone) return "";
	if (_o.object_index == syst_upgrades)         return "upgrades";
	if (_o.object_index == syst_tiles)            return "tiles";
	if (_o.object_index == syst_automation_panel) return "automation";
	if (_o.object_index == syst_rm_ability)       return "abilities";
	if (_o.object_index == syst_timebank_panel)   return "timebank";
	if (_o.object_index == syst_battery_panel)    return "battery";
	if (_o.object_index == syst_ccore_panel)      return "ccore";
	if (_o.object_index == syst_gift_panel)       return "gift";
	if (_o.object_index == syst_exped_panel)      return "expeditions";
	if (_o.object_index == syst_statistics_v2)    return "statistics";
	if (_o.object_index == syst_rebirth)          return "rebirth";
	if (_o.object_index == syst_offlog)           return "offlog";
	return "";
}
