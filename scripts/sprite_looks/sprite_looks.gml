/// @description sprite_looks() - THE EYE STYLES AND THE MATERIALS, as
/// data (his ask, 2026-09-11: "different eyes and colors and maybe
/// even shaders/materials"). A sprite rolls one of each at birth.
///
///   eyes[i]  { name, w, h, pupil, mouth, gap }
///     w/h    the white's size in room px (2x2 dots, 2x4 pills - his
///            inspiration's tall bars - 3x2 wide, one 3x3 cyclops...)
///     pupil  true = a 1px pupil that looks at the pointer
///     mouth  true = the little mouth dot below
///     gap    px between the two eyes' inner edges (0 = one eye)
///   mats[i]  { name }  the sh_blob material by index - picked by RARITY
///            (sprite_spawn's table: commons are matte, exotic finishes
///            are for the exotic ones; opal is divine and up)
function sprite_looks() {
	if (variable_global_exists("sprite_looks_cfg")) return g.sprite_looks_cfg;
	g.sprite_looks_cfg = {
		eyes : [
			{ name : "dots",    w : 2, h : 2, pupil : true,  mouth : true,  gap : 3 },
			{ name : "pills",   w : 2, h : 4, pupil : false, mouth : false, gap : 3 },
			{ name : "wide",    w : 3, h : 2, pupil : true,  mouth : true,  gap : 2 },
			{ name : "cyclops", w : 3, h : 3, pupil : true,  mouth : true,  gap : 0 },
			{ name : "sparkle", w : 2, h : 2, pupil : false, mouth : true,  gap : 3 },   // dark eyes with a glint
			{ name : "lidded",  w : 2, h : 2, pupil : true,  mouth : true,  gap : 3 },   // half-closed
			{ name : "beady",   w : 1, h : 1, pupil : false, mouth : true,  gap : 4 },
		],
		mats : [
			{ name : "matte" },
			{ name : "glass" },
			{ name : "metal" },
			{ name : "jelly" },
			{ name : "opal"  },
		],
		// the material by rarity: common .. ultimate
		mat_by_rar : [0, 0, 3, 3, 1, 1, 2, 4],
	};
	return g.sprite_looks_cfg;
}
