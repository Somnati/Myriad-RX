/// @description offlog_record(entry) - file one replay's entry in the
/// offline log, newest first; the ledger keeps the last OFFLOG_KEEP.
/// offline_replay is the ONE caller - it builds the entry as it runs,
/// every number a snapshot of the state the systems actually saw.
function offlog_record(_e) {
	offlog_init();
	array_insert(g.offlog.runs, 0, _e);
	while (array_length(g.offlog.runs) > OFFLOG_KEEP) array_pop(g.offlog.runs);
}
