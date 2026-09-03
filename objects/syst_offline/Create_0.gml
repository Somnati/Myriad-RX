/// syst_offline - THE ABSENCE WATCHER (Myriad DE's syst_offline +
/// obj_idletime, rebuilt). Persistent; lazy-spawned by
/// syst_handle_save's Create so it exists from boot in every room.
/// Two jobs, both tiny - the calculator itself is offline_replay():
///   1. THE SUSPEND CATCH-UP (Step): GM stops stepping while a phone
///      has the app in the background or a laptop sleeps, but the
///      wall clock runs on. A gap between two consecutive steps longer
///      than GAP seconds can only be a suspension, so it is replayed
///      exactly like a closed-app absence. DE re-loaded the save on
///      Android resume to get the same effect; measuring the step gap
///      needs no platform hooks and covers PC sleep too.
///   2. THE REPORT (Step): the queued g.offline_report becomes DE's
///      stacked welcome-back banners the next time the money room is
///      up with a run started - "welcome back" on top.

if (instance_number(syst_offline) > 1) { kill; exit; }

last_now = date_current_datetime();
GAP = 5;        // seconds between steps that reads as a suspension
REPORT_MIN = 60; // absences shorter than this replay silently
