serverNumber = 9;
userNumber = 90;
gapOfServer = 25;
[serverMap,userMap] = genLocation(userNumber,serverNumber,gapOfServer);
Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
    
Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
task_circle = 1000e6;
task_size = 420 * 1024 * 8; %480KB
Tu = repmat(T0,userNumber,1);
for i = 1:userNumber    %初始化任务矩阵
Tu(i).data = task_size;
Tu(i).circle = task_circle;
end
lamda = ones(userNumber,1);
beta_time = 0.2 * ones(userNumber,1);
beta_enengy = ones(userNumber,1) - beta_time;

Pu = 0.001 * 10^2 * ones(userNumber,1);    %用户输出功率矩阵

Sigma_square = 1e-13;
W = 20e6;   %系统总带宽
k = 5e-27;

%测试不同子信道数下的平均目标函数值
index = 1;

annealing_time_mean = zeros(10,1);
annealing_objective_mean = zeros(10,1);
    
for sub_bandNumber = 1:10
    H = genGainByLocation(userNumber,serverNumber,sub_bandNumber,serverMap,userMap);   %用户到服务器的增益矩阵

    test_time = 20;  %每个算法循环次数

    annealing_time = zeros(test_time,1);
    annealing_objective = zeros(test_time,1);

    %退火算法
    parfor time = 1: test_time  
    tic;
    [J2,X2,F2] = optimize_annealing(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber,...
    10e-9,...                       % 温度下界
    0.95,...                        % 温度的下降率
    5 ...                           % 邻域解空间的大小
    );
    annealing_time(time) = toc;
    annealing_objective(time) = J2;
    end

    annealing_time_mean(index) = mean(annealing_time);
    annealing_objective_mean(index) = mean(annealing_objective);
    
    index = index + 1;
end
   
figure
x = 1:10;
plot(x,annealing_objective_mean);
xlabel('子信道数');
ylabel('平均目标函数值');