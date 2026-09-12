/// @description abilities_close() - arm the deck's close; its Step
/// eases it out and destroys it (and its slots, cards and scrollbar)
function abilities_close() {
	if (!instance_exists(syst_rm_ability)) return;
	syst_rm_ability.closing = true;
}
