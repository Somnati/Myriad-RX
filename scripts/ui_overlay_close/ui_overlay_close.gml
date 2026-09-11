/// @description ui_overlay_close() - shut whichever full-screen panel is
/// up, through its OWN close so nothing is skipped.
///
/// Each panel has real work to do on the way out - settings flushes a
/// debounced save and reverts an unconfirmed display change; statistics
/// hands its scroll position back - so this dispatches rather than
/// destroying, which would silently drop that work. The burger's X is
/// the caller that made it worth having: one press, whichever is open.
function ui_overlay_close() {
	if (instance_exists(syst_settings))      { settings_close();   return; }
	if (instance_exists(syst_statistics_v2)) { statistics_close(); return; }
	if (instance_exists(syst_timebank_panel)) { timebank_close();   return; }
	if (instance_exists(syst_gift_panel))     { gift_close();       return; }
	if (instance_exists(syst_faq))            { faq_close();        return; }
	if (instance_exists(syst_automation_panel)) { automation_close(); return; }
	if (instance_exists(syst_battery_panel))    { battery_close();    return; }
	if (instance_exists(syst_rebirth) && syst_rebirth.open) { syst_rebirth.open = false; return; }
}
