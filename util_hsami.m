% % % Utilisation du modele hydrologique HSAMI
profile on

% initialisation des variables
depart = 1970; fin = 1990;
n = fin-depart+1;
debits_horizontaux_perturbes = nan(366,n);
debits_verticaux_perturbes = nan(366,n);
etat_ini = zeros(1,10);
eau_hydrogrammes_ini = zeros(10,2);
etat_n = nan(n,10);

% calcul des debits vertical et horizontal perturbes
for i=1:n
    annee_cible = depart+i-1;
    if annee_cible==depart
        etat=etat_ini; 
        eau_hydrogrammes=eau_hydrogrammes_ini;
    end
    annee_perturbee = pretraitement_meteo_qtl(50, 's', annee_cible, 2014, 2, 0);
    [debits_horizontaux_perturbes(:,i) ...
        debits_verticaux_perturbes(:,i) ...
        etat eau_hydrogrammes] = ...
            utilisation_hsami(annee_cible,annee_perturbee,etat,eau_hydrogrammes,15,2);
    etat_n(i,:)=etat;
end

% on scrape la premiere annee
if n~=1
    debits_horizontaux_perturbes(:,1) = [];
    debits_verticaux_perturbes(:,1) = [];
    etat_n(1,:) = [];
    
    % vecteur de debit simule pour faire un graphique sur n annees
    vect_h = nan(366*(n-1),1);
    vect_v = nan(366*(n-1),1);
    for i=1:(n-1)
        vect_h(366*(i-1)+1:366*i,1)=debits_horizontaux_perturbes(:,i);
        vect_v(366*(i-1)+1:366*i,1)=debits_verticaux_perturbes(:,i);  
    end
end

                 % % % section graphique % % %
                  
figure, hold on, box on, grid on, xlim([1 366])
plot(debits_horizontaux_perturbes,'-b','linewidth',2)
plot(debits_verticaux_perturbes,'-r','linewidth',1)
hold off
figure, hold on, box on, grid on, xlim([1 length(vect_h)])
plot(vect_h,'b')
plot(vect_v,'r')
hold off

colorb = colormap(cbrewer('seq','Blues',10)); close;
for e=1:10
    figure, hold on, box on, grid on, xlim([1 n-1])
    plot(etat_n(:,e),'-','color',colorb(e,:),'linewidth',2);
end
hold off

% Section Profiler
time = profiler(profile('info'));
profile off