% call_caseNo1.m conducts design diagnostic 

% the prerequisite: TEDS (https://github.com/longitude-jyang/TEDS-ToolboxEngineeringDesignSensitivity)

% 4/8/2022 @ Franklin Court, Cambridge  [J Yang] 

% -------------------------------------------------------------------------   
% options 
    Opts.nSampMC  = 2000;  % number of MC samples 
    Opts.Ny       = 50;     % length y vector for cdf and pdf estimation 
    Opts.funName  ='design_TCylinder';
    Opts.distType ='Normal'; 
    Opts.isNorm   = 1; 
    caseNo = 1;
% -------------------------------------------------------------------------
% input 
    varName=[{'\rho'},{'\rho_f'},{'L'},{'L_S'},{'L_b'},{'r'},{'t'},{'m_b'},{'C_a'}]';
    nVar = numel(varName);

    vNominal = [1180 1025 1 0.2 0.15 4.5e-2 1e-3 3 1].';
    CoV = 1/1e4 * ones(nVar,1);

    RandV.nVar = nVar;
    RandV.vNominal = vNominal;
    RandV.CoV = CoV;
   
% -------------------------------------------------------------------------
% call TEDS   
    [y,V_e,D_e,xS,ListPar] = call_TEDS(Opts,RandV,[],caseNo);

% -------------------------------------------------------------------------
% calculate deterministic sensitivity for the natural frequencies (analytical)
    [r1,r2] = design_TCylinder_OmSensitivity(vNominal);

% -------------------------------------------------------------------------
% display    
   figNo = 1;
   display_caseNo1(D_e,V_e,r1,r2,varName,1,figNo)