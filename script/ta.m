function [J, X, F] = ta( ...
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

    x= genRandX(userNumber, serverNumber,sub_bandNumber);    %随机得到初始解
    
    picture = zeros(2,1);
    index = 1;
    
    while(T>T_min)
        for I=1:k
            [fx, F] = Fx(x,para);
            J = fx;
            x_new = getneighbourhood(x,userNumber, serverNumber,sub_bandNumber);
            [fx_new, F_new] = Fx(x_new,para);
            delta = fx_new-fx;
            if (delta>0)
                x = x_new;
                J = fx_new;
                X = x;
                F = F_new;
                if fx_new > minimal_cost
                    picture(index,1) = T;
                    picture(index,2) = J;
                    figure
                    title('模拟退火算法进行任务调度优化');
                    xlabel('温度T');
                    ylabel('目标函数值');
                    plot(picture(:,1),picture(:,2),'b-.')
                    set(gca,'XDir','reverse');      %对X方向反转
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
    title('模拟退火算法进行任务调度优化');
    xlabel('温度T');
    ylabel('目标函数值');
    plot(picture(:,1),picture(:,2),'b-.');
    set(gca,'XDir','reverse');      %对X方向反转
end
 
function res = getneighbourhood(x,userNumber,serverNumber,sub_bandNumber)
    user = unidrnd(userNumber);     %指定要扰动的用户对象
    flag_found = 0;
    for server = 1:serverNumber
        for band = 1:sub_bandNumber
            if x(user,server,band) ~= 0
                flag_found = 1;
                break;  %找到用户所分配的服务器和频带
            end
        end
        if flag_found == 1
            break;
        end
    end
    %两种扰动方式，交换或者赋值
    chosen = rand;
    if chosen > 0.3   %50%的概率更改（即和原来不一样）某个用户的频带或服务器
        if chosen > 0.75   %45%的概率更改用户的服务器（选择offload）
            x(user,server,band) = 0;
            vary_server = unidrnd(serverNumber);    %目标服务器
            vary_band = randi(sub_bandNumber);    %目标频带
            x(user,vary_server,vary_band) = 1;
        else    %25%的概率更改用户的频带（选择offload）
            if sub_bandNumber ~= 1
                x(user,server,band) = 0;
                vary_band = unidrnd(sub_bandNumber);    %目标频带
                while vary_band == band
                    vary_band = unidrnd(sub_bandNumber);
                end
                x(user,server,vary_band) = 1;
            end
        end
    else 
        if chosen > 0.2  %10%的概率交换两个用户的服务器和频带
            if userNumber ~= 1
                user_other = unidrnd(userNumber);    %指定另一个用户
                while user_other == user
                    user_other = unidrnd(userNumber);
                end
                flag_found = 0;
                for server_other = 1:serverNumber
                    for band_other=1:sub_bandNumber
                        if x(user_other,server_other,band_other) ~= 0
                            flag_found = 1;
                            break;  %找到另一个用户所分配的服务器和频带
                        end
                    end
                    if flag_found == 1
                        break;
                    end
                end
                xValue =  x(user,server,band);
                xValue_other =  x(user_other,server_other,band_other);
                x(user,server,band) = 0;
                x(user_other,server_other,band_other) = 0;
                x(user,server_other,band_other) = xValue_other;  %更改频带和服务器
                x(user_other,server,band) = xValue;
            end
        else    %20%的概率改变该用户的决策
            x(user,server,band) = 1 - x(user,server,band);
        end
    end
    res = x;
end
 
function p = getProbability(delta,t)
    k = 1e-3;
    p=exp(delta/(k*t));
end

function x = genRandX(userNumber, serverNumber,sub_bandNumber)
%GenRandX  将种子矩阵转化为X矩阵
    seed = genRandSeed(userNumber, serverNumber,sub_bandNumber);
    x = zeros(userNumber, serverNumber,sub_bandNumber);
    for user=1:userNumber
        for server=1:serverNumber
            if seed(user, server) ~= 0
                x(user, server, seed(user, server)) = 1;
            end
        end
    end
end

function seed = genRandSeed(userNumber, serverNumber,sub_bandNumber)
%GenRandSeed    生成满足约束的随机种子矩阵
    seed = zeros(userNumber, serverNumber);
    for server=1:serverNumber
        if sub_bandNumber >= userNumber
            seed(:,server) = randperm(sub_bandNumber+1,userNumber) - 1;    %为每个服务器随机分配最多N个用户
        else
            temp = randperm(sub_bandNumber+1,sub_bandNumber) - 1;
            member = randperm(userNumber,sub_bandNumber);
            seed(member,server) = temp;
        end
    end
    for user=1:userNumber
        number = 0;
        notzero = [];
        for server=1:serverNumber   %统计该维度中不为零元素个数
            if seed(user,server) ~= 0
                number = number + 1;
                notzero(number) = server;
            end
        end
        if number > 1
            chosen = unidrnd(number);
            for server=1:number
                if server~=chosen
                    seed(user,notzero(server)) = 0;
                end
            end
        end
    end
end

function [Jx, F] = Fx(x,para)
    [F,res_cra] = cra(x,para.Fs,para.Eta_user);
    Jx = 0;
    [~,serverNumber,sub_bandNumber] = size(x);
    for server = 1:serverNumber
        [Us,n] = genUs(x,server);
        multiplexingNumber = zeros(sub_bandNumber,1);
        for band = 1:sub_bandNumber
            multiplexingNumber(band) = sum(x(:,server,band));
        end
        if n > 0
            for user = 1:n
                Pi = getPi(x,user,server,Us(user,2),sub_bandNumber,multiplexingNumber(Us(user,2)),para.beta_time,para.beta_enengy,para.tu_local,para.Eu_local,para.Tu,para.Pu,para.Ht,para.Sigma_square,para.W);
                Jx = Jx + para.lamda(Us(user,1)) * (1 - Pi);
            end
        end
    end
    Jx = (Jx - res_cra);
end

function Pi = getPi(x,user,server,band,sub_bandNumber,multiplexingNumber,beta_time,beta_enengy,tu_local,Eu_local,Tu,Pu,Ht,Sigma_square,W)
%GetPi 计算Pi_us
    B = W / sub_bandNumber;
    Pi = beta_time(user)/tu_local(user) + beta_enengy(user)/Eu_local(user)*Pu(user);
    Gamma_us = getGamma(x,Pu,Sigma_square,Ht,user,server,band);
    Pi = Pi * Tu(user).data / B / log2(1 + Gamma_us) / multiplexingNumber;
end

function Gamma = getGamma(G,Pu,Sigma_square,H,user,server,band)
%GetGamma 计算Gamma_us
    [~,serverNumber,~] = size(G);
    denominator = 0;
    for i = 1:serverNumber
        if i ~= server
            [Us,n] = genUs(G,i);
            for k = 1:n
                denominator = denominator + G(Us(k,1),i,band) * Pu(Us(k,1)) * H(Us(k,1),i,band);
            end
        end
    end
    denominator = denominator + Sigma_square;
    Gamma = Pu(user)*H(user,server,band)/denominator;
end

