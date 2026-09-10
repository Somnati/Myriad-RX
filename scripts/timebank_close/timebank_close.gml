/// @description timebank_close() - take the time bank panel down. Arms
/// the exit (the panel has to be alive to animate off - its Step
/// destroys it once the ease reaches zero). Nothing here to flush: the
/// speed choice and every purchase marked the save at the moment they
/// happened.
function timebank_close() {
	if (!instance_exists(syst_timebank_panel)) return;
	syst_timebank_panel.closing = true;
}
