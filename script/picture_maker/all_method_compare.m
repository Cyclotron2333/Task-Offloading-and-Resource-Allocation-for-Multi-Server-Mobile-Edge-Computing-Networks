userNumber = 11;
serverNumber = 2;
sub_bandNumber = 2;
Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵
Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
gapOfServer = 25;
H = genGain(userNumber,serverNumber,sub_bandNumber,gapOfServer);   %用户到服务器的增益矩阵
    
%测试不同任务所需时钟周期数下的各个算法的目标函数值
index = 1;

annealing_time_mean = zeros(4,1);
hJTORA_time_mean = zeros(4,1);
greedy_time_mean = zeros(4,1);
localSearch_time_mean = zeros(4,1);
exhausted_time = zeros(4,1);

annealing_objective_mean = zeros(4,1);
hJTORA_objective_mean = zeros(4,1);
greedy_objective_mean = zeros(4,1);
localSearch_objective_mean = zeros(4,1);
exhausted_objective = zeros(4,1);
    
for task_circle = [100e6 500e6 1000e6 2000e6]    %100 Megacycles 
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

    test_time = 20;  %每个算法循环次数

    annealing_time = zeros(test_time,1);
    hJTORA_time = zeros(test_time,1);
    greedy_time = zeros(test_time,1);
    localSearch_time = zeros(test_time,1);
    annealing_objective = zeros(test_time,1);
    hJTORA_objective = zeros(test_time,1);
    greedy_objective = zeros(test_time,1);
    localSearch_objective = zeros(test_time,1);

    %hJTORA算法
    parfor time = 1: test_time    
    tic;
    [J0,X0,F0] = optimize_hJTORA(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber ...
    );
    hJTORA_time(time) = toc;
    hJTORA_objective(time) = J0;
    end

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

    %贪心算法
    parfor time = 1: test_time
    tic;
    [J3,X3,F3] = optimize_greedy(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber ...
    );
    greedy_time(time) = toc;
    greedy_objective(time) = J3;
    end

    %局部搜索算法
    parfor time = 1: test_time
    tic;
    [J4,X4,F4] = optimize_localSearch(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber,...
    30 ...                          % 最大迭代次数
    );
    localSearch_time(time)  = toc;
    localSearch_objective(time) = J4;
    end

    %穷举法
    tic;
    [J5,X5,F5] = optimize_exhausted(Fu,Fs,Tu,W,Pu,H,...
    lamda,Sigma_square,beta_time,beta_enengy,...
    k,...                           % 芯片能耗系数
    userNumber,serverNumber,sub_bandNumber...
    );
    exhausted_time(index) = toc;
    exhausted_objective(index) = J5;

    annealing_time_mean(index) = mean(annealing_time);
    hJTORA_time_mean(index) = mean(hJTORA_time);
    greedy_time_mean(index) = mean(greedy_time);
    localSearch_time_mean(index) = mean(localSearch_time);

    annealing_objective_mean(index) = mean(annealing_objective);
    hJTORA_objective_mean(index) = mean(hJTORA_objective);
    greedy_objective_mean(index) = mean(greedy_objective);
    localSearch_objective_mean(index) = mean(localSearch_objective);
    
    index = index + 1;
end
   
figure
x = [100,500,1000,2000];
vals = [annealing_objective_mean(1),hJTORA_objective_mean(1),greedy_objective_mean(1),localSearch_objective_mean(1),exhausted_objective(1);
    annealing_objective_mean(2),hJTORA_objective_mean(2),greedy_objective_mean(2),localSearch_objective_mean(2),exhausted_objective(2);
    annealing_objective_mean(3),hJTORA_objective_mean(3),greedy_objective_mean(3),localSearch_objective_mean(3),exhausted_objective(3);
    annealing_objective_mean(4),hJTORA_objective_mean(4),greedy_objective_mean(4),localSearch_objective_mean(4),exhausted_objective(4)];
b = bar(x,vals);
xlabel('任务负载(Megacycles)');
ylabel('目标函数值J');