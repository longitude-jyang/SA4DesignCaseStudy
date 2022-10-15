% call_SimExCompare compares the simulation and measurement, with and
% without the offset at the base plate 

% 4/8/2022 @ Franklin Court, Cambridge  [J Yang] 

% the prerequisite: TEDS (https://github.com/longitude-jyang/TEDS-ToolboxEngineeringDesignSensitivity)
% the prerequisite: CHAOS (https://github.com/longitude-jyang/hydro-suite)

 disp('                                                            ')
 disp(' --- Solving The Equations --- ')
 disp(' Analysis Starts: ...')
 tic;  

 ModPar = getModPar_FWTtank () ; 

    % for harmonic wave 
    ModPar.aw = 0.05/2;              % wave amplitude to match tank for harmonic wave
    ModPar.wavetype = 1;             % regular wave
    ModPar.calcType = 1;             % freq domain 

    f_v = [0.50 0.55 0.60 0.65 0.70 0.72 0.74 0.76 0.78 0.79 0.80 ...
            0.81 0.82 0.84 0.86 0.88 0.90 0.95 1 1.05 1.10];  % vector of frequency tested 
    ModPar.om_range = f_v * 2 *pi;  % use samve frequency vector as experiment 

 ii = 0;   
 for delta = [0 0.06]   

     ii = ii + 1;
     ModPar.delta = delta;
     %---------------------------------------------------------------------
     Out{ii} = maincode (ModPar);    
     %---------------------------------------------------------------------
     
 end
 elapseTime = floor(toc*100)/100; 
 disp(strcat('Analysis Completed: ',num2str(elapseTime),'[s]'))

 %%
 %  experiment data  
    load('HarWaveAmp.mat');

    xamp {1} = x0amp/1e3; 
    xamp {2} = x1amp/1e3; 
    xamp {3} = x2amp/1e3; 

    xphase = Hx_phase; 

 %%
xtest = [0.8 0.5 0.2];  % measured positions 
ix = zeros(1,3);
for ii = 1 : 3
    xcoor = Out{1}.xCoord;
    [~, ix(ii)] = min(abs(xcoor - xcoor(end)  + xtest(ii)));

end

 % plot comparision 

    fig1 = figure;
    tiledlayout(2,3,'TileSpacing','Compact','Padding','Compact');
    for ii = 1 : 3    

        % first plot the amplitdues 
        nexttile (ii);

        h1 = plot(f_v,abs(Out{1}.response.frf(ix(ii),:)),'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','+','MarkerSize',4);
        hold on ; 
        
        h2 = plot(f_v,abs(Out{2}.response.frf(ix(ii),:)),'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','o','MarkerSize',4);
        hm = errorbar(f_v,mean(xamp{ii}),std(xamp{ii}),'color','r','linewidth',1,'LineStyle','--');

        hold off
    
        if ii == 1
            ht = [h1;h2;hm];
            legend(ht,["Simulated (w/o offset)"; "Simulated (with offset)"; "Measured"],...
                'Interpreter','latex','FontSize',14,...
             'Location','northeast','box','off')
        end

        title (['$$\xi_',num2str(ii-1),'$$',' - amp [m]'],...
            'Interpreter','latex')
        set(gca,'FontSize',14)
        set(gca,'TickLabelInterpreter','latex','FontSize',14)
        grid on

     % then plot the phase
        nexttile(ii + 3);

        h1 = plot(f_v,angle(Out{1}.response.frf(ix(ii),:)),'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','+','MarkerSize',4);
        hold on;

        h2 = plot(f_v,angle(Out{2}.response.frf(ix(ii),:)),'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','o','MarkerSize',4);
        hm = plot (f_v,Hx_phase(ii,:),'color','r','linewidth',1,'LineStyle','--'); 

        hold off

%         ylim([-pi pi])

        xlabel('Frequency [Hz]','Interpreter','latex')
        title (['$$\xi_',num2str(ii-1),'$$',' - phase [rad]'],...
            'Interpreter','latex')
        set(gca,'FontSize',14)
        set(gca,'TickLabelInterpreter','latex','FontSize',14)

        grid on
    end    

        figuresize(32, 16, 'centimeters');
        movegui(fig1, [50 20])
        set(gcf, 'Color', 'w');

         isExportFig = 1; 

        figName = strcat('SimExCompare');
        exportFig(isExportFig,[],figName);    