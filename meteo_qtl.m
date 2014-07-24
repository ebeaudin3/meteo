% % % PERTURBATION DES DONNEES METEO PAR QUANTILE % % %
function [donnees_perturbees p] = meteo_qtl(type_meteo, N, freq, cap, annee_source, fig)

profile on

switch lower(type_meteo)
    case 'tmin', type_meteo='tasmin'; tm=2; type = 'additive'; y = 'T_{min} [^oC]';
    case 'tmax', type_meteo='tasmax'; tm=3; type = 'additive'; y = 'T_{max} [^oC]';
    case 'pluie', type_meteo = 'pr'; tm=4; type = 'multiplicative'; y = 'Pluie [mm]';
    case 'neige', type_meteo = 'pr'; tm=5; type = 'multiplicative'; y = 'Neige [mm]';
end

%% INITIALISATION DES VARIABLES
simu = ['meteo_2_1'; 'meteo_2_2'; 'meteo_2_3'; 'meteo_2_4'; 'meteo_2_5'];
%simu = ['meteo_5_1'; 'meteo_5_2'; 'meteo_5_3'; 'meteo_5_4'; 'meteo_5_5'];

h = waitbar(0,'Perturbation par quantiles');

for annee_cible = 1950:1:2013;
    
    waitbar((annee_cible-1949)/(2013-1949),h)
    
    dsf = 0;%cell(size(simu,1),1);
    P = 0;%nan(size(simu,1),N);
    
    %% CHARGEMENT DES DONNEES OBSERVEES
    donnees_obs = load('meteo_Manic2.csv');
       if annee_cible==1950, donnees_perturbees = nan(length(donnees_obs),size(simu,1)); end   
    obs = struct();
    obs.dates(:,[1 2 3 4 5 6]) = nan;
    a = datenum({'01-Jan-1950 00:00:00';'31-Dec-2013 23:00:00'});
    obs.dates = datevec(a(1):1:a(2));
    ind_dates = find(obs.dates==annee_cible);
    obs.dates = obs.dates(ind_dates,:);
    obs.data = donnees_obs(ind_dates,tm);
    out = nan(length(ind_dates),size(simu,1));
    
    %% PERTURBATION DES DONNEES OBSERVEES
    %   ET CHARGEMENT DES DONNEES DU MODELE
    
    for i_simu = 1:size(simu,1);
        
        % Chargement et traitement des donnees du modele
        donnees_mod = load([simu(i_simu,:), '.mat']);
        ref.data = eval(sprintf('donnees_mod.model_data.ref.%s.data',type_meteo));
        ref.dates = eval('donnees_mod.model_data.ref.dates');
        fut.data = eval(sprintf('donnees_mod.model_data.fut.%s.data',type_meteo));
        fut.dates = eval('donnees_mod.model_data.fut.dates');
        
        [out(:,i_simu), dsf P] = downscaling_daily_scaling(obs, ref, fut, N, type, freq, cap, annee_source, annee_cible);
         
    end
    
    donnees_perturbees(ind_dates,:)=out;
    
    %% SECTION GRAPHIQUE
    if fig==1
        colorb = colormap(cbrewer('qual','Set2',8)); if annee_cible==1950, close; end
        figure
        hold on, grid on, box on
        xlim([0 366])
        %datetick('x','mmm')
        ylabel(y)
        set(gca,'fontsize',14)
        plot(obs.data,'linewidth',0.5,'color',[0.4020 0.4020 0.4020]);
        minout = min(out,[],2);
        maxout = max(out,[],2);
        jbfill([1:length(ind_dates)],[min(out,[],2)]',[max(out,[],2)]',colorb(tm,:),colorb(tm,:));
        %figure
        %for i_simu=1:size(simu,1)
        %    plot(out(:,i_simu),'color',colorb(:,i_simu));
        %    plot([1:366]',minout,'.m',[1:366]',maxout,'.g')
        %    figure
        %    xlim([0 366])
        %end
    end
    
end

close(h);

%% SECTION PROFILER
p=profile('info');
profile off

time=zeros(size(p.FunctionTable,1),2);
time = num2cell(time);
for t=1:size(p.FunctionTable,1)
    time(t,1) = char2cell(eval(sprintf('p.FunctionTable(%g,1).FunctionName',t)));
    time(t,2) = num2cell(eval(sprintf('p.FunctionTable(%g,1).TotalTime',t)));
end
time = sortrows(time,2);