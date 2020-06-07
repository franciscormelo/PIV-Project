function [sortedrgb, imgs , imgsd ] = load_gray(im1)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

sortedrgb=natsort({im1.rgb});                   %sort filenames by numerical order
sorteddepth=natsort({im1.depth});

info=imfinfo(sortedrgb{1});                         %get info on file size

%imgrgb=zeros(info.Height,info.Width,3,length(im1));  %matriz 3D com imagens rgb
imgs=zeros(info.Height,info.Width,length(im1));     %matriz 3D com imagens gray
imgsd=imgs;                                         %matriz 3D com imagens depth

for currentFrame=1:length(im1)
    %aux=imread(sortedrgb{currentFrame});                          %guarda imagem em rgb matriz 3D
    %imgrgb(:,:,:,currentFrame)=aux;
    imgs(:,:,currentFrame)=rgb2gray(imread(sortedrgb{currentFrame}));%guarda imagem em gray matriz 3D
    %rgb sao 3 matrizes, em gray so guardamos uma
    
    load(sorteddepth{currentFrame});
    imgsd(:,:,currentFrame)=double(depth_array)/1000;%dupla precisao e conversão para metros
%{    
    figure(1)%rgb
    imshow(uint8(imgs(:,:,currentFrame)));
    
    figure(2);%depth
    imagesc(imgsd(:,:,currentFrame));
    
     figure(3);%rgb
     imagesc(aux); 
    
    colormap(gray);
    %w = waitforbuttonpress;
    pause(1);
 %}   
end

