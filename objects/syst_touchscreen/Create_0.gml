
on_screen = false;

x_ = -100;
y_ = -100;

drag_dist = 0;
dragspd = 0;
dragspdlerp = 0;
dir = 0;

x_prev = 0;
y_prev = 0;

time = 0;

wmx = 0;
wmy = 0;






//two finger / pinch
touches = 0;        // fingers down (0-2), finger 0 doubles as the mouse
t0x = 0; t0y = 0;   // finger positions, gui space
t1x = 0; t1y = 0;

pinching = false;
pinch_dist = 0;      // finger gap this step
pinch_dist_prev = 0; // finger gap last step
pinch_delta = 0;     // gap change this step: + apart, - together
pinch_scale = 1;     // gap ratio this step: multiply a zoom by this
pinch_cx = 0;        // midpoint between the fingers
pinch_cy = 0;
