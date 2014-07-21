%%% TEST DE LA FONCTION PERCTILE AVEC LA TEMP DE MANIC 2 ET 5
fig=0;
%%% pour size(METEO) = [366, 2]

% Initialisation des variables
nb_quant=17;
P = linspace(1,100,nb_quant);
percentiles = nan(nb_quant,64);

moy_qtl = nan(2,nb_quant);
diff_qtl = nan(1,nb_quant);

tic
for j=1:2   
    matrice = [(1:366)' METEO(:,j)];
    srtmat = sortrows(matrice,2);
    for i=1:nb_quant
        % Calcul des bornes
        if round(366/nb_quant)<366/nb_quant;
            n = 366;
            while mod(n,nb_quant)~=0
                n=n+1;
            end
            a =(i-1)*floor(n/nb_quant)+1;
            b = i*floor(n/nb_quant); 
        else
            a =(i-1)*round(366/nb_quant)+1;
            b = i*round(366/nb_quant);
        end
        
        % Initialisation des variables
        if i==1, quantiles = zeros(b-a+1,nb_quant); end
        
        % Borne sup?rieure plus grande que 366
        if b>366,
            NaN_mat = NaN(b-a+1,1);
            NaN_mat(1:367-a,1) = srtmat(a:366,2);
            quantiles(:,i) = NaN_mat;
        else quantiles(:,i) = srtmat(a:b,2);
        end
    end
    moy_qtl(j,:) = nanmean(quantiles);
end
toc

diff_qtl = moy_qtl(2,:)-moy_qtl(1,:);

if fig==1
    figure
    plot(1:nb_quant,moy_quant)
    xlim([1 nb_quant])
end
