/// @description stk_perks() -> THE CINDER TREE (q317): the perks cinders buy - declarative, APPEND ONLY. { key, name, base, step, max, what }: rank r costs base + step x r cinders
function stk_perks() {
	static _p = [
		{ key : "headstart", name : "headstart",      base : 2, step : 1, max : 3, what : "every run starts with the well at lv 3 a rank" },
		{ key : "focus",     name : "sharper focus",  base : 3, step : 1, max : 4, what : "the focused sink +x.25 a rank" },
		{ key : "reach",     name : "the long reach", base : 2, step : 1, max : 5, what : "the catch-up reaches a day more a rank" },
		{ key : "hand",      name : "the hand",       base : 3, step : 0, max : 1, what : "while away, [chase] re-runs every layer each ten minutes" },
		{ key : "seventh",   name : "the seventh",    base : 5, step : 0, max : 1, what : "a seventh sink opens on every layer: siphon, mirror, crucible" },
		{ key : "keep",      name : "the keep",       base : 4, step : 2, max : 3, what : "the turn keeps 10% of every level a rank" },
		{ key : "tidewatch", name : "tidewatch",      base : 3, step : 2, max : 2, what : "the flood +x.5 a rank" },
		{ key : "veins",     name : "rich veins",     base : 4, step : 0, max : 1, what : "two veins a layer" },
		{ key : "burn",      name : "long burn",      base : 2, step : 1, max : 3, what : "a burn lasts +50% a rank" },
	];
	return _p;
}
