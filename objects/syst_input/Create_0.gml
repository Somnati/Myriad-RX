/// global input arbitration. two per-frame globals, computed in the
/// BEGIN step so they're settled before any object's step reads them:
///
///   g.input_block  what layer a clickable needs to accept input.
///                  0 = anything goes. raised by blockers (menu open,
///                  dialogue up), all listed in input_free().
///   g.click_owner  the ONE instance allowed to react to the pointer
///                  this frame: topmost eligible clickable under the
///                  cursor. mouse_over() just compares against this,
///                  so overlapping buttons can't double-fire.
///
/// region ui that isn't an instance (save menu rows, the star map,
/// obj_click) follows the same two rules by hand:
///   if input_free() if g.click_owner == noone { ...take the click }

g.input_block = 0;
g.click_owner = noone;

// the controller framework rides input's coattails: pad_init lazy-
// spawns persistent syst_gamepad, so pads work from boot everywhere
pad_init();
