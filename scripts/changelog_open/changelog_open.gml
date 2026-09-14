/// @description changelog_open() - put the changelog up over whatever
/// room you are standing in. THE ONE DOOR (the settings door's rule): a
/// panel still fading out is caught and revived; a second is refused.
function changelog_open() {
	if (instance_exists(syst_changelog) && syst_changelog.closing) {
		syst_changelog.closing = false;
		return;
	}
	if (instance_exists(syst_changelog)) return;
	if (ui_overlay() != noone) ui_overlay_close();   // one panel at a time
	create_obj(0, 0, syst_changelog);
}
