function [joinedFrame] = joinpc(Frame1,Frame2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for currentFrame=1:length(Frame1)
    objs1=size(Frame1(currentFrame).object,2);        %number of objects in each frame
    objs2=size(Frame2(currentFrame).object,2);
    
    if objs1==0       %if one frame 1 is zero or both are just copy to frame2
        joinedFrame(currentFrame)=Frame2(currentFrame);
        %joinedFrame(currentFrame).object(t).centroid=[0 0]; %if copying from frame 2 ignore centroid
    elseif objs1~=0 && objs2==0
        joinedFrame(currentFrame)=Frame1(currentFrame);
    else
        H=[];
        for x=1:objs1
            for y=1:objs2
                H(y,x)=norm(Frame1(currentFrame).object(x).COM-Frame2(currentFrame).object(y).COM);
            end
        end
        
        [order,cost]=munkres(H);
        
            
        for t=1:length(order)
            
            position=order(t);
            if position~=0
                
                joinedFrame(currentFrame).object(t).pco=pcmerge(Frame1(currentFrame).object(position).pco,Frame2(currentFrame).object(t).pco,0.001);
                pc=joinedFrame(currentFrame).object(t).pco;
                
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
                
                joinedFrame(currentFrame).object(t).box=boxPoints;
                
                joinedFrame(currentFrame).object(t).COM=mean(pc.Location);                     %compute and store COM
                joinedFrame(currentFrame).object(t).centroid=Frame1(currentFrame).object(position).centroid; %copy centroid ffrom frame1
                joinedFrame(currentFrame).object(t).histogram= mean([Frame1(currentFrame).object(position).histogram;Frame2(currentFrame).object(t).histogram]);
                
            else% a zero in order means this object does not exist in Frame1 so we copy it straigth from Frame2
               % joinedFrame(currentFrame).object(t)=struct('box',{},'pco',{},'COM',{},'centroid',{});
                joinedFrame(currentFrame).object(t)=Frame2(currentFrame).object(t);
                joinedFrame(currentFrame).object(t).centroid=[0 0]; %if copying from frame 2 ignore centroid
                joinedFrame(currentFrame).object(t).histogram=Frame2(currentFrame).object(t).histogram;
                
            end
            
        end
        
        for t=length(order)+1:objs1          %if size of order is smaller than objs1 that means some objects in Frame 2 do not exist in Frame1
            % so lets copt straight
            % from Frame1
            
            joinedFrame(t)=Frame1(t);
        end
        
    end
    
    
    
    
    %
    %     for t=1:max(objs1,objs2)                           %iterate trough all objects in both frames
    %
    %         if (t<=objs2)                                    %if still in range of objs1 objects
    %             if order(t)~=0                                              %match found
    %                 Frame(objs2Frame).object(t).id=Frame(lastFrame).object(order(t)).id;  %store correct order number in frame (lastFrame does not require end protection because hat is built in from object matching)
    %             else
    %                 if isfield(Frame(objs2Frame).object,'id')        %if current frame already has objects associated
    %                     maxobjectnumber=max(...                        %find number of object to use from maximum of current and objs1 frame
    %                         max([Frame(lastFrame).object.id]),max([Frame(currentFrame).object.id]))...
    %                         +1;
    %                 else                                                %otherwise find from objs1 frame only
    %                     maxobjectnumber=max([Frame(lastFrame).object.id])+1;
    %                 end
    %
    %                 Frame(currentFrame).object(t).id=maxobjectnumber;
    %             end
    %         end
    %
    
    
end






