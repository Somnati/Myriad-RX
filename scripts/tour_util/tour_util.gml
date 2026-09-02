/// tour_util - THE SMALL TOOLS  (engine/util)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== MOTION ==================================
//   trickle(val, target, adj)   your DE exponential chase (divide the
//                    gap by adj each step, delta-aware). Never quite
//                    arrives - callers snap the last bit.
//   move_to(val, target, adj)   the same shape for cases that want it
//                    (the header glide uses it in log space).
//   clamp_min(v, m), in_range(v, a, b)   guards.

// ========================== COLOURS =================================
//   rgb(r,g,b)       the macro-backed colour maker (main_macros'
//                    c_* palette is built from it).
//   c_hsv(h,s,v), c_hue(c), c_sat(c), c_val(c)   make and read HSV.
//   color_set_random / color_set_comp / color_to_hex   profile colours
//                    and their complements.

// ========================== TIME + TEXT =============================
//   crunch_time(steps)        "1m 23s" style, short.
//   crunch_time_long(steps)   the long form for statistics.
//   roll_perc(p)              a p% chance.
//   line(name, desc)          a DE list-row builder that rode along
//                             with the port. NOTHING CALLS IT - a
//                             delete candidate.

// ========================== AUDIO ===================================
//   play_sound_ext(snd, pitch_min, pitch_max, vol, vib)   the ONE way
//                    to play a sound: random pitch in the range,
//                    volume through g.vol_sfx and g.mute, an optional
//                    haptic tick with it.
//   vibrate(...)     haptics through the extension, gated by
//                    g.haptics.

// ========================== INSTANCES ===============================
//   create_obj(x, y, obj)     instance_create at the caller's depth.
//   is_object(obj)            exists-and-is-an-object guard.
//   toggle(b)                 !b, for readability in Step chains.
//   show(txt)                 show_debug_message with a prefix.
//   os_paused()               the app-paused check the delta chain
//                             uses so a backgrounded app doesn't
//                             produce a huge frame.
