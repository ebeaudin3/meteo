function [out, sf, P] = rank_based_scaling(obs, ref, fut, N, type, cap, annee_source, annee_cible)

% Generic scaling method. A daily scaling factor
% is computed from the percentiles of the reference and the future period 
% and applied to observational data to simulate the future transition.
%
% Parameters
% ----------
% obs : matrix
%   The observational data.
% ref : matrix
%   The GCM data for the reference period.
% fut : matrix
%   The GCM data for the future period. 
% N : int
%   The number of points in the percentile table.
% type : string
%   Either 'multiplicative' or 'additive'. 
% cap : float
%   Maximum value allowed in the scaling factor, defaults to inf. 
%
% Returns
% -------
% out : matrix
%   The observational data scaled by a daily scaling factor computed from 
%   the distribution of the reference and future periods. 
% dsf : 1xN matrix
%   Daily scaling factor evaluated at ~linspace(0,100,N).
% P : 1xN matrix
%   Percents.
%  
% Notes
% -----
% A small positive random perturbation vector is added to obs, ref and 
% fut to avoid singularities in the percentiles, leading to NaNs. 
      
% Random perturbations are added to avoid singularities in the computations.

if ~exist('cap', 'var')
    cap = inf;
end
r_ref = rand(size(ref))*1e-6;
r_fut = rand(size(fut))*1e-6;
r_obs = rand(size(obs))*1e-6;


% Compute the percentiles for all three datasets. 
% The 0th and 100th percentile are usually the minimum and maximum values
% respectively. This produces spikes in the ratio and is not very robust. I 
% elected to extrapolate the 0th and 100th percentile from nearby values
% instead. One problem created with this approach is that the extralation
% can lead to negative values when the domain is positive. For
% multiplicative factor, this is embarassing and negative factors are
% clipped at 0. 

Pa = linspace(1,99,50);
P = linspace(0,100,N);

refP = interp1(Pa, perctile(ref+r_ref, Pa), P, 'cubic', 'extrap');
futP = interp1(Pa, perctile(fut+r_fut, Pa), P, 'cubic', 'extrap');
obsP = interp1(Pa, perctile(obs+r_obs, Pa), P, 'cubic', 'extrap');


%plot(P, [refP;futP;obsP])

% Compute the daily scaling factor and apply it to the observations.
switch lower(type)

    case 'multiplicative'
        % Clip to 0 if negative.
        sf = futP./refP;
        sf =  1 + (sf-1).*((annee_source-annee_cible)/(2055-1975));%sf.^((annee_source-annee_cible)/80);
        sf(sf<0) = 0.;
        sf(sf>cap) = cap;
        out = interp1(obsP, sf, obs, 'nearest', 'extrap') .*  obs;
                    %%% GRAPHIQUE %%%
                    %colorb = colormap(cbrewer('div','RdYlBu',65)); close;
                    %figure, hold on
                    %sf = futP./refP; sf(sf<0) = 0.; plot(sf,'k','linewidth',1)
                    %for annee_cible = 1950:1:2013;
                    %    sf_n(annee_cible-1949,:) =  1 + (sf-1).*((annee_source-annee_cible)/(2055-1975));%1 + (sf-1)./(annee_source-annee_cible);
                    %    plot(sf_n(annee_cible-1949,:),'color',colorb(annee_cible-1949,:),'linewidth',2); 
                    %end
                    %xlabel('Quantiles')
                    %xlim([25 50])
                    %ylabel('Scaling factor')
                    %colormap(cbrewer('div','RdYlBu',2013-1950+1));
                    %colorbar('YTickLabel', {'1950','1960','1970','1980','1990','2000','2010'})
                    %set(gca,'fontsize',12)
                    %box on
                    %matlab2tikz('sf_hiver.tikz', 'height', '\figureheight', 'width', '\figurewidth');
                    %savefile = 'sf_s3.png';
                    %print(gcf, '-dpng','-r400', savefile) 
                       

    case 'additive'
        sf = futP - refP;
        sf_source = ((annee_source-1975)/80)*sf;
        sf_cible = ((annee_cible-1975)/80)*sf;
        sf = sf_source - sf_cible;
        sf(sf>cap) = cap;
        out = interp1(obsP, sf, obs, 'nearest', 'extrap') + obs;
    otherwise
        error('type not understood.')

end

if any(isnan(sf))
  error('NaN in sf.')
end

if any(isnan(out))
  error('NaN in out.')
end



