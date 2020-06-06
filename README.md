# Task Offloading and Resource Allocation for Multi-Server Mobile-Edge Computing Networks
# 多用户多服务器移动边缘计算网络系统的卸载决策和计算、通信资源分配算法

**这份说明还没写完，等论文通过了再接着写**

## 简介
***
### &emsp;&emsp;1.背景  
本项目源于个人**本科毕设**，水平有限请各位多多包涵。  
我的毕业设计主要研究多用户多服务器系统在单任务场景下的通信与计算资源优化问题，力求在资源有限的最大化计算卸载对系统的增益，该增益使用用户时延和能耗相对改善值的加权和来衡量。算法将优化问题分解为卸载决策问题与计算资源分配问题，设计了一个基于模拟退火算法的启发式算法对卸载决策和通信资源进行优化，并在此基础上利用Karush-Kuhn-Tucker条件求得最优服务器计算资源分配方案，可以在多项式时间内求得问题的次优解。同时算法可以根据不同用户对时延或能耗的偏好以及边缘计算服务提供商对用户的偏好进行系统优化，可以灵活应对不同需求。  *（没错这是我从摘要里扣下来的）*
 
### &emsp;&emsp;2.模型
模型主要参考论文—— T. X. Tran and D. Pompili. Joint Task Offloading and Resource Allocation for Multi-Server Mobile-Edge Computing Networks[J]. IEEE Transactions on Vehicular Technology. 68(1). 2019,1: 856-868.  
本项目的模型在其基础上考虑了蜂窝小区内子信道简单时分复用的效果（将子信道复用机制融入到通信资源分配中，即单个基站的多个用户可以同时使用一个子信道了），但取消了对用户设备发射功率的优化（设为常数）；
本项目对于计算资源分配的算法与参考论文相同，都是使用KKT条件求解，具体求解函数为script/cra.m.  
但在X矩阵的求解上使用了自己设计的启发式算法，实现在task_allocation.m（调用完整求解是要使用定义在script/optimize_annealing.m中的函数）。  
原文的算法的实现在script/other_algorithm/optimize_hJTORA.m *（可能是本人的能力问题，计算时间挺长的）*
  

## 测试（运行）
***
首先，我个人设计的算法的入口为script/optimize_annealing.m。需要输入算法所使用的参数，算法输出有三个——卸载决策矩阵X，服务器资源分配矩阵F，目标函数值J  

其他算法的入口在script/other_algorithm中，直接调用即可，输出同上述

如果想要运行看看效果可以运行script/simulation里的optimizeTest.m，这是一个测试文件，里面还包含测试其他算法（穷举法、贪心算法等等）的代码

也可以直接看test_figure里的效果图


## 文件目录图
***
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
