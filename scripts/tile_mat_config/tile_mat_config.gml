/// @description tile_mat_config() -> THE MATERIAL LADDER (his call,
/// 2026-09-13: "the shaders should be tied to the tier"). One row a
/// tier, in order: the tier's shader kind (sh_tile_mat's u_kind; 0 =
/// flat, no shader) and its name. Every tile of a tier wears the same
/// surface; the surfaces climb in strangeness with the tiers. Past the
/// last row the ladder CYCLES its top six, so a board that outgrows it
/// keeps changing rather than freezing on one look. Edit here; the
/// twin (tilemat_twin.py) prints the ladder as it reads it.
function tile_mat_config() {
	static _c = [
		{ tier : 1,  key : "flat",    kind : 0  },
		{ tier : 2,  key : "sheen",   kind : 1  },
		{ tier : 3,  key : "bands",   kind : 5  },
		{ tier : 4,  key : "stripes", kind : 6  },
		{ tier : 5,  key : "lattice", kind : 7  },
		{ tier : 6,  key : "liquid",  kind : 2  },
		{ tier : 7,  key : "ripple",  kind : 8  },
		{ tier : 8,  key : "pulse",   kind : 11 },
		{ tier : 9,  key : "hole",    kind : 3  },
		{ tier : 10, key : "ember",   kind : 9  },
		{ tier : 11, key : "orbit",   kind : 10 },
		{ tier : 12, key : "aurora",  kind : 13 },
		{ tier : 13, key : "static",  kind : 12 },
		{ tier : 14, key : "stars",   kind : 4  },
	];
	return _c;
}
