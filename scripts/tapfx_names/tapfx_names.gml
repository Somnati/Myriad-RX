/// @description tapfx_names() -> the tap effects, by saved index (g.tap_fx)
/// ONE list for syst_tapfx (which fires by index) and the settings pill
/// (settings > visuals > the tap, his call 2026-09-14 - the money room's
/// [fx] chip is gone). The index is the settings.ini value: append, never
/// reorder, or every saved pick shifts.
function tapfx_names() {
	static _n = ["none", "glow", "shock mono", "shock chroma", "glow + mono",
	             "plus", "x", "square", "implode", "lightning"];
	return _n;
}
