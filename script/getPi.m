function Pi = getPi(G,Pu,Sigma,Ht,user,server)
%º∆À„Pi_us
    Pi = 0;
    [~,serverNumber,sub_bandNumber] = size(G);
    for j = 1:sub_bandNumber
        denominator = 0;
        for i = 1:serverNumber
            if i ~= server
                [Us,n] = genUs(G,i);
                for k = 1:n
                    denominator = denominator + G(Us(k),i,j) * Pu(Us(k)) * Ht(Us(k),i,j);
                end
            end
        end
        denominator = denominator + Sigma^2;
        Pi = Ht(user,server,j)/denominator;
    end
end

