/// @description faq_open() - put the FAQ up over whatever room you are
/// standing in. THE ONE DOOR (the settings door's rule): a panel still
/// fading out is caught and revived; a second panel is refused.
function faq_open() {
	if (instance_exists(syst_faq) && syst_faq.closing) {
		syst_faq.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;   // one panel at a time
	create_obj(0, 0, syst_faq);
}
