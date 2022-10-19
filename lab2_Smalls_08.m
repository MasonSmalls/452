dataIn =[0,1,0,1,0,0,0,1,0,0,0,0,1,0,0,0, ( rand(1, 2^14) > 0.5)];
freq_carrier = 2000;
freq_symbol = 200;
noiseList = [0, 0.01, 0.05, 0.1, .5, 1, 2, 5] %noise level
errList = zeros(1, numel(noiseList));
errRate = zeros(1, numel(noiseList));
SNR = zeros(1, numel(noiseList));


for i=1: numel(noiseList)
    noise = noiseList(i)
    %%%%%% MODEM PART %%%%%%%%%
    dC = numel(dataIn);
    %Total numbeer of bits
    symbolCount = dC/2;
    %In qpsk number of points that are represented by the 2 bit points
    totalTime = symbolCount / freq_symbol;
    SR = 16 * freq_carrier;
    nSample = totalTime * SR;
    noiseSeries = randn(1, nSample) * noise;
    
    %%%%%%%%% Signal Portion %%%%%%%%%
    
    dataPol = dataIn*2-1;
    dataI = [dataPol(1:2:end)];
    dataQ = dataPol(2:2:end);
    t=(0:1000)*0.0001;
    SamplePerSymbol= round(1001/16);
    %square wave
    for j=0:1000
    mes1(j+1) = dataI( floor( j / 1001 * 16)+1);
    mes2(j+1) = dataQ( floor( j / 1001 * 16)+1);
    end
    m1Noise= mes1 + randn(1,1001)*noise;
    m2Noise= mes2 + randn(1,1001)*noise;
    dataOut = m1Noise( round(SamplePerSymbol/2):SamplePerSymbol:end)>0
    dataSplit= reshape(dataIn, 2, numel(dataIn)/2)
    noiseSeries = randn(1, nSample)* noise;
    signal = zeros(1, numel(noiseSeries));
    signalWNoise = signal + noiseSeries;
    signalWNoise = signalWNoise(1:1001);
    
    % MODULATION OF MESSAGES%
    
    A=m1Noise.*cos(2*pi*freq_carrier*t)+m2Noise.*sin(2*pi*freq_carrier*t)+signalWNoise.*noise;
    
    %Demodulation of Message%
    
    [bb,aa]=butter(15, .6);
    m1D= A.*cos(2*pi*freq_carrier*t);
    m2D= A.*sin(2*pi*freq_carrier*t);   
    message1=filtfilt(bb, aa, m1D);
    message2=filtfilt(bb,aa, m2D);
    if i==2;
    subplot(3,1,1); plot (t, message1, t, message2, '*');
    else if i==5;
    subplot(3,1,2); plot (t, message1, t, message2, '*');
    end
    %%% Error Count%%%
    l=1;
    m=1;
    BEC=0;
    data1 = reshape([mes1 mes2]',1,[]);
    data2 = reshape([message1 message2]',1,[]);
    temp = data2;
    for k=1:numel(data1)
        if temp(l)>=0
            temp(l)= 1;
            l=l+1;
        else temp(l)=-1;
            l=l+1;
        end
    end
    l=1;
    for k=1:numel(data1)
        if temp(l) ~= data1(l)
            BEC=BEC+1;
            l=l+1;
        else
            l=l+1;
        end
    end

    SNR(i)=1/noise;
    errList(i) = BEC;
    errRate(i)=errList(i)/2002;

    subplot(3, 2, 5); plot(noiseList, errRate);
    subplot(3, 2, 6); semilogy(errRate, SNR);
    end
end
