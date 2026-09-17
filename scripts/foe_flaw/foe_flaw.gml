/// @description foe_flaw(seed) -> a foe's one flaw (flaw_gen off its seed) - every foe has one too (his call, 2026-09-17)
function foe_flaw(_seed) {
	return flaw_gen(hash_mix(_seed & $7fffffff, 9500));
}
