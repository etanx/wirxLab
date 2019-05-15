function [h1] = ArcadePlot(pic)

%This program creates a figure for plotting field lines in.  Try it to find
%out what that figure looks like.  pic is the picture number (1-4) from the
%current shot (specified global as "shot") from which to take the current
%measurements.  This is so that one doesn't have to do it manually.
%If you want to manually change the current values, call ArcadePlot first
%and then change the values in the base workspace.  See BfigSet.m for an
%example.
%Note that ArcadePlot.m can only properly be called AFTER Btrace.m has been
%called.  There will be strange plots if you don't call Blines.m first.
%(Blines.m sets the h and d values).
%Be sure to declare the vars global in your base workspace before 
%using this program.
%Created by Matthew McMillan Summer 2010.
%If you are reading this you should be capable of deciphering this program
%without comments everywhere.
%Hesitate to call me if you have problems with this at 630-639-0487.
%Or you can email me any time at matthew.mcmillan@my.wheaton.edu

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

mdsclose();
mdsopen('wirxtree', shot);
picsets = camSettings();

PlasmaCurrentSig = 1000.*mdsvalue( '\wirxtree::TOP.IV_MEAS.PROCESSED:IDIS' );
PlasmaCurrentTime = mdsvalue( 'DIM_OF(\wirxtree::TOP.IV_MEAS:VD1_HI)' );
CoilCurrentSig = mdsvalue( '\wirxtree::TOP.IV_MEAS.PROCESSED:ICOIL' );
CoilCurrentTime = mdsvalue( 'DIM_OF(\wirxtree::TOP.IV_MEAS:VD1_HI)' );

PostTrigArray = find( PlasmaCurrentTime > 0 );
TrigIndex = PostTrigArray(1) - 1;
CoilCurrent = mean( CoilCurrentSig( 1:( floor( 4./5.*TrigIndex ) ) ) );

dtp = ( PlasmaCurrentTime( length( PlasmaCurrentTime ) ) - PlasmaCurrentTime( 1 ) )./2499;

switch pic
    case 1
        picindex = floor( picsets(1)./(1000000.*dtp) ) + TrigIndex;
        PlasmaCurrent = mean( PlasmaCurrentSig( (picindex - 3):(picindex + 3) ) );
    case 2
        picindex = floor( picsets(3)./(1000000.*dtp) ) + TrigIndex;
        PlasmaCurrent = mean( PlasmaCurrentSig( (picindex - 3):(picindex + 3) ) );
    case 3
        picindex = floor( picsets(6)./(1000000.*dtp) ) + TrigIndex;
        PlasmaCurrent = mean( PlasmaCurrentSig( (picindex - 3):(picindex + 3) ) );
    case 4
        picindex = floor( picsets(8)./(1000000.*dtp) ) + TrigIndex;
        PlasmaCurrent = mean( PlasmaCurrentSig( (picindex - 3):(picindex + 3) ) );
end
cdir = mdsvalue( '\wirxtree::TOP.SETTINGS:COIL_DIR' );

Ip = PlasmaCurrent;
Ic = CoilCurrent.*109.*cdir;

h1 = figure();
h2 = axes();
hold on
set(h1, 'Color', 'k');
set(h2, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
hold on

for j = (-a/2 + p):.005:(a/2 + p)
xcr = -c/2:.001:c/2;
xcr = [xcr, c/2];
ycr = xcr.*0 + j;
zcr = -sqrt( R^2 - xcr.^2 ) + d;
plot3(ycr, xcr, zcr, 'r');
xcr = -c/2 - b:.001:c/2 + b;
xcr = [xcr, c/2 + b];
zcr = -sqrt( (R + h)^2 - xcr.^2 ) + d;
ycr = xcr.*0 + j;
plot3(ycr, xcr, zcr, 'r');
end

plot3( [-a/2 + p, -a/2 + p], [-c/2 - b, -c/2], [0, 0], 'r' );
plot3( [a/2 + p, a/2 + p], [-c/2 - b, -c/2], [0, 0], 'r' );
plot3( [-a/2 + p, -a/2 + p], [c/2 + b, c/2], [0, 0], 'r' );
plot3( [a/2 + p, a/2 + p], [c/2 + b, c/2], [0, 0], 'r' );

px = ((-a/2 + p):.001:(a/2 + p)).*0 + c/2;
py = (-a/2 + p):.001:(a/2 + p);
pz = ((-a/2 + p):.001:(a/2 + p)).*0;
plot3( py, px, pz, 'r' );

px = ((-a/2 + p):.001:(a/2 + p)).*0 - c/2;
py = (-a/2 + p):.001:(a/2 + p);
pz = ((-a/2 + p):.001:(a/2 + p)).*0;
plot3( py, px, pz, 'r' );


px = ((-a/2 + p):.001:(a/2 + p)).*0 + c/2 + b;
py = (-a/2 + p):.001:(a/2 + p);
pz = ((-a/2 + p):.001:(a/2 + p)).*0;
plot3( py, px, pz, 'r' );

px = ((-a/2 + p):.001:(a/2 + p)).*0 - c/2 - b;
py = (-a/2 + p):.001:(a/2 + p);
pz = ((-a/2 + p):.001:(a/2 + p)).*0;
plot3( py, px, pz, 'r' );

rotate3d on;

end

function [ settings ] = camSettings()
    
    global x y z a b c R d Ic Ip dt xc yc zc h p xx yy zz ze shot dc ye1 ye2 xf yf zf;
    
    settings = mdsvalue('ICCD.DICAM1.SETTINGS:FRAME1_TIME');
    settings = [settings, mdsvalue('ICCD.DICAM1.SETTINGS:FRAME1_EXPO')];
    settings = [settings, mdsvalue('ICCD.DICAM1.SETTINGS:FRAME2_TIME')];
    settings = [settings, mdsvalue('ICCD.DICAM1.SETTINGS:FRAME2_EXPO')];
    settings = [settings, mdsvalue('ICCD.DICAM1.SETTINGS:GAIN')];
    settings = [settings, mdsvalue('ICCD.DICAM2.SETTINGS:FRAME1_TIME')];
    settings = [settings, mdsvalue('ICCD.DICAM2.SETTINGS:FRAME1_EXPO')];
    settings = [settings, mdsvalue('ICCD.DICAM2.SETTINGS:FRAME2_TIME')];
    settings = [settings, mdsvalue('ICCD.DICAM2.SETTINGS:FRAME2_EXPO')];
    settings = [settings, mdsvalue('ICCD.DICAM2.SETTINGS:GAIN')];
    
end