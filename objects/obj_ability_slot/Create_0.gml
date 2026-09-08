/// one row of the ability deck list, ported from Myriad DE. the
/// native mechanisms kept whole:
///  - chain-spawn: slot 0 spawns slot 1 spawns slot 2... until the
///    list is covered (see the creator block in Step)
///  - the cursor lens: a = a_ + round(g.ability_page), and grab_deck
///    materializes whatever ability sits at that index into this
///    instance (name/rarity/cost/desc/flavor)
///  - toggles write BACK through return_deck, the ability() mirror -
///    this row's `input` becomes the global g.ad_* again
///  - smooth scroll: yos carries the fractional page offset
/// input itself moved to the controller (arbitrated region checks);
/// it hands actions down via pending_toggle / pending_inspect

a_ = -1;        // my fixed row in the list (set by my spawner)
a  = -999;      // the deck index i'm looking at
previous_a = -999;
input = -1;
previous_input = -1;
input_changed = 0;

pending_toggle  = false;
pending_inspect = false;

// materialized card state (grab_deck fills these)
aid = -1;
name = "";
apreq = 0;
rarity = 0;
txt = "";
sub = false;
open = true;
_open = true;
tog = true;
flavor = 0;
f = 0;
repeat (5) { flavor_text[f] = ""; flavor_color[f] = c_white; f++; }

// presentation
yos = 0;
sos = 8;   // spawn slide-in
alpha = 0;
