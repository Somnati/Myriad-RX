/// @description deck_failsafes() - dependency repair, the Myriad
/// controller's failsafe block grown into a script: a child ability
/// can never stay ENABLED without its parent enabled - turning the
/// parent off snaps its children off too (their AP returns on the
/// next grab_deck_ap). runs after every write-back and on load.
/// (GENERATED from build_deck.py's table - one line per chain link)
function deck_failsafes() {
	if (g.ad_critrate1 != 1 && g.ad_critrate2 == 1) g.ad_critrate2 = 0;
	if (g.ad_critrate2 != 1 && g.ad_critrate3 == 1) g.ad_critrate3 = 0;
	if (g.ad_critcut1 != 1 && g.ad_critcut2 == 1) g.ad_critcut2 = 0;
	if (g.ad_critcut2 != 1 && g.ad_critcut3 == 1) g.ad_critcut3 = 0;
	if (g.ad_tappersyphon1 != 1 && g.ad_tappersyphon2 == 1) g.ad_tappersyphon2 = 0;
	if (g.ad_tappersyphon2 != 1 && g.ad_tappersyphon3 == 1) g.ad_tappersyphon3 = 0;
	if (g.ad_fabricator != 1 && g.ad_fabricator2 == 1) g.ad_fabricator2 = 0;
	if (g.ad_fabricator2 != 1 && g.ad_fabricator3 == 1) g.ad_fabricator3 = 0;
	if (g.ad_automerger2 != 1 && g.ad_automerger3 == 1) g.ad_automerger3 = 0;
	if (g.ad_duplicator != 1 && g.ad_duplicator2 == 1) g.ad_duplicator2 = 0;
	if (g.ad_topgrade1 != 1 && g.ad_topgrade2 == 1) g.ad_topgrade2 = 0;
	if (g.ad_topgrade2 != 1 && g.ad_topgrade3 == 1) g.ad_topgrade3 = 0;
	if (g.ad_resetbracer != 1 && g.ad_resetbracer2 == 1) g.ad_resetbracer2 = 0;
	deck_apply();
}
