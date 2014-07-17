%%% TEST DE LA FONCTION PERCTILE AVEC LA TEMP DE MANIC 2 ET 5



%%% M?THODE 1, pour size(METEO) quelconque
figure
nb_quant=12;
P = linspace(1,100,nb_quant);
percentiles = zeros(nb_quant,64);

tic
for an=1950:2013
    matrice = [[1:366]' METEO(:,an-1949)];
    %for i=round(P)
    percentiles(1:nb_quant,an-1949) = perctile(matrice(:,2),P);
    srtmat = sortrows(matrice,2);
    plot(1:nb_quant,percentiles)
    xlim([1 nb_quant])
end
toc


%%% M?THODE 2, pour size(METEO) = 366 2
figure
nb_quant=12;
P = linspace(1,100,nb_quant);
percentiles = zeros(nb_quant,64);
matrice = [[1:366]' METEO(:,i)];
srtmat = sortrows(matrice,2);

tic
for i=1:nb_quant
    a =(i-1)*round(366/nb_quant)+1;
    b = i*round(366/nb_quant);
    % IL FAUT FAIRE EN SORTE QUE QUANTILES PRENNENT LES VALEURS DE a:366,
    % PUIS LES RESTES SERONT DES NaN.
    if b>366, quantiles(:,i) = srtmat([a:366 ,2]);
    else quantiles(:,i) = srtmat(a:b,2);
    end
    %percentiles(1:nb_quant,i) = find(perctile(matrice(:,2),89));
    %plot(1:nb_quant,percentiles)
    %xlim([1 nb_quant])
end
toc

