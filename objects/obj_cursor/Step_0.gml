// the squish spring: a press kicks it, the spring pulls it home with a
// wobble (see the Create)
if (mouse_check_button_pressed(mb_left)) sqv += .55;
sqv += (0 - sq) * .28 * delta;
sqv *= power(.78, delta);
sq  += sqv * delta;
