/// @description sprite_skills(sprite) -> its skills, an array of skill structs
/// The class's library skill, plus PROCEDURAL ones from the sheet's
/// seed: one at level 1, another at 10 and 20 (three at most), each
/// rolled from a template the class allows (sprite_classes.tmpls) -
/// derived, never stored, so a sprite's skills are the same on every
/// load and a level-up simply reveals the next.
function sprite_skills(_sp) {
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _lib = cbt_skills();
	var _out = [ _lib[$ _c.skill] ];
	var _n = clamp(1 + floor(_sh.lv / 10), 1, 3);
	for (var _i = 0; _i < _n; _i++) {
		var _tm = _c.tmpls[_i mod array_length(_c.tmpls)];
		array_push(_out, cbt_skill_gen((_sh.sks + _i * 7919) & $7fffffff, _tm));
	}
	return _out;
}
