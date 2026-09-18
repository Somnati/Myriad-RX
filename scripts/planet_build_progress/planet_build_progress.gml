/// @description planet_build_progress(pn) -> 0..1, how far a world's build stands for a veil's bar: seven tenths the rows of samples, three the sheets (planet_build_step's two stages; q225 - the formula lived in two places)
function planet_build_progress(_pn) {
	if (!is_struct(_pn)) return 0;
	return .7 * clamp(_pn.row / max(1, _pn.th), 0, 1) + .3 * clamp((_pn[$ "brow"] ?? 0) / max(1, 3 * _pn.th), 0, 1);
}
