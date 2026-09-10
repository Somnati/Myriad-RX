/// @description rng_release(seed) - leave a seeded section. Call this
/// where the old pattern called random_set_seed(the saved seed).
/// @param seed  what random_get_seed() returned before the section
///
/// ⚖️ THE "RESTORE" NEVER RESTORED. GameMaker's random_get_seed()
/// returns the seed that was SET, not the generator's evolved state
/// (CLAUDE.md knew; the roll sites did not). So
///
///     var _s = random_get_seed();
///     random_set_seed(tier * 1450); ... rolls ...
///     random_set_seed(_s);
///
/// does not hand the ambient stream back where it was - it REWINDS it
/// to the start of the boot seed's sequence. Every call. tile_color
/// and vis_tier_color did that once per tile, per frame, so every
/// frame's random() calls replayed the same numbers in the same order:
/// each tap mote flew the identical curve (its cx = random(room_width)
/// was the same number every frame), the tile fountain's slot k took
/// slot k's path every second, and the deck's finish rolls "repeated"
/// (syst_rm_ability's own comment - the symptom was seen and patched
/// locally with a randomize(), which then rewound the stream again on
/// its way out). His report, 2026-09-10: "they all are seeded to take
/// the same path".
///
/// GM exposes no state to put back, so the honest release is a FRESH
/// seed: the saved one folded with a salt that moves every call (a
/// Weyl step on the golden-ratio constant - exact in doubles, distinct
/// for 2^31 calls). The ambient stream is randomize()'d at boot and
/// nothing may depend on its continuity - the deterministic-rolls law
/// covers SEEDED sections, which this leaves untouched - so a fresh
/// seed on exit is exactly as random as the stream was supposed to be.
///
/// The hot callers also CACHE now (a tier's colour never changes), so
/// in practice this fires a handful of times a session, not sixteen
/// times a frame.
function rng_release(_seed) {
	if (!variable_global_exists("rng_salt")) g.rng_salt = 1;
	g.rng_salt = (g.rng_salt + 2654435761) & $7fffffff;
	random_set_seed((_seed ^ g.rng_salt) & $7fffffff);
}
