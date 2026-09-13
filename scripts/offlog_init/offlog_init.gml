/// @description offlog_init() - THE OFFLINE LOG's ledger (his ask,
/// 2026-09-12: "tech demo had an offline log... we need one... clean
/// and legible... maybe even a debug version that i can swap to in that
/// screen"). Techdemo II's g.offdbg, grown into a player-facing log.
///
/// SESSION-ONLY - never saved, never loaded, zero effect on the sim.
/// Every launch begins with an absence, so every session begins with an
/// entry; suspend catch-ups and the debug bench's sim buttons add more.
/// offline_replay files one entry per replay through offlog_record,
/// newest first, the last OFFLOG_KEEP kept. syst_offlog is the view.
///   g.offlog = { runs : [entry...], debug : the [debug] chip's state }
function offlog_init() {
	if (variable_global_exists("offlog")) return;
	g.offlog = { runs : [], debug : false };
}
