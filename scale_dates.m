function out = scale_dates(dates, years)

% Displace a series of dates by an integer number of years.
%
% Parameters
% ----------
% dates : datevec (t x 6)
%   A series of dates.
% years : integer
%   The number of years by which to translate the series.
%
% Return
% ------
% out : datevec (t x 6)
%   A series of dates that is coherent with the input series but with the
%   years scaled. 

n1 = datenum(dates(1,:));
%n2 = datenum(dates(1,1) + years, dates(1,2), dates(1,3), dates(1,4), dates(1,5), dates(1,6));
%les dates sur NLWIS n'ont que 3 colonnes
n2 = datenum(dates(1,1) + years, dates(1,2), dates(1,3));
dn = n2-n1;

out = datevec(datenum(dates) + dn);
if any(out(:, 2) ~= dates(:,2))
    warning('Months are not preserved by the scaling.')
end


