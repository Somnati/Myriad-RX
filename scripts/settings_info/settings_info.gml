/// @description settings_info(label, value, [help], [col]) - a plain
/// read-only row: label left, value right-aligned at the value column.
/// value is a string (stringify numbers yourself). rows with help text
/// open the floating explainer on tap.
/// runs in syst_settings' scope.
function settings_info(_label, _val, _help = "", _col = -1) {
	array_push(rows, {
		kind : sett_kind_info, name : _label, val : string(_val),
		col : (_col == -1) ? sett_ink : _col,
		help : _help, ind : 0, inst : noone, data : -1,
	});
}
