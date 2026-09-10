/// @description faq_close() - take the FAQ down. Arms the exit; its
/// Step destroys it once the ease reaches zero.
function faq_close() {
	if (!instance_exists(syst_faq)) return;
	syst_faq.closing = true;
}
