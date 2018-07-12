clear all; close all; clc;

worldNum = 7;

%imagelist = {38409, 15787, 11099, 22193, 3027,  24600, 29477};
imagelist = {38409, 64};

Up = 1;
Down = 2;
Left = 3;
Right = 4;
RL = 5; %rotate left
RR =6; %rotate right

Sequence = 32;
FW = 128;
scale = 0.06;
A=32;
certainoffset = 0.1*32/(scale*2*FW*16);%0.05*32/128; 0.1 is for physical 0.1 meter offset; move image by 32 pixels for [64 64] then it is -1 

trainworldlist = {};
trainframelist = {};
trainrelative = {};
trainposeindex = {};



%5991 rounds for trainlist
for w = [2]

    display(['processing world: ' num2str(w)]);
    %load(['pose/poseTBWorld' num2str(w) '.mat']); 
    load(['pose/poseWorld' num2str(w) '.mat']); 
    
    px = pose(:,2)/scale;
    py = pose(:,3)/scale;
    pw = pose(:,4);
    pc = pose(:,5);
        
    for i = 1:10: (imagelist{w}-Sequence)
        
        startFrame = i;
        endFrame = i - 1 + Sequence;
        compose  = [];
        poseindexlist = [];
        
        trainworldlist = [trainworldlist; w];
        trainframelist = [trainframelist; i];
        
        for j = startFrame:endFrame          
            
            if j == startFrame
                tform = [cos(0) sin(0) 0; -sin(0) cos(0) 0];
                act = 0;
                
            else
                
                anglenow = wrapToPi(pw(j)); %[-pi pi]
                
                diffw = pw(j-1) - pw(j);
                %tform = [cos(diffw) sin(diffw)  Tconv(1,3)/FW*A; -sin(diffw) cos(diffw) Tconv(2,3)/FW*A];
                
                %%for pose estimation               
                act = pc(j);
                if act >= 5                   
                   tform = [cos(diffw) sin(diffw) 0; -sin(diffw) cos(diffw) 0];              
                end             
                
                
                if act == Up
                    tform = [cos(0) sin(0) -certainoffset; -sin(0) cos(0) 0];
                elseif act == Down
                    tform = [cos(0) sin(0) certainoffset; -sin(0) cos(0) 0];
                elseif act == Left
                    tform = [cos(0) sin(0) 0; -sin(0) cos(0) -certainoffset];
                elseif act == Right
                    tform = [cos(0) sin(0) 0; -sin(0) cos(0) certainoffset];
                end
                
                
                if act == 0
                    error('pose doesnt belong to any 1 - 6');
                end
                
            end            
            poseindexlist = [poseindexlist act];
            compose = [compose tform];
        end
        trainrelative = [trainrelative; compose];
        trainposeindex = [trainposeindex; poseindexlist];
    end
    
end

save(['../../datalist/IROStrainworldlist.mat'],'trainworldlist');
save(['../../datalist/IROStrainframelist.mat'],'trainframelist');
save(['../../datalist/IROStrainrelative.mat'],'trainrelative');
save(['../../datalist/IROStrainposeindex.mat'],'trainposeindex');




% for w = 5
% 
%     testposeindex = {};
%     testworldlist = {};
%     testframelist = {};
%     testrelative = {};
%     
%     display(['processing world: ' num2str(w)]);
%     load(['pose/poseTBWorld' num2str(w) '.mat']);   
%     
%     px = pose(:,2)/scale;
%     py = pose(:,3)/scale;
%     pw = pose(:,4); 
%     pc = pose(:,5);
%     
%     load(['/home/mengmi/Proj/Proj_RGAN/MatlabCode/world/TBactionlist' num2str(w) '.mat']);
%     %this is in Proj_RGAN convention: UP = 3; DOWN = 4; LEFT = 2; RIGHT = 1;
%     %convert to Proj_3D convention: Up = 1; Down = 2; Left = 3; Right = 4;
%     indup = find(actionlist == 3);
%     inddown = find(actionlist == 4);
%     indleft = find(actionlist == 2);
%     indright = find(actionlist == 1);
%     actionlist(indup) = 1;
%     actionlist(inddown) = 2;
%     actionlist(indleft) = 3;
%     actionlist(indright) = 4;
%     actionlist = [pose(1,5); actionlist];
%     pc = actionlist;
%     
%     for i = 1:10: (imagelist{w}-Sequence)
%         
%         startFrame = i;
%         endFrame = i - 1 + Sequence;
%         compose  = [];
%         poseindexlist = [];
%         
%         testworldlist = [testworldlist; w];
%         testframelist = [testframelist; i];
%         
%         for j = startFrame:endFrame          
%             
%             if j == startFrame
%                 tform = [cos(0) sin(0) 0; -sin(0) cos(0) 0];
%                 act = 0;
%                 
%             else
%                 
%                 anglenow = wrapToPi(pw(j)); %[-pi pi]
%                 
%                 diffw = pw(j-1) - pw(j);
%                 %tform = [cos(diffw) sin(diffw)  Tconv(1,3)/FW*A; -sin(diffw) cos(diffw) Tconv(2,3)/FW*A];
%                 
%                 %%for pose estimation               
%                 act = pc(j);
%                 if act >= 5                   
%                    tform = [cos(diffw) sin(diffw) 0; -sin(diffw) cos(diffw) 0];              
%                 end             
%                 
%                 
%                 if act == Up
%                     tform = [cos(0) sin(0) -certainoffset; -sin(0) cos(0) 0];
%                 elseif act == Down
%                     tform = [cos(0) sin(0) certainoffset; -sin(0) cos(0) 0];
%                 elseif act == Left
%                     tform = [cos(0) sin(0) 0; -sin(0) cos(0) -certainoffset];
%                 elseif act == Right
%                     tform = [cos(0) sin(0) 0; -sin(0) cos(0) certainoffset];
%                 end
%                 
%                 
%                 if act == 0
%                     error('pose doesnt belong to any 1 - 6');
%                 end
%                 
%             end                
%             
%             poseindexlist = [poseindexlist act];
%             compose = [compose tform];
%         end
%         
%         testrelative = [testrelative; compose];
%         testposeindex = [testposeindex; poseindexlist];
%     end
%     
%     save(['/home/mengmi/Proj/Proj_3D/datalist/IROStestworldlist_w' num2str(w) '.mat'],'testworldlist');
%     save(['/home/mengmi/Proj/Proj_3D/datalist/IROStestframelist_w' num2str(w) '.mat'],'testframelist');
%     save(['/home/mengmi/Proj/Proj_3D/datalist/IROStestrelative_w' num2str(w) '.mat'],'testrelative');
%     save(['/home/mengmi/Proj/Proj_3D/datalist/IROStestposeindex_w' num2str(w) '.mat'],'testposeindex');
%     
% end


