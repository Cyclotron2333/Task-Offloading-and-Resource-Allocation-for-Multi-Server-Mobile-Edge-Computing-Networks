function H = genGainByLocation(userNumber,serverNumber,sub_bandNumber,serverMap,userMap)
%GENGAIN 根据坐标图生成随机的信道增益
    H = zeros(userNumber,serverNumber,sub_bandNumber);
    for i = 1:userNumber
        for j = 1:serverNumber
            dis = ((userMap(i,1)-serverMap(j,1))^2+(userMap(i,2)-serverMap(j,2))^2)^0.5;
            gain_DB = 140.7 + 36.7*log10(dis/1000);
            H(i,j,:) = 1/(10^(gain_DB/10)) * ones(1,sub_bandNumber);
        end
    end
%     plot(serverMap(:,1),serverMap(:,2),'*r')
%     hold on
%     plot(userMap(:,1),userMap(:,2),'.b')
end
