/// @description syz_open() - to SYZYGY's room (the menu's [syzygy], q315)
function syz_open() {
	syz_init();
	goto_room(rm_syzygy);
}
