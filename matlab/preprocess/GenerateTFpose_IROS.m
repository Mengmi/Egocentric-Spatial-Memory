clear all;
close all;
clc;

FW = 128;
scale = 0.06;
certainoffset = 0.1*32/(scale*2*FW*16); %0.0125

tf = [1 0 0; 0 1 0];
save('../../datalist/IROSTransForm_0.mat','tf');


tf = [1,0,-certainoffset;0,1,0];
save('../../datalist/IROSTransForm_1.mat','tf');


tf = [1,0,certainoffset;0,1,0];
save('../../datalist/IROSTransForm_2.mat','tf');


tf = [1,0,0;0,1,certainoffset];
save('../../datalist/IROSTransForm_3.mat','tf');


tf = [1,0,0;0,1,-certainoffset];
save('../../datalist/IROSTransForm_4.mat','tf');

diffw = -45/180*pi;
tf = [cos(diffw) sin(diffw) 0; -sin(diffw) cos(diffw) 0];
save('../../datalist/IROSTransForm_5.mat','tf');


diffw = 45/180*pi;
tf = [cos(diffw) sin(diffw) 0; -sin(diffw) cos(diffw) 0];
save('../../datalist/IROSTransForm_6.mat','tf');