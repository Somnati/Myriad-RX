
if (bind_on == undefined) exit;

input = bind_on() ? 1 : 0;

pair // par_toggle_single: flips input on an arbitrated click

if (clicked)
if (!bind_on()) {
	bind_pick();
	if (instance_exists(syst_settings)) syst_settings.dirty_tic = 45;
}
