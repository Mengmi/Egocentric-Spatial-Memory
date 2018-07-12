clear all; close all; clc;

worldrange = [16];
ind = [1:length(worldrange)];

%load gt first
gtstore = {};
for w = worldrange
    load(['DataForPlot/gt_loopclose_w' num2str(w) '.mat']);
    gtstore =[ gtstore; gt];
end

hb = figure;
hold on;

%triplet
load(['DataForPlot/pred_loopclose_w' num2str(worldrange(1)) '.mat']);
[prec, tpr, fpr, thresh] = prec_rec(pred,gtstore{1});
%tpr
plot([0; tpr],[1 ; prec],'r','LineWidth',2);

%bag of words
load(['DataForPlot/pred_BoW_w' num2str(worldrange(1)) '.mat']);
[prec, tpr, fpr, thresh] = prec_rec(pred,gtstore{1});
%tpr
plot([0; tpr],[1 ; prec],'b','LineWidth',2);


%pixel
load(['DataForPlot/pred_Pixelwise_w' num2str(worldrange(1)) '.mat']);
[prec, tpr, fpr, thresh] = prec_rec(pred,gtstore{1});
%tpr
plot([0; tpr],[1 ; prec],'k','LineWidth',2);
    
%random
plot([0 1], [1 0], 'm','LineWidth',2);
xlabel('Recall','FontSize', 16, 'Fontweight', 'bold');
ylabel('Precision','FontSize', 16, 'Fontweight', 'bold');

legend({'Our model','BoW','Pixelwise','Random'},'Location','southwest','FontSize',10);
hold off;

set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(hb,['/media/mengmi/MimiDrive/Publications/IROS_2018/nfigure/PreRecall.pdf'],'-dpdf','-r0')




