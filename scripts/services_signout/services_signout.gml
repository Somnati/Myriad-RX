/// @description services_signout() - google play sign-out. same
/// contract as services_signin: the game only ever calls this.
function services_signout() {
	if (!variable_global_exists("services")) services_init();

	if (!g.services.gpgs_on) {
		g.services.signed_in = false;
		services_log("sign out > STUB ok (gpgs not installed)");
		return;
	}

	services_log("sign out > requesting...");
	// >>> PLUG IN (google play):
	// GooglePlayServices_SignOut();
	// async result: set g.services.signed_in = false + log it.
}
