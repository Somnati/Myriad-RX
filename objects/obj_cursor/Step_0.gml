// the squish spring: a TAP kicks it (cursor_kick, from tap_fire's sound
// branch - his ask, 2026-09-10: only when the tap sound plays, never
// under an overlay), the spring pulls it home with a wobble (see the
// Create). A bare press no longer kicks: the squish is the tap's
// feedback, not the button's.
sqv += (0 - sq) * .28 * delta;
sqv *= power(.78, delta);
sq  += sqv * delta;
