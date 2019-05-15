% gas puff volume and pressure estimation


% half-cylinder gas puff volume
R = 3/100; %m cylinder radius
L = 20/100; %m electrode length plus a little more
V = 0.5*pi*R^2*L; % estimate volume of gas cloud

fprintf('Half-clinder volume is %4.1f cm^3\n',V*1e6)

% Pressure after puff near electrodes
r_pipe = 0.4e-3; % m, gas line radius
R = 8.314; % J/mol K
P_line = 660e3; % Pa
t_puff = 750e-6; % s, (aka 'On' time)
T = 295; % Room temperature (in KELVINS)

M = 40; % molecular mass (u) dpends on gas
gamma = 5/3; % adiabatic constant, 5/3 for Argon, 7/5 for Hydrogen

v_sound = sqrt(gamma.*R*T/M);
P = (P_line .* v_sound .* t_puff .* pi.* r_pipe.^2)./V;
fprintf('Electrode gas pressure is %4.4f Pa\n',P)

% calculate pd for paschen curve
d = 5.4; % electrode spacing (cm)
pd = P/133.322 .* d % Torr cm

%%

x = [0:0.01:4];
p = raylpdf(x,1);
figure;
hold on
plot(x+1,p,'m-','LineWidth',2)
plot(x+1.8,p,'b','LineWidth',2)
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
xlim([0 inf])
xlabel('Time')
ylabel('Pressure')
set(gca,'Fontsize',15);
legend('H','Ar')


