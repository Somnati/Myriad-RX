
// the knob's grab ease (round 26; before the block-bail so a drag
// interrupted by a modal still settles smoothly)
gsc = move_to(gsc, grabbed ? 1 : 0, 3);

// blocked ui (menu drawer up, dialogue): par_slider grabs on RAW
// geometry, so bail here or a drag on the drawer would drag a slider
// underneath it. menu-layer sliders (in_menu, the power rail) listen
// THROUGH the drawer's block - the same rules the drawer plays by
if (in_menu ? !input_free(ui_layer_menu) : !input_free()) {
	grabbed = false;
	xdrag = 0;
	exit;
}

pair // par_slider: drag, val from knob position, edge clicks

if (bind_get == undefined) exit;

if (snap > 1) val = round(val / snap) * snap;

if (grabbed) {
	// push while dragging: live settings (volume, fps) apply as you go
	if (val != __last) {
		__last = val;
		bind_set(val);
		if (instance_exists(syst_settings)) syst_settings.dirty_tic = 45;
	}
}
else {
	// follow EXTERNAL changes (a settings load, reset to defaults)
	var _v = bind_get();
	if (_v != __last) {
		__last = _v;
		val = _v;
		pval = _v;
		p = (val - vmin) / max(1, vmax - vmin);
		xx = lerp(xmin, xmax, p);
	}
}
