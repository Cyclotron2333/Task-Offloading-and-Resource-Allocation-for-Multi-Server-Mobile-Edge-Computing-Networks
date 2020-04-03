function [J, X, P, F] = ta( ...
    userNumber,...              % 用户个数
    serverNumber,...            % 服务器个数
    sub_bandNumber,...          % 子带个数
    T,...                       % 初始化温度值
    T_min,...                   % 温度下界
    alpha,...                   % 温度的下降率
    k, ...                      % 邻域解空间的大小
    minimal_cost,...            % 最小目标值（函数值越小，则适应度越高）
    para...                     % 所需参数
)
%TA Task allocation,任务分配算法，采用模拟退火算法

    %T=1000;         
    %T_min=1e-12;    
    %alpha=0.98;     
    %k=1000;         

    x= genRandSeed(userNumber, serverNumber,sub_bandNumber);    %随机得到初始解
    
    picture = zeros(2,1);
    index = 1;
    
    while(T>T_min)
        for I=1:k
            G = convert2G(x,userNumber, serverNumber,sub_bandNumber);
            [fx, P, F] = Fx(G,para);
            J = fx;
            x_new = getneighbourhood(x,userNumber, serverNumber,sub_bandNumber);
            G_new = convert2G(x_new,userNumber, serverNumber,sub_bandNumber);
            [fx_new, P_new, F_new] = Fx(G_new,para);
            delta = fx_new-fx;
            if (delta<0)
                x = x_new;
                J = fx_new;
                X = x;
                P = P_new;
                F = F_new;
                if fx_new < minimal_cost
                    picture(index,1) = T;
                    picture(index,2) = J;
                    figure
                    plot(picture(1),picture(2))
                    return;
                end
            else
                pro=getProbability(delta,T);
                if(pro>rand)
                    x=x_new;
                end
            end
        end
        picture(index,1) = T;
        picture(index,2) = J;
        index = index + 1;
        T=T*alpha;
    end
    figure
    plot(picture(1),picture(2))
end
 
function res = getneighbourhood(x,userNumber,serverNumber,sub_bandNumber)
    user = unidrnd(userNumber);
    for server = 1:serverNumber
        if x(user,server) ~= 0
            break;  %找到用户所分配的服务器
        end
    end
    %两种扰动方式，交换或者赋值
    if rand > 0.3   %更改某个用户的频带和服务器
        x(user,server) = 0;     %取消原来的分配
        band_flag = zeros(sub_bandNumber,2);    %频带使用情况的标记数组
        if rand > 0.6   %更改用户的服务器
            vary_server = unidrnd(serverNumber);    %目标服务器
            for i=1:userNumber  %使用一轮循环进行标记
                if x(i,vary_server) ~= 0
                    band_flag(x(i,vary_server),1) = 1;      %第一维是1说明已经使用
                    band_flag(x(i,vary_server),2) = i;      %第二维标记是谁用的
                end
            end
            vacancy = 0;
            for j=1:sub_bandNumber  %使用一轮循环查找空缺的频带
                if band_flag(j,1) ~= 1
                    vacancy = 1;
                    x(user,vary_server) = j;
                    break;
                end
            end
            if vacancy == 0     %如果没有空缺的频带
                vary_band = unidrnd(sub_bandNumber);
                victimeUser = band_flag(vary_band,2);
                x(victimeUser,vary_server) = 0;
                x(user,vary_server) = vary_band;   %随便找另一个用户的丢一个给他
            end
        else    %更改用户的频带（也是在选择是否offload）
            vary_band = unidrnd(sub_bandNumber+1)-1;    %目标频带
            if vary_band ~= 0    %如果不是更改至本地执行，可能会产生冲突，要进行检查处理
                for i=1:userNumber  %使用一轮循环进行标记
                    if x(i,server) ~= 0
                        band_flag(x(i,server),1) = 1;      %第一维是1说明已经使用
                        band_flag(x(i,server),2) = i;      %第二维标记是谁用的
                    end
                end
                if band_flag(vary_band,1) == 1  %如果这个频带被使用了，要给原先的用户分配一个自带
                    victimeUser = band_flag(vary_band,2);
                    vacancy = 0;
                    for j=1:sub_bandNumber  %使用一轮循环查找空缺的频带
                        if band_flag(j,1) ~= 1
                            vacancy = 1;
                            x(victimeUser,server) = j;
                            break;
                        end
                    end
                    if vacancy == 0     %如果没有空缺的频带，那就拜拜了，自己算吧
                        x(victimeUser,server) = 0;
                    end
                end
            end
            x(user,server) = vary_band;
        end
    else    %交换两个用户的服务器和频带
        user_other = unidrnd(userNumber);
        server_other = unidrnd(serverNumber);
        temp_band = x(user,server);
        x(user,server) = 0;
        x(user,server_other) = x(user_other,server_other);  %更改频带和服务器
        x(user_other,server_other) = 0;
        x(user_other,server) = temp_band;
    end
    res = x;
end
 
function p = getProbability(delta,t)
    p=exp(-delta/t);
end

function G = convert2G(pop,userNumber, serverNumber,sub_bandNumber)
%Convert2G  将pop矩阵转化为G矩阵
    G = zeros(userNumber, serverNumber,sub_bandNumber);
    for user=1:userNumber
        for server=1:serverNumber
            sub = pop(user, server);
            if sub ~= 0
                G(user, server,sub) = 1;
            end
        end
    end
end

function pop = genRandSeed(userNumber, serverNumber,sub_bandNumber)
%GenRandSeed    生成满足约束的随机种子矩阵
    pop = zeros(userNumber, serverNumber);
    for server=1:serverNumber
        if sub_bandNumber >= userNumber
            pop(:,server) = randperm(sub_bandNumber+1,userNumber) - 1;    %为每个服务器随机分配最多N个用户
        else
            temp = randperm(sub_bandNumber+1,sub_bandNumber) - 1;
            member = randperm(userNumber,sub_bandNumber);
            pop(member,server) = temp;
        end
    end
    for user=1:userNumber
        number = 0;
        notzero = [];
        for server=1:serverNumber   %统计该维度中不为零元素个数
            if pop(user,server) ~= 0
                number = number + 1;
                notzero(number) = server;
            end
        end
        if number > 1
            chosen = unidrnd(number);
            for server=1:number
                if server~=chosen
                    pop(user,notzero(server)) = 0;
                end
            end
        end
    end
end

function [Jx, P, F] = Fx(x,para)
    [P,res_pra] = pra(x,para.beta_time,para.beta_enengy,para.Tu,para.tu_local,para.Eu_local,para.W,para.Ht,para.Pu,para.Sigma,para.r,para.Epsilon,para.beta,para.lamda);
    [F,res_cra] = cra(x,para.Fs,para.Eta_user);
    Jx = 0;
    [~,serverNumber,~] = size(x);
    for server = 1:serverNumber
       [Us,n] = genUs(x,server);
        if n > 0
            for user = 1:n
                Kappa = getKappa(x,user,server,para.beta_time,para.beta_enengy,para.Sigma,para.Tu,para.tu_local,para.Eu_local,para.W,para.Hr,para.Pur,para.Ps);
                Jx = Jx + para.lamda(Us(user)) * (1 - Kappa);
            end
        end
    end
    Jx = (Jx - res_pra - res_cra);
end

function Kappa = getKappa(x,user,server,beta_time,beta_enengy,Sigma,Tu,tu_local,Eu_local,W,Hr,Pur,Ps)
%GetKappa 计算Kappa_us
    Kappa = beta_time(user)/tu_local(user) + beta_enengy(user)/Eu_local(user)*Pur(user);
    Xi_us = getXi(x,Ps,Sigma,Hr,user,server);
    Kappa = Kappa * Tu(user).output/W /log2(1 + Xi_us) ;
end

function Xi = getXi(G,Ps,Sigma,Hr,user,server)
%GetXi 计算Xi_us
    Xi = 0;
    [~,serverNumber,sub_bandNumber] = size(G);
    for sub_band = 1:sub_bandNumber
        denominator = 0;    %计算分母
        for i = 1:serverNumber
            if i ~= server
                [Us,userNumber] = genUs(G,i);
                for k = 1:userNumber
                    denominator = denominator + G(Us(k),i,sub_band) * Ps(Us(k)) * Hr(Us(k),i,sub_band);
                end
            end
        end
        denominator = denominator + Sigma^2;    %分母计算完成
        Xi = Ps(user)*Hr(user,server,sub_band)/denominator;
    end
end
