% chargement des donnees ruissellement Manic
function deb = fct_debit_obs(annee, manic)

%manic = 2;
mois = 10;
%fenetre = 15;

if manic==2; app_Manic = load('app_Manic2.csv'); end
if manic==5; app_Manic = load('app_Manic5.csv'); end

ind = find(app_Manic(:,1)==annee);
deb = app_Manic(ind,2);
if length(ind)==365
    deb = insertrow(deb,NaN,365);
end

% Annee hydrologique debutant le MMMe mois
deb = annee_hydro(deb,mois);