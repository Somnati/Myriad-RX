/// @description tile_mat(tier) -> { metal, iri } - what a tier is made
/// of, for sh_tile. Stable per tier: the same tier is the same material
/// on every board and across saves.
///
/// ⚖️ HASHED FROM THE TIER, NOT ROLLED. A material re-rolled per frame is
/// a strobe; one rolled per instance makes two tier-7s look like two
/// different things, which is precisely the pair-finding the shape
/// channel exists to protect. sin/frac touches no RNG stream and needs
/// no seed save-and-restore (vis_tier_color documents that trap - DE's
/// version scrambled the caller's stream mid-formula).
///
/// The colour is NOT here on purpose. It stays tile_color(tier), the
/// rarity ladder, because colour is the channel that says how far up
/// the ladder a tile is and a material must not be allowed to lie about
/// that. Material says what it is MADE OF; colour says what it is WORTH.
///
/// Two lopsided distributions, both deliberate:
///   a third of tiers are near-matte, because a board where everything
///   glints is a board where the glint says nothing
///   a fifth are films, because the film is the loudest finish and the
///   one that fights the digit on top hardest
function tile_mat(_tier) {
	if (_tier <= 0) return { metal : 0, iri : 0 };
	var _h1 = frac(sin(_tier * 12.9898) * 43758.5453);
	var _h2 = frac(sin(_tier * 94.6730) * 16180.3399);
	var _metal = (_h1 < .34) ? lerp(0, .12, _h1 / .34)
	                         : lerp(.30, 1.0, (_h1 - .34) / .66);
	var _iri = (_h2 < .80) ? 0 : lerp(.45, .85, (_h2 - .80) / .20);
	return { metal : _metal, iri : _iri };
}
