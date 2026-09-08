/// @description deck_failsafes() - dependency repair, the Myriad
/// controller's failsafe block grown into a script: a child ability
/// can never stay ENABLED without its parent enabled - turning the
/// parent off snaps its children off too (their AP returns on the
/// next grab_deck_ap). runs after every write-back and on load.
/// one line per parent->child chain; keep in sync with the batches.
function deck_failsafes() {
	if (g.ad_probespeed != 1 && g.ad_probespeed2 == 1) g.ad_probespeed2 = 0;
	if (g.ad_automerger != 1 && g.ad_automerger2 == 1) g.ad_automerger2 = 0;
	if (g.ad_fabricator != 1 && g.ad_fabricator2 == 1) g.ad_fabricator2 = 0;
}
