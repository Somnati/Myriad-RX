/// @description menu2_button(name, room, color) - one navigation
/// entry in the menu v2 registry (files under the current
/// menu2_section). adding a destination to the game menu is exactly
/// one call in menu2_content. runs in syst_menu2's scope.
function menu2_button(_name, _rm, _col, _key = "") {
	array_push(btns, {
		name : _name,
		rm   : _rm,
		col  : _col,
		sec  : cur_sec,
		key  : _key,   // the unfold key, for the "new" pulse (unfold_fresh) - "" for none
	});
}
