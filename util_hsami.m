% % % Utilisation du modele hydrologique HSAMI
profile on
fig=0;
scrape=0;
manic=2;

% initialisation des variables
depart = 1950; fin = 2013;
n = fin-depart+1;
debits_horizontaux = nan(366,n);
debits_verticaux = nan(366,n);
debit = nan(366,n);
etat_n = nan(n,10);
debit_meteo_non_perturbee = nan(366,n);
b=0;

% calcul des debits vertical et horizontal perturbes
h = waitbar(0,sprintf('%d-%d',depart,fin));

for i=1:n
    waitbar(i/n,h)
    annee_cible = depart+i-1;
    
    if annee_cible==depart
        etat = zeros(1,10);
        eau_hydrogrammes=zeros(10,2);
    end
    
    % Chargement d_obses donnees perturbees
    meteo_perturbee = pretraitement_meteo_qtl(50, 's', annee_cible, 2014, 2, 0);
    
    % Chargement des donnees reelles
    if manic==2, donnees_obs = load('/home/beaudin/matlab/Manic/meteo/meteo_Manic2.csv'); 
    elseif manic==5, donnees_obs = load('/home/beaudin/matlab/Manic/meteo/meteo_Manic5.csv'); 
    end
    ind = find(donnees_obs(:,1)==annee_cible);
    meteo_reelle = donnees_obs(ind,2:5);
    
    [debits_horizontaux(:,i) ...
        etat eau_hydrogrammes] = ...
            utilisation_hsami(meteo_perturbee,etat,eau_hydrogrammes,manic);
    debit(:,i) = fct_debit_obs(annee_cible,manic);
    etat_n(i,:)=etat;
    
    %figure, hold on
    %h1=plot(meteo_perturbee(:,4),'-r','linewidth',2);
    %h2=plot(meteo_reelle(:,4),'-b');
end
close(h)



% on scrape la premiere annee
if n~=1 && scrape==1
    debits_horizontaux(:,1) = [];
    etat_n(1,:) = [];
    debit(:,1) = [];
else
end
% vecteur de debit simule pour faire un graphique sur n annees
vect_h = nan(366*(size(debits_horizontaux,2)),1);
debit_n = nan(366*(size(debits_horizontaux,2)),1);
for i=1:(size(debits_horizontaux,2))
    vect_h(366*(i-1)+1:366*i,1)=debits_horizontaux(:,i);
    debit_n(366*(i-1)+1:366*i,1)=debit(:,i);
end
for i=1:length(vect_h)
    if isnan(vect_h(i))
        vect_h(i)=[];
    end
end
                    % % % section graphique % % %
         
if fig==1
    % courbes superposees
    color_b = colormap(cbrewer('seq','Blues',n)); close;
    figure, hold on, box on, grid on, xlim([1 366])
    for i=1:10:size(debits_horizontaux,2)
        plot(debits_horizontaux(:,i),'color',color_b(i,:),'linewidth',2)
    end
    hold off
    
    % n annees
    figure, hold all, box on, grid on, xlim([1 length(vect_h)])
    subplot(2,1,1), plot(debit_n,'b','linewidth',3),  xlim([1 length(vect_h)])
    subplot(2,1,2), hold on, plot(vect_h,'r','linewidth',3),  xlim([1 length(vect_h)])
    subplot(2,1,2), hold on, plot(debit_sim_catherine,'g'),  xlim([1 length(vect_h)])
    hold off
    
    %%% SUBAXIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    debit_catherine = nan(366,n);
    a = datenum({'01-Jan-1950 00:00:00';'31-Dec-2013 23:00:00'});
    dsc = load('debit_manic2_catherine');
    debit_sim_catherine(:,2)=dsc.debit;
    dates = datevec(a(1):1:a(2));
    debit_sim_catherine(:,1)=dates(:,1);
    for annee=depart:fin
        ind = find(debit_sim_catherine(:,1)==annee);
        if length(ind)==365
            debit_catherine(:,annee-1949) = insertrow(debit_sim_catherine(ind,2),nan,365);
        else debit_catherine(:,annee-1949) = debit_sim_catherine(ind,2);
        end
    end
    
    color_b = colormap(cbrewer('seq','Blues',n));
    figure
    donnees=debits_horizontaux;
    pos=[1 1;1 2;1 3;1 4;1 5;1 6;1 7;1 8;2 1;2 2;2 3;2 4;2 5;2 6;2 7;2 8;3 1;3 2;3 3;3 4;3 5;3 6;3 7;3 8;4 1;4 2;4 3;4 4;4 5;4 6;4 7;4 8;5 1;5 2;5 3;5 4;5 5;5 6;5 7;5 8;6 1;6 2;6 3;6 4;6 5;6 6;6 7;6 8;7 1;7 2;7 3;7 4;7 5;7 6;7 7;7 8;8 1;8 2;8 3;8 4;8 5;8 6;8 7;8 8];
    
    for i=1:size(donnees,2)
        hold on
        
        subaxis(8,8,pos(i,2),pos(i,1),'SpacingHoriz',0,'SpacingVert',0.04), hold on
        plot(debit_catherine(:,i),'k','linewidth',1.5), hold off
        subaxis(8,8,pos(i,2),pos(i,1),'SpacingHoriz',0,'SpacingVert',0.04), hold on
        plot(donnees(:,i),'color',color_b(45,:),'linewidth',1.5) 
        
        xlim([0 length(donnees(:,i))])
        ylim([0 1.1*max(max(donnees))])
        if pos(i,2)~=1, set(gca,'Ytick',[]), else set(gca,'fontsize',8), ylabel('m^3/s'); end
        if pos(i,1)~=8, set(gca,'Xtick',[]), else set(gca,'fontsize',8); end
        title(1949+i,'fontsize',6)
    end
    
    savefile='debit_perturbe.png';
    print(gcf, '-dpng','-r400', savefile) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
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