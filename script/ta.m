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

    X= genRandSeed(userNumber, serverNumber,sub_bandNumber);    %随机得到初始解
    
    while(T>T_min)
        for I=1:k
            G = convert2G(pop,userNumber, serverNumber,sub_bandNumber);
            fx = Fx(G,para);
            x_new = getneighbourhood(X,userNumber, serverNumber,sub_bandNumber);
            G_new = convert2G(pop,userNumber, serverNumber,sub_bandNumber);
            fx_new = Fx(G_new,para);
            delta = fx_new-fx;
            if (delta<0)
                X = x_new;
                if fx_new < minimal_cost
                    J = fx_new;
                    return;
                end
            else
                P=getProbability(delta,T);
                if(P>rand)
                    X=x_new;
                end
            end
        end
        T=T*alpha;
    end
end
 
function res = getneighbourhood(x,userNumber,serverNumber,sub_bandNumber)
    user = unidrnd(userNumber);
    server = unidrnd(serverNumber);
    sub_band = unidrnd(sub_bandNumber+1);
    if rand > 0.5   %两种扰动方式，交换或者赋值
        for i=1:userNumber
            x(i,server) = 0;
        end
        for j=1:serverNumber
            if x(user,j) == sub_band
                x(user,j) = 0;
            end
        end
        x(user,server) = sub_band;
    else    %交换两个用户的服务器和频带
        user_other = unidrnd(userNumber);
        server_other = unidrnd(serverNumber);
        temp = x(user,server);
        x(user,server) = x(user_other,server_other);
        x(user_other,server_other) = temp;
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
            sub = pop(userNumber, serverNumber);
            G(userNumber, serverNumber,sub) = 1;
        end
    end
end

function pop = genRandSeed(userNumber, serverNumber,sub_bandNumber)
%GenRandSeed    生成满足约束的随机种子矩阵
    pop = zeros(userNumber, serverNumber);
    for server=1:serverNumber
        if sub_bandNumber >= userNumber
            pop(s,:,server) = randperm(sub_bandNumber+1,userNumber) - 1;    %为每个用户随机分配最多N个用户
        else
            temp = randperm(sub_bandNumber+1,sub_bandNumber) - 1;
            member = randperm(userNumber,sub_bandNumber);
            pop(s,member,server) = temp;
        end
    end
    for user=1:userNumber
        number = 0;
        for server=1:serverNumber   %统计改维度种不为零元素个数
            if pop(s,user,server) ~= 0
                number = number + 1; 
            end
        end
        if number > 1
            chosen = unidrnd(number);
            index = 0;
            for server=1:serverNumber
                if server~=chosen
                    index = index +1;
                    if index~=chosen
                        pop(s,user,server) = 0;  %用户随机选择一个被分配的服务器（也有可能是自己）
                    end
                end
            end
        end
    end
end

%%Fx.m
function fx=Fx(x,para)
    [~,serverNumber,~] = size(x);
    for server = 1:serverNumber
       [Us,n] = genUs(x,server);
        if n > 0
            for user = 1:n
                Kappa = getKappa(x,user,server,para.beta_time,para.beta_enengy,para.Tu,para.tu_local,para.Eu_local,para.W,para.Hr,para.Pur,para.Ps);
                fx = 1 - Kappa;
            end
        end
    end
    [~,res_pra] = pra(x,para.beta_time,para.beta_enengy,para.Tu,para.tu_local,para.Eu_local,para.lamda,para.W,para.Ht,para.Pu,para.Sigma,para.r,para.Epsilon,para.beta);
    [~,res_cra] = cra(x,para.Fs,para.Eta_user);
    fx = lamda(Us(user)) * (fx - res_pra - res_cra);
end

function Kappa = getKappa(x,user,server,beta_time,beta_enengy,Tu,tu_local,Eu_local,W,Hr,Pur,Ps)
%GetKappa 计算Kappa_us
    Kappa = beta_time(user)/tu_local(user) + beta_enengy(user)/Eu_local(user)*Pur(user);
    Xi_us = getXi(x,Ps,Sigma,Hr,user,server);
    Kappa = Kappa * Tu.output(user)/W /log2(1 + Xi_us) ;
end

function Xi = getXi(G,Ps,Sigma,Hr,user,server)
%GetXi 计算Xi_us
    Xi = 0;
    [~,serverNumber,sub_bandNumber] = size(G);
    for j = 1:sub_bandNumber
        denominator = 0;
        for i = 1:serverNumber
            if i ~= server
                [Us,n] = genUs(G,i);
                for k = 1:n
                    denominator = denominator + G(Us(k),i,j) * Ps(Us(k)) * Hr(Us(k),i,j);
                end
            end
        end
        denominator = denominator + Sigma^2;
        Xi = Ps*Hr(user)/denominator;
    end
end
