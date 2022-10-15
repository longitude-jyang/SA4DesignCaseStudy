function display_caseNo2(DD,VV,varName,isExportFig)

 
nPar = numel(varName);

for ii = 1 : numel(varName)
    LabelName{ii,1} = strcat('$$',varName{ii},'$$');
end

colorvec = [{[0.75 0.75 0.75]},{[0 0 0]}];
titleNo = [{'(a)'},{'(b)'},{'(c)'}];

fig1 = figure;

t = tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact');

%      VV{ii}(:,2) = - VV{ii}(:,2); 
for ii = 1 : 3
     nexttile; 

     b = bar([1:2*nPar]',VV{ii},'FaceColor','Flat');          % just 1st eigenvector
     b(1).FaceColor = colorvec{1};
     b(2).FaceColor = colorvec{2};

     b(2).CData(1,:) = [0.2 0.6 0.5];

     if  ii == 3
        set(gca,'xtick',[round(nPar/2) nPar+round(nPar/2)],'xticklabel',[{'Mean'},{'Std Dev'}],...
         'TickLabelInterpreter','latex','FontSize',16);
%      set(gca,'xtick',[round(nPar/2)],'xticklabel',[{'Mean Value'}],...
%          'TickLabelInterpreter','latex','FontSize',18);
     else 
         set(gca,'xtick',[],'TickLabelInterpreter','latex','FontSize',16);
     end

     xtips = b.XData;
     y1 = b(1).YData;
     y2 = b(2).YData;
     ytips = y1;
     ytips (y2 > y1) = y2(y2 > y1);
     ytips = ytips.*double(ytips>0);
     labels = [LabelName;LabelName];
%           labels = [LabelName];
     text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','Interpreter','latex','FontSize',14);

     if ii == 1 
         legend('Small CoV','Large CoV',...
             'Interpreter','latex','FontSize',16,...
             'Location','southeast','box','off')
     end
          
     ylim([-1 1])

    ttlName = strcat(titleNo{ii},'{ }','No.', num2str(ii) ,' Fisher EigVector ');
    ttl = title(ttlName,'Interpreter','latex','FontSize',16);
    ttl.Units = 'Normalize'; 
    ttl.Position = [0.85 0.8 0];
    ttl.EdgeColor= 'k';
%     ttl.Position(1) = 0; % use negative values (ie, -0.1) to move further left
%     ttl.HorizontalAlignment = 'left';  
   

end

        figuresize(28, 16, 'centimeters');
        movegui(fig1, [50 20])
        set(gcf, 'Color', 'w');

        figName = strcat('caseNo2');
        exportFig(isExportFig,[],figName);

 %-----------------------------------------------
 % plot eigenvalues 
 
 D1 = DD{1};  D2 = DD{2}; 
 DDn = [D1/max(D1) D2/max(D2)];
 nDD = numel(D1); 
 fig2 = figure;

     b = bar([1:nDD]',DDn,'FaceColor','Flat');          % just 1st eigenvector
     b(1).FaceColor = colorvec{1};
     b(2).FaceColor = colorvec{2};

     b(2).CData(1,:) = [0.2 0.6 0.5];
     
     ylim([0 1.2])
     legend('Small CoV','Large CoV',...
             'Interpreter','latex','FontSize',16,...
             'Location','northeast','box','off')

     xlabel('Index of Fisher EigValues','Interpreter','latex')
     ylabel('Normalised amplitdue','Interpreter','latex')

%     ttl = title('Fisher Eigenvalues','Interpreter','latex','FontSize',18);
%     ttl.Units = 'Normalize'; 
%     ttl.Position(1) = 0; % use negative values (ie, -0.1) to move further left
%     ttl.HorizontalAlignment = 'left';  

     set(gca,'TickLabelInterpreter','latex','FontSize',16)
     set(gca,'FontSize',16)
        
     
        figuresize(20, 8, 'centimeters');
        movegui(fig2, [50 20])
        set(gcf, 'Color', 'w');

        figName = strcat('caseNo2_eig');
        exportFig(isExportFig,[],figName);
 