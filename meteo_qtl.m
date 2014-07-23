% % % PERTURBATION DES DONNEES METEO PAR QUANTILE % % %
tic

fig=1;

%% CHOIX DES DONNEES
annee_cible = 1950;
annee_source = 2014;

type_meteo = 'tmin';
switch lower(type_meteo)
    case 'tmin', type_meteo='tasmin'; tm=2; type = 'additive'; y = 'T_{min} [^oC]';
    case 'tmax', type_meteo='tasmax'; tm=3; type = 'additive'; y = 'T_{max} [^oC]';
    case 'pluie', type_meteo = 'pr'; tm=4; type = 'multiplicative'; y = 'Pluie [mm]';
    case 'neige', type_meteo = 'pr'; tm=5; type = 'multiplicative'; y = 'Neige [mm]';
end

N = 50; % nb de quantiles par mois/saison/annee
freq = 's'; % 's'=saison, 'm'=mois, 'y'=annee
cap = inf; % borne superieure 

profile on

%% INITIALISATION DES VARIABLES
simu = ['meteo_2_1'; 'meteo_2_2'; 'meteo_2_3'; 'meteo_2_4'; 'meteo_2_5'];
%simu = ['meteo_5_1'; 'meteo_5_2'; 'meteo_5_3'; 'meteo_5_4'; 'meteo_5_5'];

out = nan(366,size(simu,1));
dsf = 0;%cell(size(simu,1),1);
P = nan(size(simu,1),N);

%% CHARGEMENT DES DONNEES OBSERVEES
donnees_obs = load('meteo_Manic2.csv');
obs = struct();
obs.dates(:,[1 2 3 4 5 6]) = nan;
a = datenum({'01-Jan-1950 00:00:00';'31-Dec-2013 23:00:00'});
obs.dates = datevec(a(1):1:a(2));
ind_dates = find(obs.dates==annee_cible);
obs.dates = obs.dates(ind_dates,:);
obs.data = donnees_obs(ind_dates,tm);
if length(ind_dates)==365,
    obs.dates=insertrow(obs.dates,[annee_cible 02 29 0 0 0],59);
    obs.data=insertrow(obs.data,(obs.data(59)+obs.data(60))/2,59);
end

%% PERTURBATION DES DONNEES OBSERVEES 
%   ET CHARGEMENT DES DONNEES DU MODELE

for i_simu = 1:size(simu,1);

    % Chargement et traitement des donnees du modele
    donnees_mod = load([simu(i_simu,:), '.mat']);
    ref.data = eval(sprintf('donnees_mod.model_data.ref.%s.data',type_meteo));
    ref.dates = eval('donnees_mod.model_data.ref.dates');
    fut.data = eval(sprintf('donnees_mod.model_data.fut.%s.data',type_meteo));
    fut.dates = eval('donnees_mod.model_data.fut.dates');
    
    [out(:,i_simu), dsf P(i_simu,:)] = downscaling_daily_scaling(obs, ref, fut, N, type, freq, cap, annee_source, annee_cible);


end

%% SECTION GRAPHIQUE
if fig==1
    colorb = colormap(cbrewer('qual','Set2',8)); close;
    figure
    hold on, grid on, box on
    xlim([0 366])
    %datetick('x','mmm')
    ylabel(y)
    set(gca,'fontsize',14)
    plot(obs.data,'linewidth',0.5,'color',[0.4020 0.4020 0.4020]);
    minout = min(out,[],2);
    maxout = max(out,[],2);
    jbfill([1:366],[min(out,[],2)]',[max(out,[],2)]',colorb(tm,:),colorb(tm,:));
    %figure
    %for i_simu=1:size(simu,1)
    %    plot(out(:,i_simu),'color',colorb(:,i_simu));
    %    plot([1:366]',minout,'.m',[1:366]',maxout,'.g')
    %    figure
    %    xlim([0 366])
    %end 
end


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
    
  
toc    