function [best_assignment,best_cost] = sequential(costMat)
%drop one colum at a time from the cost matrix to evaluate how the cost
%function changes

width=size(costMat,2);
%numbertrials=ceil(width/2);
numbertrials=min([5 ceil(width/2)]);        %set the maximum number of objecs to delete to 5

best_assignment=[];
best_cost=[];

for n=1:numbertrials
    assignments=[];%zeros(1,heigth);
    costs=[];
    
    for i=1:width-n+1;        %Only move until remaining coluns are enough for the number of columns to Nan
        
        
        
        auxmatrix= costMat;
        auxmatrix(:,i)=NaN;% Set one column to NAN
        
        [assignments,costs]=nanacolumn(auxmatrix,n,assignments,costs); %turn remaing number of colums to NaN recursively
        
    end
    
    [best_cost(n),I]=min(costs);
    best_assignment(n,:)=assignments(I,:);
    
    
end

