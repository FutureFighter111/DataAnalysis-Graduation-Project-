%%%此程序采用动态惯性权重基本粒子群算法完成
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

%%%设置bp神经网络模型
inputNum=10;
hiddenNum=12;
outputNum=1;
Epochs=2000;
p1=xn_train;
t1=dn_train;
P=xn_test;
T=dn_test;

%%%创建神经网络
net=newff(minmax(p1),[hiddenNum,outputNum],{'logsig','logsig','logsig'},'trainlm');
%%%设置神经网络相关参数
net.performFcn='sse';
net.trainParam.goal=0.004;
net.trainParam.min_grad=1e-20;
net.trainParam.show = 80;
net.trainParam.epochs = 100;
net.trainParam.mc = 0.95;
net.trainParam.lr=0.001;
net.divideFcn = '';

%%%设置粒子群算法相关参数
N=60;%粒子种群数量
D=inputNum*hiddenNum+hiddenNum+hiddenNum*outputNum+outputNum;%每个粒子的维度
MaxGEN=200;%最大循环次数
c1=3;%学习率
c2=3;
Wmax=1.7;%惯性权值
Wmin=0.1;
Xmax=3;%查找范围
Xmin=-3;
Vmax=0.005;%粒子速度范围
Vmin=-0.005;
%%初始化种群个体
x=rand(N,D)*(Xmax-Xmin)+Xmin;
v=rand(N,D)*(Vmax-Vmin)+Vmin;
%%初始化个体最优位置和最优值
p=x;
pbest=ones(N,1);
for i=1:N
 pbest(i)=funcl(x(i,:),p1,t1,hiddenNum);
end
%%%初始化全局最优位置和最优值
g=ones(1,D);%保存最优个体
gbest=inf;%保存最优适应度值
for i=1:N
 if(pbest(i)<gbest)
     g=p(i,:);
     gbest=pbest(i);
 end
end
gb=ones(1,MaxGEN);
%%%按照公式依次迭代，直到满足精度或者达到迭代次数
tic;
for i=1:MaxGEN
 for j=1:N
     %%%更新个体最优位置和最优值
     if funcl(x(j,:),p1,t1,hiddenNum)<pbest(j)
         p(j,:)=x(j,:);
         pbest(j)=funcl(x(j,:),p1,t1,hiddenNum);
     end
     %%%更新全局最优位置和最优值
     if pbest(j)<gbest
         g=p(j,:);
         gbest=pbest(j);
     end
     %%%计算动态惯性权重数
     w=Wmax-(Wmax-Wmin)*i/MaxGEN;
     %%%更新位置和速度值
     v(j,:)=w*v(j,:)+c1*rand*(p(j,:)-x(j,:))+c2*rand*(g-x(j,:));
     x(j,:)=x(j,:)+v(j,:);
     %%%边界条件处理
     for ii=1:D
         if (v(j,ii)>Vmax) | (v(j,ii)<Vmin)
             v(j,ii)=rand*(Vmax-Vmin)+Vmin;
         end
         if (x(j,ii)>Xmax) | (x(j,ii)<Xmin)
             x(j,ii)=rand*(Xmax-Xmin)+Xmin;
         end
     end
 end
 %%%记录历代最优值
 gb(i)=gbest;
 disp(gbest);
end;
toc;

%%%将pso算法优化后的权值阈值矩阵带入建好的神经网络中
w1=g(1,1:inputNum*hiddenNum);
b1=g(1,inputNum*hiddenNum+1:inputNum*hiddenNum+hiddenNum);
w2=g(1,inputNum*hiddenNum+hiddenNum+1:inputNum*hiddenNum+hiddenNum+hiddenNum*outputNum);
b2=g(1,inputNum*hiddenNum+hiddenNum+hiddenNum*outputNum+1:inputNum*hiddenNum+hiddenNum+hiddenNum*outputNum+outputNum);

net.IW{1,1}=reshape(w1,hiddenNum,inputNum);
net.LW{2,1}=reshape(w2,outputNum,hiddenNum);
net.b{1}=b1';
net.b{2}=b2';

%%%计算pso算法训练后的拟合结果
wout=sim(net,p1);
figure;
plot(1:trainNum,t1,1:trainNum,wout);
title('pso优化后的拟合结果');
legend('真实值','PSO输出值');

disp('pso拟合评价');
errorCal(wout,t1,trainNum,1);

%%%网络再由bp算法进行下一步的训练
net=train(net,p1,t1);

%%%经过pso算法和bp算法的复合训练后得出的结果
wout1=sim(net,p1);
figure;
plot(1:trainNum,t1,1:trainNum,wout1);
title('经过pso和bp复合算法学习后的拟合结果');
legend('真实值','神经网络输出值');

disp('pso-bp拟合评价');
errorCal(wout1,t1,trainNum,1);

%%%计算预测值
result=sim(net,P);

%%%结果反标准化
testData=zeros(1,testNum);
stdData=zeros(1,testNum);
finData=Eliminate(P(10,1),result,T);
for i=1:testNum
    testData(i)=finData(i)*(MAX-MIN)+MIN;
    stdData(i)=T(i)*(MAX-MIN)+MIN;
end

figure;
plot(1:testNum,stdData,'r+:',1:testNum,testData,'bo:');
title('经过pso和bp复合算法学习后的预测结果');
legend('真实值','预测值');

%%%统计误差
interval=[0;0.005;0.01;0.015;0.02;0.05;1];%输入统计函数的统计区间
[a,b]=showResult(testData,stdData,interval,1);%统计预测数据
disp(['SSE:',num2str(sumsqr(result-T))]);

figure;
bar(b);
title('预测数据误差统计');

figure;
plot(1:200,gb);
title('PSO算法训练表现');

figure;
plot(1:testNum,result,'r+:',1:testNum,finData,'bo:');
legend('原数据','经过误差处理');
title('修正数据对比')
