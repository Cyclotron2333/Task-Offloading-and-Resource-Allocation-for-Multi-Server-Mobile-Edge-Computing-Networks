function X = GenRandX(userNumber, serverNumber,sub_bandNumber)
%Convert2G  将pop矩阵转化为G矩阵
    pop = genRandSeed(userNumber, serverNumber,sub_bandNumber);
    X = zeros(userNumber, serverNumber,sub_bandNumber);
    for user=1:userNumber
        for server=1:serverNumber
            sub = pop(user, server);
            if sub ~= 0
                X(user, server,sub) = 1;
            end
        end
    end
end

function pop = genRandSeed(userNumber, serverNumber,sub_bandNumber)
%GenRandSeed    生成满足约束的随机种子矩阵
    pop = zeros(userNumber, serverNumber);
    for server=1:serverNumber
        if sub_bandNumber >= userNumber
            pop(:,server) = randperm(sub_bandNumber+1,userNumber) - 1;    %为每个服务器随机分配最多N个用户
        else
            temp = randperm(sub_bandNumber+1,sub_bandNumber) - 1;
            member = randperm(userNumber,sub_bandNumber);
            pop(member,server) = temp;
        end
    end
    for user=1:userNumber
        number = 0;
        for server=1:serverNumber   %统计该维度中不为零元素个数
            if pop(user,server) ~= 0
                number = number + 1; 
            end
        end
        if number > 1
            chosen = unidrnd(number);
            index = 0;
            for server=1:serverNumber
                if server~=chosen
                    index = index +1;
                    if index~=chosen
                        pop(user,server) = 0;  %用户随机选择一个被分配的服务器（也有可能是自己）
                    end
                end
            end
        end
    end
end