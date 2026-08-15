/// one floating text. spawn through float_text(), which sets text and
/// the gradient colors; everything here is the motion recipe

text  = "";
c_top = c_white;   // gradient, set by float_text()
c_bot = c_white;
fnt_use = -1;      // optional font override (float_text's 5th arg)
sw    = 0;         // string dims, set by float_text()
sh2   = 0;

rise  = random_range(-1, -.5);  // upward px per step, decays with age
tilt  = random_range(-5, 5);    // fixed jaunty angle per float

alpha   = 0;    // fades in fast, out slower
life    = 30;   // steps at full presence before the fade-out
life_   = life;
scale   = 0;    // pops 0 -> 1 fast, shrinks to .5 while dying
scale_  = 1;
pop     = 2;    // steps of extra-fast pop at birth
drift_y = 0;    // accumulated rise
