function yout = design_TCylinder(xS,~)


    if  any(xS <= 0) 
        omn=[NaN ; NaN];
    else
    

    %% Tethered Floating Cylinder Design
    %% 
    % % 
    % We are proposing a simple tethered floating cylinder as shown in the figure 
    % below. It consisits of a single uniform cylinder and a vertical string below. 
    % There are nine design variables out of which seven can be varied. 
    % 
    % % 
    % The values for the variables can be adjusted here, to investigate corresponding 
    % natural frequencies of the system. The optimal frequency for the wave tank under 
    % consideration is 0.8 Hz for design waves. 

    % assign the values using the options below 
    rho     = xS(1);
    rho_f   = xS(2);
    L       = xS(3);
    L_S     = xS(4);
    L_b     = xS(5);
    r       = xS(6);
    t       = xS(7);
    mb      = xS(8);
    Ca      = xS(9);
    %% 1 Design
    % 1.1 Design variables 

    % assigne the values to a struct and run the eigen analysis to get natural
    % freuqencies 
    var_Name=[{'rho'},{'rho_f'},{'L'},{'L_S'},{'L_b'},{'r'},{'t'},{'mb'},{'Ca'}]';
    Nvar=numel(var_Name);
    for ii=1:Nvar
        var=['var' num2str(ii)];  
        varValue=eval(var_Name{ii});
        Svar.(var)=varValue; % assign the values to Svar 
    end
    [omn,V1,V2,para,tank]=cal_eig(Svar);%call the function for eig analysis


    yout.y = omn.';  % this is for Fisher 
    yout.ys = omn.';    % this is all results 
    % sprintf('Natural frequencies are %g and %g [%s].',round((omn/2/pi)*100)/100,'Hz')
    % set(gcf,'Visible','on')
    % plot_modes(V1,V2,omn,L,L_S,tank.d);
    end
end



