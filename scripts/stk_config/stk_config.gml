/// @description stk_config() -> THE STACK's roster (q316): three layers, six sinks each - declarative, APPEND ONLY (the index is the save format and the wiring)
/// A sink: { key, name, col, per (bonus % a level^0.75), kind, what, [thk] }. thk = the sink's threshold factor (the wells are DEEP: x6 the ladder).
/// kind says what the bonus DOES (stk_mult reads it):
///   "spark"  - multiplies spark made        "speed_en" / "speed_ae" / "speed_qu" / "speed_all" - multiplies a layer's progress
///   "thr_en" / "thr_ae" / "thr_qu" - DIVIDES a layer's thresholds (reduction)     "capcost" - divides energy's cap price
///   "gen"    - MAKES spark: per x level^0.75 a second      "cap_ae" / "cap_qu" - IS the next layer's cap: floor(per/100 x level^STK_CAP_POW)
///   "cap_en_flat" / "cap_ae_flat" - ADD the same law's number to that layer's cap      "per_all" - multiplies every other sink's per
function stk_config() {
	static _c = [
		[   // ENERGY
			{ key : "generator", name : "generator",   col : c_sgreen,    per : 100, kind : "gen",         what : "spark a second" },
			{ key : "dynamo",    name : "dynamo",      col : c_seagreen,  per : 4,   kind : "speed_en",    what : "energy speed" },
			{ key : "condenser", name : "condenser",   col : c_aqua,      per : 3,   kind : "thr_en",      what : "energy thresholds" },
			{ key : "well",      name : "the well",    col : c_hpurple,   per : 12,  kind : "cap_ae",      what : "aether cap", thk : 8 },
			{ key : "lens",      name : "lens",        col : c_gold,      per : 6,   kind : "spark",       what : "spark" },
			{ key : "ballast",   name : "ballast",     col : c_steelblue, per : 4,   kind : "capcost",     what : "cap price" },
		],
		[   // AETHER
			{ key : "resonator", name : "resonator",   col : c_sgreen,    per : 8,   kind : "speed_en",    what : "energy speed" },
			{ key : "amplifier", name : "amplifier",   col : c_gold,      per : 10,  kind : "spark",       what : "spark" },
			{ key : "deepwell",  name : "the deep well", col : c_hred,    per : 20,  kind : "cap_qu",      what : "quintessence cap", thk : 4 },
			{ key : "prism",     name : "prism",       col : c_hpurple,   per : 5,   kind : "speed_ae",    what : "aether speed" },
			{ key : "hollow",    name : "the hollow",  col : c_seagreen,  per : 30,  kind : "cap_en_flat", what : "energy cap", thk : 3 },
			{ key : "echo",      name : "echo",        col : c_aqua,      per : 3,   kind : "thr_ae",      what : "aether thresholds" },
		],
		[   // QUINTESSENCE
			{ key : "keystone",  name : "keystone",    col : c_gold,      per : 2,   kind : "per_all",     what : "every bonus" },
			{ key : "tempo",     name : "tempo",       col : c_sgreen,    per : 6,   kind : "speed_all",   what : "every speed" },
			{ key : "loop",      name : "the loop",    col : c_seagreen,  per : 50,  kind : "cap_en_flat", what : "energy cap", thk : 3 },
			{ key : "crown",     name : "crown",       col : c_gold,      per : 12,  kind : "spark",       what : "spark" },
			{ key : "still",     name : "still",       col : c_aqua,      per : 3,   kind : "thr_qu",      what : "quintessence thresholds" },
			{ key : "ember",     name : "ember",       col : c_hred,      per : 30,  kind : "cap_ae_flat", what : "aether cap", thk : 3 },
		],
	];
	return _c;
}
