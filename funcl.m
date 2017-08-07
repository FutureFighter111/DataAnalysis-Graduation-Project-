function [fitnessScore,data] =funcl(WBM,input,output,hiddennum)
    [outputnum,a]=size(output);
    [inputnum,SampleNum]=size(input);
    w1=WBM(1,1:inputnum*hiddennum);
    b1=WBM(1,inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
    w2=WBM(1,inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
    b2=WBM(1,inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

    W1=reshape(w1,hiddennum,inputnum);
    W2=reshape(w2,outputnum,hiddennum);
    B1=b1';
    B2=b2';
    
    W1out=W1*input;
    [width,length]=size(W1out);
    A1=zeros(width,length);
    for i=1:length
        A1(:,i)=logsig(W1out(:,i)+B1);
    end
    W2out=W2*A1;
    [width,length]=size(W2out);
    A2=zeros(width,length);
    for i=1:length
        A2(:,i)=logsig(W2out(:,i)+B2);
    end  
    SE=sumsqr(output-A2);
    fitnessScore=SE;
    data=A2;
end