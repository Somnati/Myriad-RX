/// @description sprite_flaw(sprite) -> its one flaw (flaw_gen off its id) - derived, never stored
function sprite_flaw(_sp) {
	return flaw_gen(hash_mix(_sp.id, 9500));
}
