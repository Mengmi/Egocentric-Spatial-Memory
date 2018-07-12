clear all; close all; clc;

n_data = 10;
seq = 32;
batch = 299;
w = 5;
load(['/home/mengmi/Proj/Proj_3D/datalist/IROStestframelist_w' num2str(w) '.mat']);

mselossmat = zeros(batch, seq);
Rlossmat = zeros(batch, seq);
MIlossmat = zeros(batch, seq);

for i = 1: batch
    load(['/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld' num2str(w) '/predicted_ucb20e_' num2str(i) '.mat']);
    pred = x;
    
    load(['/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld' num2str(w) '/predicted_ucb20gt_' num2str(i) '.mat']);
    gt = x;
    
    mseloss = [];
    Rloss = [];
    MIloss = [];
    
    framenum = testframelist{i};
    
    for t = 1:seq
        for n = 1: 1
            
            cameraimg = imread(['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/camera_wd/camera_' num2str(framenum+t-1) '.jpg']);
            
            
            pred1 = squeeze(pred(t,n,:,:));
            %always compare with the map at time step 32
            gt1 = squeeze(gt(32,n,:,:));
            
            gt1 = mat2gray(gt1);
            pred1 = mat2gray(pred1);
            mseerror = sum(sum((gt1 - pred1).^2))/(32*32);
            mseloss = [mseloss mseerror];
            
            Rerror = corr2(pred1,gt1);
            Rloss = [Rloss Rerror];
            
            pred1 = int32(255*(pred1));
            gt1 = int32(255*(gt1));
            
%             gtrgb = ind2rgb(gt1, colormap);
%             gtrgb = cat(3, gtrgb, gtrgb, gtrgb);
%             
%             predrgb = ind2rgb(pred1, colormap);
%             predrgb = cat(3, predrgb, predrgb, predrgb);
            
            %pred1 = double(pred1);
            %gt1 = double(gt1);
            
            %imshow(gt1);
            %[MIerror,joint_entropy]=MutualInformation(pred1,gt1);
            [jhist jent MIerror] = ent(pred1,gt1);
            
            %MIerror = KLdiv(pred1, gt1);
            MIloss = [MIloss MIerror];
            
            
            
%             subplot(2,2,1);
%             imshow(mat2gray(pred1));
%             subplot(2,2,2);
%             imshow(mat2gray(gt1));
%             subplot(2,2,3);
%             imshow(cameraimg);
%             
%             pause(0.5);
        end
    end
    
    mselossmat(i,:) = mseloss;
    Rlossmat(i,:) = Rloss;
    MIlossmat(i,:) = MIloss;
end

display('errorWithGTPose: ');
WithGTPose_MSE = mean(mselossmat,1);
WithGTPose_R = mean(Rlossmat,1);
WithGTPose_MI = mean(MIlossmat,1);
%plot(WithGTPose_MI);
display(WithGTPose_MSE(32));
display(WithGTPose_R(32));
display(WithGTPose_MI(32));

% figure;
% hold on;
% plot(WithGTPose_MSE);
% plot(WithGTPose_R);
% plot(WithGTPose_MI);

storecor = Rlossmat;
storemi = MIlossmat;
storemse = mselossmat;

save('DataForPlot/storecor_B.mat','storecor');
save('DataForPlot/storemi_B.mat','storemi');
save('DataForPlot/storemse_B.mat','storemse');
display('save mat');













