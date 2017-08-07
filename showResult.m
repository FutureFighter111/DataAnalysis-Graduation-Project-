function [resultdata,errordata]=showResult(data,stdData,interval,mode)

%%%       本函数用于统计给出的测试值和标准值的误差，并用饼图绘出统计结果
%%%       data,stdData为行数组
%%%       interval=[0;0.005;0.01;0.02;0.05;1];
%%%       mode==0,取测试数据和标准数据差的绝对值;mode==1,取相差百分比的绝对值
%%%       resultdata为行向量，长度等于interval，是误差统计值
%%%       errordata为行向量，长度等于stdData，是所有测试数据的误差

len=length(data);
stdLen=length(stdData);
if(len~=stdLen)
    error('测试数据和标准数据维度不匹配');
end 
errorData=zeros(1,len);
if(mode==1)
    for i=1:len
        errorData(1,i)=(data(i)-stdData(i))/stdData(i);
    end
else
    errorData=data-stdData;
end

invlen=length(interval)-1;
result=zeros(1,invlen);
for i=1:len
    errData=abs(errorData(1,i));
    for j=1:invlen
        if errData<interval(j+1) && errData>=interval(j)
            result(j)=result(j)+1;
            break;
        end
    end
end

explode=zeros(1,invlen);
explode(1)=1;
explode(2)=1;
figure;

pie3(result,explode);
legend('0-0.5%','0.5%-1%','1%-1.5%','1.5%-2%','2%-5%','5%以上');
title('结果误差饼图');

disp('预测评价');
errorCal(data,stdData,len,0);

errordata=errorData;
resultdata=result;
end