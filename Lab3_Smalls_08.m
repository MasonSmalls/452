 clear
 clc

%%%%%Int Data Creation%%%%%
dataIn =rand(1, 2^14) > 0.5;
nu = [2,3.5,5];
nc = [2,4,7];
freq_carrier = 2000;
freq_symbol = 200;
noiseList = [0, 0.7]; %noise level
errList = zeros(1, numel(noiseList));
errRate = zeros(1, numel(noiseList));
SNR = zeros(1, numel(noiseList));
berc=zeros(1,18);
z=1;
for i=1: numel(noiseList)
    for j=1: numel(nc)
        for k=1: numel(nu)
            for a=1: 6
            noise = noiseList(i);
            loss = (3*nc(j))^(-nu(k)/2);
            phase=10+(90-10)*rand(1)*(pi/180);
            %%%%%% Int MODEM PART %%%%%%%%%
            dC = numel(dataIn);
            %Total numbeer of bits
            symbolCount = dC/2;
            %In qpsk number of points that are represented by the 2 bit points
            totalTime = symbolCount / freq_symbol;
            SR = 16 * freq_carrier;
            nSample = totalTime * SR;
            noiseSeries = randn(1, nSample) * noise;
            
            %%%%%%%%% Int Signal Portion %%%%%%%%%
            
            dataPol = dataIn*2-1;
            dataI = [dataPol(1:2:end)];
            dataQ = dataPol(2:2:end);
            t=(0:1000)*0.0001;
            SamplePerSymbol= round(1001/16);
            %square wave
            for l=0:1000
            mes1(l+1) = dataI( floor( l / 1001 * 16)+1);
            mes2(l+1) = dataQ( floor( l / 1001 * 16)+1);
            end
            m1Noise= mes1 + randn(1,1001)*noise;
            m2Noise= mes2 + randn(1,1001)*noise;
            dataOut = m1Noise( round(SamplePerSymbol/2):SamplePerSymbol:end)>0;
            dataSplit = reshape(dataIn, 2, numel(dataIn)/2);
            noiseSeries = randn(1, nSample)* noise;
            signal = zeros(1, numel(noiseSeries));
            signalWNoise = signal + noiseSeries;
            signalWNoise = signalWNoise(1:1001);
            
            % Int MODULATION OF MESSAGES%
            
            A=loss*((m1Noise.*cos(2*pi*freq_carrier*t+phase)+m2Noise.*sin(2*pi*freq_carrier*t+phase))+signalWNoise.*noise);

            if a == 1
                dint1=A;
            end
            if a == 2
                dint2=A;
            end
            if a == 3
                dint3=A;
            end
            if a == 4
                dint4=A;
            end
            if a == 5
                dint5=A;
            end
            if a == 6
                dint6=A;
            end
            end
            
            %%%%Signal Creation%%%%%


dataIn =rand(1, 2^14) > 0.5;

            
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
            for l=0:1000
            mes1(l+1) = dataI( floor( l / 1001 * 16)+1);
            mes2(l+1) = dataQ( floor( l / 1001 * 16)+1);
            end
            m1Noise= mes1 + randn(1,1001)*noise;
            m2Noise= mes2 + randn(1,1001)*noise;
            dataOut = m1Noise( round(SamplePerSymbol/2):SamplePerSymbol:end)>0;
            dataSplit = reshape(dataIn, 2, numel(dataIn)/2);
            noiseSeries = randn(1, nSample)* noise;
            signal = zeros(1, numel(noiseSeries));
            signalWNoise = signal + noiseSeries;
            signalWNoise = signalWNoise(1:1001);
            
            % MODULATION OF MESSAGES%
            
            A=(m1Noise.*cos(2*pi*freq_carrier*t)+m2Noise.*sin(2*pi*freq_carrier*t)+signalWNoise.*noise);

            %%%%Adding Signlas together%%%%%

            sigcombined=A+dint1+dint2+dint3+dint4+dint5+dint6;

            %Demodulation of Message%
            
            [bb,aa]=butter(15, .6);
            m1D= sigcombined.*cos(2*pi*freq_carrier*t);
            m2D= sigcombined.*sin(2*pi*freq_carrier*t);   
            message1=filtfilt(bb, aa, m1D);
            message2=filtfilt(bb,aa, m2D);


            %%% Error Count%%%
            l=1;
            m=1;
            BEC=0;
            data1 = reshape([mes1 mes2]',1,[]);
            data2 = reshape([message1 message2]',1,[]);
            temp = data2;
            for n=1:numel(data1)
                if temp(l)>=-0.5
                    temp(l)= 1;
                    l=l+1;
                else temp(l)=-1;
                    l=l+1;
                end
            end
            o=1;
            for n=1:numel(data1)
                if temp(o) ~= data1(o)
                    BEC=BEC+1;
                    o=o+1;
                else
                    o=o+1;
                end
            end
        
            %SNR(z)=1/noise+CCI;
            %errList(z) = BEC;
            %errRate(z)=errList(z)/2002;
            berc(z) = BEC;
            errRate(z)=berc(z)/2002*100;
            z=z+1;
            %subplot(3, 2, 5); plot(noiseList, errRate);
            %subplot(3, 2, 6); semilogy(errRate, SNR);

        end
    end
end



