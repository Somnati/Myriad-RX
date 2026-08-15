



tfiller = true;


bh = 3;

p = 0;
vmin = 0
vmax = 100
val = lerp(vmin,vmax,p);
pval = -1;

xdrag = 0;

img = 0;

grabbed = false;
ww = 8;



xmin = x-1;
xmax = x+sprite_width-ww;
xx = lerp(xmin,xmax,p);
mxos = 0;







cbase = color_set_random();
hue = c_hue(cbase);
sat = c_sat(cbase);
c0 = c_hsv(hue,20,50);
c1 = cbase;
cbar = c_hsv(c_hue(c1),sat,150);
abar = 1;