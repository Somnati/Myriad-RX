/// @description stats_v2_widget([label], inst, [span]) - embed a LIVE
/// widget instance (a rarity bar, a slider, anything that draws at
/// its own x/y) inside the list. the row reserves `span` grid rows of
/// height; the framework chaperones the instance - positions it while
/// its row is in the window, parks it offscreen while it isn't, and
/// keeps it drawing above the rows. the widget stays its own object:
/// the list knows nothing about what it is (Myriad's @-anchor idea,
/// made first-class).
/// NOTE for sliders (par_slider children): the track x range is baked
/// at CREATE from x - spawn them at their final list x, the chaperone
/// only really moves them in y.
function stats_v2_widget(_name, _inst, _span = 2) {
	_span = max(1, _span);

	// the ALL-list survives rebuilds: a widget whose folder is closed
	// (or that fell out of a search) must still get parked every step,
	// or it lingers on screen. register even when the row won't build.
	if (instance_exists(_inst)) {
		var _known = false;
		for (var _w = 0; _w < array_length(widgets_all); _w++)
			if (widgets_all[_w] == _inst) { _known = true; break; }
		if (!_known) array_push(widgets_all, _inst);
		// the screen is an OVERLAY and raises g.input_block; its own
		// widgets listen through that rather than bailing on it.
		// Set HERE because this is the one funnel every widget passes
		// through - stats_v2_content creates them, this registers them.
		_inst.ui_layer = ui_layer_overlay;   // (the overlay's own rung, like settings' widgets - 2026-09-14)
		if (variable_instance_exists(_inst, "in_menu")) _inst.in_menu = true;
	}

	// widgets never appear in search results or inside closed folders
	if (search != "" || _fhid > 0) return;

	array_push(rows, {
		kind : 2, // widget
		name : _name,
		val  : "",
		c1   : rgb(195, 205, 235),
		c2   : c_white,
		fdep : _fdepth,
		path : "",
		key  : "",
		help : "",
		fav  : false,
		data : -1,
		open : false,
		inst : _inst,
		span : _span,
	});
	// pad rows keep the geometry uniform (virtualization stays trivial)
	repeat (_span - 1) array_push(rows, {
		kind : 3, name : "", val : "", c1 : c_white, c2 : c_white,
		fdep : _fdepth, path : "", key : "", help : "", fav : false,
		data : -1, open : false, inst : noone, span : 1,
	});
	span_max = max(span_max, _span);
	if (instance_exists(_inst)) {
		// depth-1: above the controller's rows, below the strip proxy
		// (depth-2) and the menu (-520). the whole screen stacks by
		// depth in the normal pass - see syst_statistics_v2's Draw_0
		// header for the recipe and the two dead ends.
		_inst.depth = depth - 1;
		array_push(widgets, _inst);
	}
}
