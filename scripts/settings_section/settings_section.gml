/// @description settings_section(name, col) - start a settings
/// category. every section becomes a TAB in the left rail, and the
/// rows declared under it show only while that tab is active -
/// declaring a section here is ALL it takes, the rail builds itself.
/// (the pushed row is a slice marker for the controller, never drawn.)
/// runs in syst_settings' scope (rows / sections are its vars).
function settings_section(_name, _col) {
	array_push(sections, { name : _name, col : _col, row : array_length(rows) });
	array_push(rows, {
		kind : sett_kind_section, name : _name, val : "", col : _col,
		help : "", ind : 0, inst : noone, data : -1,
	});
}
