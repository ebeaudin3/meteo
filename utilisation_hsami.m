% % % Utilisation du modele hydrologique HSAMI

function [debits_horizontaux_perturbes debits_verticaux_perturbes etat eau_hydrogrammes] = ...
    utilisation_hsami(annee_cible,annee_perturbee,etat,eau_hydrogrammes,fenetre,manic)


%manic=2;

% Pour Manic2: colonne 5, Manic 5: colonne 2
num = xlsread('/home/beaudin/matlab/Manic/meteo/Manic_Param.xls');
versionHSAMI = '1';
nb_pas = 1;
pas=1;
etp = -1; %S'IL EST NEGATIF, HSAMI L'EVALUE
etat_ini = zeros(1,10);
eau_hydrogrammes_ini = zeros(10,2); %pour reprendre la simu la ou elle a ete laissee, dim(10X2)
%hydrogrammes_ini = zeros(10,2); %JE NE SUIS PAS OBLIGE DE LE METTRE
if manic==2, manic=5; elseif manic==5, manic=2; end
superficie = num(24,manic);
param = num(1:23,manic);
debit = 0.8;
apport_horizontal = nan(length(annee_perturbee),3);
apport_vertical = nan(length(annee_perturbee),3);
app_h = nan(nb_pas,3);
app_v = nan(nb_pas,3);

h = waitbar(0,sprintf('Annee %d',annee_cible));

for jour=1:length(annee_perturbee)
    
    %vecteur meteo pour 1 jour
    meteo = annee_perturbee(jour,:);
    %initialisation de l'etat

    %on avance l'etat a chaque jour
    %[etat,ah,av,eau_hydrogrammes]=hsami_avancer_etat(versionHSAMI,...
    	%pas,nb_pas,superficie,param,etat,eau_hydrogrammes,meteo,debit);

    %calcul des apports horizontal et vertical pour 1 jour
    [etat,eau_hydrogrammes,app_h,app_v,eau_surface,etr]...
        =hsami_meteo_apport(versionHSAMI,pas,nb_pas,param,meteo,etp,...
        etat,eau_hydrogrammes);
    
    % Somme des apports et conversion de cm/pas_de_temps en m^3/s
    apport_horizontal(jour,:) = sum(app_h).*superficie.*nb_pas./8.64;
    apport_vertical(jour,:) = sum(app_v).*superficie.*nb_pas./8.64;
    
    waitbar(jour/length(annee_perturbee),h)
end
close(h)

%on standardise les vecteurs a 366 jours
if length(apport_horizontal)==365,
    apport_horizontal=insertrow(apport_horizontal,apport_horizontal(end),365);
    apport_vertical=insertrow(apport_vertical,apport_vertical(end),365);
end
%on applique une moyenne mobile
debits_horizontaux_perturbes = movingmean(sum(apport_horizontal,2),fenetre,[],1);
debits_verticaux_perturbes = movingmean(sum(apport_vertical,2),fenetre,[],1);
