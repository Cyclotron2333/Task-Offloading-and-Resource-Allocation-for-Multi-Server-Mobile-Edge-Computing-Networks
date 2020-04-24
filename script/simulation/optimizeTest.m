userNumber = 90;
serverNumber = 9;   %输入一个能开方的整数
sub_bandNumber = 3;
Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵
Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];
Tu = repmat(T0,userNumber,1);
parfor i = 1:userNumber    %初始化任务矩阵
    Tu(i).data = 420 * 1024 * 8;
    Tu(i).circle = 1000e6;
end
lamda = ones(userNumber,1);
beta_time = 0.5 * ones(userNumber,1);
beta_enengy = ones(userNumber,1) - beta_time;

gapOfServer = 25;
H = genGain(userNumber,serverNumber,sub_bandNumber,gapOfServer);   %用户到服务器的增益矩阵
Pu = 0.001 * 10^2 * ones(userNumber,1);    %用户输出功率矩阵

Sigma_square = 1e-13;
W = 20e6;   %系统总带宽
k = 5e-27;

%测试各个算法的质量

test_time = 20;  %每个算法使用次数
annealing_time = zeros(test_time,1);
ta_standard_time = zeros(test_time,1);
ta_2alpha_model_time = zeros(test_time,1);
localSearch_time = zeros(test_time,1);
annealing_objective = zeros(test_time,1);
ta_standard_objective = zeros(test_time,1);
ta_2alpha_model_objective = zeros(test_time,1);
localSearch_objective = zeros(test_time,1);
    
    %多次测试
    %穷举法
%     tic;
%     [J0, ~, ~] = optimize_exhausted(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber ...
%     );
%     exhausted_time = toc
%     exhausted_objective = J0
     
    %常规的退火算法
%     for time = 1: test_time
%         tic;
%         [J1,X1,F1] = optimize_annealing(Fu,Fs,Tu,W,Pu,H,...
%         lamda,Sigma_square,beta_time,beta_enengy,...
%         k,...                           % 芯片能耗系数
%         userNumber,serverNumber,sub_bandNumber,...
%         10e-9,...                       % 温度下界
%         0.95,...                        % 温度的下降率
%         5 ...                           % 邻域解空间的大小
%         );
%         annealing_time (time) = toc;
%         annealing_objective(time) = J1;
%     end
%     annealing_time_mean = mean(annealing_time)
%     annealing_time_var = var(annealing_time)
%     annealing_objective_mean = mean(annealing_objective)
%     annealing_objective_var = var(annealing_objective)
    
%     采用迭代次数进行循环判断的退火算法
%     for time = 1: test_time
%         tic;
%         [J2,X2,F2] = ta_standard_model(Fu,Fs,Tu,W,Pu,H,...
%             lamda,Sigma_square,beta_time,beta_enengy,...
%             k,...                           % 芯片能耗系数
%             userNumber,serverNumber,sub_bandNumber,...
%             userNumber*20,...
%             10e-9,...                       % 温度下界
%             0.95,...                        % 温度的下降率
%             5 ...                           % 邻域解空间的大小
%             );
%         ta_standard_time (time) = toc;
%         ta_standard_objective(time) = J2;
%     end
%     ta_standard_time_mean = mean(ta_standard_time)
%     ta_standard_time_var = var(ta_standard_time)
%     ta_standard_objective_mean = mean(ta_standard_objective)
%     ta_standard_objective_var = var(ta_standard_objective)
    
%     混合降温的模拟退火算法
%     for time = 1: test_time
%         tic;
%         [J3,X3,F3] = ta_2alpha_model(Fu,Fs,Tu,W,Pu,H,...
%         lamda,Sigma_square,beta_time,beta_enengy,...
%         k,...                           % 芯片能耗系数
%         userNumber,serverNumber,sub_bandNumber,...
%         10e-9,...                       % 温度下界
%         0.95,...                        % 温度的下降率
%         5 ...                           % 邻域解空间的大小
%         );
%         ta_2alpha_model_time(time) = toc;
%         ta_2alpha_model_objective(time) = J3;
%     end
%     ta_2alpha_model_time_mean = mean(ta_2alpha_model_time)
%     ta_2alpha_model_time_var = var(ta_2alpha_model_time)
%     ta_2alpha_model_objective_mean = mean(ta_2alpha_model_objective)
%     ta_2alpha_model_objective_var = var(ta_2alpha_model_objective)
    
    %局部搜索算法
%     for time = 1: test_time
%         tic;
%         [J4,X4,F4] = optimize_localSearch(Fu,Fs,Tu,W,Pu,H,...
%         lamda,Sigma_square,beta_time,beta_enengy,...
%         k,...                           % 芯片能耗系数
%         userNumber,serverNumber,sub_bandNumber,...
%         2320 ...                          % 最大迭代次数
%         );
%         localSearch_time (time) = toc;
%         localSearch_objective(time) = J3;
%     end
%     localSearch_time_mean = mean(localSearch_time)
%     localSearch_time_var = var(localSearch_time)
%     localSearch_objective_mean = mean(localSearch_objective)
%     localSearch_objective_var = var(localSearch_objective)
    
%单次测试
tic;
[J0,X0,F0] = optimize_hJTORA(Fu,Fs,Tu,W,Pu,H,...
lamda,Sigma_square,beta_time,beta_enengy,...
k,...                           % 芯片能耗系数
userNumber,serverNumber,sub_bandNumber ...
);
hJTORA_time = toc
hJTORA_objective = J0

tic;
[J1,X1,F1] = optimize_annealing(Fu,Fs,Tu,W,Pu,H,...
lamda,Sigma_square,beta_time,beta_enengy,...
k,...                           % 芯片能耗系数
userNumber,serverNumber,sub_bandNumber,...
10e-9,...                       % 温度下界
0.96,...                        % 温度的下降率
5 ...                           % 邻域解空间的大小
);
annealing_time = toc
annealing_objective = J1

%     tic;
%     [J6,X6,F6] = ta_standard_model(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber,...
%     userNumber*20,...
%     10e-9,...                       % 温度下界
%     0.95,...                        % 温度的下降率
%     5 ...                           % 邻域解空间的大小
%     );
%     standard_annealing_time = toc
%     standard_annealing_objective = J6
    
%     tic;
%     [J2,X2,F2] = ta_model3(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber,...
%     10e-9,...                       % 温度下界
%     0.95,...                        % 温度的下降率
%     5 ...                           % 邻域解空间的大小
%     );
%     model3_time = toc
%     model3_objective = J2
% 
%     tic;
%     [J3,X3,F3] = optimize_greedy(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber ...
%     );
%     greedy_time = toc
%     greedy_objective = J3
% 
%     tic;
%     [J4,X4,F4] = optimize_localSearch(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber,...
%     max_time ...                         % 最大迭代次数
%     );
%     localSearch_time  = toc
%     localSearch_objective = J4
%     
%     tic;
%     [J5,X5,F5] = optimize_exhausted(Fu,Fs,Tu,W,Pu,H,...
%     lamda,Sigma_square,beta_time,beta_enengy,...
%     k,...                           % 芯片能耗系数
%     userNumber,serverNumber,sub_bandNumber...
%     );
%     exhausted_time (time) = toc;
%     exhausted_objective(time) = J5;