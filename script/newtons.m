function [x,fval,iter,exitflag]=newtons(fun,grad,var,x0,eps,maxiter)
%NEWTONS 牛顿法寻找局部最优解
% X=NEWTONS(FUN,X0) 求非线性方程组的局部最优解,初始迭代点为X0
% X=NEWTONS(FUN,X0,EPS) 求非线性方程组的局部最优解,误差值为EPS
% X=NEWTONS(FUN,X0,EPS,MAXITER) 求非线性方程组的局部最优解,最大迭代次数为MAXITER
%
% [X,FVAL]=NEWTONS(...) 求非线性方程组的局部最优解并返回解处的函数值
% [X,FVAL,ITER]=NEWTONS(...) 求非线性方程组的局部最优解并返回迭代次数
% [X,FVAL,ITER,EXITFLAG]=NEWTONS(...) 求非线性方程组的局部最优解并返回迭代成功标志
%
% 输入参数
% ---FUN, 非线性方程组的符号表达式
% ---X0, 初始迭代点向量
% ---VAR, 自变量
% ---EPS, 精度要求,默认值为1e-6
% ---MAXITER, 最大迭代次数,默认值为1e4
% 输出参数
% ---X, 非线性方程的近似解向量
% ---FVAL, 解处的函数值
% ---ITER, 迭代次数
% ---EXITFLAG, 迭代成功标志, 1表示成功,0表示失败%

    if nargin<5
        eps=1e-6;
    end
    if nargin<6
        maxiter=1e4;
    end
    
    H=hessian(fun,var);
    k=0;
    err=1;
    exitflag=1;
    while err > eps
        k=k+1;
        gi = double(subs(grad,var,x0));
        fx0 = double(subs(fun,var,x0));
        Hi = double(subs(H,var,x0));
        x1 = double(x0- (pinv(Hi) * gi).');
        err = norm(x1-x0);
        x0 = x1;
        if k>=maxiter
            exitflag=0;
            break
        end
    end
    x=x1;
    fval=fx0;
    iter=k;
end
