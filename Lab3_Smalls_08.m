clear
clc

NN=1000;
scale = 1+(10-1)*rand(1, NN);
data=ones(1,1000);
data1=ones(1,NN);
chi_plot=zeros(1,5);
for q=1: 5
X = randn(1,NN);
Y = randn(1,NN);
Z = scale.*(X+1j.*Y);
for i=1: 20

    data=data.*Z;
    data1=data.*Z(i,:);
end



ourdata=abs(data);

mean=sum(data)/1000;
ourmean=sum(ourdata)/1000;
s=(sum((data-mean).^2/1000))^.5;
ours=(sum((ourdata-ourmean).^2/1000))^.5;
nD=(data-mean)/(sqrt(2)*s);
ournD= ourmean + sqrt(2)*ours*erfinv(2*ourdata-1);

%%nD fix%%
pacman=ourdata-ourmean;
luigi=sqrt(2)*ours;
sonic=pacman/luigi;

Max=2.5;
Min=-2.5;
bin=zeros(1,11);
binth=zeros(1,11);

%%%chi2 part%%%

for i=1:11
    bin(i)= sum(ourdata>Min+(Max-Min)/11*(i-1) & ourdata < Min + (Max-Min)/ 11*i);
end

for i=1:11
    binth(i)= 1000* (erf(Min+(Max-Min)/11 * i) - erf(Min+(Max-Min)/ 11*(i-1)))/2;
end

chiS= sum((bin-binth).^2./binth);
chi_plot(q)=chiS;
end
subplot(2,2,1);
histogram(abs(Z));

subplot(2,2,2);
histogram(abs(Z));
set(gca, "YScale", "log");

subplot(2,2,3)
plot(ournD, '*')
set(gca, "YScale", "log");

subplot(2,2,4)
plot(chi_plot(1:5), '*')
