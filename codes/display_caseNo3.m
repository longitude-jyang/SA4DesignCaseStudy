% display_caseNo3

   % compare with experiment and find samples fit in the thereshold 
   nS_V = 1000 : 500 : Opts.nSampMC;

   N_nS = numel(nS_V);
   N_samp_OK = zeros(N_nS,N_stype);
   ysV = cell(N_nS,N_stype);
   index = cell(N_nS,N_stype);
   indexMin = zeros(N_nS,N_stype);
   deltaMin = zeros(N_nS,N_stype);

   epsilon = 10e-6 ; 
       
   for kk = 1 : N_nS

    for jj = 1 : N_stype

        delta = zeros(nS_V(kk),3);
        for ii =  1 : 3

            ytemp  = cellfun( @(a) a(ii,:), ySamp{jj}(1:nS_V(kk)), 'UniformOutput', 0);
            ys{ii} = cell2mat(ytemp);
            delta(:,ii)  = mean((abs(ys{ii} - mean(xamp{ii}))).^2,2); 
  
        end
        ysV{kk,jj} = ys; 
        index{kk,jj} = find (mean(delta,2) < epsilon);
        [deltaMin(kk,jj),indexMin(kk,jj)] = min (mean(delta,2));
        N_samp_OK(kk,jj) = numel(find (mean(delta,2) < epsilon));
    end
   end


 %%
 isExportFig = 0; 

 colorvec = [{[0.25 0.25 0.25]},{[0 0 0]}];
 fig1 = figure;

 b = plot(nS_V' , N_samp_OK,'k');

 b(1).Color = colorvec{1};
 b(1).LineStyle = '-'; 
 b(1).Marker = '+';

 b(2).Color = colorvec{2};
 b(2).Marker = 'o';

 b(3).Marker = '*';
 
 legend('All variables (15)','Most influential (2)','Least influential (2)',...
             'Interpreter','latex','FontSize',16,...
             'Location','northwest','box','off')
 xlabel('No. of total samples','Interpreter','latex')
 ylabel('No. of valid samples','Interpreter','latex')
 
%  ttl = title('Valid criteria: $${\textstyle\sum}_{f} [y_s(f) - y_m(f)]^2 \le \epsilon$$','Interpreter','latex','FontSize',16);

     set(gca,'TickLabelInterpreter','latex','FontSize',16)
     set(gca,'FontSize',16)

     figuresize(20, 10, 'centimeters');
     movegui(fig1, [50 20])
     set(gcf, 'Color', 'w');

    figName = strcat('caseNo3_NoSamp');
    exportFig(isExportFig,[],figName);    


 %%
 % get original simulation 
    Out = maincode (ModPar); 
    ix = zeros(1,3);
    for ii = 1 : 3
        xcoor = Out.xCoord;
        [~, ix(ii)] = min(abs(xcoor - xcoor(end)  + Opts.ytest(ii)));
    end

 %%
    %------------------------------------
    % plot comparision 
    fig2 = figure;
    tiledlayout(1,3,'TileSpacing','Compact','Padding','Compact');
    for ii = 1 : 3    

        % first plot the amplitdues 
%         subplot (1,3,ii)
        nexttile; 

        % for all variables 
%         y1temp = cellfun( @(a) a(index{N_nS,1},:), ysV{N_nS,1}(ii),'UniformOutput', 0); % average fit
        y1temp = cellfun( @(a) a(indexMin(N_nS,1),:), ysV{N_nS,1}(ii), 'UniformOutput', 0); % best fit 
        y1 = mean(cell2mat(y1temp),1); % mean value from valid samples 
        h1 = plot(f_v,y1,'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','+','MarkerSize',4);

        hold on 
        % for influential variables 
%         y2temp = cellfun( @(a) a(index{N_nS,2},:), ysV{N_nS,2}(ii), 'UniformOutput', 0);
        y2temp = cellfun( @(a) a(indexMin(N_nS,2),:), ysV{N_nS,2}(ii), 'UniformOutput', 0);
        y2 = mean(cell2mat(y2temp),1); % mean value from valid samples 
        h2 = plot(f_v,y2,'color',[0,0,0] + 0.1,'linewidth',0.5,...
            'LineStyle','-','Marker','o','MarkerSize',4);

        hm = plot(f_v,mean(xamp{ii}),'color','r','linewidth',1,'LineStyle','--');
        
        hs = plot(f_v,abs(Out.response.frf(ix(ii),:)),'color',[0,0,0] + 0.3);
        hold off
    
        ylim([0 0.05])
        if ii == 2
            ht = [h1;h2;hs;hm];
            legend(ht,["Sim-Updated(All)";"Sim-Updated(Influential)";"Simulated";"Measured";],...
                'Interpreter','latex','FontSize',14,...
             'Location','northeast','box','off')
        end

        title (['$$\xi_',num2str(ii-1),'$$',' - amp [m]'],...
            'Interpreter','latex')
        xlabel('Frequency [Hz]','Interpreter','latex')
        set(gca,'FontSize',14)
        set(gca,'TickLabelInterpreter','latex','FontSize',14)
        grid on
    end       
    
        figuresize(30, 10, 'centimeters');
        movegui(fig2, [50 20])
        set(gcf, 'Color', 'w');

        figName = strcat('caseNo3_update');
        exportFig(isExportFig,[],figName);    