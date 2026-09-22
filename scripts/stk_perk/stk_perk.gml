/// @description stk_perk(s, key) -> the rank held of that perk (0 = none)
function stk_perk(_s, _key) {
	return _s.perks[$ _key] ?? 0;
}
