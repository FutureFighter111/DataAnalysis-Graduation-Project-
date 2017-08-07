function errorCal(data,stdData,len,mode)
for i=1:len
    if stdData(i)==0
        stdData(i)=data(i);
    end
end
mape=sum(abs((stdData-data)./stdData))/len;
rmse=sqrt(sumsqr(data-stdData)/len);
sse=sumsqr(data-stdData);

disp('');
disp(['MAPE:',num2str(mape)]);
disp(['RMSE:',num2str(rmse)]);
if mode==1
    disp(['SSE:',num2str(sse)]);
end
end