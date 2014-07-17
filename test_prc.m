%%% TEST DE LA FONCTION PERCTILE AVEC LA TEMP DE MANIC 2 ET 5

an = 1950; % in [1950,2013]
   
    hold on
for an=1980:2000
     figure
     percentiles = zeros(100,1);
    for p=1:100
        P = linspace(1,100);
        matrice = [[1:366]' METEO(:,an-1949)];
        percentiles(p,an) = perctile(matrice(:,2),p);
        srtmat = sort(matrice,2);
    end
    plot(1:100,percentiles)
    xlim([1 100])
end