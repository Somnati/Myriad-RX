/// @description settings_close() - take the settings screen down.
///
/// THE PENDING SAVE IS FLUSHED FIRST, and that is the whole reason this
/// is a script rather than an instance_destroy at each call site. A
/// change arms a 45-frame debounce (dirty_tic) so dragging a slider does
/// not write the ini forty times; closing inside that window used to be
/// impossible, because leaving meant a room change and the screen stayed
/// alive long enough to fire. An overlay dies the moment you close it,
/// so the flush has to be here or the last thing you changed is the one
/// thing that does not stick.
///
/// ⚖️ AN OPEN CONFIRM REVERTS. A risky display change (resolution, and
/// whatever joins it) shows a keep/revert popup with a 10s auto-revert
/// behind it, and the whole point is that a mode you cannot see out of
/// undoes itself. As a room that was safe: the popup lived as long as
/// the screen did. An overlay can be closed out from under it, and then
/// the timer dies with the object and the unconfirmed change is simply
/// kept - which is the exact failure the popup exists to prevent. So
/// closing counts as not keeping it.///
/// ⚖️ IT ARMS THE EXIT, IT DOES NOT DESTROY (2026-09-09, with the open
/// animation). The panel has to be alive to animate off, so this flips
/// `closing` and the Step destroys it once the ease reaches zero. The
/// real work above still happens NOW, at the moment you press close -
/// nothing is deferred into an animation that a room change or a crash
/// could eat.
function settings_close() {
	if (!instance_exists(syst_settings)) return;
	if (syst_settings.closing) return;   // already on its way out
	with (syst_settings) {
		if (confirm_active) {
			if (is_method(confirm_revert)) confirm_revert();
			confirm_active = false;
		}
		if (dirty_tic > 0) {
			dirty_tic = 0;
			syst_handle_save.action = sv_save;   // save + settings.ini
		}
		closing = true;
	}
}
