/// DE's blackout, ported (2026-09-09). As the hold passes 40% the whole
/// screen sinks to black under your finger, so the last half of the
/// press is the run visibly ending rather than a bar filling.
///
/// ⚖️ DRAW END, and it has to be. This is the one thing on the screen
/// that must cover EVERYTHING - the rebirth overlay, the header, the
/// menu drawer if it is somehow up, the cursor. Depth cannot do that
/// from inside the object (the header sits at -1000 and the cursor at
/// -20000); the event pass can. It is also why nothing else here uses
/// Draw End: the same power paints over the open menu, which is exactly
/// the bug that put the statistics screen's rows back in Draw_0.
///
/// DE gates on the cooldown having expired, and so does this: a bar
/// that is counting a clock down rather than taking a press must not
/// darken the room, or every visit to the screen looks like a rebirth
/// starting.
if (!visible) exit;
if (alpha <= 0) exit;
if (calc.cool > 0) exit;
if (hp <= 40) exit;

// 40..100 of the hold maps to 0..1 of black. The first 40 is free, so a
// press you change your mind about leaves no mark.
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0,
	c_black, clamp((hp - 40) / 60, 0, 1));
