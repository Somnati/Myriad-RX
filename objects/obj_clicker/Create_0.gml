/// obj_clicker - THE TAP (Myriad DE's obj_clicker + click_v2 +
/// give_click, rebuilt). Owns nothing but the tap surface: what a tap
/// is WORTH is update_click's business, and where the profit goes is
/// give_profit's. This object only decides that a tap happened.
/// DE reads five simultaneous touch devices here; RX starts with the
/// single pointer and grows into that when a device needs it.

depth = 0; // input only - this object draws nothing, but keep it
           // above the room's Background layer (100) on principle

// the live tap surface: everything under the header. The dial drawer
// carves its own face out of it every frame (see Step), so the two
// never fight for the same press - region law.
tap_y0 = 16;
tap_y1 = room_height;

pop = 0;  // a little press feedback the room can read
