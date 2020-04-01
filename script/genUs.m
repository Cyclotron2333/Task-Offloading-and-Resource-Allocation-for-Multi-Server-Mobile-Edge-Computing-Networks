function [Us,num] = genUs(G,i)
%GenUs 生成服务器对应的用户矩阵
    [~,n,z] = size(G);
    num = 0;
    Us = [];
    for j = 1:n
        for k = 1:z
            if G(i,j,k) > 0
                Us(num) = j;
                num = num + 1;
                break;
            end
        end
    end
return