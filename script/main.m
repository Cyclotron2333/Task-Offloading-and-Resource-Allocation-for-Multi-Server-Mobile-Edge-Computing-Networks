%程序入口
%基本参数设置
userNumber = 20;
serverNumber = 2;
sub_bandNumber = 7;
Fs = 10 + 40 * rand(serverNumber,1);  %服务器运算能力矩阵
Fu = 10 + 40 * rand(userNumber,1);  %用户运算能力矩阵
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
T0.output = [];
Tu = repmat(T0,userNumber);
tu_local = zeros(userNumber,1);
Eu_local = zeros(userNumber,1);
k = rand;
for i = 1:userNumber    %初始化任务矩阵
    Tu(i).data = 10 + 40 * rand;
    Tu(i).circle = 40 * rand;
    Tu(i).output = 4 * rand;
    tu_local(i) = Tu(i).circle/Fu(i);   %本地计算时间矩阵
    Eu_local(i) = k * (Fu(i))^2 * Tu(i).circle;    %本地计算能耗矩阵
end
Eta_user = zeros(userNumber,1);
lamda = rand(userNumber,1);
beta_time = rand(userNumber,1);
beta_enengy = ones(userNumber,1) - beta_time;
for i=1:userNumber  %计算CRA所需的η
    Eta_user(i) = beta_time(i) * Tu(i).circle * lamda(i) / tu_local(i);
end
Ht = rand(userNumber,serverNumber,sub_bandNumber);   %用户到服务器的增益矩阵
Hr = rand(userNumber,serverNumber,sub_bandNumber);
Pu = ones(userNumber,1);    %用户最大输出功率矩阵
Pur = ones(userNumber,1);   %用户接收功率矩阵
Ps = ones(userNumber,1);    %服务器发射功率矩阵

Sigma = rand;
Epsilon = 0.001*rand;
beta = rand;
r = 0.001*rand;
W = 20e6;   %系统总带宽
k = rand;

[J, X, P, F] = optimize(Fu,Fs,Tu,W,Pur,Pu,Ps,Ht,Hr,...
lamda,Sigma,Epsilon,beta,r,beta_time,beta_enengy,...
k,...                       % 芯片能耗系数
userNumber,serverNumber,sub_bandNumber,...
1,...                       % 初始化温度值
0.1,...                   % 温度下界
0.9,...                   % 温度的下降率
3, ...                      % 邻域解空间的大小
-30 ...             % 最小目标值（函数值越小，则适应度越高）
);