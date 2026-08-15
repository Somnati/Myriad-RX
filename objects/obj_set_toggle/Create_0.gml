/// generic BINDABLE on/off switch (par_toggle's sliding paddle) - the
/// settings screen's workhorse. syst_settings pools these and assigns
/// bind_get / bind_set; the knob re-reads bind_get every step, so it
/// can never drift from the real value (a load, a reset, another
/// system flipping the global: the paddle just follows). the old
/// one-object-per-setting toggles (obj_options_toggle_*) are untouched.

input = 0;

hue = color_get_hue(c_blue);
sat = 200;
lum = 200;

pair

bind_get = undefined; // fn -> bool : read the setting
bind_set = undefined; // fn(v)     : write the setting
__fresh  = true;      // controller calls sync() once after first bind

// put the knob on the bound state with NO slide animation (spawn and
// row-taps use this, so the paddle doesn't wander on rebinds)
sync = function() {
	input = bind_get() ? 1 : 0;
	xx = input ? x1 : x0;
};
