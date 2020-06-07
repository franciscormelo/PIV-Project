function [ label,numObj] = labelling(imgs,imgsd,bggray,bgdepth)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

disksize=5;                                             %%amount of filtering

for currentFrame=1:size(imgs,3)

    [Gmag,Gdir] = imgradient(imgsd(:,:,currentFrame));  
    imdiff = abs(imgsd(:,:,currentFrame)-bgdepth)>0.2;
    
    SE = strel('rectangle',[25 25]);
    %imdiff=imerode(imdiff,SE);
    %imdiff=imdilate(imdiff,SE);
    
    imdiff = imopen(imdiff, strel('disk', 6));
    
    Gmag = Gmag > 0.3;
    
%     imagesc(Gmag);
%     str = sprintf('Frame %d', currentFrame);
%     title(str)
%     pause();
    
    logic = Gmag == 0;
    
    imdiff = imdiff .* logic;
    imdiff = imopen(imdiff, strel('disk',disksize));   %%IMPORTANT! this was set as 2. changed to remove small objects
      

    
    label(:,:,currentFrame) = bwlabel(imdiff);
    numObj(currentFrame)= max(label(:));                      %record maximum number of objects   
    
  %{  
    %figure(1)
    subplot(131);
    imagesc(label(:,:,currentFrame));
    subplot(132);
    imagesc(imgsd(:,:,currentFrame));
    subplot(133);
    imagesc(imdiff);
    pause();

    %numObj(i)=  max(label,[],[1 2])                   %%%IMPORTANT!  bug in 2006B?  
  %}                   
    
%     [Gmag,Gdir] = imgradient(imgsd(:,:,i));  
%     imdiff = abs(imgsd(:,:,i)-bgdeptmax)>0.2;
%     imdiff = imopen(imdiff, strel('disk',6));
%     
%     Gmag = Gmag > 0.3;
%     logic = Gmag == 0;
%     
%     imdiff = imdiff .* logic;
%     imdiff = imopen(imdiff, strel('disk',2));
%       
%     figure(1)
%     label(:,:,i) = bwlabel(imdiff);
%     
%     subplot(122);
%    imagesc(label(:,:,i));
%    w = waitforbuttonpress;
%     
    
end

end


