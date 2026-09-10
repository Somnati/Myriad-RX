/// @description tile_color(tier) -> the tier's identity colour. ONE
/// palette for the whole game now (2026-09-10, his call): this is
/// vis_tier_color, so a tier-11 tile and a 1e20 field on the
/// visualiser are the same colour by construction, and the elite rung
/// is the red the tiles always had rather than the orange the
/// visualiser had - which put two yellows side by side up there.
/// Past 8 the hues step by the golden angle; see vis_tier_color for
/// why that replaced DE's seeded wheel.
function tile_color(_tier) {
	return vis_tier_color(_tier);
}
