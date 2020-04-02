function tests = craTest
    tests = functiontests(localfunctions);
end

%% testGenRandX
function testGenRandX(~)
    userNumber = 3;
    serverNumber = 2;
    sub_bandNumber = 2;
    X = GenRandX(userNumber, serverNumber,sub_bandNumber);
end
 
%% testCra
function testCra(~)
    userNumber = 3;
    serverNumber = 2;
    sub_bandNumber = 2;
    Fs = 10 + 40 * rand(userNumber,1);  %服务器运算能力矩阵
    Fu = 10 + 40 * rand(serverNumber,1);  %用户运算能力矩阵
    T0.data = [];   %任务由数据大小、运算所需时钟周期数、输出大小组成
    T0.circle = [];
    T0.output = [];
    Tu = repmat(T0,userNumber);
    tu_local = zeros(userNumber,1);
    for i = 1:userNumber    %初始化任务矩阵
        Tu(i).data = 10 + 40 * rand;
        Tu(i).circle = 40 * rand;
        Tu(i).output = 4 * rand;
        tu_local(i) = Tu(i).circle/Fu(i);   %本地计算时间矩阵
    end
    Eta_user = zeros(userNumber,1);
    lamda = rand(userNumber,1);
    beta_time = rand(userNumber,1);
    for i=1:userNumber  %计算CRA所需的η
        Eta_user(i) = beta_time(i) * Tu(i).circle * lamda(i) / tu_local(i);
    end
    X = GenRandX(userNumber, serverNumber,sub_bandNumber);
    [F,T] = cra(X,Fs,Eta_user);
    X
    F
    T
end