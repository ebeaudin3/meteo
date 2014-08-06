% % % Utilisation du modele hydrologique HSAMI

function [debits_horizontaux etat eau_hydrogrammes] = ...
    utilisation_hsami(meteo,etat,eau_hydrogrammes,manic)


%manic=2; etat_ini=zeros(1,10); eau_hydrogrammes_ini=zeros(10,2);

% Initialisation des variables
num = xlsread('/home/beaudin/matlab/Manic/meteo/Manic_Param.xls');
versionHSAMI = '1';
nb_pas = 1;
pas=1;
etp = -1; %S'IL EST NEGATIF, HSAMI L'EVALUE
%hydrogrammes_ini = zeros(10,2); %JE NE SUIS PAS OBLIGE DE LE METTRE
if manic==2, manic=5; elseif manic==5, manic=2; end
superficie = num(24,manic);
param = num(1:23,manic);
apport_horizontal = nan(length(meteo),1);
apport_vertical = nan(length(meteo),1);
app_h = nan(nb_pas,3);
app_v = nan(nb_pas,3);

% Boucle d'iteration sur une annee
for jour=1:length(meteo)
    %vecteur meteo pour 1 jour
    meteo_j = meteo(jour,:);

    %calcul des apports horizontal et vertical pour 1 jour
    [etat,eau_hydrogrammes,app_h,app_v,eau_surface,etr]...
        =hsami_meteo_apport(versionHSAMI,pas,nb_pas,param,meteo_j,etp,...
        etat,eau_hydrogrammes);
    
    % Somme des apports et conversion de cm/pas_de_temps en m^3/s
    apport_horizontal(jour,1) = sum(app_h).*superficie.*nb_pas./8.64;
end

%on standardise les vecteurs a 366 jours
if length(apport_horizontal)==365,
    apport_horizontal=insertrow(apport_horizontal,nan,365);
end
debits_horizontaux = apport_horizontal(:,1);
