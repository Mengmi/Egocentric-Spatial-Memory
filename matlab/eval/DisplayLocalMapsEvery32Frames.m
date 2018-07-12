close all; clc; clear all;

%% three plots
predmark = {'r','c','b','g','k--'};

hb = figure;
hold on;
i = 1;
load('DataForPlot/storemse.mat');
errorbar([1:32],nanmean(storemse,1),std(storemse,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemse_thres_maze.mat');
errorbar([1:32],nanmean(storemse,1),std(storemse,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemse_B.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storemse,1),100);
    chosenstore = [chosenstore; nanmean(storemse(rind,:),1)];
end
storemse = chosenstore;
errorbar([1:32],nanmean(storemse,1),std(storemse,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemse_thres.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storemse,1),100);
    chosenstore = [chosenstore; nanmean(storemse(rind,:),1)];
end
storemse = chosenstore;
errorbar([1:32],nanmean(storemse,1),std(storemse,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemse_random.mat');
plot([1:32],ones(1,32)*nanmean(storemse),predmark{i},'LineWidth',2);

xlabel('Time Steps','FontSize', 16, 'Fontweight', 'bold');
ylabel('normalized Mean Squared Error','FontSize', 16, 'Fontweight', 'bold');
xlim([0 32]);
breakyaxis([0.13 0.3]);
legend({'ESMN(Maze)','BiClassi(Maze)','ESMN(Indoor)','BiClassi(Indoor)','Chance'},'Location','southwest','FontSize',10);
hold off;

set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(hb,['/media/mengmi/MimiDrive/Publications/IROS_2018/nfigure/MSE.pdf'],'-dpdf','-r0')




hb = figure;
hold on;
i = 1;
load('DataForPlot/storecor.mat');
errorbar([1:32],nanmean(storecor,1),std(storecor,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storecor_thres_maze.mat');
errorbar([1:32],nanmean(storecor,1),std(storecor,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storecor_B.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storecor,1),100);
    chosenstore = [chosenstore; nanmean(storecor(rind,:),1)];
end
storecor = chosenstore;
errorbar([1:32],nanmean(storecor,1),std(storecor,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storecor_thres.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storecor,1),100);
    chosenstore = [chosenstore; nanmean(storecor(rind,:),1)];
end
storecor = chosenstore;
errorbar([1:32],nanmean(storecor,1),std(storecor,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storecor_random.mat');
plot([1:32],ones(1,32)*nanmean(storecor),predmark{i},'LineWidth',2);


xlabel('Time Steps','FontSize', 16, 'Fontweight', 'bold');
ylabel('Correlation','FontSize', 16, 'Fontweight', 'bold');
xlim([0 32]);
breakyaxis([0.1 0.3]);
ylim([0.02 0.34]);
legend({'ESMN(Maze)','BiClassi(Maze)','ESMN(Indoor)','BiClassi(Indoor)','Chance'},'Location','northwest','FontSize',10);
hold off;

set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(hb,['/media/mengmi/MimiDrive/Publications/IROS_2018/nfigure/COR.pdf'],'-dpdf','-r0')


hb = figure;
hold on;
i = 1;
load('DataForPlot/storemi.mat');
errorbar([1:32],nanmean(storemi,1),std(storemi,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemi_thres_maze.mat');
errorbar([1:32],nanmean(storemi,1),std(storemi,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemi_B.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storemi,1),100);
    chosenstore = [chosenstore; nanmean(storemi(rind,:),1)];
end
storemi = chosenstore;
errorbar([1:32],nanmean(storemi,1),std(storemi,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemi_thres.mat');
chosenstore = [];
randomgp = 3;
for j = 1: randomgp
    rind = randperm(size(storemi,1),100);
    chosenstore = [chosenstore; nanmean(storemi(rind,:),1)];
end
storemi = chosenstore;
errorbar([1:32],nanmean(storemi,1),std(storemi,0,1),predmark{i},'LineWidth',2);
i = i+1;
load('DataForPlot/storemi_random.mat');
plot([1:32],ones(1,32)*nanmean(storemi),predmark{i},'LineWidth',2);


xlabel('Time Steps','FontSize', 16, 'Fontweight', 'bold');
ylabel('Mutual Information','FontSize', 16, 'Fontweight', 'bold');
xlim([0 32]);
legend({'ESMN(Maze)','BiClassi(Maze)','ESMN(Indoor)','BiClassi(Indoor)','Chance'},'Location','northwest','FontSize',10);
hold off;

set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(hb,['/media/mengmi/MimiDrive/Publications/IROS_2018/nfigure/MI.pdf'],'-dpdf','-r0')


