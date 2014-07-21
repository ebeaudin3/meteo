simu = ['meteo_2_1'; 'meteo_2_2'; 'meteo_2_3'; 'meteo_2_4'; 'meteo_2_5'];
%simu = ['meteo_5_1'; 'meteo_5_2'; 'meteo_5_3'; 'meteo_5_4'; 'meteo_5_5'];

%type_meteo = 'tmin';
switch lower(type_meteo)
    case 'tmin', type_meteo='tasmin'; type = 'additive';
    case 'tmax', type_meteo='tasmax'; type = 'additive';
    case {'pluie','neige'}, type_meteo = 'pr'; type = 'multiplicative';
end

an = 1950;
obs = METEO(:,an-1949);

N = 10;
freq = 'y';

for i_simu=1:1
    % Chargement des donnees
    donnees = load([simu(i_simu,:), '.mat']);
    % Traitement des donnees
    ref = eval(sprintf('donnees.model_data.ref.%s.data',type_meteo));
    ref_yr = eval('donnees.model_data.ref.dates');
    fut = eval(sprintf('donnees.model_data.fut.%s.data',type_meteo));
    fut_yr = eval('donnees.model_data.fut.dates');
    
    [out, dsf, P] = downscaling_daily_scaling(obs, ref, fut, N, type, freq)
end

