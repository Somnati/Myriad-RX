/// generic BINDABLE single-choice pip (par_toggle_single's lit dot).
/// syst_settings pools one per option row and assigns bind_on /
/// bind_pick; the pip re-reads bind_on every step, so exactly one
/// option in a group lights and it's always the true current choice.

input = 0;

hue = color_get_hue(c_gold);
sat = 200;
lum = 220;

pair

bind_on   = undefined; // fn -> bool : is THIS option the current pick
bind_pick = undefined; // fn         : make it the pick
__fresh   = true;
