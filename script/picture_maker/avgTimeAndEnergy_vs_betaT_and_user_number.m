clear;
serverNumber = 9;
sub_bandNumber = 3;
gapOfServer = 25;
Fs = 20e9 * ones(serverNumber,1);   %服务器运算能力矩阵

task_circle = 1000e6;
task_size = 420 * 1024 * 8; %480KB
T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
T0.circle = [];    

Sigma_square = 1e-13;
W = 20e6;   %系统总带宽
k = 5e-27;

%测试不同子信道数下的平均目标函数值
outter_index = 1;

time_mean = zeros(5,3);
energy_mean = zeros(5,3);
    
for beta_t = 0.05:0.15:0.95
    inner_index = 1;
    for userNumber = [20,50,90]
        
        Fu = 1e9 * ones(userNumber,1);  %用户运算能力矩阵
        lamda = ones(userNumber,1);
        H = genGain(userNumber,serverNumber,sub_bandNumber,gapOfServer);   %用户到服务器的增益矩阵
        Pu = 0.001 * 10^2 * ones(userNumber,1);    %用户输出功率矩阵
        Tu = repmat(T0,userNumber,1);
        for i = 1:userNumber    %初始化任务矩阵
            Tu(i).data = task_size;
            Tu(i).circle = task_circle;
        end

        beta_time = beta_t * ones(userNumber,1);
        beta_enengy = ones(userNumber,1) - beta_time;

        test_time = 10;  %每个算法循环次数

        time_consumption = zeros(test_time,1);
        energy_consumption = zeros(test_time,1);

        %退火算法
        for time = 1: test_time  
            [J2,X2,F2,tconsumption,econsumption] = picture_used_annealing_optimize(Fu,Fs,Tu,W,Pu,H,...
            lamda,Sigma_square,beta_time,beta_enengy,...
            k,...                           % 芯片能耗系数
            userNumber,serverNumber,sub_bandNumber,...
            10e-9,...                       % 温度下界
            0.97,...                        % 温度的下降率
            5 ...                           % 邻域解空间的大小
            );
            time_consumption(time) = tconsumption/userNumber;
            energy_consumption(time) = econsumption/userNumber;
        end

        time_mean(outter_index,inner_index) = mean(time_consumption);
        energy_mean(outter_index,inner_index) = mean(energy_consumption);
        inner_index = inner_index + 1;
    end
    outter_index = outter_index + 1;
end
   
figure
x = 0.05:0.15:0.95;
plot(x,time_mean(:,1),'-s');
hold on
plot(x,time_mean(:,2),'-o');
hold on
plot(x,time_mean(:,3),'-d');
xlabel('用户对时间的偏好值');
ylabel('平均每个用户的计算时间');
grid on
legend('用户数为20','用户数为50','用户数为90');

figure
plot(x,energy_mean(:,1),'-s');
hold on
plot(x,energy_mean(:,2),'-o');
hold on
plot(x,energy_mean(:,3),'-d');
xlabel('用户对时间的偏好值');
ylabel('平均每个用户的能量消耗');
grid on
legend('用户数为20','用户数为50','用户数为90');