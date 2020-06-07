function [ Frame ] = hungarian(Frame,label,sortedrgb)
fontsize=20;
lastFrame=0;                                    %stores location of last frame with data
display3d=0;
displaycost=0;
displayrgb=0;
%75
%51
%66
for currentFrame=1:length(Frame)
    if ~isempty(Frame(currentFrame).object)
        current=length(Frame(currentFrame).object);       %number of objects in current frame
        if lastFrame==0                        %this is the first iteration
            imagesc(label(:,:,currentFrame));
            str = sprintf('Frame %d', currentFrame);
            title(str)
            for j=1:length(Frame(currentFrame).object)
                Frame(currentFrame).object(j).id=j;       %so assign sequential numbers
            end
            hold on
            for t=1:current
                %text(Frame(currentFrame).object(t).centroid(1),Frame(currentFrame).object(t).centroid(2),num2str(t),'Color','red','FontSize',fontsize);
            end
            %pause();
            
        else                                    %all iterations other than first
            previous=length(Frame(lastFrame).object);       %number of objects in previous frame
            H=[];                                           %hungarian matrix
            hist=[];
            
            for x=1:previous
                for y=1:current
                    H(y,x)=norm(Frame(lastFrame).object(x).COM-Frame(currentFrame).object(y).COM);
                    hist(y,x)=bhattacharyya(Frame(lastFrame).object(x).histogram,Frame(currentFrame).object(y).histogram);
                end
            end
            %[order,cost]=hungarian(H);                             %calculate hugarian method
            [order,cost]=munkres(H+hist);
            oders=[];
            costs=[];
            %[orders,costs]=hypotheses(H);
            [orders,costs] = sequential(H+hist);
            
            penalty=cost.*(1:length(costs))/length(costs);
            
            [mincost,I]=min(costs+ penalty);
            if (cost>mincost)
                %disp('Cost replaced')
                order=orders(I,:);
            end
            
            
            %             if (cost>min(costs)*2)                                  %if cost ignoring one object is less than half of cost with all objects, use the version with less one object
            %                 disp('Cost replaced')
            %                 [M,I]=min(costs);
            %                 order=orders(I,:);
            %
            %             end
            
            
            
            newobjs=find(order==0);                                  %these are the newest cost objects so they are probably new objects
            %order(order==0)=[];                                       %strip new objects from array
            subplot(121)
            imagesc(label(:,:,currentFrame));
            hold on;
            str = sprintf('Frame %d', currentFrame);
            title(str)
            hold on
            for t=1:max(previous,current)                           %iterate trough all objects in both frames
                subplot(121)
                if (t<=previous)
                    text(Frame(lastFrame).object(t).centroid(1),Frame(lastFrame).object(t).centroid(2),num2str(Frame(lastFrame).object(t).id),'Color','black','FontSize',fontsize); %print previous frame objects number in black
                end
                
                if (t<=current)                                    %if still in range of previous objects
                    text(Frame(currentFrame).object(t).centroid(1),Frame(currentFrame).object(t).centroid(2),num2str(t),'Color','red','FontSize',fontsize);   %print current objects number in red
                    if order(t)~=0                                              %match found
                        Frame(currentFrame).object(t).id=Frame(lastFrame).object(order(t)).id;  %store correct order number in frame (lastFrame does not require end protection because hat is built in from object matching)
                    else
                        if isfield(Frame(currentFrame).object,'id')        %if current frame already has objects associated
                            maxobjectnumber=max(...                        %find number of object to use from maximum of current and previous frame
                                max([Frame(lastFrame).object.id]),max([Frame(currentFrame).object.id]))...
                                +1;
                        else                                                %otherwise find from previous frame only
                            maxobjectnumber=max([Frame(lastFrame).object.id])+1;
                        end
                        
                        Frame(currentFrame).object(t).id=maxobjectnumber;
                    end
                end
                
                
                subplot(122)
                if display3d
                    hold on
                    if (t<=current) && order(t)~=0
                        x3d=Frame(currentFrame).object(t).COM(1);
                        y3d=Frame(currentFrame).object(t).COM(2);
                        z3d=Frame(currentFrame).object(t).COM(3);
                        plot3(x3d,y3d,z3d);
                        
                        text(x3d,y3d,z3d,num2str(Frame(currentFrame).object(t).id),'Color','red','FontSize',fontsize);   %print current objects number in red
                        ax = gca;
                        ax.CameraPosition=[0.0193    0.0388   -0.0523];
                        ax.CameraTarget=[-0.5049   -0.3012    2.6540];
                        ax.CameraUpVector=[0.0477   -0.9922   -0.1154];
                        ax.CameraViewAngle=[52.7480];
                        ax.Projection='perspective';
                    end
                end
                if displaycost
                    hold off;
                    plot(0:length(costs),[cost costs])
                    xlim([0 inf])
                    set(gca,'xtick',0:length(costs))
                    str = sprintf('Total cost per number objects removed (Frame %d)', currentFrame);
                    title(str)
                    hold on;
                    
                    plot(0:length(costs),[cost costs+penalty])
                    
                end
                if displayrgb
                     imagesc(imread(sortedrgb{currentFrame}));
                     set(gca,'ydir','reverse')
                     set(gca,'xdir','normal')
                end
                
                
                
            end
            %pause();
            %close all;
            subplot(121)
            
            imagesc(label(:,:,currentFrame));
            str = sprintf('Frame %d after hungarian', currentFrame);
            title(str)
            hold on
            for t=1:current
                if (t<=current)
                    text(Frame(currentFrame).object(t).centroid(1),Frame(currentFrame).object(t).centroid(2),num2str(Frame(currentFrame).object(t).id),'Color','red','FontSize',fontsize);
                end
                if (t<=previous)
                    text(Frame(lastFrame).object(t).centroid(1),Frame(lastFrame).object(t).centroid(2),num2str(Frame(lastFrame).object(t).id),'Color','black','FontSize',fontsize); %print previous frame objects number in black
                end
            end
            
            %pause();
            
        end
        
        %numObj(i)= max(label(:));
        
        lastFrame=currentFrame;                            %store as valid frame
    end
end


end

