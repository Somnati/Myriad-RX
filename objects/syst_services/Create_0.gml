/// services test bench (rm_services) - debug buttons for everything
/// steam / google play, wired TODAY so the sdk hookup later is just
/// uncommenting. every button routes through the services_* scripts
/// (the game's ONE service api - gameplay code calls those, never an
/// extension directly), and everything they do reports into the log
/// panel on the right.
///
/// >>> ADD A BUTTON: one line in the rows array below.
/// >>> HOOK UP AN SDK: follow the checklist in services_init().
///
/// async note for future me: extension results land in Async - Social
/// / Async - Steam events. when the extensions are in, add those
/// events to THIS object, parse async_load, and end every branch with
/// services_log(...) - the bench then shows live sdk traffic.

services_init();

bby = obj_ui_header.sprite_height;

// the bench rows: fn = -1 draws a section header, anything else is a
// button running that call. adding one = one line.
rows = [
	{ name : "google play",             col : c_seagreen,  fn : -1 },
	{ name : "sign in",                 col : c_seagreen,  fn : function() { services_signin(); } },
	{ name : "sign out",                col : c_seagreen,  fn : function() { services_signout(); } },

	{ name : "cloud save",              col : c_sblue,     fn : -1 },
	{ name : "push save to cloud",      col : c_sblue,     fn : function() { services_cloud_push(); } },
	{ name : "pull cloud save (!)",     col : c_hred,      fn : function() { services_cloud_pull(); } },

	{ name : "steam",                   col : c_steelblue, fn : -1 },
	{ name : "unlock test achievement", col : c_steelblue, fn : function() { services_achieve("ACH_TEST"); } },
	{ name : "clear test achievement",  col : c_steelblue, fn : function() { services_achieve_clear("ACH_TEST"); } },
	{ name : "overlay test",            col : c_steelblue, fn : function() {
		services_log("overlay > STUB (steam_activate_overlay(\"friends\") when live)"); } },
	{ name : "store stats flush",       col : c_steelblue, fn : function() {
		services_log("stats flush > STUB (steam_store_stats() when live)"); } },
];

// geometry: buttons down the left, the log panel owns the right.
// one function feeds draw AND hit test (house rule - no drift)
btn_x = 8;
btn_w = 158;
btn_h = 15;
log_x = btn_x + btn_w + 10;
__row_y = function(_i) { return bby + 20 + _i * (btn_h + 2); };
