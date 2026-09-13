/// @description tile_mat_config() -> THE MATERIAL POOL (his model,
/// 2026-09-13: "each tier pulls from an active set of shaders it
/// qualifies for and more exotic shaders become available at higher
/// tiers"). One row a material: its shader kind (sh_tile_mat's u_kind;
/// 0 = flat, no shader), the tier it opens at, its weight in the roll,
/// and whether that weight GROWS with the tiles' distance above the
/// floor (an exotic stays rare where it opens and becomes common far
/// above it; flat never grows, so it is outvoted as the pool widens).
/// A tile rolls once, when it is made (tile_skin_roll), and keeps its
/// surface for life; a merge makes a new tile, which rolls again from
/// the bigger pool - the merge moment's little reveal. Edit here.
function tile_mat_config() {
	static _c = [
		{ key : "flat",   kind : 0, min : 1, w : 4, grow : false },
		{ key : "sheen",  kind : 1, min : 2, w : 3, grow : true  },
		{ key : "liquid", kind : 2, min : 4, w : 3, grow : true  },
		{ key : "hole",   kind : 3, min : 6, w : 2, grow : true  },
		{ key : "stars",  kind : 4, min : 9, w : 1, grow : true  },
	];
	return _c;
}
