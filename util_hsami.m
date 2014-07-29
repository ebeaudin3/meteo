% % % Utilisation du modele hydrologique HSAMI

debits_horizontaux_perturbes = nan(366,2013-1950+1);
debits_verticaux_perturbes = nan(366,2013-1950+1);
for annee_cible=1950:2013
    
    annee_perturbee = pretraitement_meteo_qtl(50, 's', annee_cible, 2014, 2, 0);
    [debits_horizontaux_perturbes(:,annee_cible-1949) ...
        debits_verticaux_perturbes(:,annee_cible-1949)] = ...
            utilisation_hsami(annee_cible,annee_perturbee,15,2);
end

figure
plot(debits_horizontaux_perturbes)




profile on
% Pour Manic2: colonne 5, Manic 5: colonne 2
num = xlsread('/home/beaudin/matlab/Manic/meteo/Manic_Param.xls');

versionHSAMI = '1';
nb_pas = 1;

debits_horizontaux_perturbees = nan(366,2013-1950+1);
debits_verticaux_perturbees = nan(366,2013-1950+1);
colorb = colormap(cbrewer('seq','Blues',2013-1950+1)); close;


for annee_cible=1950:1:2013;
fprintf('%d  ',annee_cible)
% Initialisation de la matrice de donnees meteo perturbees

etp = -1; %S'IL EST NEGATIF, HSAMI L'EVALUE
etat_ini = [0 0 0 0 0 0 0 0 0 0];
eau_hydrogrammes_ini = zeros(10,2); %pour reprendre la simu la ou elle a ete laissee, dim(10X2)
%hydrogrammes_ini = zeros(10,2); %JE NE SUIS PAS OBLIGE DE LE METTRE
superficie = num(24,5);
param = num(1:23,5);
debit = 0.8;
apport_horizontal = nan(length(annee_perturbee),3);
apport_vertical = nan(length(annee_perturbee),3);
app_h = nan(nb_pas,3);
app_v = nan(nb_pas,3);

h = waitbar(0,'Jour');
for jour=1:length(annee_perturbee)
    
    meteo = annee_perturbee(jour,:);
    if jour==1; etat=etat_ini; eau_hydrogrammes=eau_hydrogrammes_ini;
    else
       [etat,ah,av,eau_hydrogrammes]=hsami_avancer_etat(versionHSAMI,...
            pas,nb_pas,superficie,param,etat,eau_hydrogrammes,meteo,debit);
    end
    
    for pas = 1:nb_pas %nb_pas=1
        [etat,eau_hydrogrammes,app_h(pas,:),app_v(pas,:),eau_surface,etr]...
            =hsami_meteo_apport(versionHSAMI,pas,nb_pas,param,meteo,etp,etat,...
            eau_hydrogrammes);
    end
    % Conversion de cm/pas_de_temps en m^3/s
    apport_horizontal(jour,:) = mean(app_h).*superficie.*nb_pas./8.64;
    apport_vertical(jour,:) = mean(app_v).*superficie.*nb_pas./8.64;
    
    waitbar(jour/length(annee_perturbee),h)
end
close(h)
    
%for i=1:3
%    figure(i)
%    hold on
%    plot(1:length(annee_perturbee),apport_vertical(:,i),'-r','linewidth',3)
%    plot(1:length(annee_perturbee),apport_horizontal(:,i),'-b','linewidth',1.5)
%    xlim([1 length(annee_perturbee)])
%    hold off
%end

if length(apport_horizontal)==365, 
    apport_horizontal=insertrow(apport_horizontal,apport_horizontal(end),365);
    apport_vertical=insertrow(apport_vertical,apport_vertical(end),365);
end
debits_horizontaux_perturbees(:,annee_cible-1949) = movingmean(sum(apport_vertical,2),15,[],1);
debits_verticaux_perturbees(:,annee_cible-1949) = movingmean(sum(apport_vertical,2),15,[],1);

hold on
plot(1:366,debits_horizontaux_perturbees(:,annee_cible-1949),'color',colorb(annee_cible-1949,:),'linewidth',3)
%plot(1:366,debits_verticaux_perturbees(:,annee_cible-1949),'-b','linewidth',1.5)
xlim([1 length(annee_perturbee)])
%datetick('x','mmm')


end


figure
hold on
plot(1:366,mean(debits_horizontaux_perturbees(:,1:30),2),'-r','linewidth',3)
plot(1:366,mean(debits_horizontaux_perturbees(:,(end-30):end),2),'-r','linewidth',3)
xlim([1 length(annee_perturbee)])
datetick('x','mmm')
hold off


% Section Profiler
p=profile('info');
profile off

time=zeros(size(p.FunctionTable,1),2);
time = num2cell(time);
for t=1:size(p.FunctionTable,1)
    time(t,1) = char2cell(eval(sprintf('p.FunctionTable(%g,1).FunctionName',t)));
    time(t,2) = num2cell(eval(sprintf('p.FunctionTable(%g,1).TotalTime',t)));
end
time = sortrows(time,2);
