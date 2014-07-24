% % % Utilisation du modele hydrologique HSAMI

%dossier_para = load('Manic_Param.csv');

% Pour Manic2, colonne 5, pour Manic 5, colonne 2
[num,txt,raw] = xlsread('/home/beaudin/matlab/Manic/meteo/Manic_Param.xls');

versionHSAMI = '1';
pas = 1;
nb_pas = 24;
param = num(1:23,5);
meteo = mean(meteo_qtl('tmin',50,'s',Inf,2014,1),2);
etp = 1;%????
etat = %voir hsami_meteo_apport.m. Sinon, on le modifiera avec les variables d'etat en sortie
eau_hydrogrammes = % y reflechir, ou demander a Marie-Claude Simard
hydrogrammes = % IDEM
superficie = num(24,5); %N'EST PAS DEMANDE DANS LA FONCTION...?

[etat,eau_hydrogrammes,apport_horizontal,apport_vertical,eau_surface,etr]...
=hsami_meteo_apport(versionHSAMI,pas,nb_pas,param,meteo,etp,etat,...
eau_hydrogrammes,hydrogrammes);