function [R21, T21] = camera2to1(RGB1, RGB2, dep1, dep2, Kd, K_rgb, R, T)
% load cameraparametersAsus.mat
% K_rgb = cam_params.Krgb;
% Kd = cam_params.Kdepth;
% R = cam_params.R;
% T = cam_params.T;
% 
% Ia = imread('rgb_image1_1.png');
% Ib = imread('rgb_image2_1.png');
% 
% load depth1_1.mat
% dep1 = depth_array;
% load depth2_1.mat
% dep2 = depth_array;
Ia = RGB1;
Ib = RGB2;

xyz_1 = get_xyzasus(dep1(:),[480 640],(1:480*640)',Kd,1,0);
xyz_2 = get_xyzasus(dep2(:),[480 640],(1:480*640)',Kd,1,0);

rgbd_1 = get_rgbd(xyz_1, Ia, R, T, K_rgb);
rgbd_2 = get_rgbd(xyz_2, Ib, R, T, K_rgb);

% pc1 = pointCloud(xyz_1, 'Color', reshape(rgbd_1,[480*640 3]));
% pcshow(pc1)

Ia = single(rgb2gray(rgbd_1));
Ib = single(rgb2gray(rgbd_2));

[fa, da] = vl_sift(Ia) ;
[fb, db] = vl_sift(Ib) ;

thresh = 2;
[matches, score] = vl_ubcmatch (da, db, thresh);

xa = fa(1,matches(1,:));
xb = fb(1,matches(2,:));
%xb = fb(1,matches(2,:)) + size(Ia,2) ;
ya = fa(2,matches(1,:));
yb = fb(2,matches(2,:));

% figure(2) ; clf ;
% imagesc(cat(2, rgbd_1, rgbd_2)) ;
% 
% hold on ;
% h = line([xa ; xb], [ya ; yb]) ;
% set(h,'linewidth', 1, 'color', 'b') ;
% 
% vl_plotframe(fa(:,matches(1,:))) ;
% fb(1,:) = fb(1,:) + size(Ia,2) ;
% vl_plotframe(fb(:,matches(2,:))) ;
% axis image off ;

ind1=sub2ind(size(dep1),fix(ya),fix(xa));
ind2=sub2ind(size(dep2),fix(yb),fix(xb));

P1=xyz_1(ind1,:);

P2=xyz_2(ind2,:);

inds=find((P1(:,3).*P2(:,3))>0);

P1=P1(inds,:);
P2=P2(inds,:);

x = P1;
y = P2;


[inliers, dist] = ransacWiki(x, y, 0.25, 0.05); 


[d,~,tr] = procrustes(x(inliers,:),y(inliers,:),'scaling',false,'reflection',false);

% error = vecnorm((x(inliers,:) - (y(inliers,:)*tr.T + ones(length(y(inliers,:)),1)*tr.c(1,:)))')';

% n21 = y*tr.T + ones(length(y),1)*tr.c(1,:);

% xyz21=xyz_2*tr.T+ones(length(xyz_2),1)*tr.c(1,:);
% pc1=pointCloud(xyz_1,'Color',reshape(rgbd_1,[480*640 3]));
% pc2=pointCloud(xyz21,'Color',reshape(rgbd_2,[480*640 3]));
% figure(1);clf; showPointCloud(pc1); view(0,-90);
% figure(2);clf; showPointCloud(pc2); view(0,-90);
% figure;pcshow(pcmerge(pc1,pc2,0.001));
% view(0,-90);

% test1 = K_rgb*[R T]*[x(inliers,:)';ones(1,length(inliers))];
% u1 = test1(1,:)./test1(3,:);
% v1 = test1(2,:)./test1(3,:);
% 
% test2 = K_rgb*[R T]*[y(inliers,:)';ones(1,length(inliers))];
% u2 = test2(1,:)./test2(3,:);
% v2 = test2(2,:)./test2(3,:);
% 
% test21 = K_rgb*[R T]*[n21(inliers,:)';ones(1,length(inliers))];
% u21 = test21(1,:)./test21(3,:);
% v21 = test21(2,:)./test21(3,:);
% 
% figure()
% imshow(rgbd_1); hold on;
% plot(u1,v1, 'g*'); hold on;
% plot(u21, v21, 'y*');
% figure()
% imshow(rgbd_2); hold on;
% plot(u2,v2, 'y*');

R21 = tr.T;
T21 = tr.c(1,:)';
end