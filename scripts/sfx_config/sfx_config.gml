/// @description sfx_config(kind) - THE SOUND ROSTERS, declared as data.
/// Myriad DE's swappable "gen sound" list, generalised: DE had one
/// swappable sound and RX now has three (tap, dial cycle, critical), and
/// three near-identical scripts would have been three places to forget.
///
/// >>> TO ADD A SOUND: add ONE row to the right roster. The settings
/// >>> pill builds itself from the array and the save stores the ID.
///
/// DE keeps this as a chain of `if g.gen_sound = snd_a g.gen_sound =
/// snd_b` in one object's Step to advance it, a second chain elsewhere
/// to LABEL it, and a third in syst_production to give each sound its
/// pitch and volume - so adding one sound meant three edits in three
/// files, and forgetting the third made it play at the wrong volume
/// forever. One row here instead.
///
/// THE SAVE STORES THE ID, NOT AN INDEX (changed 2026-09-08, the first
/// time he edited the roster). It used to store the position, so
/// deleting "pop" from the middle silently repointed every saved
/// preference at its neighbour, and there was a standing rule that the
/// list could only ever be appended to. A string id costs nothing, makes
/// the order free to change, and an id that no longer exists simply
/// falls back to the first row. The rule is gone with it.
///
/// FIELDS: id (the save key - NEVER reuse one for a different sound),
/// name (the pill's label), snd (-1 = deliberately silent), pmn/pmx (the
/// pitch range a play rolls in - varying pitch is why a fast tapper
/// hears a sound rather than a buzz), vol.
function sfx_config(_kind) {
	if (!variable_global_exists("sfx_cfg")) {
		g.sfx_cfg = {
			// ---- THE TAP ----
			// His edits, 2026-09-08: pop, cartian and coin toss dropped;
			// tap heavy and tap light both louder. The gains above 1 are
			// deliberate - audio_sound_gain amplifies, those two samples
			// are quiet at source, and the tap volume fader is the trim
			// if a device dislikes it.
			tap : [
				{ id : "click1",  name : "click",       snd : snd_tap_click1, pmn : .95, pmx : 1.1,  vol : .5  },
				{ id : "click2",  name : "click two",   snd : snd_tap_click2, pmn : .95, pmx : 1.1,  vol : .5  },
				{ id : "click3",  name : "click three", snd : snd_tap_click3, pmn : .95, pmx : 1.1,  vol : .5  },
				{ id : "gold",    name : "gold",        snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : .5  },
				{ id : "gold2",   name : "gold two",    snd : snd_gold2,      pmn : .8,  pmx : 1.5,  vol : .5  },
				{ id : "heavy",   name : "tap heavy",   snd : snd_tapheavy,   pmn : .8,  pmx : 1.5,  vol : .9  },
				{ id : "light",   name : "tap light",   snd : snd_tap2,       pmn : 1,   pmx : 1.2,  vol : 1.5 },
				{ id : "atlas",   name : "atlas",       snd : snd_atlas,      pmn : .8,  pmx : 1.5,  vol : .2  },
				{ id : "drum",    name : "drum",        snd : snd_drum,       pmn : .8,  pmx : 1.5,  vol : .5  },
			],

			// ---- THE DIAL CYCLE ----
			// OFF IS FIRST AND IS THE DEFAULT, which is a judgement about
			// FREQUENCY rather than taste: a late fleet completes several
			// cycles a second across six dials, and a sound firing on
			// every one of them stops being feedback within a minute.
			// syst_dials rate-limits whatever is chosen, and opting in is
			// the honest default for a noise you cannot outrun. The levels
			// sit well under the tap's on purpose - this is not something
			// you are doing, it is something happening.
			dial : [
				{ id : "off",     name : "off",         snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
				{ id : "soft",    name : "soft click",  snd : snd_softclick,  pmn : .9,  pmx : 1.2,  vol : .18 },
				{ id : "mat",     name : "matte",       snd : snd_matclick,   pmn : .9,  pmx : 1.2,  vol : .18 },
				{ id : "pop",     name : "pop",         snd : snd_popclick,   pmn : .8,  pmx : 1.5,  vol : .16 },
				{ id : "coin",    name : "coin",        snd : snd_cointoss,   pmn : .9,  pmx : 1.3,  vol : .16 },
				{ id : "gold",    name : "gold",        snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : .14 },
				{ id : "click",   name : "click",       snd : snd_tap_click1, pmn : .9,  pmx : 1.2,  vol : .18 },
			],

			// ---- THE CRITICAL TAP ----
			// snd_orb is where this started: tap_fire played it hard
			// coded, and a crit is exactly the moment that wants a sound
			// of its own. It stays the default.
			crit : [
				{ id : "orb",     name : "orb",         snd : snd_orb,        pmn : .95, pmx : 1.05, vol : .5  },
				{ id : "diamond", name : "diamond",     snd : snd_diamond,    pmn : .95, pmx : 1.1,  vol : .5  },
				{ id : "coin",    name : "coin",        snd : snd_cointoss,   pmn : .9,  pmx : 1.2,  vol : .5  },
				{ id : "gold",    name : "gold",        snd : snd_gold2,      pmn : .9,  pmx : 1.2,  vol : .55 },
				{ id : "tier",    name : "tier up",     snd : snd_tierup,     pmn : .95, pmx : 1.1,  vol : .45 },
				{ id : "off",     name : "off",         snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
			],
		};
	}
	if (!variable_struct_exists(g.sfx_cfg, _kind)) return [];
	return g.sfx_cfg[$ _kind];
}
