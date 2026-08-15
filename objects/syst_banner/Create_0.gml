
x1 = -room_width/2; x = x1;
des_x = 0;
y = 29+8;


lines = 20;

yy = 0;
l = 0; h = 9; ind = 2;

repeat lines{
text[l] = "";
c_text[l] = c_white;
c_back[l] = c_black;
alpha[l] = 0;
hp[l] = 0;
glow[l] = 0;
y_[l] = yy;
w[l] = 10000;
dy[l] = yy;
dx[l] = 0
l++; yy+=(h+ind);}

clear = false;

assign_banner("welcome",c_gold,c_black);