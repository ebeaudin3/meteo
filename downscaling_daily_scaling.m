function [out, dsf, P] = downscaling_daily_scaling(obs, ref, fut, N, type, freq, cap, annee_source, annee_cible)

% Downscale GCM data using the daily scaling method. A daily scaling factor
% is computed from the percentiles of the reference and the future period 
% and applied to observational data to simulate the future transition. 
% The scaling factor can be computed on an annual, a seasonal or a monthly 
% basis.
%
% Parameters
% ----------
% obs : matrix
%   The observational data. See `freq` below. 
% ref : matrix
%   The GCM data for the reference period.
% fut : matrix
%   The GCM data for the future period. 
% N : int
%   The number of points in the percentile table.
% type : string
%   Either 'multiplicative' (precipitation) or 'additive' (temperature). 
% freq : {'m', 's', 'y'} Default='y'
%   Either monthly 'm', seasonal 's' or annual 'y'. If the monthly option 
%   is chosen, obs, ref and fut must be structures with fields `data` and 
%   `dates`, instead of simple vectors.
% cap : float
%   Maximum value allowed in the scaling factor, defaults to inf. 
%
% Returns
% -------
% out : matrix
%   The observational data scaled by a daily scaling factor computed from 
%   the distribution of the reference and future periods. 
% dsf : mxN matrix
%   Daily scaling factor evaluated at ~linspace(0,100,N). m is equal to 1
%   for the annual frequency, 4 for seasonaly, and 12 for monthly.
% P : 1xN matrix
%   Percents.
%  
      
if ~exist('freq', 'var')
    freq = 'y';
end
if ~exist('cap', 'var')
    cap = inf;
end
switch lower(freq)
    
    case 'y'
        if isstruct(obs), obs = obs.data; end       
        if isstruct(ref), ref = ref.data; end      
        if isstruct(fut), fut = fut.data; end
        
        [out, dsf, P] = rank_based_scaling(obs, ref, fut, N, type, cap);
       
    case 'm'
        dsf = nan(12,N);
        for m = 1:12        
            oi = obs.dates(:,2) == m;
            ri = ref.dates(:,2) == m;
            fi = fut.dates(:,2) == m;

            [out.data(oi), dsf(m,:), P] = rank_based_scaling(obs.data(oi), ref.data(ri), fut.data(fi), N, type, cap, annee_source, annee_cible);
        end

        out.dates = scale_dates(obs.dates, fut.dates(1,1) - ref.dates(1,1));
        
	case 's'
        dsf = nan(4,N);
        season = [12 1 2; 3 4 5; 6 7 8; 9 10 11]; 
        for s = 1:4;
            oi = logical((obs.dates(:,2) == season(s,1)) + (obs.dates(:,2) == season(s,2)) + (obs.dates(:,2) == season(s,3)));
            ri = logical((ref.dates(:,2) == season(s,1)) + (ref.dates(:,2) == season(s,2)) + (ref.dates(:,2) == season(s,3)));
            fi = logical((fut.dates(:,2) == season(s,1)) + (fut.dates(:,2) == season(s,2)) + (fut.dates(:,2) == season(s,3)));
            
            [out(oi,:), dsf(s,:), P] = rank_based_scaling(obs.data(oi), ref.data(ri), fut.data(fi), N, type, cap, annee_source, annee_cible);
        % avant, out=out.data(oi,:)
        end
        
        %out.dates = scale_dates(obs.dates, fut.dates(1,1) - ref.dates(1,1));   
end

