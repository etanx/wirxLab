function [] = Btrace(xs, ys, zs, sc, dir)


% This program is used to launch a field line from a single starting point,
% defined by (xs, ys, zs) (ordered triple).
% sc is the maximum length to run a field line without stopping.
% dir is the direction to go along the lines; usually -1 for electrons, 1 otherwise.
% The field line dies if it goes above y = 0.
% This program uses and thus requires access to Bfield.m.
% This program is used by BfigScan.m, Blines, and BlinesSet.m.  Use
% ArcadePlot.m to make a figure to plot the lines on.
% Be sure to declare the vars global in your base workspace before using this program.
% Created by Matthew McMillan Summer 2010.
% If you are reading this you should be capable of deciphering this program
% without comments everywhere.
% Hesitate to call me if you have problems with this at 630-639-0487.
% Or you can email me any time at matthew.mcmillan@my.wheaton.edu

% Globals:
% (x, y, z) is the current point at which the field is calculated.
% a, b, c, R, d, h, p are parameters for the plasma:
% a is the length of the arcade.
% b is the width at the electrodes.
% c is the distance between the electrodes.
% R is the approximate radious of the arcade (from somewhere in the
% middle).
% d is the distance from the center of the circle of the arcade to the
% electrodes.
% h is the width of the arcade at the bottom.
% p is the offset position of the entire arcade.
% Ic is the coil current, after multiplying by the number of turns in the
% coil (which is around 109).
% Ip is the plasma current.
% xc is the distance from the inner loops of the coil to the outer ones.
% yc is the vertical position of the coil.
% zc is the distance from the middle of the coil to one endpoint along the
% z direction.
% xx is an array containing x coordinate data for a field line.
% yy is an array containing y coordinate data for a field line.
% zz is an array containing z coordinate data for a field line.
% ze is the length of the electrodes.
% shot is the current shot number; used for retrieving current data in
% ArcadePlot.m
% dc is the step size for tracing field lines.
% dt is the angle that Bfield.m skips around points in the current arcade.

global x y z a b c R d Ic Ip dt xc yc zc h p xx yy zz ze shot dc ye1 ye2 xf yf zf;
d = sqrt(R.^2 - (c.^2)./4);
h = -R + sqrt(R.^2 + b.*c + b.^2);

x = xs;
y = ys;
z = zs;
xx = [];
yy = [];
zz = [];

switch dir
    case -1
        for j = 1:floor((sc./dc))
            
            [bx, by, bz] = Bfield2;
            xx = [xx, x];
            yy = [yy, y];
            zz = [zz, z];
            x = x - (bx./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
            y = y - (by./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
            z = z - (bz./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
            if y>0
                break;
            end
        end
    case 1
        for j = 1:floor((sc./dc))
    
            [bx, by, bz] = Bfield2;
            xx = [xx, x];
            yy = [yy, y];
            zz = [zz, z];
            x = x + (bx./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
            y = y + (by./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
            z = z + (bz./(sqrt(bx.^2 + by.^2 + bz.^2))).*dc;
    
            if y>0
                break;
            end
        end
end

end