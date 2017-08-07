function result=Eliminate(startData,data,stdData)
    len=length(data);
    dataSet=zeros(1,len);
    dataSet(1)=startData;
    dataSet(2:len)=stdData(1:len-1);
    resultData=zeros(1,len);
    for i=1:len
        amplitude=(data(i)-dataSet(i))/dataSet(i);
        if abs(amplitude)<=0.02
            resultData(i)=data(i);
        else
            resultData(i)=fun(amplitude)*dataSet(i)+dataSet(i);
        end
    end
    result=resultData;
end