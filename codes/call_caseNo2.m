% call_caseNo2 for critical uncertainty identification

% 4/8/2022 @ Franklin Court, Cambridge  [J Yang] 

% the prerequisite: TEDS (https://github.com/longitude-jyang/TEDS-ToolboxEngineeringDesignSensitivity)
% the prerequisite: CHAOS (https://github.com/longitude-jyang/hydro-suite)

% -------------------------------------------------------------------------   
% options 
    Opts.nSampMC  = 5000;  % number of MC samples 
    Opts.Ny       = 50;     % length y vector for cdf and pdf estimation 
    Opts.funName  ='design_FWTtank';
    Opts.distType ='Normal'; 
    Opts.isNorm   = 1; 
    caseNo = 2;
    wavetype = 2; 

    Opts.ytest = [0.8 0.5 0.2]';  % measured positions 
    isF = 1;
% -------------------------------------------------------------------------
% input 

    % set up simulation paramters 
    ModPar = getModPar_FWTtank (); % get norminal values for all parameters  
    % overwrite some parameters

    if wavetype == 1
    % for harmonic wave 
        fwave = [0.5:0.1:1.1]; 
        ModPar.wavetype = 1;             % regular wave
        ModPar.calcType = 1;             % freq domain 
        ModPar.aw = 0.05/2;              % wave amplitude to match tank
        ModPar.om_range = (fwave)*2*pi;  

    elseif wavetype == 2
    % for random wave 
        ModPar.aw = 1;                   % wave amplitude = 1 for random wave 
        ModPar.wavetype = 2;             % random wave
        ModPar.calcType = 1;             % freq domain 
        ModPar.jonswapTz = 1.8539/2;     % wave peak frequency
    end

%     no base plate case 
    ModPar.delta = 0; % 

    % general set 
    varName_V = [...
                {'rho'},{'rho_f'}, {'d'},{'Ca'},{'Cd'},...
                {'Lcolumn'},{'mb'}, {'L_b'},{'mcap_top'},{'Lcap_top'},{'mcap_bottom'},{'Lcap_bottom'},...          
                {'Ltether'},{'r'},{'t'}, ...
                {'delta'}...   
                ];      
    
    var_select = [1:15];
    varName =  varName_V(var_select);

    LabelName_V = [{'\rho'},{'\rho_f'},{'d'},{'C_a'},{'C_d'},...
    {'L'},{'m_b'}, {'L_b'},{'m_{tc}'},{'L_{tc}'},{'m_{bc}'},{'L_{bc}'},...          
    {'L_s'},{'r'},{'t'},...
    {'\delta'}]';   
    LabelName =  LabelName_V(var_select);

    RandV.nVar = numel(varName);
    % first assign nominal values from ModPar; 
    RandV.vNominal = zeros(RandV.nVar,1); 
    for ii = 1 : RandV.nVar
        RandV.vNominal(ii) = ModPar.(varName{ii});
    end

    Opts.varName = varName; 
    Opts.ModPar  = ModPar ; 

   
% -------------------------------------------------------------------------
% call TEDS   

   coef = [1/100 1/10]; 
   for mm = 1 : 2
        % then assign CoV (same for all for screening task)
        RandV.CoV = coef(mm) * ones(RandV.nVar,1);
        [y,V_e,D_e,xS,ListPar] = call_TEDS(Opts,RandV,[],caseNo,isF);

        for ii = 1 : 15
           VV{ii} (:,mm)= V_e(:,ii);
        end
         
        DD{mm} = diag(D_e);
   end
   display_caseNo2(DD,VV,LabelName,0);
