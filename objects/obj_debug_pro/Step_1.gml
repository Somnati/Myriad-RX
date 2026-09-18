/// THE PHASE TIMER (q222): the frame's phases in microseconds - Begin Step to End Step (every object's Step), Draw Begin
/// to Draw End (every Draw: the rooms, the panels, the CRT post-process), GUI Begin to GUI End (the overlays); the frame
/// itself Begin Step to Begin Step. An average over ~half a second and the WORST of the last sixty frames (the hitch),
/// shown on the SYSTEM page. Begin / End events run by phase, not by depth, so this object brackets everyone
var _now = get_timer();
if (variable_global_exists("prof_f0")) __prof_take("frame", _now - g.prof_f0);
g.prof_f0 = _now;
g.prof_s0 = _now;
