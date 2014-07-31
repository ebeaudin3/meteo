% % % Utilisation du modele hydrologique HSAMI
profile on
fig=0;

% initialisation des variables
depart = 1950; fin = 2013;
n = fin-depart+1;
debits_horizontaux = nan(366,n);
debits_verticaux = nan(366,n);
debit = nan(366,n);
etat_n = nan(n,10);

% calcul des debits vertical et horizontal perturbes
h = waitbar(0,sprintf('%d-%d',depart,fin));
for i=1:n
    waitbar(i/n,h)
    annee_cible = depart+i-1;
    
    if annee_cible==depart
        etat = zeros(1,10);
        eau_hydrogrammes=zeros(10,2);
    end
    
    % Chargement des donnees perturbees
    meteo_perturbee = pretraitement_meteo_qtl(50, 's', annee_cible, 2014, 2, 0);
    % Chargement des donnees reelles
    donnees_obs = load('/home/beaudin/matlab/Manic/meteo/meteo_Manic2.csv'); 
    ind = find(donnees_obs(:,1)==annee_cible);
    meteo_reelle = donnees_obs(ind,2:5);
    
    [debits_horizontaux(:,i) ...
        debits_verticaux(:,i) ...
        etat eau_hydrogrammes] = ...
            utilisation_hsami(meteo_reelle,etat,eau_hydrogrammes,1,2);
    debit(:,i) = fct_debit_obs(annee_cible,2);
    etat_n(i,:)=etat;

end

close(h)

% on scrape la premiere annee
if n~=1
    debits_horizontaux(:,1) = [];
    debits_verticaux(:,1) = [];
    etat_n(1,:) = [];
    debit(:,1) = [];
    
    % vecteur de debit simule pour faire un graphique sur n annees
    vect_h = nan(366*(n-1),1);
    vect_v = nan(366*(n-1),1);
    debit_n = nan(366*(n-1),1);
    for i=1:(n-1)
        vect_h(366*(i-1)+1:366*i,1)=debits_horizontaux(:,i);
        vect_v(366*(i-1)+1:366*i,1)=debits_verticaux(:,i);
        debit_n(366*(i-1)+1:366*i,1)=debit(:,i);
    end
end

                    % % % section graphique % % %
         
if fig==1
    % courbes superposees
    color_b = colormap(cbrewer('seq','Blues',n)); close;
    color_r = colormap(cbrewer('seq','Blues',n)); close;
    figure, hold on, box on, grid on, xlim([1 366])
    for i=1:n-1
        plot(debits_horizontaux,'color',color_b(i,:),'linewidth',2)
        plot(debits_verticaux,'color',color_r(i,:),'linewidth',1)
    end
    hold off
    
    % n annees
    figure, hold on, box on, grid on, xlim([1 length(vect_h)])
    plot(debit_n,'b','linewidth',5)
    plot(vect_h,'g')
    plot(vect_v,'m')
    plot(vect_h+vect_v,'r')
    hold off
    
    % etats
    colorb = colormap(cbrewer('qual','Accent',10)); colorb(5,1)=0;
    figure
    for e=1:10
        subplot(5,2,e)
        title(sprintf('Etat %d',e),'fontsize',12,'FontWeight','bold')
        hold on, box on, grid on, xlim([1 n-1])
        plot(etat_n(:,e),'*-','color',colorb(e,:),'linewidth',1);
    end
    hold off
end

% Section Profiler
time = profiler(profile('info'));
profile off