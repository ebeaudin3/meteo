%%% METEO : Tmin, Tmax, Pluie, Neige

% Initialisation des variables
mois = 1;
fenetre = 21;
manic = 2;
type_meteo = 'tmin';        % 'tmin', 'tmax', 'pluie', 'neige'
switch lower(type_meteo)
    case 'tmin', m=2; y = 'T min [^oC]';
    case 'tmax', m=3; y = 'T max [^oC]';
    case 'pluie', m=4; y = 'Pluie [mm]';
    case 'neige', m=5; y = 'Neige [mm]';
end
start_year = [1950:2013]';
n = length(start_year);
end_year = start_year - 1 + 1;
if manic==2; colorb = colormap(cbrewer('seq', 'Reds', n));
elseif manic==5; colorb = colormap(cbrewer('seq', 'Blues', n));
end
%colorb = [0.2157 0.4941 0.7216 ; 0.8941 0.1020 0.1098];
METEO = zeros(366,n);

% Chargement des donnees
if manic==2; donnees=load('meteo_Manic2.csv');
elseif manic==5; donnees=load('meteo_Manic5.csv');
end
year = donnees(:,1);
donnees = donnees(:,m);


for i_year = 1:n
    
    nb_year = end_year(i_year,:) - start_year(i_year,:) + 1;
    meteo = zeros(366,nb_year);
    
    fprintf('Manic %d %s %d-%d \n',manic,type_meteo,start_year(i_year),end_year(i_year));
    
    for i_bis = start_year(i_year,:):end_year(i_year,:)
        ind = find(year==i_bis);
        % Annee non-bissextile, on ajoute le 29 fevrier
        if length(ind)==365
            meteo(:,i_bis-start_year(i_year)+1) = insertrow(donnees(ind),NaN,59);
            meteo(60) = (meteo(59) + meteo(61))/2;
        elseif length(ind)==366
            meteo(:,i_bis-start_year(i_year)+1) = donnees(ind);
        end
    end
    METEO(:,i_year) = annee_hydro(movingmean(nanmean(meteo,2),fenetre,1,2),mois); %on enleve le bruit de la courbe
end


% Graphique
figure
hold on
for i=1:n
    plot(METEO(:,i),'color',colorb(i,:),'LineWidth', 2)
end
if mois==1, datetick('x','mmm'); end
ylabel(y)
set(gca,'fontsize',14)
titre = sprintf('Manic %d - %s%s',manic,upper(type_meteo(1)),lower(type_meteo(2:end)));
title(titre,'fontweight','bold','fontsize',12);
xlim([1 366])


% Legende-------------------------------------------------
%Legend = cell(2,1);
%Legend{1} = ['1960-1990']; Legend{2} = ['2070-2100'];
%Legend{1} = ['1960-1990']; Legend{2} = ['1995-2025']; Legend{3} = ['2035-2065']; Legend{4} = ['2070-2100'];
%legend(Legend);
% --------------------------------------------------------

