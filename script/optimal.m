function [G,F,P] = optimal(U,Fu,S,Fs,Tu,sub_band,B,W,Pur,Pu,Ht,Hr,lamda,beta_time,beta_enengy,userNumber,serverNumber,sub_bandNumber)
%负责执行优化操作
    tu_local = Tu.circle./Fu;   %本地计算时间矩阵
    k = rand;
    Eu_local = k * (Fu.*Fu) * Tu.circle;    %本地计算能耗矩阵
    Eta_user = zero(userNumber,1)
    for i=1:userNumber
        Eta_user(i) = lamda * Tu(i).circle * lamda(i) / tu_local(i);
    end
end