% plot_mode plots the mode shape, with box shapes, for the floating column
% case study 

% assign the values using the options below 
xS = [1180 1025 1 0.2 0.15 4.5e-2 3.5e-3 3 1].';
rho     = xS(1);
rho_f   = xS(2);
L       = xS(3);
L_S     = xS(4);
L_b     = xS(5);
r       = xS(6);
t       = xS(7);
mb      = xS(8);
Ca      = xS(9);


% assigne the values to a struct and run the eigen analysis to get natural
% freuqencies 
var_Name=[{'rho'},{'rho_f'},{'L'},{'L_S'},{'L_b'},{'r'},{'t'},{'mb'},{'Ca'}]';
Nvar=numel(var_Name);
for ii=1:Nvar
    var=['var' num2str(ii)];  
    varValue=eval(var_Name{ii});
    Svar.(var)=varValue; % assign the values to Svar 
end

% call the function for eig analysis
[omn,V1,V2,para,tank]=cal_eig(Svar);

% plot mode shape
omn = round((omn)*100)/100;

% plot parameters
   xlimL = -0.5;  % xlim lower
   xlimH = 0.5;    % xlim higher

   % cylinder geometry
   a = 0.045; % radius 
   L  = 1;
   Ls = 0.2; 

   box_X = [-a 0 a a 0 -a -a];
   box_Y = [0 0 0 L L L 0] + Ls;
   box_coor = [box_X; box_Y];

fig1 = figure;   
for jj = 1 : 2
        
    subplot(1,2,jj)
        

    % plot stationary backbone 
    plot(box_X,box_Y,'Color','black','LineStyle',':','LineWidth',1)
    hold on 
    plot([0  0] ,[0 Ls],'black','LineStyle',':','LineWidth',1); 

    % normalise the mode shape 
    if jj==1
        V=V1/2;
    elseif jj==2
        V=V2/5;
    end    
    Vm = V;

    theta1 = Vm(1);
    theta2 = Vm(2);
        
    deltax = Ls*sin(theta1); 
    R = [cos(theta2) sin(theta2);...
        -sin(theta2) cos(theta2)]; % rotation matrix 
    box_coor_2 = R*(box_coor  - [0; Ls] ) + [deltax;Ls]; % rotation plus translation at the tether point
    
    b1 = plot(box_coor_2(1,:),box_coor_2(2,:),'Color',[0,0,0] + 0.1,'LineStyle','-','LineWidth',1.5);
    b2 = plot([0  deltax] ,[0 Ls],'Color',[0,0,0] + 0.1,'LineWidth',1.5); 
    
    title(['Mode ' num2str(jj) ': ','$$', 'f_',num2str(jj), '$$','=' num2str(round(omn(jj)/2/pi*1e2)/1e2) ' [Hz]'],...
            'Interpreter','latex','FontSize',14)
    xlabel('Arbitrary Amplitude','Interpreter','latex','FontSize',16)  
    ylabel('Coordinate [m]','Interpreter','latex','FontSize',16) 
    set(gca,'TickLabelInterpreter','latex','FontSize',16)
    xlim([xlimL xlimH])
    ylim([0 1.4])
         
end

isExportFig = 1;

        figuresize(20, 14, 'centimeters');
        movegui(fig1, [50 20])
        set(gcf, 'Color', 'w');

        figName = strcat('modeshape');
        exportFig(isExportFig,[],figName);    
 
