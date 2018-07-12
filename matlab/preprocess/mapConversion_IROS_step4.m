clear all; close all; clc;
%generate accumulative global map from t = 1 to the last frame in the
%dataset


worldNum = 7;

imagelist = {38409, 15787, 11099, 22193, 3027,  24600, 29477};

Sequence = 32;
W=1500;
A=32;
scale = 0.06;
tfGM = affine2d();
FW = 250;

for w = [5]%worldNum

    display(['processing world: ' num2str(w)]);
    load(['pose/poseTBWorld' num2str(w) '.mat']);
    %prefixGMP = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World' num2str(w) '/map_global/map_'];
    
    %save as local map
    prefixGMPR = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_global_all_converted/map_'];
    %save as global map
    prefixGMPR2 = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_global_all_converted/Mmap_'];
    
    px = pose(:,2)/scale;
    py = pose(:,3)/scale;
    pw = pose(:,4); 
%     min(min(px))
%     min(min(py))
%     max(max(px))
%     max(max(py))
    
    %for i = 1:10: (imagelist{w}-Sequence)

       %global world map        
        M = zeros(W,W);
        GM = zeros(W,W);
        startFrame = 1;
        endFrame = imagelist{w};
        i = 1;
        for j = startFrame:endFrame
            j
            %if exist([prefixGMPR num2str(i) '_' num2str(j-startFrame+1) '.jpg'], 'file') == 2
                %continue;
            %end
            
            tform = [cos(pw(j)) -sin(pw(j)) px(j); sin(pw(j)) cos(pw(j)) py(j); 0 0 1];
            GM = zeros(W,W);
            EM = zeros(2*FW,2*FW);
            
            %recover physical dim of local map
            localM = imread(['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_converted/map_' num2str(j) '_1.jpg']);            
            localM = imresize(localM, [100 100]);
            localM = mat2gray(localM);
            localM = im2bw(localM, 0.6);
            
            subplot(1,3,1);
            imshow(localM);
            hold on;
            plot(50,100,'r*');
            hold off;
            title('gt: local map');


            %recover coordinate in local map
            index = find(localM==1);
            [cx,cy] = ind2sub(size(localM),index);
            cx = cx- 100;
            cy = cy - 50;    
            cx = floor(cx);
            cy = floor(cy);
            cxy = [cx cy ones(length(cx),1)];            

            %% occupied
            Gx = [];
            Gy = [];
            for k = 1: length(cx)
                temp = tform * (cxy(k,:)');
                Gx = [Gx; temp(1)];
                Gy = [Gy; temp(2)];
            end

            Gxp = ceil(Gx + W/2);
            Gyp = ceil(Gy + W/2);
            Gxy = Gxp*W + Gyp;    
            M(Gxy) = 1;

            %% plot only 
            subplot(1,3,2);
            imshow(imresize(mat2gray(M),[W W]));
            hold on;
            plot(W/2,W/2,'r*');
            hold off;
            title('global map');
            drawnow;
%             
            %% warping back to egocentric coordinate
            %Create a 3-by-3 transformation matrix, called T in this example, that defines the transformation. 
            %In this matrix, T(3,1) specifies the number of pixels to shift the image in the horizontal direction
            %and T(3,2) specifies the number of pixels to shift the image in the vertical direction.
            %
            %Apply 10-Degree Counter-Clockwise rotation to Image Using imwarp Function
            %theta = 10;tform = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1])
            index = find(M==1);
            [cy,cx] = ind2sub(size(M),index);
            cx =  cx - W/2;
            cy = cy - W/2;
            cx = floor(cx);
            cy = floor(cy);
            cxy = [cx cy ones(length(cx),1)];
            Gx = [];
            Gy = [];
            for k = 1: length(cx)
                temp = inv(tform) * (cxy(k,:)');
                Gx = [Gx; temp(1)];
                Gy = [Gy; temp(2)];
            end
            Gxp = ceil(Gx + W/2);
            Gyp = ceil(Gy + W/2);
            Gxy = Gxp*W + Gyp;    
            GM(Gxy) = 1;
            
            
             t90 = -90/180*3.141592653;
%             %T = [cos(-pw(j)+t90) -sin(-pw(j)+t90) 0; sin(-pw(j)+t90) cos(-pw(j)+t90) 0; 0 0 1];
%             %tfGM = affine2d(T);
%             %GM = imwarp(mat2gray(FlipM),tfGM);  
             GM = imrotate(GM, radtodeg(0+t90));
%             GM = imtranslate(GM,[py(j), px(j)]);
%             %GM = imrotate(GM, radtodeg(-pw(j)+t90));
             GM = flipdim(GM,2);
            
            ss = size(GM,1);
            ss = ceil(ss/2);
            ssl = ss - FW;
            ssr = ssl + 2*FW-1;
            ssu = ssl;
            ssd = ssr;
            EM = GM(ssl: ssr, ssu:ssd);
            
            se = strel('disk',4,4);
            EM = imclose(EM, se);
            
            subplot(1,3,3);
            imshow(EM);
            hold on;
            plot(FW, FW, 'r*');
            hold off;
            title('GMR');
            drawnow;
             
             pause;
            imwrite(EM, [prefixGMPR num2str(i) '_' num2str(j-startFrame+1) '.jpg']);
            imwrite(imresize(mat2gray(M),[W W]), [prefixGMPR2 num2str(i) '_' num2str(j-startFrame+1) '.jpg']);
         end
    %end
end
