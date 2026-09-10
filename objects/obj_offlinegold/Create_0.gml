/// obj_offlinegold - THE OFFLINE PILE (Myriad DE's obj_offlinegold,
/// ported 2026-09-10, his ask: "all offline gold goes into that pool
/// until i click it"). Everything an absence earned sits in
/// g.offline_pool rather than landing in the pile, and this small
/// button slides in from the money room's left edge to say so. Tap it
/// and the pool pays out: give_profit, a mote burst carrying the amount
/// into the header counter (so the number climbs as they land), the
/// banner. Untouched, it waits - across rooms, across a quit, across
/// however long you leave it, because the pool is saved with profit.
///
/// DE's shape, kept: x slides between off-screen (-20) and its seat (3)
/// through trickle; y 85, under the per-tap block and the credits
/// panel; it retreats while anything covers the room (an overlay, the
/// rebirth, the menu, the dial drawer); it draws as three tinted layers
/// of spr_popbutton_offlinegold - a dark base, a bright shine, the
/// white icon - in the profit colour rather than DE's picked palette.
/// ADDED: the amount beside it. DE said what you got only after you
/// tapped; a pile you can see the size of is a pile you tap on purpose.
///
/// A syst_input FAMILY MEMBER (its sprite is its mask), so a press on
/// it sets g.click_owner and the tap surface under it never sees the
/// press - the puck's arrangement.
///
/// SPAWNED BY syst_offline whenever the money room lacks one - a
/// runtime instance rather than two room placements, so both shapes
/// of the room get it and neither can be forgotten ("code ports once,
/// instances port twice").

depth = -300;   // over the visualiser and the banner, under the drawers (-320) and the header

x1 = -20;       // parked, off the left edge
x2 = 3;         // seated
x  = x1;
y  = 85;
desx = x1;

// the pulse on the shine, so the button reads as lit
pt = random(360);

// a short flash after a collect, so the button leaves with a flourish
flash = 0;
