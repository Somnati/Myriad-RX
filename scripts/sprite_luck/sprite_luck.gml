/// @description sprite_luck(sprite) -> the sprite's LUCK (his ask, 2026-09-16): the class's point or three, one more every five levels, one for the sly and the dreamy
/// Outside the forty-point budget (the shape is untouched, the twin holds).
/// What it does: half a point of crit a point (sprite_pawn), the party's
/// luck leans the loot ladder (exped_party_luck), and the lucky make fewer
/// dumb moments (sprite_take). Foes carry a luck of their own (foe_gen).
function sprite_luck(_sp) {
	if (is_undefined(_sp)) return 0;
	var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
	var _l = (_c[$ "luck"] ?? 1) + floor(_sh.lv / 5);
	var _pl = sprite_personalities();
	var _pn = _pl[clamp(_sp[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
	if (_pn == "sly" || _pn == "dreamy") _l += 1;
	if (is_struct(_sh[$ "elix"])) _l += _sh.elix[$ "luck"] ?? 0;   // (an elixir of luck, 2026-09-16)
	_l += sprite_ab(_sp).luck;   // (the "lucky" ability, 2026-09-17 - and jinxed, the flaw)
	return max(0, _l);
}
