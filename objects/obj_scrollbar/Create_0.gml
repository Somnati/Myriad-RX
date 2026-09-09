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
