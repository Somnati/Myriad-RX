/// @description planet_build_step(pn, [until], [rows]) -> true once the world stands (planet_lite_ready): THE ONE BUILDER'S STEP (q225) - the rows of samples (planet_gen_step, one at a time against the deadline; `rows` caps them, a caller's per-frame ration), then the three sheets (planet_bake on the same deadline); no deadline = the whole world in one call
/// THE BUILDERS' LAW (q225, after bug hunt 4 - five resumable builders
/// written on five days, and the bug sat in the seam between two of them):
///   - the CURSOR lives on the thing being built (pn.row, pn.brow, l.row,
///     gen.i), never on the caller - any caller may step it, none owns it;
///   - a STEP takes a get_timer deadline (microseconds) and does what fits,
///     at least one unit when it can - a call is never wasted;
///   - a LOST sheet is only ever a FINISHED stage's (its sheet is uploaded
///     at the stage's end): a stage in progress has none by design and
///     must never be restarted for it (the q224 bug);
///   - READY is one predicate, read by the veils and the painters alike
///     (planet_lite_ready here; l.ready for a tier; galaxy_ready for the
///     chart) - a painter draws nothing of a world that is not ready.
/// The four callers that composed rows-then-bake by hand (the boot's
/// builder, the stamps' list, the page's __worlds_step, planet_get_lite's
/// whole path) all step through here now; the tier (TierKeep.step) and the
/// chart (starmap_gen_step) keep the same shape on their own structs
function planet_build_step(_pn, _until = infinity, _rows = undefined) {
	if (!is_struct(_pn)) return false;
	var _n = 0;
	while (_pn.row < _pn.th && get_timer() < _until && (is_undefined(_rows) || _n < _rows)) { planet_gen_step(_pn, 1); _n++; }
	if (_pn.row >= _pn.th) planet_bake(_pn, _until);
	return planet_lite_ready(_pn);
}
