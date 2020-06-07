function [objects] = track3D_part1( im1, cams )

[sortedrgb, imgs , imgsd ] = load_gray(im1);  %load depth files and imahe while converting to gray scale

[bggray,bgdepth] = background(imgs , imgsd); %obtain backgrounds

[label,numObj]=labelling(imgs,imgsd,bggray,bgdepth);

[Frame]=pointclouds(label,numObj,sortedrgb,imgs,imgsd,cams);

[Frame]=hungarian(Frame,label,sortedrgb);

[ objects ] = output(Frame);    %generate object list

%load lab1JPC
%cam1toW.R=R1;
%cam1toW.T=T1;
%cam2toW.R=R2;
%cam2toW.T=T2;
