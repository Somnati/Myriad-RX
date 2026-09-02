/// tour_services - STEAM AND GOOGLE PLAY  (engine/services)
/// A TOUR SCRIPT: comments only, nothing runs.
/// ALL STUBS TODAY. No SDK extension is installed, and GML will not
/// compile a call to a function an uninstalled extension defines -
/// so the real calls sit in comment blocks marked ">>> PLUG IN".

// ========================== THE FILES ===============================
//   services_init    builds g.services (steam_on, gpgs_on, signed_in,
//                    cloud_stamp, log) once; safe to call anywhere.
//                    Its header is THE HOOKUP CHECKLIST for the day
//                    the extensions arrive.
//   services_signin / services_signout / services_cloud_push /
//   services_cloud_pull / services_achieve / services_achieve_clear
//                    THE ONE API gameplay calls. Each logs what it
//                    WOULD do and carries its >>> PLUG IN block.
//   services_log     every result routes here, into the bench panel.
//   syst_services + rm_services   the bench (menu > game > services):
//                    a button per call on the left, the log on the
//                    right. Adding a button is one line in `rows`.

// ============================= WHY ==================================
// So gameplay never talks to an extension directly. When the SDKs are
// in, the only edits are inside services_*; the game code stays as
// it is. Async results (Steam / Social events) get added to
// syst_services and end in services_log.
