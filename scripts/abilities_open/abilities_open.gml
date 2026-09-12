/// @description abilities_open() - put the ability deck up over the
/// room you are standing in (his ask, 2026-09-12: the deck as an
/// overlay, like the upgrades - rm_abilitydeck is a dead room now).
/// The overlay contract: one panel at a time, the burger's X and
/// escape close it through ui_overlay_close, syst_input holds the room
/// quiet, ui_blur_tick softens it behind (the deck paints its own
/// black ground over that - the room it was is black).
function abilities_open() {
	if (instance_exists(syst_rm_ability) && syst_rm_ability.closing) {
		syst_rm_ability.closing = false;
		return;
	}
	if (ui_overlay() != noone) return;   // one panel at a time
	create_obj(0, 0, syst_rm_ability);
}
