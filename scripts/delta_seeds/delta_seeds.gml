/// @description delta_seeds() -> the seed ladder: name, yield a harvest, the silt and the wet it wants, seconds to ripen
function delta_seeds() {
	static _s = [
		{ name : "reeds",   yield : 1,  silt : .06, wet : .12, ripen : 40 },
		{ name : "barley",  yield : 3,  silt : .15, wet : .18, ripen : 55 },
		{ name : "rice",    yield : 9,  silt : .28, wet : .30, ripen : 70 },
		{ name : "saffron", yield : 30, silt : .45, wet : .25, ripen : 110 },
	];
	return _s;
}
