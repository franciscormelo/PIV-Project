function  [bestInliers, iter] = ransacWiki(x,y,threshDist,inlierRatio)

 num=4;
 % iter: the number of iterations ->Calculate like in the slides
 % threshDist: the threshold of the distances between points and the fitting line
 % inlierRatio: the threshold of the number of inliers 
 
 %iter = round(log(1-0.99)/log(1-0.2^num));
iter = 566;
 number = length(x(:,1)); % Total number of points
 bestInNum = 0; % Best fitting model with largest number of inliers
 bestInliers=[];
 %bestParameter1=0;
 %bestParameter2=0; % parameters for best fitting line
 for i=1:iter
 %% Randomly select 4 points
     idx = randperm(number,num);   
 %% Compute fitting model with Procrustes
 [d,~,tr] = procrustes(x(idx,:),y(idx,:),'scaling',false,'reflection',false);
 
 
 %% Compute the distances between all points with the fitting model
    a=x;
    b =y *tr.T+ones(length(y),1)*tr.c(1,:);
    %distance = vecnorm((a-b)')';
    sub = a-b;
    distance = sqrt(sub(:,1).^2 + sub(:,2).^2 + sub(:,3).^2);
    
 %% Compute the inliers with distances smaller than the threshold
     inlierIdx = find(abs(distance)<= threshDist);
     inlierNum = length(inlierIdx);
     
 
     
 %% Update the number of inliers and fitting model if better model is found     
     if inlierNum>=round(inlierRatio*number) && inlierNum>bestInNum
         bestInNum = inlierNum;
         bestInliers=inlierIdx;
         
     end
 end
end