function [y,V_e,D_e,xS,ListPar] = call_TEDS(Opts,RandV,yExLevel,caseNo,isF)

isNorm = Opts.isNorm; % normalisation options 

% -------------------------------------------------------------------------
% generate random samples 

    [ListPar,parJ] = parList(Opts,RandV,isNorm);
    [nPar, ~] = size(ListPar);                                  % get size
    nS = Opts.nSampMC;                                          % No. of samples
    [xS,ListPar,ParSen] = parSampling (ListPar, nPar,nS);    

% -------------------------------------------------------------------------
% with the generated random samples, evaluate the blackbox function h 

     disp('Monte Carlo Analysis Starts: ...')
     tic;  
     
        h_Results = cal_h (xS, Opts);
        y = h_Results.y;    
        
     elapseTime = floor(toc*100)/100; 
     disp(strcat('Analysis Completed: ',num2str(elapseTime),'[s]'))   

% -------------------------------------------------------------------------
% with y, post process for FIM 
% first estimate the pdf of y and then form F matrix     
   [~,N_QoI] = size(y); % Ns is number of samples


   if caseNo == 1

       V_e=zeros(nPar*2,nPar*2,N_QoI);
       D_e=zeros(nPar*2,nPar*2,N_QoI);
    
         for ii = 1:N_QoI
             yjpdf = cal_jpdf_hist (y(:,ii),xS,Opts.Ny);

             % compute fisher matrix (raw)
             Fraw = cal_jFisher (yjpdf,nPar);
             Fraw = Fraw(1:nPar*2,1:nPar*2);  % 3rd/4th parameters are not implemented
             % re-parameterization and normalization  - transformation 
             Fn = parTran(Fraw, ListPar,parJ,isNorm) ;
             [V_e_t,D_e_t] = eig(Fn); 
             lambda = diag(D_e_t);
             [EigSorter,EigIndex] = sort(lambda,'descend');
             V_e_t = V_e_t(:,EigIndex);
             lambda = lambda(EigIndex);
             D_e_t = diag(lambda);
             
             V_e(:,:,ii) = V_e_t;
             D_e(:,:,ii) = D_e_t; 
         end 

    else
        if isF == 1
         disp('Estimating Fisher: ...')
         tic;   
         
             yF = y;
             yjpdf = cal_jpdf_hist (yF,xS,Opts.Ny);
    
             % compute fisher matrix (raw)
             Fraw = cal_jFisher (yjpdf,nPar);
             Fraw = Fraw(1:nPar*2,1:nPar*2);  % 3rd/4th parameters are not implemented     
    
         elapseTime = floor(toc*100)/100; 
         disp(strcat('Fisher EigenAnalysis Completed: ',num2str(elapseTime),'[s]'))
    
    % ------------------------------------------------------------------------- 
         % eigen analysis 
         % re-parameterization and normalization  - transformation 
         Fn = parTran(Fraw, ListPar,parJ,isNorm) ;
    
         [V_e,D_e] = eig(Fn); 
         lambda = diag(D_e);
         [EigSorter,EigIndex] = sort(lambda,'descend');
         V_e = V_e(:,EigIndex);
         lambda = lambda(EigIndex);
         D_e = diag(lambda);
    
        else
    
            V_e = ones(nPar*2,nPar*2);
            D_e = diag(ones(nPar*2,1));
    
        end
    end
% -------------------------------------------------------------------------    
% compute failure probablity and its sensitivity
    if isempty(yExLevel) ~= 1

    else
          PfSen_v_norm = [];
    end
    