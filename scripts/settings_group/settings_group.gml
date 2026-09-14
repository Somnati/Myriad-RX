/// @description settings_group(name, [col]) - a HEADING inside a tab: the
/// name in the tab's colour with a rule running to the value column, no
/// widget, nothing to tap. The favorites tab's group-title row, offered
/// to content (his ask, 2026-09-14: the visuals tab organised). Rows
/// under it are not indented - the rule is the grouping.
/// runs in syst_settings' scope.
function settings_group(_name, _col = -1) {
	array_push(rows, {
		kind : sett_kind_info, name : _name, val : "",
		col : (_col == -1) ? sett_ink : _col,
		help : "", ind : 0, inst : noone, data : -1, group : true,
	});
}
