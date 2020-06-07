function [objects, cam2toW] = track3D_part2( im1, im2, cam_params )
% CODE TO GET cam2toW
K_rgb = cam_params.Krgb;
Kd = cam_params.Kdepth;
R = cam_params.R;
T = cam_params.T;

Ia = imread(im1(1).rgb);
Ib = imread(im2(1).rgb);
load(im1(1).depth)
dep1 = depth_array;
load(im2(1).depth)
dep2 = depth_array;

[R21, T21] = camera2to1(Ia, Ib, dep1, dep2, Kd, K_rgb, R, T);

cam2toW.R = R21;
cam2toW.T = T21;

[sortedrgb1, imgs , imgsd ] = load_gray(im1);  %load depth files and imahe while converting to gray scale

[bggray,bgdepth] = background(imgs , imgsd); %obtain backgrounds

[label1,numObj1]=labelling(imgs,imgsd,bggray,bgdepth);

[Frame1]=pointclouds(label1,numObj1,sortedrgb1,imgs,imgsd,cam_params);

clear sortedrgb
clear imgs
clear imgsd
clear bggray
clear bgdepth
clear numObj
clear Frame

[sortedrgb2, imgs , imgsd ] = load_gray(im2);  %load depth files and imahe while converting to gray scale

[bggray,bgdepth] = background(imgs , imgsd); %obtain backgrounds

[label2,numObj2]=labelling(imgs,imgsd,bggray,bgdepth);

[Frame2]=pointclouds_TRY(label2,numObj2,sortedrgb2,imgs,imgsd,cam_params, cam2toW);

[joinedFrame] = joinpc(Frame1,Frame2);


[Frame]=hungarian(joinedFrame,label1,sortedrgb1);

[ objects ] = output(Frame);

%load lab1JPC
%cam1toW.R=R1;
%cam1toW.T=T1;

end

