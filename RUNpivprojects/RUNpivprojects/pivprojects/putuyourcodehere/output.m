function [ objects ] = output(Frame)
%generate a list of objects, deleting the ones that only occur in one frame
objects(1).X=[];
objects(1).Y=[];
objects(1).Z=[];
objects(1).frames_tracked=[];

for currentFrame=1:length(Frame)
    if ~isempty(Frame(currentFrame).object)
        current=length(Frame(currentFrame).object);       %number of objects in current frame
        for j=1:current
            object_number=Frame(currentFrame).object(j).id;
            if (object_number>length(objects))  %new objects
                objects(object_number).X=[];
                objects(object_number).Y=[];
                objects(object_number).Z=[];
                objects(object_number).frames_tracked=[];
            end
            
            [objects(object_number).X(end+1,:)]=Frame(currentFrame).object(j).box(1,:);
            objects(object_number).Y(end+1,:)=Frame(currentFrame).object(j).box(2,:);
            objects(object_number).Z(end+1,:)=Frame(currentFrame).object(j).box(3,:);
            objects(object_number).frames_tracked(end+1)=currentFrame;
            
        end
    end
end

%remove objects that only appear 1 time(noise)
k=1;
idx=0;
for l=1:length(objects)
    if length(objects(l).frames_tracked) > 1
        idx(k)=l;
        k=k+1;
    end
end
objects=objects(idx);

end

