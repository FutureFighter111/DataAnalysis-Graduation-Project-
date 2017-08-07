clear all;
warning off;
X0= xlsread('C:\Users\luany\Desktop\AUL9.xlsx','E5:E424');
MIN=min(X0);
MAX=max(X0);
totalNum=length(X0);
aa=zeros(1,totalNum);
%%%数据极大极小标准化
for i=1:totalNum
    aa(i)=(X0(i)-MIN)/(MAX-MIN);
end
dd=aa;
%%%将整个数据集合的4/5作为训练集，剩下的1/5作为验证集
trainNum=round(totalNum*4/5);
testNum=totalNum-trainNum-10;

n1=zeros(trainNum,10);%归一化训练输入集
n2=zeros(testNum,10);%归一化测试输入集
x1=zeros(trainNum,1);%归一化训练输出集
x2=zeros(testNum,1);%归一化测试输出集

%%%%制作训练集
p=1;
for i=1:1:trainNum
    for j=p:10+p-1
        n1(i,j-p+1)=dd(j);
        x1(i,1)=dd(j+1);
    end
    p=p+1;
end
%%%%制作测试集
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

%%%bp神经网络的参数设置
NodeNum=12;%隐层节点数
TypeNum=1;%输出节点数
Epochs=500;%最大学习次数
p1=xn_train;
t1=dn_train;
P=xn_test;%测试输入集
T=dn_test;%测试输出集
net=newff(minmax(p1),[NodeNum,TypeNum],{'logsig','logsig','logsig'},'trainlm');
net.performFcn='sse';
net.trainParam.goal=0.001;%训练sse目标
net.trainParam.min_grad=1e-20;%最小梯度
net.trainParam.show = 200;
net.trainParam.epochs = Epochs;
net.trainParam.mc = 0.95;%动量因子
net.trainParam.lr=0.01;%学习率
net.divideFcn = '';

%%%神经网络的训练及结果的输出
tic;
net=train(net,p1,t1);%根据训练输入集和输出集对网络进行训练
toc;
X=sim(net,P);%预测的结果集
xx=sim(net,p1);%拟合的结果集

disp('拟合评价');
errorCal(xx,t1,trainNum,1);

figure;
plot(1:length(n2),x2,'r+:',1:length(n2),X,'bo:');
title('预测结果 未经过尖峰处理');
legend('真实值','预测值');

figure;
plot(1:length(n1),x1',1:length(n1),xx);
title('拟合结果');
legend('标准值','拟合值');

%%反标准化
testData=zeros(1,testNum);
stdData=zeros(1,testNum);
% finData=X;
finData=Eliminate(P(10,1),X,T);
for i=1:testNum
    testData(i)=finData(i)*(MAX-MIN)+MIN;
    stdData(i)=T(i)*(MAX-MIN)+MIN;
end

%%%统计预测结果
interval=[0;0.005;0.01;0.015;0.02;0.05;1];%输入统计函数的统计区间
[a,b]=showResult(testData,stdData,interval,1);%统计预测数据
disp(['SSE:',num2str(sumsqr(X-T))]);

figure;
bar(b);
title('预测数据误差统计');

figure;
plot(1:testNum,finData,'r+:',1:testNum,X,'bo:');
legend('经过误差处理','原数据');
title('数据处理后的对比');

figure;
plot(1:length(n2),stdData,'r+:',1:length(n2),testData,'bo:');
title('处理后的预测结果');
legend('真实值','预测结果');
