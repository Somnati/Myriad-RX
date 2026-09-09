/// obj_cursor - the mouse pointer, drawn by us (his sprite, 2026-09-08).
///
/// ⚖️ DRAWN, NOT SET. GameMaker has cursor_sprite built in and it is one
/// line, but it renders inside the room's own pipeline - which means the
/// glow, the vignette and the menu blur all get a go at it. A pointer
/// that softens because a panel opened underneath it is a pointer that
/// looks broken. So this is an instance at a depth nothing else reaches,
/// above every FX layer, and the OS cursor is simply turned off.
///
/// IT FOLLOWS mousex/mousey, NOT mouse_x/mouse_y. Those macros are the
/// touchscreen-aware pair the whole UI hit-tests against, so the arrow
/// is drawn exactly where a click will land rather than approximately
/// where the OS thinks the pointer is. If those two ever disagree, this
/// is where you would SEE it, which is worth something on its own.

depth = -20000;   // above the header (-1000), the overlays (-510) and
                  // every FX layer. Nothing in the game draws here.
persistent = true;

// no OS pointer under ours
window_set_cursor(cr_none);
