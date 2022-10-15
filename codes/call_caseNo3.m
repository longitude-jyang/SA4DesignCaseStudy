% call_caseNo3 for focused updating

% 4/8/2022 @ Franklin Court, Cambridge  [J Yang] 

% the prerequisite: TEDS (https://github.com/longitude-jyang/TEDS-ToolboxEngineeringDesignSensitivity)
% the prerequisite: CHAOS (https://github.com/longitude-jyang/hydro-suite)

% bring in measure data 
    load('HarWaveAmp.mat','f_v','x0amp','x1amp','x2amp');
   
    % get mean value at each frequqnecy for all three positions 
    x0m = mean(x0amp);x1m = mean(x1amp);x2m = mean(x2amp); % all row vectors 
    ym = [x0m.'  x1m.'  x2m.'];

    Opts.ym = ym*1e-3; % convert to m 
    xamp {1} = x0amp*1e-3; % convert to m 
    xamp {2} = x1amp*1e-3; 
    xamp {3} = x2amp*1e-3; 
% -------------------------------------------------------------------------   
% options 
    Opts.nSampMC  = 5000;  % number of MC samples 
    Opts.funName  ='design_FWTtank';

    % distribution type, note that TEDS cannot use uniform distribution as input, 
    % so the sampling for uniform type is conducted separately if chosen
    disType = 1; 
    if disType == 1
        Opts.distType ='Normal'; 
    elseif disType == 2
        Opts.distType ='uniform';
    end

    caseNo = 3;
    wavetype = 1; 


    Opts.ytest = [0.8 0.5 0.2]';  % measured positions 
    isF = 1;
% -------------------------------------------------------------------------
% input 

    % set up simulation paramters 
    ModPar = getModPar_FWTtank (); % get norminal values for all parameters  
    % overwrite some parameters

    if wavetype == 1
    % for harmonic wave 
        fwave = f_v; 
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


    % general set 
    varName_V = [...
                {'rho'},{'rho_f'}, {'d'},{'Ca'},{'Cd'},...
                {'Lcolumn'},{'mb'}, {'L_b'},{'mcap_top'},{'Lcap_top'},{'mcap_bottom'},{'Lcap_bottom'},...          
                {'Ltether'},{'r'},{'t'}, ...
                {'delta'}...   
                ];      

    LabelName_V = [{'\rho'},{'\rho_f'},{'d'},{'C_a'},{'C_d'},...
    {'L'},{'m_b'}, {'L_b'},{'m_{tc}'},{'L_{tc}'},{'m_{bc}'},{'L_{bc}'},...          
    {'L_s'},{'r'},{'t'},...
    {'\delta'}]';   


    s_type = [{[1:15]}, {[3 14]}, {[5 12]}];
    N_stype = numel(s_type);

    ySamp = cell(N_stype,1);
    % loop over different scenarios 
    for ss = 1 : N_stype
    
        var_select = s_type{ss};
        varName =  varName_V(var_select);
        LabelName =  LabelName_V(var_select);
    
        RandV.nVar = numel(varName);
    
        % first assign nominal values from ModPar; 
        RandV.vNominal = zeros(RandV.nVar,1); 
        for ii = 1 : RandV.nVar
            RandV.vNominal(ii) = ModPar.(varName{ii});
        end
        RandV.CoV = 1/10 * ones(RandV.nVar,1);
    
        Opts.varName = varName; 
        Opts.ModPar  = ModPar ; 
    
        % -------------------------------------------------------------------------
        % generate random samples 
    
        switch disType

            case 1  % for Guassian distribution, use TEDS for sampling 
                [ListPar,parJ] = parList(Opts,RandV,Opts.isNorm);
                [nPar, ~] = size(ListPar);                                  % get size
                nS = Opts.nSampMC;                                          % No. of samples             
                [xS,ListPar,ParSen] = parSampling (ListPar, nPar,nS);    
    
            case 2  
                nS = Opts.nSampMC;                                          % No. of samples
                nPar = numel(var_select);
                
                dist='Uniform';
                aa = RandV.vNominal*0.8;
                bb = RandV.vNominal*1.2;
                
                xS.samp=zeros(nS,nPar);
                for ii=1:nPar
                    samp= random(dist, aa(ii),bb(ii), [1 nS]);   
                    xS.samp(:,ii) = samp.';
                end
        end
        % -------------------------------------------------------------------------
        % with the generated random samples, evaluate the blackbox function h 
    
         disp('Monte Carlo Analysis Starts: ...')
         tic;  
         
            h_Results = cal_h (xS, Opts);
            ySamp{ss} = h_Results.ys;
    
         elapseTime = floor(toc*100)/100; 
         disp(strcat('Analysis Completed: ',num2str(elapseTime),'[s]'))   
    end


   