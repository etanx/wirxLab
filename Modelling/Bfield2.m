function [Bx, By, Bz] = Bfield2()

% This function calculates the magnetic field vector at any point (x, y, z)
% inside the vacuum vessel.  a, b, c are parameters of the electrodes, R is
% the radius of the arcade, I is the plasma current, and dt is the angle
% around a point inside the arcade that the integrate functions will skip to
% avoid the singularity when calculating the field inside the arcade.
% There are addtional singularity catching lines that are currently
% commented out for speed purposes.  We don't seem to need them.

% This program is used by BfigScan.m, BlinesSet.m, Blines.m, and Btrace.m.
% Use ArcadePlot.m to make a figure to plot the lines on.
% Be sure to declare the vars global in your base workspace before
% using this program.
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
% ye1 is the height of the electrode on the left.
% ye2 is the height of the electrode on the right.
% xf is the length of the current feed wire.
% yf is the y coordinate for the position of the current feed wire.
% zf is the z coordinate for the position of the current feed wire.


global x y z a b c R d Ic Ip dt xc yc zc h p xx yy zz ze shot dc ye1 ye2 xf yf zf;

zn = z - p;  %This is because of a coord. change for an integration.

if ((-a/2 - dc)<zn)&(zn<(a/2 + dc))  %These lines decide if the point is inside the current segment and needs singularity fixing.
    rr = sqrt(x.^2 + (y - d).^2);
    if ((R - dc)<rr)&(rr<(R + h + dc))
        th = atan2(y - d, x);
        if ((C(rr) - dt)<th)&(th<(D(rr) + dt))
            [Bx, By, Bz] = Bsplit(th);
        else
            [Bx, By, Bz] = Bnosplit();
        end
    else
        [Bx, By, Bz] = Bnosplit();
    end
else
    [Bx, By, Bz] = Bnosplit();
end
    
    function [Bx, By, Bz] = Bsplit(th)  %This function is for skipping an angle th around the point if it is in the current arcade.
        Bx = quad2d(@Bx3, R, R + h, @C, th - dt) + quad2d(@Bx3, R, R + h, th + dt, @D) + ...
            quad2d(@Bx1, 0, ye1, @E, @F) + ...
            quad2d(@Bx2, 0, ye2, @G, @H) + ...
            (1e-7).*(Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(-2.*Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4))) + ...
            (1e-7).*(Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)));
        
        By = quad2d(@By3, R, R + h, @C, th - dt) + quad2d(@By3, R, R + h, th + dt, @D) + ...
            quadgk(@By1, 0, ye1) + ...
            quadgk(@By2, 0, ye2) + ...
            (1e-7).*(-Ip.*(z-zf).*(((xf+2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2+4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2-8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2-8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2+4.*x.*xf+4.*x.^2).*y.^2)+((xf-2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2-4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2+8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2+8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2-4.*x.*xf+4.*x.^2).*y.^2))) + ...
            (1e-7).*(-Ic.*(x+xc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(2.*Ic.*x.*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4))) + ...
            (1e-7).*(-Ic.*(x-xc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(-Ic.*(z+zc).*(((x+xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(Ic.*(z+zc).*(x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2))) + ...
            (1e-7).*(Ic.*(z-zc).*(((x+xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(-Ic.*(z-zc).*(x/((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))/(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)));
        
        Bz = quad2d(@Bz3, R, R + h, @C, th - dt) + quad2d(@Bz3, R, R + h, th + dt, @D) + ...
            quadgk(@Bz1, 0, ye1) + ...
            quadgk(@Bz2, 0, ye2) + ...
            (1e-7).*(Ip.*(y-yf).*(((xf+2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2+4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2-8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2-8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2+4.*x.*xf+4.*x.^2).*y.^2)+((xf-2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2-4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2+8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2+8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2-4.*x.*xf+4.*x.^2).*y.^2))) + ...
            (1e-7).*(Ic.*(y-yc).*(((x+xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(-Ic.*(y-yc).*(x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2))) + ...
            (1e-7).*(-Ic.*(y-yc).*(((x+xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(Ic.*(y-yc).*(x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)));
                    
    end
    function [Bx, By, Bz] = Bnosplit()
        Bx = quad2d(@Bx3, R, R + h, @C, @D) + ...
            quad2d(@Bx1, 0, ye1, @E, @F) + ...
            quad2d(@Bx2, 0, ye2, @G, @H) + ...
            (1e-7).*(Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(-2.*Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4))) + ...
            (1e-7).*(Ic.*(y-yc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)));
        
        By = quad2d(@By3, R, R + h, @C, @D) + ...
            quadgk(@By1, 0, ye1) + ...
            quadgk(@By2, 0, ye2) + ...
            (1e-7).*(-Ip.*(z-zf).*(((xf+2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2+4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2-8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2-8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2+4.*x.*xf+4.*x.^2).*y.^2)+((xf-2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2-4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2+8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2+8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2-4.*x.*xf+4.*x.^2).*y.^2))) + ...
            (1e-7).*(-Ic.*(x+xc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2+2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2-8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4+4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(2.*xc.*zc.^2+4.*xc.*yc.^2+4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(2.*Ic.*x.*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2+2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))./((y.^2-2.*yc.*y+x.^2+yc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2-2.*yc.^2.*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2+zc.^2+6.*yc.^2).*y.^2+(-4.*yc.*x.^2-2.*yc.*zc.^2-4.*yc.^3).*y+x.^4+(zc.^2+2.*yc.^2).*x.^2+yc.^2.*zc.^2+yc.^4))) + ...
            (1e-7).*(-Ic.*(x-xc).*(((z+zc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(2.*zc.*y.^2-4.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+(2.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4)-((z-zc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./((y.^2-2.*yc.*y+x.^2-2.*xc.*x+yc.^2+xc.^2).*z.^2+(-2.*zc.*y.^2+4.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x+(-2.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(2.*x.^2-4.*xc.*x+zc.^2+6.*yc.^2+2.*xc.^2).*y.^2+(-4.*yc.*x.^2+8.*xc.*yc.*x-2.*yc.*zc.^2-4.*yc.^3-4.*xc.^2.*yc).*y+x.^4-4.*xc.*x.^3+(zc.^2+2.*yc.^2+6.*xc.^2).*x.^2+(-2.*xc.*zc.^2-4.*xc.*yc.^2-4.*xc.^3).*x+(yc.^2+xc.^2).*zc.^2+yc.^4+2.*xc.^2.*yc.^2+xc.^4))) + ...
            (1e-7).*(-Ic.*(z+zc).*(((x+xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(Ic.*(z+zc).*(x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2))) + ...
            (1e-7).*(Ic.*(z-zc).*(((x+xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(-Ic.*(z-zc).*(x/((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))/(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)));
        
        Bz = quad2d(@Bz3, R, R + h, @C, @D) + ...
            quadgk(@Bz1, 0, ye1) + ...
            quadgk(@Bz2, 0, ye2) + ...
            (1e-7).*(Ip.*(y-yf).*(((xf+2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2+4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2-8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2+4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2-8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2+4.*x.*xf+4.*x.^2).*y.^2)+((xf-2.*x).*sqrt(4.*zf.^2-8.*z.*zf+4.*z.^2+4.*yf.^2-8.*y.*yf+4.*y.^2+xf.^2-4.*x.*xf+4.*x.^2))./(4.*zf.^4-16.*z.*zf.^3+(24.*z.^2+8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*zf.^2+((-16.*yf.^2+32.*y.*yf-16.*y.^2-2.*xf.^2+8.*x.*xf-8.*x.^2).*z-16.*z.^3).*zf+4.*z.^4+(8.*yf.^2-16.*y.*yf+8.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*z.^2+4.*yf.^4-16.*y.*yf.^3+(24.*y.^2+xf.^2-4.*x.*xf+4.*x.^2).*yf.^2+((-2.*xf.^2+8.*x.*xf-8.*x.^2).*y-16.*y.^3).*yf+4.*y.^4+(xf.^2-4.*x.*xf+4.*x.^2).*y.^2))) + ...
            (1e-7).*(Ic.*(y-yc).*(((x+xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2+4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(-Ic.*(y-yc).*(x./((z.^2+2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2+2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4+4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(4.*zc.*y.^2-8.*yc.*zc.*y+2.*zc.*x.^2-4.*xc.*zc.*x+4.*zc.^3+(4.*yc.^2+2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2))) + ...
            (1e-7).*(-Ic.*(y-yc).*(((x+xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2+2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2-4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2+2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2-4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(2.*xc.*zc.^2+2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)-x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2)))) + ...
            (1e-7).*(Ic.*(y-yc).*(x./((z.^2-2.*zc.*z+y.^2-2.*yc.*y+zc.^2+yc.^2).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2+zc.^2+yc.^2))-((x-xc).*sqrt(z.^2-2.*zc.*z+y.^2-2.*yc.*y+x.^2-2.*xc.*x+zc.^2+yc.^2+xc.^2))./(z.^4-4.*zc.*z.^3+(2.*y.^2-4.*yc.*y+x.^2-2.*xc.*x+6.*zc.^2+2.*yc.^2+xc.^2).*z.^2+(-4.*zc.*y.^2+8.*yc.*zc.*y-2.*zc.*x.^2+4.*xc.*zc.*x-4.*zc.^3+(-4.*yc.^2-2.*xc.^2).*zc).*z+y.^4-4.*yc.*y.^3+(x.^2-2.*xc.*x+2.*zc.^2+6.*yc.^2+xc.^2).*y.^2+(-2.*yc.*x.^2+4.*xc.*yc.*x-4.*yc.*zc.^2-4.*yc.^3-2.*xc.^2.*yc).*y+(zc.^2+yc.^2).*x.^2+(-2.*xc.*zc.^2-2.*xc.*yc.^2).*x+zc.^4+(2.*yc.^2+xc.^2).*zc.^2+yc.^4+xc.^2.*yc.^2)));
    end
    function Bx3out = Bx3(r, t)
        y1 = y - d;
        U = sqrt(4.*zn.^2+4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        V = sqrt(4.*zn.^2-4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        Bx3out = ((1e-7).*Ip./(a.*h)).*((r.*cos(t).*(2.*U-2.*V))./(U.*V));
%         Bx3out(~isfinite(Bx3out)) = sign(Bx3out(~isfinite(Bx3out)))./eps;
%         Bx3out(isnan(Bx3out)) = 1;
    end
    function By3out = By3(r, t)
        y1 = y - d;
        U = sqrt(4.*zn.^2+4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        V = sqrt(4.*zn.^2-4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        By3out = ((1e-7).*Ip./(a.*h)).*((r.*sin(t).*(2.*U-2.*V))./(U.*V));
%         By3out(~isfinite(By3out)) = sign(By3out(~isfinite(By3out)))./eps;
%         By3out(isnan(By3out)) = 1;
    end
    function Bz3out = Bz3(r, t)
        y1 = y - d;
        U = sqrt(4.*zn.^2+4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        V = sqrt(4.*zn.^2-4.*a.*zn+4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2+a.^2);
        Bz3out = ((1e-7).*Ip./(a.*h)).*(r.*(-sin(t).*y1-cos(t).*x+r).*((U.*(2.*zn+a))./((4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2).*zn.^2+(4.*a.*y1.^2-8.*a.*r.*sin(t).*y1+4.*a.*x.^2-8.*a.*r.*cos(t).*x+4.*a.*r.^2).*zn+4.*y1.^4-16.*r.*sin(t).*y1.^3+(8.*x.^2-16.*r.*cos(t).*x+16.*r.^2.*sin(t).^2+8.*r.^2+a.^2).*y1.^2+(-16.*r.*sin(t).*x.^2+32.*r.^2.*cos(t).*sin(t).*x+(-16.*r.^3-2.*a.^2.*r).*sin(t)).*y1+4.*x.^4-16.*r.*cos(t).*x.^3+(16.*r.^2.*cos(t).^2+8.*r.^2+a.^2).*x.^2+(-16.*r.^3-2.*a.^2.*r).*cos(t).*x+4.*r.^4+a.^2.*r.^2)-(V.*(2.*zn-a))./((4.*y1.^2-8.*r.*sin(t).*y1+4.*x.^2-8.*r.*cos(t).*x+4.*r.^2).*zn.^2+(-4.*a.*y1.^2+8.*a.*r.*sin(t).*y1-4.*a.*x.^2+8.*a.*r.*cos(t).*x-4.*a.*r.^2).*zn+4.*y1.^4-16.*r.*sin(t).*y1.^3+(8.*x.^2-16.*r.*cos(t).*x+16.*r.^2.*sin(t).^2+8.*r.^2+a.^2).*y1.^2+(-16.*r.*sin(t).*x.^2+32.*r.^2.*cos(t).*sin(t).*x+(-16.*r.^3-2.*a.^2.*r).*sin(t)).*y1+4.*x.^4-16.*r.*cos(t).*x.^3+(16.*r.^2.*cos(t).^2+8.*r.^2+a.^2).*x.^2+(-16.*r.^3-2.*a.^2.*r).*cos(t).*x+4.*r.^4+a.^2.*r.^2)));
%         Bz3out(~isfinite(Bz3out)) = sign(Bz3out(~isfinite(Bz3out)))./eps;
%         Bz3out(isnan(Bz3out)) = 1;
    end
    function Cout = C(r)
        Cout = -pi/2 - acos(sqrt(R.^2 - (c.^2)./4)./r);
    end
    function Dout = D(r)
        Dout = -pi/2 + acos(sqrt(R.^2 - (c.^2)./4)./r);
    end
    function Eout = E(Y)
        Eout = (-p./ye1).*Y + p - a./2;
    end
    function Fout = F(Y)
        Fout = (-p./ye1).*Y + p + a./2;
    end
    function Gout = G(Y)
        Gout = (-p./ye2).*Y + p - a./2;
    end
    function Hout = H(Y)
        Hout = (-p./ye2).*Y + p + a./2;
    end
    function Bx1out = Bx1(Y, Z)
        Bx1out = ((1e-7).*Ip./(a.*b)).*((-(ye1.*(z-Z))./p-Y+y).*(((2.*x-c+2.*b).*sqrt(4.*Z.^2-8.*z.*Z+4.*z.^2+4.*Y.^2-8.*y.*Y+4.*y.^2+4.*x.^2+(8.*b-4.*c).*x+c.^2-4.*b.*c+4.*b.^2))./(4.*Z.^4-16.*z.*Z.^3+(24.*z.^2+8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2+(8.*b-4.*c).*x+c.^2-4.*b.*c+4.*b.^2).*Z.^2+((-16.*Y.^2+32.*y.*Y-16.*y.^2-8.*x.^2+(8.*c-16.*b).*x-2.*c.^2+8.*b.*c-8.*b.^2).*z-16.*z.^3).*Z+4.*z.^4+(8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2+(8.*b-4.*c).*x+c.^2-4.*b.*c+4.*b.^2).*z.^2+4.*Y.^4-16.*y.*Y.^3+(24.*y.^2+4.*x.^2+(8.*b-4.*c).*x+c.^2-4.*b.*c+4.*b.^2).*Y.^2+((-8.*x.^2+(8.*c-16.*b).*x-2.*c.^2+8.*b.*c-8.*b.^2).*y-16.*y.^3).*Y+4.*y.^4+(4.*x.^2+(8.*b-4.*c).*x+c.^2-4.*b.*c+4.*b.^2).*y.^2)-((2.*x-c).*sqrt(4.*Z.^2-8.*z.*Z+4.*z.^2+4.*Y.^2-8.*y.*Y+4.*y.^2+4.*x.^2-4.*c.*x+c.^2))./(4.*Z.^4-16.*z.*Z.^3+(24.*z.^2+8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2-4.*c.*x+c.^2).*Z.^2+((-16.*Y.^2+32.*y.*Y-16.*y.^2-8.*x.^2+8.*c.*x-2.*c.^2).*z-16.*z.^3).*Z+4.*z.^4+(8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2-4.*c.*x+c.^2).*z.^2+4.*Y.^4-16.*y.*Y.^3+(24.*y.^2+4.*x.^2-4.*c.*x+c.^2).*Y.^2+((-8.*x.^2+8.*c.*x-2.*c.^2).*y-16.*y.^3).*Y+4.*y.^4+(4.*x.^2-4.*c.*x+c.^2).*y.^2)));
%         Bx1out(~isfinite(Bx1out)) = sign(Bx1out(~isfinite(Bx1out)))./eps;
%         Bx1out(isnan(Bx1out)) = 1;
    end
    function By1out = By1(Y)
        By1out = ((1e-7).*Ip./(a.*b)).*(log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(4.*a-8.*p).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2-4.*a.*p+c.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p-4.*a).*ye1)./ye1)-log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(4.*a-8.*p).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2+(8.*b-4.*c).*x+4.*p.^2-4.*a.*p+c.^2-4.*b.*c+4.*b.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p-4.*a).*ye1)./ye1)-log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(-8.*p-4.*a).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2+4.*a.*p+c.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p+4.*a).*ye1)./ye1)+log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(-8.*p-4.*a).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2+(8.*b-4.*c).*x+4.*p.^2+4.*a.*p+c.^2-4.*b.*c+4.*b.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p+4.*a).*ye1)./ye1));
%         Bx1out(~isfinite(Bx1out)) = sign(Bx1out(~isfinite(Bx1out)))./eps;
%         Bx1out(isnan(Bx1out)) = 1;
    end
    function Bz1out = Bz1(Y)
        Bz1out = ((1e-7).*Ip./(a.*b)).*((ye1.*(-log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(4.*a-8.*p).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2-4.*a.*p+c.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p-4.*a).*ye1)./ye1)+log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(4.*a-8.*p).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2+(8.*b-4.*c).*x+4.*p.^2-4.*a.*p+c.^2-4.*b.*c+4.*b.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p-4.*a).*ye1)./ye1)+log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(-8.*p-4.*a).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2+4.*a.*p+c.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p+4.*a).*ye1)./ye1)-log((4.*sqrt(4.*ye1.^2.*z.^2+(8.*p.*ye1.*Y+(-8.*p-4.*a).*ye1.^2).*z+(4.*ye1.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye1-8.*y.*ye1.^2).*Y+(4.*y.^2+4.*x.^2+(8.*b-4.*c).*x+4.*p.^2+4.*a.*p+c.^2-4.*b.*c+4.*b.^2+a.^2).*ye1.^2)-8.*ye1.*z-8.*p.*Y+(8.*p+4.*a).*ye1)./ye1)))./p);
%         Bz1out(~isfinite(Bz1out)) = sign(Bz1out(~isfinite(Bz1out)))./eps;
%         Bz1out(isnan(Bz1out)) = 1;
    end
    function Bx2out = Bx2(Y, Z)
        Bx2out = -((1e-7).*Ip./(a.*b)).*(-(ye2.*(z-Z))./p-Y+y).*(((2.*x-c).*sqrt(4.*Z.^2-8.*z.*Z+4.*z.^2+4.*Y.^2-8.*y.*Y+4.*y.^2+4.*x.^2-4.*c.*x+c.^2))./(4.*Z.^4-16.*z.*Z.^3+(24.*z.^2+8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2-4.*c.*x+c.^2).*Z.^2+((-16.*Y.^2+32.*y.*Y-16.*y.^2-8.*x.^2+8.*c.*x-2.*c.^2).*z-16.*z.^3).*Z+4.*z.^4+(8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2-4.*c.*x+c.^2).*z.^2+4.*Y.^4-16.*y.*Y.^3+(24.*y.^2+4.*x.^2-4.*c.*x+c.^2).*Y.^2+((-8.*x.^2+8.*c.*x-2.*c.^2).*y-16.*y.^3).*Y+4.*y.^4+(4.*x.^2-4.*c.*x+c.^2).*y.^2)-((2.*x-c-2.*b).*sqrt(4.*Z.^2-8.*z.*Z+4.*z.^2+4.*Y.^2-8.*y.*Y+4.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+c.^2+4.*b.*c+4.*b.^2))./(4.*Z.^4-16.*z.*Z.^3+(24.*z.^2+8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+c.^2+4.*b.*c+4.*b.^2).*Z.^2+((-16.*Y.^2+32.*y.*Y-16.*y.^2-8.*x.^2+(8.*c+16.*b).*x-2.*c.^2-8.*b.*c-8.*b.^2).*z-16.*z.^3).*Z+4.*z.^4+(8.*Y.^2-16.*y.*Y+8.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+c.^2+4.*b.*c+4.*b.^2).*z.^2+4.*Y.^4-16.*y.*Y.^3+(24.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+c.^2+4.*b.*c+4.*b.^2).*Y.^2+((-8.*x.^2+(8.*c+16.*b).*x-2.*c.^2-8.*b.*c-8.*b.^2).*y-16.*y.^3).*Y+4.*y.^4+(4.*x.^2+(-4.*c-8.*b).*x+c.^2+4.*b.*c+4.*b.^2).*y.^2));
%         Bx2out(~isfinite(Bx2out)) = sign(Bx2out(~isfinite(Bx2out)))./eps;
%         Bx2out(isnan(Bx2out)) = 1;
    end
    function By2out = By2(Y)
        By2out = -((1e-7).*Ip./(a.*b)).*(-log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(4.*a-8.*p).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2-4.*a.*p+c.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p-4.*a).*ye2)./ye2)+log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(4.*a-8.*p).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+4.*p.^2-4.*a.*p+c.^2+4.*b.*c+4.*b.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p-4.*a).*ye2)./ye2)+log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(-8.*p-4.*a).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2+4.*a.*p+c.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p+4.*a).*ye2)./ye2)-log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(-8.*p-4.*a).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+4.*p.^2+4.*a.*p+c.^2+4.*b.*c+4.*b.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p+4.*a).*ye2)./ye2));
%         Bx1out(~isfinite(Bx1out)) = sign(Bx1out(~isfinite(Bx1out)))./eps;
%         Bx1out(isnan(Bx1out)) = 1;
    end
    function Bz2out = Bz2(Y)
        Bz2out = -((1e-7).*Ip./(a.*b)).*(-(ye2.*(-log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(4.*a-8.*p).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2-4.*a.*p+c.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p-4.*a).*ye2)./ye2)+log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(4.*a-8.*p).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((4.*a.*p-8.*p.^2).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+4.*p.^2-4.*a.*p+c.^2+4.*b.*c+4.*b.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p-4.*a).*ye2)./ye2)+log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(-8.*p-4.*a).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2-4.*c.*x+4.*p.^2+4.*a.*p+c.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p+4.*a).*ye2)./ye2)-log((4.*sqrt(4.*ye2.^2.*z.^2+(8.*p.*ye2.*Y+(-8.*p-4.*a).*ye2.^2).*z+(4.*ye2.^2+4.*p.^2).*Y.^2+((-8.*p.^2-4.*a.*p).*ye2-8.*y.*ye2.^2).*Y+(4.*y.^2+4.*x.^2+(-4.*c-8.*b).*x+4.*p.^2+4.*a.*p+c.^2+4.*b.*c+4.*b.^2+a.^2).*ye2.^2)-8.*ye2.*z-8.*p.*Y+(8.*p+4.*a).*ye2)./ye2)))./p);
%         Bz2out(~isfinite(Bz2out)) = sign(Bz2out(~isfinite(Bz2out)))./eps;
%         Bz2out(isnan(Bz2out)) = 1;
    end

end