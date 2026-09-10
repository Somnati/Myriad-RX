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

// THE RAYCAST (his ask, 2026-09-10): sh_cursor lights the arrow as an
// extruded solid the way the dice and the puck are lit, silhouette
// still the sprite's texel for texel - read the shader's header. The
// uniforms are looked up once; the sprite's page rect and trim are
// what let the fragment turn a texcoord back into a sprite pixel.
u_uv    = shader_get_uniform(sh_cursor, "u_uv");
u_trim  = shader_get_uniform(sh_cursor, "u_trim");
u_light = shader_get_uniform(sh_cursor, "u_light");
u_on    = shader_get_uniform(sh_cursor, "u_on");

// THE SQUISH (his ask, 2026-09-10: "a cute lil squish effect" on a
// click): a press kicks a spring that squashes the arrow wide and
// short, and it wobbles back to shape. sq is the squash amount, sqv
// its velocity - the puck's spring, in miniature.
sq  = 0;
sqv = 0;
// the arrow's own axis, tip to tail, in screen degrees (y down): the
// sprite points up-left, so its length runs down and to the right.
// Measured off the pixels - the body's centroid sits ~50 degrees
// below the tip's row.
axis = 50;
