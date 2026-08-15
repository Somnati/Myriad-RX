/// @description services_init() - platform services state (steam +
/// google play), self-contained: safe to call from anywhere, runs
/// once. NOTHING here touches a real SDK yet: every services_* entry
/// point logs what it WOULD do, and the real calls sit in comment
/// blocks marked ">>> PLUG IN". that split is deliberate - GML will
/// not COMPILE a call to a function an uninstalled extension defines,
/// so live code stays extension-free until the extension is in.
///
/// THE HOOKUP CHECKLIST (when the extensions arrive):
///  1. install the extension (Steamworks / YYGooglePlayServices)
///  2. open each services_* script, uncomment its >>> PLUG IN block
///  3. flip the matching *_on detection below
///  4. rm_services (menu > system > services) is the test bench:
///     every button routes through these scripts, and the async
///     results land in syst_services' log panel
function services_init() {
	if (variable_global_exists("services")) return;
	g.services = {
		steam_on : false,  // >>> PLUG IN (steam): after the extension is
			// in, detect with steam_initialised() here
		gpgs_on : false,   // >>> PLUG IN (google play): true on android
			// once GooglePlayServices_* exists
		signed_in : false, // google play sign-in state (async callbacks
			// will drive this; the stub flips it instantly)
		cloud_stamp : "never", // last cloud push/pull, for the bench
		log : [],          // the debug room's on-screen log lines
	};
	services_log("services init (stub mode - no sdk wired)");

	// >>> PLUG IN (steam): nothing to init by hand - GM auto-inits
	// steamworks when the extension + app id are configured. verify:
	// services_log("steam: " + string(steam_initialised()));

	// >>> PLUG IN (google play):
	// GooglePlayServices_Initialize();
	// then wait for the async system event before signing in.
}
