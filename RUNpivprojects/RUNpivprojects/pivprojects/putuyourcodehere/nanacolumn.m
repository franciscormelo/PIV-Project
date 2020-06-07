function [assignments,costs] = nanacolumn(matrix,remaining,assignments,costs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

remaining=remaining-1;
if remaining==0 
    [assignments(end+1,:),costs(end+1)]= munkres(matrix);     %end of recursion. calculate values
    return
end

[~, startnan]=find(isnan(matrix)); %find first column with nan

for i=startnan(end)+1:size(matrix,2)
    auxmatrix=matrix;
    if ~isnan(auxmatrix(1,i))
        auxmatrix(:,i)=NaN;
        [assignments,costs]=nanacolumn(auxmatrix,remaining,assignments,costs);
    end
end

end

