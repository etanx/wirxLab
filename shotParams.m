% A script to extract shot parameters and compare them
% Currently script is looking at event frequencies in parameters

clear all

shot = 1190305020;

% Extract MDS data
mdsconnect('WIRX07');
mdsopen('wirxtree', shot); %Open the tree for the desired shot
%Idischarge = mdsvalue('IV_MEAS.PROCESSED:IDIS');
Idis = mdsvalue('DTACQ.acq216_270:ch15/.5');
%Icoil = mdsvalue('IV_MEAS.PROCESSED:ICOIL');
Icoil = mdsvalue('DTACQ.acq216_270:ch16/20*1000')

timecoil = mdsvalue('dim_of(IV_MEAS.PROCESSED:ICOIL)');
%Vdischarge = mdsvalue('IV_MEAS.PROCESSED:VDIS');
Vdis = mdsvalue('iv_meas.processed:vdis*1000');
photodiode = mdsvalue('DTACQ.acq216_254:ch16');
timePD = mdsvalue('dim_of(DTACQ.acq216_254:ch16)');
mdsclose();
mdsdisconnect();

%% Calculate average Icoil (and B)
I_avg = mean(Icoil(find(timecoil >= 0.5e-3 & timecoil <= 5.5e-3)))
B_avg = 7.7*I_avg% convert kiloAmpere to Gauss
Ip_avg = mean(Idis(find(timecoil >= 0.5e-3 & timecoil <= 5.5e-3)))

%% Extract PPD data
[PicOut, times, position] = PPD_horizontal(shot, [1:80000], [0 0.36846]);
timePPD = times.*1e-7; % convert ticks to seconds
sumPPD = rssq(PicOut,2);


%% Cleanup frequencies
timerange = [5.115e-3 5.15e-3];
freqrange = [1e3 1000e3];

tindex = find(timePD >= timerange(1) & timePD <= timerange(2));
tPPDindex = find(timePPD >= timerange(1) & timePPD <= timerange(2));

[Icoil_filtered, f, y, y2] = fftf(timecoil(tindex),Icoil(tindex),freqrange);
[PPD_filtered, f, y, y2] = fftf(timePPD(tPPDindex),sumPPD(tPPDindex),freqrange);
[PD_filtered, f, y, y2] = fftf(timePD(tindex),photodiode(tindex),freqrange);

%%
figure
yyaxis left
plot(timecoil(tindex),Icoil_filtered)
ylabel('Coil Current')
xlim(timerange)
%ylim([-0.4 0.4])

yyaxis right
plot(timePD(tindex),PD_filtered)
ylabel('Photodiode Intensity')
xlim(timerange)
xlabel('Time')
grid minor
title(['Shot #' num2str(shot) '; Bandpass ' num2str(freqrange(1)/1000) '-' num2str(freqrange(2)/1000) 'kHz'])

figure
yyaxis left
plot(timecoil(tindex),Icoil_filtered)
ylabel('Coil Current')
xlim(timerange)
%ylim([-0.4 0.4])

yyaxis right
plot(timePPD(tPPDindex),PPD_filtered)
ylabel('PPD-Sum Intensity')
xlim(timerange)
xlabel('Time')
grid minor
title(['Shot #' num2str(shot) '; Bandpass ' num2str(freqrange(1)/1000) '-' num2str(freqrange(2)/1000) 'kHz'])

%% Single Photodiode intensity
[Idis_filtered, f, y, y2] = fftf(timecoil(tindex),Idis(tindex),[15 2000].*1e3);
[B_filtered, f, y, y2] = fftf(timecoil(tindex),7.7.*Icoil(tindex),[0 2000].*1e3);
[PPD_filtered, f, y, y2] = fftf(timePPD(tPPDindex),sumPPD(tPPDindex),[0 10000000].*1e3);

gap = [0 0];
marginw = [0.15 0.015];
marginh = [0.15 0.07];
minTime = 5e-3;
maxTime = inf;
fontsize = 10;

figure('Name',['Shot #' num2str(shot)],'units','inches', 'position',[10, 4, 6.37, 3]);

subtightplot(2,1,1,gap,marginh,marginw)
plot(timePD(tindex),photodiode(tindex))
ylabel('Photodiode (V)')
xlim(timerange)
ylim([ 0.22 0.41])
xlabel('Time (s)')
set(gca,'XTickLabel',[]);
grid on
title(['Shot #' num2str(shot)])
text(0.95,0.95,'(a)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)
set(gca,'fontsize',fontsize)

subtightplot(2,1,2,gap,marginh,marginw)
plot(timePPD(tPPDindex),PPD_filtered)
ylabel('PPD Array (V)')
xlim(timerange)
ylim([0.72 1.01])
xlabel('Time (s)')
grid on
text(0.95,0.95,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)
set(gca,'fontsize',fontsize)

%saveas(gca,'fig_burstyEmission.png')

% subtightplot(2,1,2,gap,marginh,marginw)
% plot(timecoil(tindex),B_filtered)
% ylabel('B (G)')
% xlim(timerange)
% ylim([0.89 0.94])
% xlabel('Time (s)')
% grid on

% subtightplot(2,1,2,gap,marginh,marginw)
% plot(timecoil(tindex),Idis_filtered)
% ylabel('I_p (kA)')
% xlim(timerange)
% ylim([0.65 0.85])
% xlabel('Time (s)')
% grid on

tightfig;

%%

%plot parameters
gap = [0 0];
marginw = [0.15 0.01];
marginh = [0.15 0.07];
minTime = 5e-3;
maxTime = inf;
fontsize = 10;

figure('Name',['Shot #' num2str(shot)],'units','inches', 'position',[14, 4, 3.37, 3]);
subtightplot(3,1,1,gap,marginh,marginw)
hold on 
plot(timecoil,7.7*Icoil,'Color', [0.4 0.1 0.5])
line([0 5e-3],[B_avg B_avg],'Color','black','LineStyle','-')
ylabel('B (G)');
set(gca,'XTickLabel',[]);
xlim([minTime maxTime])
ylim([-50 500])
title(['Shot #' num2str(shot)])
%legend('Magnetic field',['B_{avg} = ' num2str(B_avg) ' G'],'location','southeast')
grid on
text(0.01,0.95,'(a)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)

subtightplot(3,1,2,gap,marginh,marginw)
hold on 
plot(timecoil,Idis,'Color', [0.4 0.1 0.5])
ylabel('I_{dis} (kA)');  
set(gca,'XTickLabel',[]);
xlim([minTime maxTime])
ylim([-0.18 2])
grid on
text(0.01,0.95,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)

subtightplot(3,1,3,gap,marginh,marginw)
hold on 
plot(timecoil,Vdis,'Color', [0.4 0.1 0.5])
ylabel('V_{dis} (V)'); 
xlabel('Time (s)'); 
xlim([minTime maxTime])
ylim([-0.08 0.1])
grid on
text(0.01,0.95,'(c)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)

%
% clear all,
% 
% shot = 1170517084;
% filtering = 0.2;
% 
% % Plotting controls
% figure('Name',['Shot #' num2str(shot)],'units','inches', 'position',[14, 4, 3.37, 3]);
% gap = [0 0];
% marginw = [0.18 0.01];
% marginh = [0.15 0.015];
% tRange = [5 27]; % 6 to 26 ms
% fontsize = 10;
% legendPosition = 'southwest';
% beamSize = 1;
% 
% vRange = [18 42];
% vModeRange = [10 38];
% SXRRange = [0 2.2];
% torfluxRange = [0.65 0.9];
% Xtickspacing = 5;
% 
% smoothV = 0.03;
% smoothMode = 0.0004;
% smoothSXR = 0.0008;
% smoothtorflux = 0.0002;
% 
% % load data
% load(['data_' num2str(shot)])
% 
% %% plot toroidal flux change to indicate PPCD
% subtightplot(3,1,1,gap,marginh,marginw)
% 
% mdsconnect('dave.physics.wisc.edu');
% mdsopen('mst',shot);
% btave = mdsvalue('\mst_ops::btave');
% time_torflux = mdsvalue('dim_of(\mst_ops::btave)');
% 
% % Calculate flux with cross section area
% torflux = btave.* pi.*0.52.^2./1000;
% 
% plot(time_torflux.*1000,smooth(torflux,smoothtorflux),'-','Color', [0.4 0.1 0.5],'LineWidth',2);
% mdsclose;
% mdsdisconnect;
% 
% xlim([tRange(1) tRange(2)])
% ylim([torfluxRange(1) torfluxRange(2)])
% xlabel('Time (ms)')
% ylabel('{\phi}-Flux (Wb)')
% text(0.9,0.95,'(a)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)
% 
% set(gca,'XTickLabel',[]);
% set(gca,'fontsize',fontsize)
% ax = gca;
% ax.XGrid = 'on';
% ax.GridLineStyle = '-';
% 
% %% plot soft x-ray to indicate PPCD
% %figure('Position', [0, 0, 800, 720])
% subtightplot(3,1,2,gap,marginh,marginw)
% 
% mdsconnect('dave.physics.wisc.edu');
% mdsopen('mst',shot);
% sxr_be1 = mdsvalue('\mraw_ops::sxr_be1_l');
% time_sxr = mdsvalue('dim_of(\mraw_ops::sxr_be1_l)');
% 
% sxr_be1 = 10.^(-sxr_be1); % calibrates data
% 
% sxr = plot(time_sxr.*1000,smooth(sxr_be1,smoothSXR),'-','Color', [0 0.8 0],'LineWidth',2);
% mdsclose;
% mdsdisconnect;
% 
% xlim([tRange(1) tRange(2)])
% ylim([SXRRange(1) SXRRange(2)])
% xlabel('Time (ms)')
% ylabel('SXR')
% text(0.9,0.95,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)
% 
% set(gca,'XTickLabel',[]);
% set(gca,'fontsize',fontsize)
% ax = gca;
% ax.XGrid = 'on';
% ax.GridLineStyle = '-';
% %tightfig;
% 
% 
%     
% %% plot mode velocity
% subtightplot(3,1,3,gap,marginh,marginw)
% mdsconnect('dave.physics.wisc.edu');
%     mdsopen('mst',shot);
%         vMode = mdsvalue('\mst_mag::bp_n06_vel');
%         t1 = mdsvalue('dim_of(\mst_mag::bp_n06_vel)');        
%  mdsclose;
%  mdsdisconnect;
%  
% [vMode t1 vModeNeg] = modeSeparate(shot,6);
% %[vMode, vMode_error] = reshapeModeJA(vMode,t1,time, 0);
% 
% %[vMode, vMode_error] = reshapeModeJA(vel_bp_n06,t1,time, 0);
% mode = plot(t1.*1000,smooth(vMode,smoothMode),'LineWidth',2,'Color',[0.5 0.5 0.5]);
% 
% 
% xlabel('Time (ms)')
% ylabel('|V_{\phi}^{n=6}| (km/s)')
% text(0.91,0.95,'(c)','Units', 'Normalized', 'VerticalAlignment', 'Top','fontsize',fontsize)
% 
% 
% xlim([tRange(1) tRange(2)])
% ylim([vModeRange(1) vModeRange(2)])
% set(gca,'fontsize',fontsize)
% set(gca,'XTick',0:Xtickspacing:40);
% %set(gca,'XTickLabel',[]);
% ax = gca;
% ax.XGrid = 'on';
% ax.GridLineStyle = '-';
% %tightfig;
% 
