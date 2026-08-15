
if (bind_get == undefined) exit;

input = bind_get() ? 1 : 0;

pair // par_toggle: knob animation + flips input on an arbitrated click

if (clicked) {
	bind_set(input == 1);
	if (instance_exists(syst_settings)) syst_settings.dirty_tic = 45;
}
