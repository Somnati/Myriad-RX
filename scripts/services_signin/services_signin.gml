/// @description services_signin() - google play sign-in. the game
/// calls THIS everywhere (never the extension directly), so swapping
/// the stub for the real call is one edit in one file.
function services_signin() {
	if (!variable_global_exists("services")) services_init();

	if (!g.services.gpgs_on) {
		// stub: pretend the async round-trip succeeded instantly
		g.services.signed_in = true;
		services_log("sign in > STUB ok (gpgs not installed)");
		return;
	}

	services_log("sign in > requesting...");
	// >>> PLUG IN (google play):
	// GooglePlayServices_SignIn();
	// the result arrives in an Async - Social event (check it in
	// syst_services' notes); on success set g.services.signed_in = true
	// and services_log the account. on failure log the error code.
}
