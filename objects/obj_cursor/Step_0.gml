// the squish spring, and who kicks it (his three asks, 2026-09-10):
//   a PRESS kicks once, anywhere - the title screen, the menu, a
//   settings row - a click is a click and the arrow answers it;
//   a HELD tap's repeats kick only where they PERFORM (cursor_kick from
//   tap_fire's sound branch: the money room, never under an overlay),
//   so a hold in another room does not bounce the arrow for nothing.
// The press's own first tap is NOT kicked twice: tap_fire kicks held
// taps only.
if (mouse_check_button_pressed(mb_left)) sqv += .3;
sqv += (0 - sq) * .28 * delta;
sqv *= power(.78, delta);
sq  += sqv * delta;
