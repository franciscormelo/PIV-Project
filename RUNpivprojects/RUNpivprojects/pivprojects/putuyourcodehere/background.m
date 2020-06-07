function [bggray,bgdepth] = background(imgs , imgsd)
%Calculo background pela MEDIANA!!!!
%calculo da mediana de cada pixel no conjunto das imagnes contidas na matriz
%3D
bgdepthmed=median(imgsd,3); %bg da camara depth
bggray=median(imgs,3); %bg da camara 2D

for currentFrame=1:size(imgs,3)
    
    %gray image
    imdif = imgs(:,:,currentFrame) -bggray;
    imdif = imdif(:);
    erro(currentFrame) = imdif'*imdif;
    
end

[m2, index] = min(erro);
bggray = imgs(:,:,index);
bgdepth=imgsd(:,:,index);

%bgdepth=max(imgsd,[],3); %bg da camara depth com valor máximo 

%{ 
figure(1);
subplot(131);imagesc(bgdepthmed);
subplot(132);imagesc(bgdepth);
subplot(133);imagesc(bgdeptmax);
%}  

end

