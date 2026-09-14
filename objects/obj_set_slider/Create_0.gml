/// generic BINDABLE slider (par_slider's drag track). syst_settings
/// spawns one per slider row - at its FINAL x, because par_slider
/// bakes the track range at create - then scales/binds it and calls
/// reinit(). pushes bind_set live WHILE dragging (volume and fps cap
/// react under the finger); follows external changes (loads, resets)
/// when idle.

pair

vmin = 0;
vmax = 100;
suffix = "";  // readout decoration: "%", " fps"
snap = 1;     // dragged values round to this step
in_menu = false; // true = the slider LIVES on the menu layer (the
	// power rail rides the hamb drawer): it listens through the menu
	// input block instead of bailing on it
bind_get = undefined; // fn -> real : read the setting
bind_set = undefined; // fn(v)      : write the setting
bind_rel = undefined; // fn()       : the knob was released (a fader's audition)
__was_grabbed = false;
if (!variable_instance_exists(id, "ui_layer")) ui_layer = 0;   // its rung (syst_input reads it; the gate below too)
__last = undefined;
gsc = 0; // grab ease 0..1 (round 26): the knob used to SWAP frames
	// on grab/release (inset 7x7 <-> full 9x9) and the track margin
	// around it popped back in when a drag settled (his report) -
	// the knob is ONE solid frame now, scale-eased through this

// bake the track from the final x + xscale and put the knob on the
// bound value. the controller calls this once after configuring.
reinit = function() {
	xmin = x - 1;
	xmax = x + sprite_width - ww;
	val = bind_get();
	__last = val;
	pval = val;
	p = (val - vmin) / max(1, vmax - vmin);
	xx = lerp(xmin, xmax, p);
	x1 = xx - 1; // the knob hitbox: par_slider only computes it in its
	y1 = y - 1;  // step, but our step can bail (blocked ui) before the
	x2 = x1 + ww + 1; // first draw reads it
	y2 = y1 + ww + 1;
};

// safe pre-reinit values for the same reason
x1 = xx - 1;
y1 = y - 1;
x2 = x1 + ww + 1;
y2 = y1 + ww + 1;

// house accent instead of par_slider's random spawn color
cbase = c_sblue;
hue = c_hue(cbase);
sat = c_sat(cbase);
c0 = c_hsv(hue, 20, 50);
c1 = cbase;
cbar = c_hsv(c_hue(c1), sat, 150);
/// a track in another colour (settings_slider's col): white reads as a
/// grey track with a white knob
recolour = function(_c) {
	cbase = _c; hue = c_hue(_c); sat = c_sat(_c);
	c0 = c_hsv(hue, min(sat, 20), 50);
	c1 = _c;
	cbar = (sat < 10) ? merge_colour(_c, c_black, .3) : c_hsv(hue, sat, 150);
};
