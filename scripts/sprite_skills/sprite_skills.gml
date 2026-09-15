/// @description sprite_skills(sprite) -> its skills, an array of skill structs
/// The class's library skill first, then the ones LEARNED ON THE ROAD
/// (the sheet's learned list: { tmpl, seed } each, rebuilt by
/// cbt_skill_gen so the same seed is the same skill on every load). One
/// at level 1 (his call, 2026-09-15); the rest come from fights, shrines,
/// taverns and levels (sprite_skill_learn), up to SPRITE_SKILLS in all.
function sprite_skills(_sp) {
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _lib = cbt_skills();
	var _out = [ _lib[$ _c.skill] ];
	for (var _i = 0; _i < array_length(_sh.learned) && array_length(_out) < SPRITE_SKILLS; _i++) {
		var _l = _sh.learned[_i];
		array_push(_out, cbt_skill_gen(_l.seed & $7fffffff, _l.tmpl));
	}
	return _out;
}
