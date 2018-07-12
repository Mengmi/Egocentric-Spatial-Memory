function [ Rvec ] = fcn_givemelistrandnum(selectrandnum )
%FCN_GIVEMELISTRANDNUM Summary of this function goes here
%   Detailed explanation goes here

    Rvec = [];
    
    for i = 1:selectrandnum
        nr = randperm(6,1);
        Rvec = [Rvec; nr];
    end
end

