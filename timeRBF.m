clear all;
warning off;
X0= xlsread('C:\Users\luany\Desktop\AUL9.xlsx','E5:E424');
MIN=min(X0);
MAX=max(X0);
totalNum=length(X0);
aa=zeros(1,totalNum);
for i=1:length(X0)
    aa(i)=(X0(i)-MIN)/(MAX-MIN);
end
dd=aa;

trainNum=round(totalNum*4/5);
testNum=totalNum-trainNum-10;

n1=zeros(trainNum,10);%归一化训练输入集
n2=zeros(testNum,10);%归一化测试输入集
x1=zeros(trainNum,1);%归一化训练输出集
x2=zeros(testNum,1);%归一化测试输出集

p=1;
for i=1:1:trainNum
    for j=p:10+p-1
        n1(i,j-p+1)=dd(j);
        x1(i,1)=dd(j+1);
    end
    p=p+1;
end
q=1;
for i=1:1:testNum
    for j=q:10+q-1
        n2(i,j-q+1)=dd(j+trainNum);
        x2(i,1)=dd(j+trainNum+1);
    end
    q=q+1;
end
%训练样本
xn_train=n1';
%训练目标
dn_train=x1';
%测试样本
xn_test=n2';
%测试目标
dn_test=x2';

p1=xn_train;
t1=dn_train;
P=xn_test;%测试输入集
T=dn_test;%测试输出集

spread=6;
tic;
net=newrbe(p1,t1,spread);
X=sim(net,P);
toc;
xx=sim(net,p1);

disp('拟合评价');
errorCal(xx,t1,trainNum,1);

figure;
plot(1:length(n1),x1',1:length(n1),xx);
title('拟合结果');
legend('标准值','拟合值');

SE=sumsqr(x1'-xx);
disp(SE);

e=sum((dn_test-X).^2);
disp(e);

figure;
plot(1:length(n2),x2,'r+:',1:length(n2),X,'bo:');
title('rbf网络预测结果');
legend('真实值','预测值');

testData=zeros(1,testNum);
stdData=zeros(1,testNum);
for i=1:testNum
    testData(i)=X(i)*(MAX-MIN)+MIN;
    stdData(i)=T(i)*(MAX-MIN)+MIN;
end

%%%统计预测结果
interval=[0;0.005;0.01;0.015;0.02;0.05;1];%输入统计函数的统计区间
[a,b]=showResult(testData,stdData,interval,1);%统计预测数据
disp(['SSE:',num2str(sumsqr(X-T))]);

figure;
bar(b);
title('预测数据误差统计');
