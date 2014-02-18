% In this file, we will perform some statistical tests 
% to ensure that the data collected is i.i.d. and 
% follows a Normal Distribution. 

%% Step 1. Collect the data from csv file. 

% Collect data from csv file. 
Data = csvread('TolBenNGPrices.csv',1,1); 

% Separate data by type of commodity. 
Benzene = Data(:,1); 
Toluene = Data(:,2); 
NaturalGas = Data(:,3); 

%% Step 2. Construct plot for price data. 

% Collect date vectors for plot 
startdate = datenum('01-Feb-2011','dd-mm-yyyy'); 
enddate = datenum('01-Jan-2013','dd-mm-yyyy'); 
DateVector = linspace(startdate,enddate,24); 

% Make plot of the prices of the commodities. 
figure(1) 
plot(DateVector,Benzene,DateVector,Toluene,'r',DateVector,NaturalGas,'g')
title('Price Plot for Commodities involved in the HDA Process') 
legend('Benzene','Toluene','Natural Gas')
ylabel('Prices') 
xlabel('Dates')
datetick('x','mmm-yy') 

%% Step 3. Calculate log-returns and perform statistical analysis. 

% Compute log returns for the prices of all the commodities. 
for i = 2 : length(Benzene)
    LRBenzene(:,i-1) = log(Benzene(i)/Benzene(i-1));
    LRToluene(:,i-1) = log(Toluene(i)/Toluene(i-1));
    LRNG(:,i-1) = log(NaturalGas(i)/NaturalGas(i-1));
end

% Make plot of the prices of the commodities. 
figure(2) 
subplot(3,3,[1 2 3])
plot(DateVector(2:end),LRBenzene)
title('Log Return Plot for Commodities involved in the HDA Process') 
legend('Benzene')
ylabel('Log Returns') 
xlabel('Dates')
datetick('x','mmm-yy') 
% Construct a lag plot for the prices. 
subplot(3,3,4)
LagBenzene = lagmatrix(LRBenzene,[0,1]); 
scatter(LagBenzene(:,1),LagBenzene(:,2),'fill')
axis 'equal'
axis 'square'

% Construct Histograms for the log returns. 
subplot(3,3,[5 6])
histfit(LRBenzene(:),10);

subplot(3,3,[7 8 9])
autocorr(LRBenzene)

% Make plot of the prices of the commodities. 
figure(3) 
subplot(3,3,[1 2 3])
plot(DateVector(2:end),LRToluene,'r')
title('Log Return Plot for Commodities involved in the HDA Process') 
legend('Toluene')
ylabel('Log Returns') 
xlabel('Dates')
datetick('x','mmm-yy') 
% Construct a lag plot for the prices. 
subplot(3,3,4)
LagToluene = lagmatrix(LRToluene,[0,1]); 
scatter(LagToluene(:,1),LagToluene(:,2),'fill')
axis 'equal'
axis 'square'

% Construct Histograms for the log returns. 
subplot(3,3,[5 6])
histfit(LRToluene(:),10,'normal');

subplot(3,3,[7 8 9])
autocorr(LRToluene)

% Make plot of the prices of the commodities. 
figure(4) 
subplot(3,3,[1 2 3])
plot(DateVector(2:end),LRNG,'g')
title('Log Return Plot for Commodities involved in the HDA Process') 
legend('Natural Gas')
ylabel('Log Returns') 
xlabel('Dates')
datetick('x','mmm-yy') 
% Construct a lag plot for the prices. 
subplot(3,3,4)
LagNG = lagmatrix(LRNG,[0,1]); 
scatter(LagNG(:,1),LagNG(:,2),'fill')
axis 'equal'
axis 'square'

% Construct Histograms for the log returns. 
subplot(3,3,[5 6])
histfit(LRNG(:),10);

subplot(3,3,[7 8 9])
autocorr(LRNG)

%%  

LR = [LRBenzene(:),LRToluene(:),LRNG(:)]


