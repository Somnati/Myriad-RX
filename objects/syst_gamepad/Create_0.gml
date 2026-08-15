/// THE controller runner (2026-07-09, his queue: one object,
/// universal support). persistent + lazy-spawned by pad_init() (the
/// syst_tiletimer pattern - syst_input's create calls pad_init, so
/// this exists from boot in every room). all the actual work lives
/// in the pad_* scripts:
///
///   pad_config       THE action map - add actions there
///   pad_tick         per-step poll (begin step, below)
///   pad_down/pressed/released/value/x/y   consumer reads
///   pad_rebind/pad_glyph                  rebinding + button labels
///   pad_binds_save/load                   settings.ini "pad"
///   pad_rumble                            active-device vibration
///
/// bench: rm_gamepad (menu > misc) - devices, live sticks, rebinds.
/// consumers so far: obj_procgen's [3d] walk (left stick move, right
/// stick look, l3 sprint, cancel exits).

if (instance_number(syst_gamepad) > 1) { kill; exit; }
pad_init();
