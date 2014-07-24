% % % Utilisation du modele hydrologique HSAMI

% Pour Manic2: colonne 5, Manic 5: colonne 2
num = xlsread('/home/beaudin/matlab/Manic/meteo/Manic_Param.xls');

versionHSAMI = '1';
nb_pas = 24;

% Initialisation de la matrice de donnees meteo perturbees
oui=1;
if oui==1
    %annee_perturbees=nan(23376,4);
    annee_perturbee(:,1) = mean(meteo_qtl('tmin',50,'s',Inf,1950,2014,0),2);
    annee_perturbee(:,2) = mean(meteo_qtl('tmax',50,'s',Inf,1950,2014,0),2);
    annee_perturbee(:,3) = mean(meteo_qtl('pluie',50,'s',Inf,1950,2014,0),2);
    annee_perturbee(:,4) = mean(meteo_qtl('neige',50,'s',Inf,1950,2014,0),2);
end

etp = -1; %S'IL EST N?GATIF, HSAMI L'?VALUE
etat_ini = [0 60 0 4 0 60 7 8 21 9];
eau_hydrogrammes_ini = [10 2000];%???
hydrogrammes_ini = [100 200]; %JE NE SUIS PAS OBLIG? DE LE METTRE
superficie = num(24,5);
param = num(1:23,5);


for jour=1:length(annee_perturbee)
    meteo = annee_perturbee(jour,:);
    for pas = 1:nb_pas
        if pas>1;etat_ini=etat;
            %etp=etr;
            eau_hydrogrammes_ini=eau_hydrogrammes;
        end
        
        [etat,eau_hydrogrammes,apport_horizontal,apport_vertical,eau_surface,etr]...
            =hsami_meteo_apport(versionHSAMI,pas,nb_pas,param,meteo,etp,etat_ini,...
            eau_hydrogrammes_ini,hydrogrammes_ini);
        
        % Conversion de cm/pas_de_temps en m^3/s
        apport_horizontal = apport_horizontal.*superficie.*nb_pas./8.64;
        apport_vertical = apport_vertical.*superficie.*nb_pas./8.64;
    end
end