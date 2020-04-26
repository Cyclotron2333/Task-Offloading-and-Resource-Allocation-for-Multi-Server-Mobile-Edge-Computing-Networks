clear;
serverNumber = 9;
userNumber = 50;
gapOfServer = 25;
sub_bandNumber = 3;
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
Tu = repmat(T0,userNumber,1);
task_size = 420 * 1024 * 8; %480KB
Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵
H = genGain(userNumber,serverNumber,sub_bandNumber,gapOfServer);   %用户到服务器的增益矩阵
Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
lamda = ones(userNumber,1);
beta_time = 0.5 * ones(userNumber,1);
beta_enengy = ones(userNumber,1) - beta_time;

Pu = 0.001 * 10^2 * ones(userNumber,1);    %用户输出功率矩阵

Sigma_square = 1e-13;
W = 20e6;   %系统总带宽
k = 5e-27;

%测试不同任务数据大小下算法的平均目标函数值

annealing_time_mean = zeros(5,1);
hJTORA_time_mean = zeros(5,1);
greedy_time_mean = zeros(5,1);
localSearch_time_mean = zeros(5,1);

annealing_objective_mean = zeros(5,1);
hJTORA_objective_mean = zeros(5,1);
greedy_objective_mean = zeros(5,1);
localSearch_objective_mean = zeros(5,1);
 
index = 1;
for task_circle = [1:5]*1e9
    
    for i = 1:userNumber    %初始化任务矩阵
    Tu(i).data = task_size;
    Tu(i).circle = task_circle;
    end
    
    test_time = 20;  %每个算法循环次数

    annealing_time = zeros(test_time,1);
    hJTORA_time = zeros(5,1);
    greedy_time = zeros(test_time,1);
    localSearch_time = zeros(test_time,1);
    
    annealing_objective = zeros(test_time,1);
    hJTORA_objective = zeros(5,1);
    greedy_objective = zeros(test_time,1);
    localSearch_objective = zeros(test_time,1);

    %hJTORA算法
    for time = 1: 5    
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
    0.97,...                        % 温度的下降率
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

x = 1:5;
figure
plot(x,annealing_objective_mean,'-s');
hold on
plot(x,hJTORA_objective_mean,'-d');
hold on
plot(x,greedy_objective_mean,'-o');
hold on
plot(x,localSearch_objective_mean,'-x');
xlabel('工作负载(兆周期)');
ylabel('平均目标函数值');
grid on
legend('模拟退火算法','hJTORA算法','贪心算法','局部搜索算法');
