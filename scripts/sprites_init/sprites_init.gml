/// @description sprites_init([force]);
/// @param [force]
/// SPRITES (his idea, 2026-09-11): little blob-with-eyes helpers that
/// live in the room they help. Free - no RAM, off the battery - passive
/// and stacking: each one contributes to one automation's output. The
/// first job is the autotapper (obj_blob taps through tap_fire, its
/// taps NOT counted as yours). Slow, lazy (a work / idle / wander /
/// nap loop), and unsupervised offline: their work decays with time
/// away (sprites_offline) and after a long absence they are found
/// asleep.
///
///   g.sprites[i]  { id, name, col, pers, job, taps, fx, fy, away, asleep, acc }
///     name/col/pers  rolled at birth (sprite_spawn)
///     job            "tap" for now
///     taps           lifetime taps it has made (its own counter - never
///                    g.total_taps, his call)
///     fx/fy          where it stands, as fractions of the room
///     away           taps it made during the last absence (the card)
///     asleep         found asleep on return (a poke wakes it)
///     acc            the headless tap accumulator (sprites_tick)
///
/// Save section "sprites". Meta: a rebirth keeps them, a new game does
/// not. HOW THEY ARE EARNED IS NOT DECIDED - settings > data has a debug
/// spawn for now.
function sprites_init(_force = false) {
	if (variable_global_exists("sprites") && !_force) return;
	g.sprites = [];
	g.sprite_seq = 0;
}
