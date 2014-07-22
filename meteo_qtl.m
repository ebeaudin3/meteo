profile on



simu = ['meteo_2_1'; 'meteo_2_2'; 'meteo_2_3'; 'meteo_2_4'; 'meteo_2_5'];
%simu = ['meteo_5_1'; 'meteo_5_2'; 'meteo_5_3'; 'meteo_5_4'; 'meteo_5_5'];

type_meteo = 'tmin';
switch lower(type_meteo)
    case 'tmin', type_meteo='tasmin'; tm=2; type = 'additive';
    case 'tmax', type_meteo='tasmax'; tm=3; type = 'additive';
    case 'pluie', type_meteo = 'pr'; tm=4; type = 'multiplicative';
    case 'neige', type_meteo = 'pr'; tm=5; type = 'multiplicative';
end


annee_cible = 1950;
annee_source = 2070;

% Chargement et traitement des donnees observees
donnees_obs = load('meteo_Manic2.csv');
obs = struct();
obs.dates(:,[1 2 3 4 5 6]) = nan;
a = datenum({'01-Jan-1950 00:00:00';'31-Dec-2013 23:00:00'});
obs.dates = datevec(a(1):1:a(2));
ind_dates = find(obs.dates==annee_cible);
obs.dates = obs.dates(ind_dates,:);
obs.data = donnees_obs(ind_dates,tm);

N = 10;
freq = 's';
i_simu = 1;
cap = inf;

    % Chargement et traitement des donnees du modele
    donnees_mod = load([simu(i_simu,:), '.mat']);
    ref.data = eval(sprintf('donnees_mod.model_data.ref.%s.data',type_meteo));
    ref.dates = eval('donnees_mod.model_data.ref.dates');
        %ref_yr = eval('donnees.model_data.ref.dates');
    fut.data = eval(sprintf('donnees_mod.model_data.fut.%s.data',type_meteo));
    fut.dates = eval('donnees_mod.model_data.fut.dates');
        %fut_yr = eval('donnees.model_data.fut.dates');
    
    [out, dsf, P] = downscaling_daily_scaling(obs, ref, fut, N, type, freq, cap, annee_source, annee_cible);

p=profile('info');
profile off  

hold on, grid on, box on
xlim([0 366])
plot(obs.data,'-b'); 
plot(out.data,'-r');

time=zeros(size(p.FunctionTable,1),2);
time(:,1)=1:size(p.FunctionTable,1);
for t=1:size(p.FunctionTable,1)
    time(t,2) = eval(sprintf('p.FunctionTable(%g,1).TotalTime',t));
end
time = sortrows(time,2);
    
  
    