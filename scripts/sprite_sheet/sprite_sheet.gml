/// @description sprite_sheet(sprite) -> its SHEET (made on first ask)
/// { cls, lv, xp, sks, w1, w2, armor[], talis[], inv[], notes[] } - the class
/// (rolled from the sprite's id so a sprite is the same class on every
/// load), the level and its xp toward the next, the skill seed (its
/// procedural skills derive from it: sprite_skills), the worn gear by
/// slot kind (armor / talis are arrays, the class says how many) and
/// the inventory (SPRITE_INV at most). A sprite saved before sheets
/// existed gets one here, level 1, empty-handed. Meta: survives rebirth
/// with the sprite (his call).
function sprite_sheet(_sp) {
	if (is_struct(_sp[$ "sheet"])) { if (!is_array(_sp.sheet[$ "notes"])) _sp.sheet.notes = []; if (!is_array(_sp.sheet[$ "learned"])) _sp.sheet.learned = []; return _sp.sheet; }
	var _cl = sprite_classes();
	var _sh = {
		cls : (_sp.id * 7 + 3) mod array_length(_cl),   // spread across the roster, stable per id
		lv : 1, xp : 0,
		sks : (_sp.id * 2654435761 + 977) & $7fffffff,
		w1 : undefined, w2 : undefined, armor : [], talis : [],
		inv : [],
		notes : [],   // THE NOTEPAD (his ask): { txt, tag } - tag "foe:<kind>" or "" (sprite_note)
		learned : [], abil : [-1, -1, -1, -1], abnew : false,   // SKILLS LEARNED ON THE ROAD (2026-09-15): { tmpl, seed } each (cbt_skill_gen rebuilds them); the class's own skill is always first
	};
	_sp.sheet = _sh;
	return _sh;
}
