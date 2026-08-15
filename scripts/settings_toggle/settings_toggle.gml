/// @description settings_toggle(label, get, set, [help], [col]) - an
/// on/off row carrying a live obj_set_toggle (par_toggle child, the
/// sliding-paddle switch). `get` returns the current bool, `set(v)`
/// applies a new one - the row owns NO state of its own, so the switch
/// can never drift from the real setting (a load, a reset, another
/// system flipping the global: the knob just follows).
/// tapping ANYWHERE on the row flips it too (fat mobile targets).
/// runs in syst_settings' scope; the widget spawns once, keyed by
/// label, and gets rebound every pass.
function settings_toggle(_label, _get, _set, _help = "", _col = -1) {

	var _inst = __widget("t_" + _label, obj_set_toggle);
	_inst.bind_get = _get;
	_inst.bind_set = _set;
	if (_inst.__fresh) { _inst.sync(); _inst.__fresh = false; }

	array_push(rows, {
		kind : sett_kind_toggle, name : _label, val : "",
		col : (_col == -1) ? sett_ink : _col,
		help : _help, ind : 0, inst : _inst,
		data : { get : _get, set : _set },
	});
}
