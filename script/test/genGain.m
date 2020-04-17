function H = genGain(userNumber,serverNumber,sub_bandNumber,gapOfServer)
%GENGAIN 生成随机的信道增益
    [serverMap,userMap] = genLocation(userNumber,serverNumber,gapOfServer);
    H = zeros(userNumber,serverNumber,sub_bandNumber);
    for i = 1:userNumber
        for j = 1:serverNumber
            dis = ((userMap(i,1)-serverMap(j,1))^2+(userMap(i,2)-serverMap(j,2))^2)^0.5;
            gain_DB = 140.7 + 36.7*log10(dis/1000);
            H(i,j,:) = 10^(gain_DB/10) * ones(1,sub_bandNumber);
        end
    end
    plot(serverMap(:,1),serverMap(:,2),'*r')
    hold on
    plot(userMap(:,1),userMap(:,2),'.b')
end

function [serverMap,userMap] = genLocation(userNumber,serverNumber,gapOfServer)
%GENLOCATION 生成随机的用户和服务器的坐标
%服务器在正方形区域内均匀排列，用户随机排列
    xlength = (serverNumber^0.5+1) * (gapOfServer);
    ylength = xlength;
    index = 1;
    serverMap = zeros(serverNumber,2);
    for i = 1:serverNumber^0.5
        for j = 1:serverNumber^0.5
            serverMap(index,1) = i * gapOfServer;
            serverMap(index,2) = j * gapOfServer;
            index = index + 1;
        end
    end
    index = 1;
    userMap = zeros(userNumber,2);
    for i = 1:userNumber
        userMap(index,1) =  xlength * rand;
        userMap(index,2) =  ylength * rand;
        index = index + 1;
    end
end
