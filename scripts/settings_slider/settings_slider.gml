/// @description settings_slider(label, vmin, vmax, get, set, [suffix],
/// [snap], [help]) - a numeric row carrying a live obj_set_slider
/// (par_slider child). `get`/`set` bind it to the real value, `suffix`
/// decorates the readout ("%", " fps"), `snap` rounds dragged values
/// to a step (fps cap snaps to 5s; volume runs free at 1).
/// par_slider bakes its track x range at CREATE, so the widget spawns
/// at its final list x (sl_x, controller-derived) and the chaperone
/// only ever moves it in y - the same rule stats_v2_widget documents.
/// runs in syst_settings' scope; widget pooled by label.
/// [col]  the track's colour (the house blue when omitted) - his ask,
///        2026-09-14: the four faders in four colours
/// [rel]  a function run when the knob is RELEASED - what a fader
///        auditions with, so a drag is not a sound a frame (his report)
/// [live] true = a VISUALISER setting: while this knob is held in a room
///        with the visualiser, the whole screen fades to the knob (the
///        peek - syst_settings' Step) so the change is seen as it is made
function settings_slider(_label, _vmin, _vmax, _get, _set, _suffix = "", _snap = 1, _help = "", _col = -1, _rel = undefined, _live = false) {

	var _k = "s_" + _label;
	var _inst = pool[$ _k];
	if (_inst == undefined || !instance_exists(_inst)) {
		// spawned at final x (track bakes there), parked in y
		_inst = create_obj(sl_x, -1000, obj_set_slider);
		_inst.depth = depth - 1; // above rows, under the strip proxy/menu
		// the screen is an OVERLAY and raises g.input_block; its own
		// widgets listen through that block rather than bailing on it
		// (ui_layer for syst_input's arbitration, in_menu for the
		// slider's own gate - it was built for exactly this)
		_inst.ui_layer = ui_layer_overlay;   // (the overlay's own rung: under a pillbox it goes quiet - his report, 2026-09-14)
		_inst.in_menu  = true;
		_inst.image_xscale = sl_scale;
		pool[$ _k] = _inst;
		_inst.vmin     = _vmin;
		_inst.vmax     = _vmax;
		_inst.suffix   = _suffix;
		_inst.snap     = _snap;
		_inst.bind_get = _get;
		_inst.bind_set = _set;
		_inst.reinit(); // recompute track + knob from the bound value
	}
	// rebind every pass: content closures are rebuilt each step
	_inst.bind_get = _get;
	_inst.bind_set = _set;
	_inst.bind_rel = _rel;
	_inst.live = _live;
	if (_col != -1 && _inst.cbase != _col) _inst.recolour(_col);

	array_push(rows, {
		kind : sett_kind_slider, name : _label, val : "",
		col : sett_ink, help : _help, ind : 0, inst : _inst, data : -1,
	});
}
