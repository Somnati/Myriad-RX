/// obj_boost_spd - DE's SPEED ARROW, as it was (his ask, 2026-09-10:
/// "there is a speed arrow sprite in DE that draws in the top right of
/// the production room when its enabled... ported over as is, shown in
/// the clicker room in the top right"). DE flew it while the ad speed
/// boost ran, with the boost's remaining time as a green fill across
/// the plate; RX has no ad boost, so the arrow is THE TIME BANK's - up
/// while a multiplier above x1 is running, and the fill is what the
/// bank has left against its cap. The chevrons walk (DE's ani_set /
/// ani_step: a frame every 30 ticks, looping; RX has neither helper, so
/// the tick lives here). Sprite: spr_boost_spd, DE's own pixels.
///
/// PERSISTENT and spawned once by syst_handle_save beside the cockpit
/// chip; it shows only in the money room, the way the chip does. Draw
/// only: DE's tap was already commented out, and the chip is the tap.

depth = -300;   // the chip's lane: under the header, over the drawer
persistent = true;
image_speed = 0;

alpha   = 0;
ani     = 0;    // which chevron frame is up (drawn as ani + 1; 0 is the plate)
ani_tic = 30;   // DE's ani_set(image_max - 1, 30): a frame every 30 ticks
desx = room_width - sprite_get_width(spr_boost_spd) - 3;   // DE's seat
desy = 0;
x = desx;
y = 0;

/// showing? a multiplier has to be running, and we have to be in the
/// money room (the chip's rule)
__live = function() {
	if (!variable_global_exists("timebank")) return false;
	if (g.timebank.spd <= 1) return false;
	return in_room(rm_clicker);
};
