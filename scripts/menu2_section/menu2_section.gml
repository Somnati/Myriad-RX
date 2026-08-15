/// @description menu2_section(name) - begins a labeled group in the
/// menu v2 registry. every menu2_button() after it files under this
/// header until the next section. runs in syst_menu2's scope.
function menu2_section(_name) {
	cur_sec = _name;
	array_push(secs, _name);
}
