/// syst_nudge - THE NUDGES (the tutorial that is not a script; his
/// spec 2026-09-13, after DE's timed monologue). Persistent, spawned by
/// syst_handle_save's Create. Every frame it asks nudge_config for the
/// first row whose state is live and whose job is not done, and draws
/// it: a breathing ring around the thing to touch (the region law:
/// every button already knows its rectangle) and one line beside it -
/// or, with no rectangle, at the foot of the room. Nothing blocks:
/// the room keeps working under it. A panel's first visit gets its
/// one sentence the same way (unfold_first_line), until it has been
/// closed once. The burger's ring says what just arrived
/// (g.unf.fresh) until the menu is opened.
///
/// Depth -1100: over the header (-1000) and every overlay (-510), so a
/// ring can sit on a button inside a panel; under the veil (-1500).
/// Hidden while the menu drawer is out.

if (instance_number(syst_nudge) > 1) { kill; exit; }
depth = -1100;
cur   = "";     // the live nudge's key
a     = 0;      // its fade, eased
t     = 0;      // seconds shown
txt   = "";
r     = undefined;
line_a = 0;     // the first-open line's fade
line_txt = "";
