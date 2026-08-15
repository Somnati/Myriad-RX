//x1 = room_width;
//x2 = room_width;
r = 0;
alpha = 0;
balpha = 0;
reached_dest = false;
black_hold = 0; // presented full-black frames before the switch (round 2)

cur_room = room_get_name(room);
cur_room_id = room;
des_room = "none";
des_room_id = -1;
switch_rooms = false;

// ---- THE SLICE WIPE (round 7, his showcase ask: "snappy") ----
// six horizontal slats shoot across the room in ALTERNATING
// directions with a small per-slat stagger: ease-IN so they build
// speed and slam the cover shut, three presented black frames (the
// heavy-room fix, shared with the circle), switch, then the same
// slats keep flying the SAME way and ease-OUT to reveal the new room
// - one continuous gesture straight through the switch. all
// spr_pixel_1x1 rects, hard edges, nothing gradients (8-bit safe by
// construction); a 1px slate accent rides each moving edge.
// g.trans_kind picks the mode (0 circle / 1 slice; default in system
// Create, persisted in settings.ini display, pillbox row in settings)
// and goto_room LATCHES it per flight so a mid-wipe settings change
// can't mix modes.
trans_active_kind = 1; // the latched kind for the CURRENT flight
slice_phase = 0;  // 0 idle / 1 covering / 2 revealing
slice_t     = 0;  // slat clock, 60hz steps (delta-fed)
slice_n     = 6;  // slat count (270/6 = 45px bands)
slice_dur   = 8;  // one slat's sweep, in steps - the snap lever
slice_stag  = 1.2; // per-slat start offset, in steps



