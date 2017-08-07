function result=fun(n)  
  x=(abs(n)-0.02)*35;
  a = 0.03*(-1/(x+1)+1);
  if n>=0
    result=a+0.02;
  else
    result=-a-0.02;
  end
end
