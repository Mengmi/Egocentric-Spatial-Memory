function [ pcnew] = fcn_getmeNewPoseMat( pccopy )
%FCN_GETMENEWPOSEMAT Summary of this function goes here
%   Detailed explanation goes here

Rx = 0;
Ry = 0;
Rr = 0;
offset = 0.1;
pcnew = [];

for i =1: length(pccopy)
     
   if pccopy(i) == 1
       Rx = Rx + offset * cos(Rr + pi);
       Ry = Ry + offset * sin(Rr + pi);
       
   elseif pccopy(i) == 2
       
       Rx = Rx + offset * cos(Rr );
       Ry = Ry + offset * sin(Rr );
       
   elseif pccopy(i) == 3
       
       Rx = Rx + offset * cos(Rr + 3*pi/2);
       Ry = Ry + offset * sin(Rr + 3*pi/2);
       
   elseif pccopy(i) == 4
       Rx = Rx + offset * cos(Rr + pi/2);
       Ry = Ry + offset * sin(Rr + pi/2);
       
       
   elseif pccopy(i) == 5
       Rr = Rr + 0.1;
       
   else
       Rr = Rr - 0.1;
       
   end
   
   pcnew = [pcnew; [i Rx Ry Rr pccopy(i)]];
    
end

end

