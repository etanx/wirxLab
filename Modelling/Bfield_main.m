clear all

load Bfield_calc.mat
sc = 0.05;

[Bx, By, Bz] = Bfield2();

dir = -1;
Btrace(xs, ys, zs, sc, dir);
Blines(xt, yt, zt, sc, dir);
[h1] = ArcadePlot(pic)