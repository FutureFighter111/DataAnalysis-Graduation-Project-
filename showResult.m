function [resultdata,errordata]=showResult(data,stdData,interval,mode)

%%%       ����������ͳ�Ƹ����Ĳ���ֵ�ͱ�׼ֵ�������ñ�ͼ���ͳ�ƽ��
%%%       data,stdDataΪ������
%%%       interval=[0;0.005;0.01;0.02;0.05;1];
%%%       mode==0,ȡ�������ݺͱ�׼���ݲ�ľ���ֵ;mode==1,ȡ���ٷֱȵľ���ֵ
%%%       resultdataΪ�����������ȵ���interval�������ͳ��ֵ
%%%       errordataΪ�����������ȵ���stdData�������в������ݵ����

len=length(data);
stdLen=length(stdData);
if(len~=stdLen)
    error('�������ݺͱ�׼����ά�Ȳ�ƥ��');
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
legend('0-0.5%','0.5%-1%','1%-1.5%','1.5%-2%','2%-5%','5%����');
title('�������ͼ');

disp('Ԥ������');
errorCal(data,stdData,len,0);

errordata=errorData;
resultdata=result;
end