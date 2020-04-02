%程序入口
%基本参数设置
userNumber = 100;   %用户人数
U = 1:userNumber;   %用户矩阵
Fu = 4 * rand(userNumber,1);    %用户运算能力矩阵
serverNumber = 10;  %服务器个数
S = 1:serverNumber; %服务器矩阵
Fs = 10 + 40 * rand(userNumber,1);  %服务器运算能力矩阵
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
T0.output = [];
Tu = repmat(T0,userNumber);
for i = 1:userNumber    %初始化任务矩阵
    Tu(i).data = 10 + 40 * rand;
    Tu(i).circle = 40 * rand;
    Tu(i).output = 4 * rand;
end
W = 20e6;   %系统总带宽
sub_bandNumber = 10;    %子带个数
sub_band = 1:sub_bandNumber;    %子带矩阵
Ground = zeros(userNumber,serverNumber,sub_bandNumber);  %频带和服务器分配矩阵
Pu = zeros(userNumber,1);    %用户最大输出功率矩阵
for i = 1:userNumber
    Pu(i) = 10 + 40 * rand;
end
Pur = ones(userNumber,1);   %用户接收功率矩阵
Ps = ones(userNumber,1);    %服务器发射功率矩阵
for i = 1:userNumber
    Pu(i) = 10 + 40 * rand;
end
Ht = rand(userNumber,serverNumber,sub_bandNumber);   %用户到服务器的增益矩阵
Hr = rand(userNumber,serverNumber,sub_bandNumber);   %服务器到用户的增益矩阵
lamda = rand(userNumber,1);
Sigma = rand(userNumber,1);
Epsilon = rand(userNumber,1);
beta = rand(userNumber,1);
r = rand(userNumber,1);
beta_time = rand(userNumber,1);
beta_enengy = ones(userNumber,1) - beta_time;
[   J,...   %可行性度量
    X,...   %频带和服务器分配矩阵
    F,...   %服务器计算资源分配矩阵
    P...    %用户发射功率分配矩阵
    ] = optimize(Fu,Fs,Tu,W,Pur,Pu,Ps,Ht,Hr,lamda,Sigma,Epsilon,beta,r,beta_time,beta_enengy,userNumber,serverNumber,sub_bandNumber);