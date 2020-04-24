function [Us,num] = comparation_genUs(G,server)
%GenUs 生成服务器对应的用户矩阵
    [Us(:,1),Us(:,2)] = find(G(:,server,:)>0);
    [num,~] = size(Us(:,1));
end