/// @description framework

sh = sprite_height;

stic = tsec*5;

mx = 0; mn = 0;

bar_y = 0;
bar_height = 0;
bar_height_ = 0;
slot_height = 0;

selected = false;

output = 0;

balpha = 0;

enabled = true;
// ⚖️ THE RELEASE LATCH (his report: "when i hold on it and drag it down
// when i release it snaps back to the top"). The touch path arms from a
// screen-wide bounds check and reads touch_y, which is start-minus-
// current for the WHOLE gesture. `selected` kept it out while the bar
// was grabbed - but `selected` clears on the release frame, and the
// touch block then armed with the entire drag still in touch_y and slammed
// ty to the far end. The comment at that block already described this
// failure for a different lane; the guard was just one frame short.
// This latch holds from the first grabbed frame until the pointer is
// genuinely up.
was_sel = false;

// some owners do their own list dragging (the menu drawer does). Two
// drag paths writing one scroll value is double speed at best and a
// fight at worst, so an owner can keep the GRAB and refuse the rest.
touch_scroll = true;

// the bar's colour. Owners that have a meaningful hue - the menu tints
// it to whatever room you are in - set this; the rest stay white.
col = c_white;

// THE WHEEL'S ZONE (2026-09-10): two bars on one screen - statistics'
// content and its tab rail - both heard every wheel notch, wherever the
// pointer was. An owner can fence the wheel to a horizontal band; -1
// (the default) keeps the old whole-screen listen.
wheel_x1 = -1;
wheel_x2 = -1;
in_menu = false; // true = this bar LIVES above a ui block (the settings
                 // overlay, the menu drawer): it listens through the
                 // block instead of bailing on it. obj_set_slider's own
                 // flag, same meaning, same reason.
i = 0;
input = 0;

/*
id 0 statistics
id 1 ability deck
id 2 upgrades
id 3 change log
id 4 goals



/* */
///touchscreen
touching = false;
ty = 0; ty_ = 0;
ty_speed = 0;
ty_speed_actual = 0;
ty_speed_max = 16;//8
ty_friction_ = .05;
ty_mouse_friction = .17;
ty_friction = ty_friction_;
ty_dir = 0;

/* */
/*  */
