# Task Offloading and Resource Allocation for Multi-Server Mobile-Edge Computing Networks（多用户多服务器移动边缘计算网络系统的卸载决策和计算、通信资源分配算法)

**看到Star的人这么多，实在不好意思挖坑不埋了，这两周找时间把公式和代码注释都补上**

## &emsp;&emsp;1.背景  
&emsp;&emsp;本项目源于个人**本科毕设**，水平有限请各位多多包涵。  
&emsp;&emsp;我的毕业设计主要研究多用户多服务器系统在单任务场景下的通信与计算资源优化问题，力求在资源有限的最大化计算卸载对系统的增益，该增益使用用户时延和能耗相对改善值的加权和来衡量。算法将优化问题分解为卸载决策问题与计算资源分配问题，设计了一个基于模拟退火算法的启发式算法对卸载决策和通信资源进行优化，并在此基础上利用Karush-Kuhn-Tucker条件求得最优服务器计算资源分配方案，可以在多项式时间内求得问题的次优解。同时算法可以根据不同用户对时延或能耗的偏好以及边缘计算服务提供商对用户的偏好进行系统优化，可以灵活应对不同需求。  *（没错这是我从摘要里扣下来的）*



## &emsp;&emsp;2.模型
&emsp;&emsp;模型主要参考论文—— T. X. Tran and D. Pompili. Joint Task Offloading and Resource Allocation for Multi-Server Mobile-Edge Computing Networks[J]. IEEE Transactions on Vehicular Technology. 68(1). 2019,1: 856-868。**本项目的模型在不改变参考论文目标函数表达式的基础上将每个MEC设备的发射功率设置为常数，即不考虑对发射功率的优化，并考虑了蜂窝小区内子信道简单时分复用的效果（将子信道复用机制融入到通信资源分配中，即单个基站的多个用户可以同时使用一个子信道了）**  
&emsp;&emsp;求解目标为**卸载决策矩阵X和服务器计算资源分配矩阵F**  
&emsp;&emsp;本项目对于计算资源分配的算法与参考论文相同，都是使用KKT条件求解，具体求解函数为script/cra.m，但在X矩阵的求解上使用了自己设计的启发式算法，实现在task_allocation.m（调用完整求解是要使用定义在script/optimize_annealing.m中的函数）。  
&emsp;&emsp;原文的算法的实现在script/other_algorithm/optimize_hJTORA.m *（可能是本人的能力问题，计算时间挺长的）* 
下面贴一些公式的截图，方便有兴趣的朋友理解
首先是目标函数及其约束：  
<div style="align: center">
    <img src="https://raw.githubusercontent.com/Cyclotron2333/img-folder/master/%E7%9B%AE%E6%A0%87%E5%87%BD%E6%95%B0.png"/>
    <img src="https://github.com/Cyclotron2333/img-folder/blob/master/%E7%BA%A6%E6%9D%9F%E6%9D%A1%E4%BB%B6.png"/>
</div>  
拆解后的目标函数（代码中使用的）：  
<div style="align: center">
    <img src="https://github.com/Cyclotron2333/img-folder/blob/master/J(X%2CF).png"/>
</div>  
其中的信噪比计算：
<div style="align: center">
    <img src="https://github.com/Cyclotron2333/img-folder/blob/master/%E4%BF%A1%E5%99%AA%E6%AF%94.png"/>
</div>  
信息传输速率计算：  
<div style="align: center">
    <img src="https://github.com/Cyclotron2333/img-folder/blob/master/%E4%BF%A1%E6%81%AF%E4%BC%A0%E8%BE%93%E9%80%9F%E7%8E%87.png"/>
</div>  
时延和能耗计算：  
<div style="align: center">
    <img src="https://github.com/Cyclotron2333/img-folder/blob/master/%E6%97%B6%E5%BB%B6%E5%92%8C%E8%83%BD%E8%80%97.png"/>
</div>  


## &emsp;&emsp;3.测试（运行）
&emsp;&emsp;首先，我个人设计的算法的入口为script/optimize_annealing.m。需要输入算法所使用的参数，算法输出有三个——卸载决策矩阵X，服务器资源分配矩阵F，目标函数值J  
&emsp;&emsp;其他算法的入口在script/other_algorithm中，直接调用即可，输出同上述  
&emsp;&emsp;如果想要运行看看效果可以运行script/simulation里的optimizeTest.m，这是一个测试文件，里面还包含测试其他算法（穷举法、贪心算法等等）的代码  
&emsp;&emsp;也可以直接看test_figure里的效果图  



## &emsp;&emsp;4.算法伪代码描述
|Algorithm1：基于模拟退火的启发式优化算法|
|----|
|输入：用户数N，服务器数M，信道数K，系统总带宽W，用户CPU频率矩阵F_u，服务器CPU频率矩阵F_s，信道增益矩阵H，运营商对用户偏好矩阵λ，用户对时延偏好矩阵β^time，用户对能量偏好矩阵β^energy，背景噪音σ^2，芯片能耗系数κ|
|输出：卸载决策矩阵X和服务器计算资源分配矩阵F，以及卸载可行性J|
|初始化:初始温度T=N，最低温度T_min=〖10〗^(-9)，温度降低系数α=0.97，马氏链长度L=5；|
|使用Initial_X来生成满足约束条件的矩阵X_old，F_old，J_old；|
|J = J_old；X=X_old；F=F_old；|
|Repeat|
|n = 0；|
|Repeat|
|使用Get_Neighborhood获得X_old的邻域解X_new； |
|根据X_new，使用式（4-6）来生成F_new； |
|根据X_new，使用式（4-8）求解卸载可行性J_new；|
|∆ =J_new-J_old；|
|if ∆ >0 then|
|J_old = J_new；X_old=X_new；F_old=F_new；|
|if J_old  >J|
|J = J_old；X=X_old；F=F_old；|
|end if|
|else if 随机数 t >exp(∆/T) then|
|J_old = J_new；X_old=X_new；F_old=F_new；|
|end if|
|n = n + 1；|
|until n = L；|
|T = α * T；|
|until T ≤ T_min|
|输出X,F,J；|

|Initial_X：生成满足约束条件的矩阵|
|----|
|输入：用户数N，服务器数M，信道数K，系统总带宽W，用户CPU频率矩阵F_u，服务器CPU频率矩阵F_s，信道增益矩阵H，运营商对用户偏好矩阵λ，用户对时延偏好矩阵β^time，用户对能量偏好矩阵β^energy，背景噪音σ^2，芯片能耗系数κ|
|输出：满足约束条件卸载决策矩阵X. X对应的卸载可行性J以及服务器计算资源分配矩阵F|
|初始化: X=0，F=0，J=0；|
|使用Initial_X来生成满足约束条件的矩阵X_old，F_old，J_old；|
|J = J_old；X=X_old；F=F_old；|
|for i = 1: N|
|for j = 1: M|
|for k = 1: K|
|X_new=X_old；|
|X_new (i,j,k)=1;|
|根据X_new，使用式（4-6）来生成F_new；|
|根据X_new，使用式（4-8）求解卸载可行性J_new；|
|if  J_new-J_old>0 then|
|J_old = J_new；X_old=X_new；F_old=F_new；|
|跳出至第一层循环；|
|end if|
|end for；|
|end for；|
|end for；|
|输出X，F，J；|

|Get_Neighborhood：获得X_old的邻域解X_new|
|----|
|输入：旧解X_old，用户数N，服务器数M，信道数K，系统总带宽W，用户CPU频率矩阵F_u，服务器CPU频率矩阵F_s，信道增益矩阵H，运营商对用户偏好矩阵λ，用户对时延偏好矩阵β^time，用户对能量偏好矩阵β^energy，背景噪音σ^2，芯片能耗系数κ|
|输出：新解X_new|
|X_new=X_old；|
|随机指定要扰动的目标用户user，并搜索X_old得到user对应的服务器server和子信道band；|
|生成随机数rand；|
|if rand > 0.2|
|if rand < 0.75|
|随机选择除server外的另一个服务器other_server；|
|寻找服务器other_server空闲的子信道other_band，如果没有空闲的子信道，则随机分配一条子信道与其他用户复用；|
|X_new (user,other_server,other_band) = 1; X_new (user,server,band) = 0;|
|elseif K > 1|
|寻找服务器server除band外空闲的子信道other_band，如果没有空闲的子信道，则随机分配一条子信道与其他用户复用；|
|X_new (user,server,other_band) = 1; X_new (user,server,band) = 0;|
|end if|
|else if rand > 0.05|
|随机选择另一个用户other_user，与user交换二者对应的服务器与子信道|
|else|
|X_new (user,server,band)=1-X_new (user,server,band) ；|
|end if|
|输出X_new；|



## 文件目录图
```
    .
    │  README.md
    │  TaskOffloadingAndResourceAllocationForMu.prj
    │  
    ├─resources
    ├─script
    │  │  cra.m
    │  │  Fx.m
    │  │  genUs.m
    │  │  optimize_annealing.m
    │  │  task_allocation.m
    │  │  
    │  ├─annealing_model
    │  │      ta_2alpha_model.m
    │  │      ta_2CoolingMethod_model.m
    │  │      ta_chao_model.m
    │  │      ta_iterations_limited_model.m
    │  │      ta_standard_model.m
    │  │      
    │  ├─other_algorithm
    │  │      optimize_exhausted.m
    │  │      optimize_greedy.m
    │  │      optimize_hJTORA.m
    │  │      optimize_localSearch.m
    │  │      
    │  ├─other_unused_method
    │  │      other_cra.m
    │  │      other_genUs.m
    │  │      
    │  ├─picture_maker
    │  │      
    │  └─simulation
    │          craTest.m
    │          genGain.m
    │          genGainByLocation.m
    │          genLocation.m
    │          optimizeTest.m
    │          taTest.m
    │          testFx.m
    │          
    ├─testFigure
    │  ├─alpha=0.95
    │  │      
    │  └─alpha=0.97
    │          
    └─workspace
        ├─alpha=0.95
        │      
        └─alpha=0.97
```
