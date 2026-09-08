/// @description tap_sound_config() - THE TAP SOUND ROSTER, declared as
/// data. Myriad DE's swappable "gen sound" list, ported whole.
///
/// >>> TO ADD A TAP SOUND: add ONE entry. The settings pill builds
/// >>> itself from this array and the save stores the INDEX.
///
/// DE keeps this as a chain of `if g.gen_sound = snd_a g.gen_sound =
/// snd_b` in one object's Step to advance it, a second chain in another
/// event to LABEL it, and a third in syst_production to give each sound
/// its pitch and volume - so adding one sound meant three edits in three
/// files, and forgetting the third made it play at the wrong volume
/// forever. One row here instead.
///
/// THE SAVE STORES AN INDEX, NOT A SOUND. DE writes the asset id into
/// its ini, and a GameMaker asset id is a build-order artifact: add a
/// sound anywhere earlier in the tree and every saved preference
/// silently becomes a different sound. Appending to this array is safe;
/// reordering it is the thing not to do.
///
/// FIELDS: name (the pill's label), snd, pmn/pmx (the pitch range a tap
/// rolls in - DE varies pitch per tap so a fast tapper does not hear one
/// sample looping), vol.
function tap_sound_config() {
	if (variable_global_exists("tap_snd_cfg")) return g.tap_snd_cfg;
	// DE's per-sound pitch and volume, from syst_production's Step_2
	// where these same assets are calibrated against each other.
	g.tap_snd_cfg = [
		{ name : "click",     snd : snd_click,    pmn : .95, pmx : 1.15, vol : .35 },
		{ name : "gold",      snd : snd_gold,     pmn : .8,  pmx : 1.5,  vol : .5  },
		{ name : "gold two",  snd : snd_gold2,    pmn : .8,  pmx : 1.5,  vol : .5  },
		{ name : "tap heavy", snd : snd_tapheavy, pmn : .8,  pmx : 1.5,  vol : .5  },
		{ name : "tap light", snd : snd_tap2,     pmn : 1,   pmx : 1.2,  vol : 1   },
		{ name : "pop",       snd : snd_popclick, pmn : .8,  pmx : 1.5,  vol : .3  },
		{ name : "atlas",     snd : snd_atlas,    pmn : .8,  pmx : 1.5,  vol : .2  },
		{ name : "drum",      snd : snd_drum,     pmn : .8,  pmx : 1.5,  vol : .5  },
		{ name : "cartian",   snd : snd_afripop2, pmn : .8,  pmx : 1.5,  vol : .5  },
		{ name : "coin toss", snd : snd_cointoss, pmn : .8,  pmx : 1.5,  vol : .5  },
	];
	return g.tap_snd_cfg;
}
