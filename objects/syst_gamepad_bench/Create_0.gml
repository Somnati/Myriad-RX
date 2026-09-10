/// gamepad bench (rm_gamepad, menu > misc) - the controller
/// framework's debug room, services-bench pattern: pure view + taps,
/// ALL real logic stays in the pad_* scripts. three columns:
/// devices + deadzone sliders + rumble/reset (left), live sticks /
/// triggers / button grid on the ACTIVE device (middle), the action
/// map with tap-to-rebind rows (right). hotplug + rebinds report in
/// the log strip bottom-left.

pad_init();

bby = obj_ui_header.bar_h;   // flush under the bar, not its shadow

// left column
dev_x = 8;
dev_w = 150;
__dev_y = function(_i) { return bby + 22 + _i * 11; };
sld_x = 8;
sld_w = 100;
dz_y  = bby + 162;
thr_y = bby + 178;
btn_y = bby + 196;
log_y = bby + 216;
drag  = "";   // "dz"/"thr" while a slider is held

// middle column: stick circles + trigger bars + the 4x4 button grid
stk_lx = 202; stk_rx = 262; stk_y = bby + 44; stk_r = 22;
trg_y  = bby + 78;
grid_x = 170; grid_y = bby + 108;
chip_w = 30;  chip_h = 12;

// right column: rebindable action rows (sticks shown read-only later)
act_x = 306;
act_w = room_width - act_x - 6;
__act_y = function(_i) { return bby + 22 + _i * 11; };
rows = [];
var _nm = g.pad.act_names;
for (var _i = 0; _i < array_length(_nm); _i++)
	if (g.pad.acts[$ _nm[_i]].kind != "s") array_push(rows, _nm[_i]);
