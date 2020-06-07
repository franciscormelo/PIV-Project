function [ Frame ] = pointclouds(label,numObj,sortedrgb,imgs,imgsd,cams)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

Kd = cams.Kdepth;
Krgb = cams.Kdepth;
R = cams.R;
T = cams.T;

display=0;                                                              %debug code
displaypc=0;

for currentFrame = 1:size(imgs,3)
    imgrgb=imread(sortedrgb{currentFrame});                                        %read rgb image
    co=1;
    
    stat = regionprops(label(:,:,currentFrame),'centroid');               %%DEBUG- ca be removed
    
    for j = 1:numObj(currentFrame)                                              %iterate trough objects list
        obj1 = label(:,:,currentFrame)==j;                                      %isolate specific label
        obj = (obj1).*imgsd(:,:,currentFrame)*1000;
        if norm(obj)~=0
            
            xyz1=get_xyzasus(obj(:),[480 640],(1:640*480)', Kd,1,0);
            
            %%% Everything else outside this section should work %%%%
            %%%%%%%% Francisco's Code for Color Histograms %%%%%%%%%%
            rgbd = get_rgbd(xyz1, imgrgb, R, T, Krgb); % XXXXXX should be the original rgb image
            
            xyz1(xyz1==0)= NaN;

            hsvImage = rgb2hsv(rgbd);
            hImage = hsvImage(:,:,1);
            hImage = hImage(hImage~=0); % takes out black spots
            
            hImage = histcounts(hImage,20);

            Frame(currentFrame).object(co).histogram=hImage;
            % Now this can be used, after measuring difference between
            % histograms, in the Hungarian cost matrix.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pc = pointCloud(xyz1);
            
            [pc,indices]= removeInvalidPoints(pc);
            
            
            xMax=pc.XLimits(2);
            xMin=pc.XLimits(1);
            
            yMax=pc.YLimits(2);
            yMin=pc.YLimits(1);
            
            zMax=pc.ZLimits(2);
            zMin=pc.ZLimits(1);
            
            boxPoints=[xMax yMax zMin;...
                xMax yMax zMax;...
                xMin yMax zMax;...
                xMin yMax zMin;...
                xMax yMin zMin;...
                xMax yMin zMax;...
                xMin yMin zMax;...
                xMin yMin zMin]';
            
            Frame(currentFrame).object(co).box=boxPoints;
            Frame(currentFrame).object(co).pco=pc;
            
            Frame(currentFrame).object(co).COM=mean(pc.Location);                     %compute and store COM
            
            Frame(currentFrame).object(co).centroid=stat(j).Centroid;
            
            img=imgrgb;
            %img(:,:,1)=img(:,:,1).*~obj1;
            %img(:,:,2)=img(:,:,2).*~obj1;
            %img(:,:,3)=img(:,:,3).*~obj1;
            
            img(cat(3, ~obj1, ~obj1, ~obj1))=0;                             %apply mask to image
            hsv = rgb2hsv(img) ;                                            %convert to hsv
            h=hsv(:,:,1);                                                   %extract H channel
            
            bins=20;
            
            [counts,binLocations]=imhist(h((obj1==1)),bins);                  %histogram of region of interest with binarization 20
            [pks,locs] = findpeaks(counts,'SortStr','descend');             %find peaks in histogram (desconding order)
            
            if length(locs)>=2
                C1=binLocations(locs(1));                                    %dominant color in HSV
                C2=binLocations(locs(2));                                    %second color in HSV
            end
            if length(locs)==1
                C1=binLocations(locs(1));
                C2=0;
            end
            if isempty(locs)                                              % this occurs in bk frame
                C1=0;
                C2=0;
            end
            
            if display                                    %red dominant colors, green second color
                red=img(:,:,1);
                red(abs(h-C1)<1/bins)=255;
                green=img(:,:,2);
                green(abs(h-C2)<1/bins)=255;
                img(:,:,1)=red;
                img(:,:,2)=green;
                
                % figure(1);
                subplot(131)
                imagesc(h.*obj1);
                subplot(132);
                imagesc(img);
                subplot(133);
                imhist(h((obj1==1)),bins)    %draw histogram of images
                pause(1);
            end
            if displaypc && currentFrame==10
                hold on
                pcshow(pc);
                x3d=Frame(currentFrame).object(co).COM(1);
                y3d=Frame(currentFrame).object(co).COM(2);
                z3d=Frame(currentFrame).object(co).COM(3);
                %plot3(boxPoints(1,:), boxPoints(2,:), boxPoints(3,:), 'r+', 'MarkerSize', 12, 'linewidth', 2.5);hold off;
                plot3(x3d, y3d, z3d, 'r+', 'MarkerSize', 12, 'linewidth', 2.5);
                ax = gca;
                ax.CameraPosition=[0.0193    0.0388   -0.0523];
                ax.CameraTarget=[-0.5049   -0.3012    2.6540];
                ax.CameraUpVector=[0.0477   -0.9922   -0.1154];
                ax.CameraViewAngle=[52.7480];
                ax.Projection='perspective';
                
                
                pause();
            end
            
            
            co=co+1;
            
        end
        
    end
end

if currentFrame>length(Frame)
    for i=length(Frame)+1:currentFrame  %fill remaining slots with empty cells
        Frame(i).object=[];
    end
end

end

