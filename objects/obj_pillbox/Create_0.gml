/// one pill of a pillbox popup (pillbox 2.0, ported from Myriad DE).
/// spawned by do_pillbox(), one instance per option, sharing width and
/// stacking geometry. everything that changed from the old framework:
///  - pill state is one STRUCT (pill), shared by reference with the
///    owner's _pills array - owner edits relight the pill live
///  - closing routes through the owner's _popen, never the object
///    name, so two boxes can never cross-talk
///  - input is fully arbitrated: syst_input raises g.input_block to
///    ui_layer_popup while any pill lives (room ui behind goes quiet
///    with no guard chains), and the pills clear it via ui_layer. the
///    sprite is spr_pixel_1x1 scaled to the pill each step, purely so
///    the arbitration sweep has a real bbox (the Draw event overrides
///    any auto-draw)

depth    = -100;
ui_layer = ui_layer_popup;

obj  = noone;     // the owner: holds _pills/_psel*/_popen
pill = undefined; // this pill's struct from set_pill()
quiet = false;    // audition boxes pick silently - see do_pillbox
i     = 0;        // index in the stack, 0 = top (also polices outside-close)
all_h = 0;        // full stack height
des_w = 0;        // shared pill width
type  = 0;        // 0 = pick closes the box, 1 = stays open

mx_ = mouse_x;    // spawn anchor (set by do_pillbox)
my_ = mouse_y;
force_side = -1;  // -1 auto (screen third), 0 open RIGHT, 1 open LEFT
openleft = false; // resolved at placement, reused by anchor + slide
sticky = false;   // outside taps DON'T close this box (a pick must be
                  // made - the combat action menu uses it, otherwise
                  // the owner's reopen loop makes it flicker)

tic  = 0;         // stagger clock: pill i fades in at tic > i
ctic = 0;         // hold-to-select clock
xx   = 0;         // slide-in offset
des_x = 0;
x_ = 0; y_ = 0;   // settled anchor
w = 0; h = 11;
alpha = 0;
glow  = 0;
selected = false;
placed   = false;
left_lat = room_width / 3; // which side of the tap the stack opens on
