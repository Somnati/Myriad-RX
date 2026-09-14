/// @description sfx_config(kind) - THE SOUND ROSTERS, declared as data.
/// Myriad DE's swappable "gen sound" list, generalised: DE had one
/// swappable sound and RX now has four (tap, dial cycle, critical,
/// credit drop), and four near-identical scripts would have been four
/// places to forget.
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
///
/// ⚖️ THE VOLS ARE MEASURED, NOT GUESSED (2026-09-14, his report: "some are
/// louder/quieter than others"). Every roster-only sample was rewritten
/// to one loudness (-16 dBFS max 50 ms RMS; scratchpad/build_sfx_norm.py),
/// snd_softclick got a normalised copy for the rosters (snd_softclick_n -
/// the UI's own click stays), and each roster's vols are ONE number = the
/// level he played at before, with the unrewritten rows (matte, pop)
/// carrying their own correction. Re-run the script after adding a sound.
function sfx_config(_kind) {
	if (!variable_global_exists("sfx_cfg")) {
		g.sfx_cfg = {
			// ⚖️ ONE UNION OF SOUNDS, FOUR ROSTERS (his ask, 2026-09-08:
			// "any sound effects that are in the dials section that arent
			// in the tapper/crits i need those put in those... any sounds
			// that arent in the dials need put in there"). Every sound is
			// offered for every job, with two deliberate exceptions:
			//   - pop and coin toss stay OUT OF THE TAP list. He pulled
			//     them from the tapper and said they stay pulled; they
			//     are still offered everywhere else.
			//   - "none" sits LAST in the tap list rather than first. A
			//     tap with no sound reads as a broken button, so it is an
			//     option rather than a default (his ask: every kind gets
			//     one). Its ID is still "off" - that string is the save
			//     key, and renaming it would repoint every save that had
			//     already chosen silence.
			//
			// The rosters are written out rather than sharing one array
			// because THE LEVELS ARE THE POINT: the same sample wants
			// .18 on a dial cycle, .5 on a tap and .9 on a critical.
			// A shared list would have to carry one volume and be wrong
			// three times, and each roster's order puts its own default
			// first. Ids are stable ACROSS rosters, so "gold" is the same
			// sound wherever it appears.
			tap : [
				{ id : "click1", name : "click",      snd : snd_tap_click1, pmn : .95, pmx : 1.1,  vol : 0.381  },
				{ id : "click2", name : "click two",  snd : snd_tap_click2, pmn : .95, pmx : 1.1,  vol : 0.508  },
				{ id : "click3", name : "click three", snd : snd_tap_click3, pmn : .95, pmx : 1.1,  vol : 0.507  },
				{ id : "heavy",  name : "tap heavy",  snd : snd_tapheavy,   pmn : .8,  pmx : 1.5,  vol : 0.56  },
				{ id : "light",  name : "tap light",  snd : snd_tap2,       pmn : 1,   pmx : 1.2,  vol : 0.296 },
				{ id : "soft",   name : "soft click", snd : snd_softclick_n,  pmn : .9,  pmx : 1.2,  vol : 0.543 },
				{ id : "mat",    name : "matte",      snd : snd_matclick,   pmn : .9,  pmx : 1.2,  vol : 0.091 },
				{ id : "gold",   name : "gold",       snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : 0.296  },
				{ id : "gold2",  name : "gold two",   snd : snd_gold2,      pmn : .8,  pmx : 1.5,  vol : 0.296  },
				{ id : "orb",    name : "orb",        snd : snd_orb,        pmn : .95, pmx : 1.05, vol : 0.296  },
				{ id : "diamond", name : "diamond",    snd : snd_diamond,    pmn : .95, pmx : 1.1,  vol : 0.296 },
				{ id : "tier",   name : "tier up",    snd : snd_tierup,     pmn : .95, pmx : 1.1,  vol : 0.296 },
				{ id : "atlas",  name : "atlas",      snd : snd_atlas,      pmn : .8,  pmx : 1.5,  vol : 0.296  },
				{ id : "drum",   name : "drum",       snd : snd_drum,       pmn : .8,  pmx : 1.5,  vol : 0.296  },
				{ id : "off",    name : "none",      snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
			],

			// NONE IS FIRST AND IS THE DEFAULT here, which is a judgement
			// about FREQUENCY rather than taste: a late fleet finishes
			// several cycles a second across every dial, and a sound on
			// each stops being feedback inside a minute. syst_dials rate
			// limits whatever is chosen. Levels sit well under the tap's
			// on purpose - this is not something you are doing, it is
			// something happening.
			dial : [
				{ id : "off",    name : "none",       snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
				{ id : "soft",   name : "soft click", snd : snd_softclick_n,  pmn : .9,  pmx : 1.2,  vol : 0.039 },
				{ id : "mat",    name : "matte",      snd : snd_matclick,   pmn : .9,  pmx : 1.2,  vol : 0.007 },
				{ id : "click1", name : "click",      snd : snd_tap_click1, pmn : .95, pmx : 1.1,  vol : 0.027 },
				{ id : "click2", name : "click two",  snd : snd_tap_click2, pmn : .95, pmx : 1.1,  vol : 0.036 },
				{ id : "click3", name : "click three", snd : snd_tap_click3, pmn : .95, pmx : 1.1,  vol : 0.036 },
				{ id : "pop",    name : "pop",        snd : snd_popclick,   pmn : .8,  pmx : 1.5,  vol : 0.016 },
				{ id : "coin",   name : "coin toss",  snd : snd_cointoss,   pmn : .9,  pmx : 1.3,  vol : 0.082 },
				{ id : "gold",   name : "gold",       snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : 0.021 },
				{ id : "gold2",  name : "gold two",   snd : snd_gold2,      pmn : .8,  pmx : 1.5,  vol : 0.021 },
				{ id : "heavy",  name : "tap heavy",  snd : snd_tapheavy,   pmn : .8,  pmx : 1.5,  vol : 0.04 },
				{ id : "light",  name : "tap light",  snd : snd_tap2,       pmn : 1,   pmx : 1.2,  vol : 0.021  },
				{ id : "orb",    name : "orb",        snd : snd_orb,        pmn : .95, pmx : 1.05, vol : 0.021 },
				{ id : "diamond", name : "diamond",    snd : snd_diamond,    pmn : .95, pmx : 1.1,  vol : 0.021 },
				{ id : "tier",   name : "tier up",    snd : snd_tierup,     pmn : .95, pmx : 1.1,  vol : 0.021 },
				{ id : "atlas",  name : "atlas",      snd : snd_atlas,      pmn : .8,  pmx : 1.5,  vol : 0.021 },
				{ id : "drum",   name : "drum",       snd : snd_drum,       pmn : .8,  pmx : 1.5,  vol : 0.021 },
			],

			// snd_orb is where this started: tap_fire played it hard
			// coded, and a crit is exactly the moment that wants a sound
			// of its own. It stays the default.
			crit : [
				{ id : "orb",    name : "orb",        snd : snd_orb,        pmn : .95, pmx : 1.05, vol : 0.228  },
				{ id : "diamond", name : "diamond",    snd : snd_diamond,    pmn : .95, pmx : 1.1,  vol : 0.228  },
				{ id : "tier",   name : "tier up",    snd : snd_tierup,     pmn : .95, pmx : 1.1,  vol : 0.228 },
				{ id : "gold2",  name : "gold two",   snd : snd_gold2,      pmn : .8,  pmx : 1.5,  vol : 0.228 },
				{ id : "gold",   name : "gold",       snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : 0.228  },
				{ id : "coin",   name : "coin toss",  snd : snd_cointoss,   pmn : .9,  pmx : 1.3,  vol : 0.881  },
				{ id : "click1", name : "click",      snd : snd_tap_click1, pmn : .95, pmx : 1.1,  vol : 0.293  },
				{ id : "click2", name : "click two",  snd : snd_tap_click2, pmn : .95, pmx : 1.1,  vol : 0.392  },
				{ id : "click3", name : "click three", snd : snd_tap_click3, pmn : .95, pmx : 1.1,  vol : 0.391  },
				{ id : "heavy",  name : "tap heavy",  snd : snd_tapheavy,   pmn : .8,  pmx : 1.5,  vol : 0.431  },
				{ id : "light",  name : "tap light",  snd : snd_tap2,       pmn : 1,   pmx : 1.2,  vol : 0.228  },
				{ id : "soft",   name : "soft click", snd : snd_softclick_n,  pmn : .9,  pmx : 1.2,  vol : 0.419 },
				{ id : "mat",    name : "matte",      snd : snd_matclick,   pmn : .9,  pmx : 1.2,  vol : 0.07 },
				{ id : "pop",    name : "pop",        snd : snd_popclick,   pmn : .8,  pmx : 1.5,  vol : 0.173 },
				{ id : "atlas",  name : "atlas",      snd : snd_atlas,      pmn : .8,  pmx : 1.5,  vol : 0.228  },
				{ id : "drum",   name : "drum",       snd : snd_drum,       pmn : .8,  pmx : 1.5,  vol : 0.228  },
				{ id : "off",    name : "none",       snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
			],

			// THE CREDIT DROP (his ask). credit_drop played snd_diamond
			// hard coded, the same way the crit played snd_orb, so that
			// is row 0 here. It rides the TAP fader: a credit drop is
			// something your tap did, not something the fleet did.
			credit : [
				{ id : "diamond", name : "diamond",    snd : snd_diamond,    pmn : .95, pmx : 1.1,  vol : 0.212  },
				{ id : "coin",   name : "coin toss",  snd : snd_cointoss,   pmn : .9,  pmx : 1.3,  vol : 0.819  },
				{ id : "tier",   name : "tier up",    snd : snd_tierup,     pmn : .95, pmx : 1.1,  vol : 0.212 },
				{ id : "orb",    name : "orb",        snd : snd_orb,        pmn : .95, pmx : 1.05, vol : 0.212  },
				{ id : "gold",   name : "gold",       snd : snd_gold,       pmn : .8,  pmx : 1.5,  vol : 0.212  },
				{ id : "gold2",  name : "gold two",   snd : snd_gold2,      pmn : .8,  pmx : 1.5,  vol : 0.212  },
				{ id : "click1", name : "click",      snd : snd_tap_click1, pmn : .95, pmx : 1.1,  vol : 0.273  },
				{ id : "click2", name : "click two",  snd : snd_tap_click2, pmn : .95, pmx : 1.1,  vol : 0.364  },
				{ id : "click3", name : "click three", snd : snd_tap_click3, pmn : .95, pmx : 1.1,  vol : 0.363  },
				{ id : "soft",   name : "soft click", snd : snd_softclick_n,  pmn : .9,  pmx : 1.2,  vol : 0.389 },
				{ id : "mat",    name : "matte",      snd : snd_matclick,   pmn : .9,  pmx : 1.2,  vol : 0.065 },
				{ id : "pop",    name : "pop",        snd : snd_popclick,   pmn : .8,  pmx : 1.5,  vol : 0.16 },
				{ id : "heavy",  name : "tap heavy",  snd : snd_tapheavy,   pmn : .8,  pmx : 1.5,  vol : 0.401 },
				{ id : "light",  name : "tap light",  snd : snd_tap2,       pmn : 1,   pmx : 1.2,  vol : 0.212  },
				{ id : "atlas",  name : "atlas",      snd : snd_atlas,      pmn : .8,  pmx : 1.5,  vol : 0.212 },
				{ id : "drum",   name : "drum",       snd : snd_drum,       pmn : .8,  pmx : 1.5,  vol : 0.212  },
				{ id : "off",    name : "none",       snd : -1,             pmn : 1,   pmx : 1,    vol : 0   },
			],
		};
	}
	if (!variable_struct_exists(g.sfx_cfg, _kind)) return [];
	return g.sfx_cfg[$ _kind];
}
