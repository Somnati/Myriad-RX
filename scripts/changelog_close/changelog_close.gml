/// @description changelog_close() - take the changelog down. Arms the
/// exit; its Step destroys it once the ease reaches zero.
function changelog_close() {
	if (!instance_exists(syst_changelog)) return;
	syst_changelog.closing = true;
}
