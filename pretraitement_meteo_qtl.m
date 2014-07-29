function annee_perturbee = pretraitement_meteo_qtl(N, freq, annee_cible, annee_source, manic, fig)

% % % PERTURBATION DES DONNEES METEO PAR QUANTILE % % %

%pour utilisation sans fonction :
%manic=2; N=50; freq='s'; annee_cible = 1960; annee_source=2014; fig=1;

%% INITIALISATION DES VARIABLES
profile on

tmin=cell(4,1); tmin{1}='tasmin'; tmin{2}=2; tmin{3}='additive'; tmin{4}='T_{min} [^oC]';
tmax=cell(4,1); tmax{1}='tasmax'; tmax{2}=3; tmax{3}='additive'; tmax{4}='T_{max} [^oC]';
pluie=cell(4,1); pluie{1}='pr'; pluie{2}=4; pluie{3}='multiplicative'; pluie{4}='Pluie [mm]';
neige=cell(4,1); neige{1}='pr'; neige{2}=5; neige{3}='multiplicative'; neige{4}='Neige [mm]';
type_meteo=cell(4,1);
type_meteo{1}=tmin; type_meteo{2}=tmax; type_meteo{3}=pluie; type_meteo{4}=neige;


dsf = 0;%cell(size(simu,1),1);
P = 0;%nan(size(simu,1),N);

if mod(annee_cible,4)==0 && mod(annee_cible,100)~=0,
    annee_perturbee=nan(366,4);
elseif mod(annee_cible,400)==0
    annee_perturbee=nan(366,4);
else annee_perturbee=nan(365,4);
end

%% CHARGEMENT DES DONNEES OBSERVEES
if manic==2, donnees_obs = load('/home/beaudin/matlab/Manic/meteo/meteo_Manic2.csv'); simu = ['meteo_2_1'; 'meteo_2_2'; 'meteo_2_3'; 'meteo_2_4'; 'meteo_2_5'];
elseif manic==5, donnees_obs = load('/home/beaudin/matlab/Manic/meteo/meteo_Manic5.csv'); simu = ['meteo_5_1'; 'meteo_5_2'; 'meteo_5_3'; 'meteo_5_4'; 'meteo_5_5'];
end
obs = struct();
obs.dates(:,[1 2 3 4 5 6]) = nan;
a = datenum({'01-Jan-1950 00:00:00';'31-Dec-2013 23:00:00'});
obs.dates = datevec(a(1):1:a(2));
ind_dates = find(obs.dates==annee_cible);
obs.dates = obs.dates(ind_dates,:);

out = nan(length(ind_dates),size(simu,1));

%% PERTURBATION DES DONNEES OBSERVEES
%   ET CHARGEMENT DES DONNEES DU MODELE


for i_meteo=1:4
    obs.data = donnees_obs(ind_dates,cell2mat(type_meteo{i_meteo}(2)));
    for i_simu = 1:size(simu,1);
        
        % Chargement et traitement des donnees du modele
        donnees_mod = load([simu(i_simu,:), '.mat']);
        ref.data = eval(sprintf('donnees_mod.model_data.ref.%s.data',cell2mat(type_meteo{i_meteo}(1))));
        ref.dates = eval('donnees_mod.model_data.ref.dates');
        fut.data = eval(sprintf('donnees_mod.model_data.fut.%s.data',cell2mat(type_meteo{i_meteo}(1))));
        fut.dates = eval('donnees_mod.model_data.fut.dates');
        type = cell2mat(type_meteo{i_meteo}(3));
        cap=Inf;
        
        [out(:,i_simu) dsf P] = downscaling_daily_scaling(obs, ref, fut, N, type, freq, cap, annee_source, annee_cible);
        
    end
    
    %% SECTION GRAPHIQUE
    if fig==1 && i_meteo==1
        colorb = colormap(cbrewer('qual','Set2',8)); if annee_cible==1950, close; end
        figure
        hold on, grid on, box on
        xlim([0 366])
        %datetick('x','mmm')
        %ylabel(y)
        set(gca,'fontsize',14)
        plot(obs.data,'linewidth',0.5,'color',[0.4020 0.4020 0.4020]);
        minout = min(out,[],2);
        maxout = max(out,[],2);
        jbfill([1:length(ind_dates)],[minout]',[maxout]',colorb(cell2mat(type_meteo{i_meteo}(2)),:),colorb(cell2mat(type_meteo{i_meteo}(2)),:));
        %figure
        %for i_simu=1:size(simu,1)
        %    plot(out(:,i_simu),'color',colorb(:,i_simu));
        %    plot([1:366]',minout,'.m',[1:366]',maxout,'.g')
        %    figure
        %    xlim([0 366])
        %end
        hold off
    end
    annee_perturbee(:,i_meteo) = mean(out,2);
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
