/// @description gear_tags() -> THE LAND'S TASTE, by place kind: { kind : { adjs, quirk, origin } }
/// An item found or sold somewhere is TAGGED with the place's kind
/// (gear_gen's tag): a flavour adjective off the kind's list, sometimes,
/// and a lean toward the kind's quirk (marsh things are oiled, crypt
/// things bright, mountain things warm, bandit things spiteful). origin
/// = the popup's first words (gear_desc).
function gear_tags() {
	static _t = {
		marsh      : { adjs : ["soggy", "bog-stained", "frog-approved", "reedy"],            quirk : "oiled",    origin : "out of the marsh" },
		desert     : { adjs : ["sun-bleached", "sandy", "dune-worn", "dusty"],               quirk : "cool",     origin : "out of the desert" },
		crypt      : { adjs : ["grave-cold", "coffin-fresh", "mournful", "dusty"],           quirk : "bright",   origin : "from a crypt" },
		dungeon    : { adjs : ["dungeon-damp", "chained (once)", "echoing"],                 quirk : "bright",   origin : "from a dungeon" },
		mine       : { adjs : ["sooty", "pit-scarred", "ore-flecked"],                       quirk : "bright",   origin : "from a mine" },
		mountains  : { adjs : ["frost-bitten", "high-country", "wind-scoured"],              quirk : "warm",     origin : "from the mountains" },
		tundra     : { adjs : ["frozen", "ice-rimed", "snow-packed"],                        quirk : "warm",     origin : "off the tundra" },
		forest     : { adjs : ["mossy", "twiggy", "bark-bound", "leafy"],                    quirk : "",         origin : "out of the forest" },
		field      : { adjs : ["hay-flecked", "farmhand's", "well-turned"],                  quirk : "",         origin : "off a field" },
		hills      : { adjs : ["well-walked", "hillfolk", "downhill"],                       quirk : "",         origin : "off the hills" },
		coast      : { adjs : ["salt-crusted", "barnacled", "tide-worn", "driftwood"],       quirk : "sturdy",   origin : "off the coast" },
		isle       : { adjs : ["island-made", "shell-studded", "castaway"],                  quirk : "",         origin : "off an island" },
		ruin       : { adjs : ["ancient-ish", "pre-owned (long ago)", "half-buried"],        quirk : "",         origin : "from a ruin" },
		shrine     : { adjs : ["blessed (a bit)", "candle-lit", "devout"],                   quirk : "eager",    origin : "from a shrine" },
		camp       : { adjs : ["bandit-issue", "stolen (probably)", "camp-smoked"],          quirk : "spiteful", origin : "off a bandit" },
		settlement : { adjs : ["homespun", "hand-me-down"],                                  quirk : "",         origin : "from a settlement" },
		village    : { adjs : ["village-made", "homespun", "market-day"],                    quirk : "",         origin : "from a village shop" },
		town       : { adjs : ["shop-bought", "town-made", "guild-stamped"],                 quirk : "",         origin : "from a town shop" },
		city       : { adjs : ["city-made", "fancy (relatively)", "imported"],               quirk : "keen",     origin : "from a city shop" },
	};
	return _t;
}
