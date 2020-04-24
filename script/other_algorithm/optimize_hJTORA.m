function [J, X, F] = optimize_hJTORA(Fu,Fs,Tu,W,Pu,H,...
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
    para...                     % 所需参数
)
%TA Task allocation,任务分配算法
%采用论文“Joint Task Of?oading and Resource Allocation for Multi-Server Mobile-Edge Computing Networks”的算法

    X = genOriginX(userNumber, serverNumber,sub_bandNumber,para);    %得到初始解
    [J, F] = Fx(X,para);
    
    picture = zeros(2,1);
    iterations = 1;
    flag = 1;
    while(flag == 1)
        flag = 0;
        [X,J,F,not_find_remove] = remove(X,userNumber,serverNumber,sub_bandNumber,para);
        if not_find_remove == 1
            [X,J,F,not_find_exchange] = exchange(X,userNumber,serverNumber,sub_bandNumber,para);
            if not_find_exchange == 0
                flag = 1;
            end
        end
        picture(iterations,1) = iterations;
        picture(iterations,2) = J;
        iterations = iterations + 1;
    end
%     figure
%     plot(picture(:,1),picture(:,2),'b-.');
%     title('hJTORA算法进行任务调度优化');
%     xlabel('迭代次数');
%     ylabel('目标函数值');
end
 
function [res,old_J,old_F,not_find] = remove(x,userNumber,serverNumber,sub_bandNumber,para)
    user = 1;
    server = 1;
    band = 1;
    not_find = 1;
    [old_J,old_F] = Fx(x,para);
    while not_find == 1 && user ~= userNumber && server ~= serverNumber && band ~= sub_bandNumber
        not_find = 1;
        for user=1:userNumber
            for server=1:serverNumber
                for band=1:sub_bandNumber
                    if x(user,server,band) == 1
                        x(user,server,band) = 0;
                        [new_J,new_F] = Fx(x,para);
                        if new_J > (1 + 1/1000)*old_J
                            not_find = 0;
                            old_J = new_J;
                            old_F = new_F;
                            break;
                        else
                            x(user,server,band) = 1;
                        end
                    end
                end
                if not_find == 0
                    break
                end
            end
            if not_find == 0
                break
            end
        end
    end
    res = x;
end

function [res,old_J,old_F,not_find] = exchange(x,userNumber,serverNumber,sub_bandNumber,para)
    not_find = 1;
    [old_J,old_F] = Fx(x,para);
    x_new = x;
    for user=1:userNumber
        for server=1:serverNumber
            for band=1:sub_bandNumber
                if x(user,server,band) == 0
                    x_new(user,:,:) = 0;
                    x_new(user,server,band) = 1;
                    [new_J,new_F] = Fx(x_new,para);
                    if new_J > (1 + 1/1000)*old_J
                        not_find = 0;
                        old_J = new_J;
                        old_F = new_F;
                        x = x_new;
                        break;
                    else
                        x_new = x;
                    end
                end
            end
            if not_find == 0
                break
            end
        end
        if not_find == 0
            break
        end
    end
    res = x;
end

function seed = genOriginX(userNumber, serverNumber,sub_bandNumber,para)
%GenLargestSeed
    seed = zeros(userNumber, serverNumber,sub_bandNumber);
    old_J = zeros(userNumber, serverNumber,sub_bandNumber);
    for user=1:userNumber
        for server=1:serverNumber
            for band=1:sub_bandNumber
                seed(user,server,band) = 1;
                [old_J(user,server,band),~] = Fx(seed,para);
                seed(user,server,band) = 0;
            end
        end
    end
    [user,server,band] = ind2sub(size(old_J),find(old_J == max(old_J(:))));
    seed(user(1),server(1),band(1)) = 1;
end
