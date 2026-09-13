if (!unfold_has("timebank")) exit;   // (the unfold: not yet arrived)
cx0 = (room_width - cw) * .5;   // rooms differ in width
cy0 = (instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16) + 3;   // under the bar, not behind it

if (!__live()) exit;
if (!input_free()) exit;
if (g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (!point_in_rectangle(mouse_x, mouse_y, cx0, cy0, cx0 + cw, cy0 + ch)) exit;

play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
timebank_open();   // the panel, over this room (rm_timebank is gone)
