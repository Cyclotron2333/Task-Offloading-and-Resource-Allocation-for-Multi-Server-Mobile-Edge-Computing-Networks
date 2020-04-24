function [J, X, F] = optimize_exhausted(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                       % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber ...
    )

%optimize 负责执行优化操作
    tu_local = zeros(userNumber,1);
    Eu_local = zeros(userNumber,1);
    for i = 1:userNumber    %初始化任务矩阵
        tu_local(i) = Tu(i).circle/Fu(i);   %本地计算时间矩阵
        Eu_local(i) = k * (Fu(i))^2 * Tu(i).circle;    %本地计算能耗矩阵
    end
    Eta_user = zeros(userNumber,1);
    for i=1:userNumber  %计算CRA所需的η
        Eta_user(i) = beta_time(i) * Tu(i).circle * lamda(i) / tu_local(i);
    end
    
    %封装参数
    para.beta_time = beta_time;
    para.beta_enengy = beta_enengy;
    para.Tu = Tu;
    para.tu_local = tu_local;
    para.Eu_local = Eu_local;
    para.W = W;
    para.Ht = H;
    para.lamda = lamda;
    para.Pu = Pu;
    para.Sigma_square = Sigma_square;
    para.Fs = Fs;
    para.Eta_user = Eta_user;
    
   [J, X, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    para ...                    % 所需参数
    );

end

function [J, X, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    para ...                    % 所需参数
)
%TA Task allocation,任务分配算法，采用穷举法

    x = zeros(userNumber, serverNumber,sub_bandNumber);
    
    global array index;
    
    array = struct;
    index = 1;
    
    search(1,x,userNumber,serverNumber,sub_bandNumber,para);
    
    [J,num] = max([array.J]);
    X = array(num).F;
    F = array(num).x;
    
    clear global;
end
 
function search(user,x,userNumber,serverNumber,sub_bandNumber,para)
    global array index;
    if user <= userNumber
        for server = 1:serverNumber
            for band = 1:sub_bandNumber
                x(user,server,band) = 1;
                [J, F] = Fx(x,para);
                array(index).J = J;
                array(index).F = F;
                array(index).x = x;
                index = index + 1;
                search(user+1,x,userNumber,serverNumber,sub_bandNumber,para);
                x(user,server,band) = 0;
            end
        end
    end
end
