/// @description gift_open() - put the daily gift up over whatever room
/// you are standing in. THE ONE DOOR (the settings door's rule): the
/// menu line calls this rather than creating the object, so "is it
/// already up" is answered in one place; a panel still fading out is
/// caught and revived rather than refused.
function gift_open() {
	if (instance_exists(syst_gift_panel) && syst_gift_panel.closing) {
		syst_gift_panel.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;   // one panel at a time
	create_obj(0, 0, syst_gift_panel);
}
