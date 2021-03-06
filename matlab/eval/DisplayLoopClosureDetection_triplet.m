clear all; close all; clc;

w = 16;
type = 2; %1 for our ESMN; 2 for BoW; 3 for pixelwise
%maze: 16-21
%16: 445 - 500
%17: 289 - 400
%18: 445 - 500
%19: 445 - 500
%20: 289 - 400
%21: 289 - 400

if w == 16 || w == 18 ||w == 19
    gt = zeros(1,500);
    gt(445:end) = 1;
else
    gt = zeros(1,400);
    gt(289:end) = 1;
end
save(['DataForPlot/gt_loopclose_w' num2str(w) '.mat'],'gt');    



load(['pose/poseWorld' num2str(w) '.mat']);  

%load(['/home/mengmi/Proj/Proj_3D/results/MatFormat/loss_triplet7_400.mat']);
if type == 1
    load(['/home/mengmi/Proj/Proj_3D/results/MatFormat/loss_triplet7_w' num2str(w) '.mat']);
elseif type == 2
    load(['/home/mengmi/Proj/Proj_3D/results/MatFormat/loss_BoW_w' num2str(w) '.mat']);
else
    load(['/home/mengmi/Proj/Proj_3D/results/MatFormat/loss_pixelwise_w' num2str(w) '.mat']);
end


img = x;
mapscale = size(img,1);
%img = triu(img);

%figure;
imshow(mat2gray(img));
img = mat2gray(img);

if type~=2
    normimg = 1 - img;
else
    normimg = img;
end

%figure;
imshow(mat2gray(img<0.02));

%figure;

ind = find(img<=1);
si = size(img);
[row,col] = ind2sub(si,ind);

% time constraints; episodes too near; dont fire
dist = (row - col).^2;
row(dist<6400) = [];
col(dist<6400) = [];
Gxy = (row-1)*mapscale + col; 
Ibinary = zeros(mapscale,mapscale);
Ibinary(Gxy) = 1;
imshow(Ibinary);


% % spatial constraints; only consider spatial coordinates near to each other
if type == 1 || type == 2 
    index = [];
    for i = 1: length(row)
        p1 = pose(row(i),2:3);
        p2 = pose(col(i),2:3);

        dist = sum((p1 - p2).^2);

        if dist >= 10
            index = [index; i];
        end
    end
    row(index) = [];
    col(index) = [];
end



%display only lower triangle
index = find(row<=col);
row(index) = [];
col(index) = [];

%figure;
Gxy = (row-1)*mapscale + col; 
Ibinary = zeros(mapscale,mapscale);
Ibinary(Gxy) = 1;
imshow(Ibinary);
%plot(col, row,'r*');
xlabel('anchor');
% xticks([1 100 200 300 400])
% xticklabels({'1st','100th','200th','300th','400th'});
ylabel('episodes in memory (time order)');
%xlim([0 400]);
%ylim([0 400]);
%hold on;
%plot([1:1:400]);
%img = 255*ones(400,400,3);
%heatmap = heatmap_overlay( img ,Ibinary);
%imshow(heatmap)
%surf(Ibinary)

pred = Ibinary.*normimg;
pred = max(pred,[],1);

if type == 1
    save(['DataForPlot/pred_loopclose_w' num2str(w) '.mat'],'pred');
elseif type == 2
    save(['DataForPlot/pred_BoW_w' num2str(w) '.mat'],'pred');
else
    save(['DataForPlot/pred_Pixelwise_w' num2str(w) '.mat'],'pred');
end


%figure;
% for i = 1:196
%     i;
%     imgname1 = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/camera_temp/camera_' num2str(row(i)) '.jpg'];
%     imgname2 = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/camera_temp/camera_' num2str(col(i)) '.jpg'];
%     im1 = imread(imgname1);
%     im2 = imread(imgname2);
%     subplot(2,2,1);
%     imshow(imresize(im1, [300 300]));
%     title('episodes');
%     
%     subplot(2,2,2);
%     imshow(imresize(im2, [300 300]));    
%     title('anchor');
%     
%     subplot(2,2,3);
%     oriimgname = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World9/map_global_all_temp/map_1_' num2str(row(i)) '.jpg'];
%     oriimg = imread(oriimgname);
%     oriimg = imresize(oriimg, [300 300]);
%     imshow(oriimg);
%     hold on;
%     plot(150,150, 'y*');
%     hold off;
%     title('place cell firing places (gt)');
%     
%     subplot(2,2,4);
%     load(['/home/mengmi/Proj/Proj_3D/results/MatFormat/predicted_ucb20gwp_' num2str(row(i)) '.mat']);
%     img = x;
%     img = imresize(img, [300 300]);    
%     %imshow(mat2gray(img));
%     imagesc(img);
%     hold on;
%     plot(150,150, 'r*');
%     %title('pred with estimated pose');
%     hold off; 
%     set(gca,'XTick',[]);
%     set(gca,'YTick',[]);
%     title('place cell firing places (pred)');
%     %set(gca,'Position',[0 0 1 1])
%     
%     drawnow;
%     %pause;
%     
%     frame = getframe(1); 
%     im{i} = frame2im(frame); 
%     
% end

% filename = 'placecellduel.gif'; % Specify the output file name
% nImages = 196;
% for idx = 1:nImages
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
%     end
% end 
