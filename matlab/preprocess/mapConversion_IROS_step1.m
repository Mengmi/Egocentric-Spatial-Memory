clear all; clc; close all;

worldNum = 7; %2D3DS dataset

%imagelist = {38409, 15787, 11099, 22193, 3027,  24600, 29477};
imagelist = {0 64};

% 9 10 12 13; 15
for w = [2]
    
    display(['Processing world: ' num2str(w)]);
    
    imageNum = imagelist{w};
    prefixFile = ['../../Data/world' num2str(w) '/map/map_']; %from ros raw map
    saveConverted = ['../../Data/world' num2str(w) '/map_converted/map_'];%color local
    %saveBinary = ['../../Data/world' num2str(w) '/map_binary/map_']; %binary boudary local
    %saveTrain = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_train/map_']; %voxels
    %saveFreeConverted = ['../../Data/world' num2str(w) '/map_global_local/map_']; %binary free local
    prefixCamera = ['../../Data/world' num2str(w) '/camera_wd/camera_'];
    
    for i = 1:imageNum
        i
        voxels = zeros(32,32,32);
        
        for j = 1: 1%32
            
            special = 1;          
            if ~exist([prefixFile  num2str(i) '_' num2str(special) '.jpg'], 'file') 
                error(['File: non-exist: ' prefixFile  num2str(i) '_' num2str(special) '.jpg']);
                continue;
            end                
            
            special = 1;
            
            %read in image
            I = imread([prefixFile  num2str(i) '_' num2str(special) '.jpg']);
            I = double(I);
            I = mat2gray(I);

            %rotate image
            Ir = imrotate(I,180);
            %imshow(Ir);

            %crop image
            IROI = Ir(1:100,50:149);
            %imshow(IROI);
            IROIresize = imresize(IROI, [32 32]);
            imwrite(IROIresize,[saveConverted num2str(i) '_' num2str(j) '.jpg']);
            
%             %save binary free space
%             BINIROI = mat2gray(IROI);
%             BINIROI = im2bw(BINIROI, 0.6);
%             BINIROIresize = imresize(BINIROI, [32 32]);
%             imwrite(BINIROIresize,[saveFreeConverted num2str(i) '_' num2str(j) '.jpg']);

            %to binary image
            Ib = mat2gray(IROI);
            Ib = im2bw(Ib, 0.2);
            Ib = ~Ib;
            %imshow(Ib);

            %thickening
            Ib = double(Ib);
            h = ones(5,5);
            If = imfilter(Ib, h);
            %imshow(If);

            %to binary image
            Ibb = im2bw(If, 0.2);
            %imshow(Ibb);

            %to resize image
            Ifinal = imresize(Ibb, [32 32]);
            %imshow(Ifinal);            
            %imwrite(Ifinal,[saveBinary num2str(i) '_' num2str(j) '.jpg']);
            
            %store in voxels            
            voxels(:,:,j) = Ifinal;
            
        end
        
%         I = imread([prefixCamera  num2str(i) '.jpg']);
%         subplot(1,4,1);
%         imshow(I);
%         title('camera view');
%         
%         I = imread([saveConverted  num2str(i) '_1.jpg']);
%         subplot(1,4,2);
%         imshow(I);
%         title('From ROS');
%         
%         I = imread([saveBinary  num2str(i) '_1.jpg']);
%         subplot(1,4,3);
%         imshow(I);
%         title('top view');
%         
%         subplot(1,4,4);          
%         index = find(voxels == 1);
%         [I1,I2,I3] = ind2sub(size(voxels),index);
%         scatter3(I1,I2,I3,'filled');
%         xlim([0 32]);
%         ylim([0 32]);
%         zlim([0 32]);
%         xlabel('x');
%         ylabel('y');
%         zlabel('z');
%         view(62,40);
%         title('3D occu map');
%         
%         drawnow;        
%         pause(0.1);
        
        %save([saveTrain num2str(i) '.mat'],'voxels');        
        
    end
end
