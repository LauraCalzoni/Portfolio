
%Dati plant ideale
%braccio modellato come un cilindro uniforme
M = 4; %[kg]
g = 9.81;
L = 0.3; %[m]
Lc = L/2; %posizione centro di massa

%Plant sottostimato
m = 2; %[kg]
l = 0.15; %[m]
lc = l/2; 

%Carico 
mc = 0; %[kg]

%Uncertainities
delta=ultidyn('delta',[1 1], 'Type', 'GainBounded','Bound', 7);
delta.SampleStateDimension = 2;
delta_sample= usample(delta,1);
nyquist(delta_sample)


delta1=ultidyn('delta1',[1 1], 'Type', 'GainBounded','Bound', 0.4);
delta1.SampleStateDimension = 2;
delta_sample1= usample(delta1,1);
nyquist(delta_sample1)


delta2=ultidyn('delta2',[1 1], 'Type', 'GainBounded','Bound', 0.8);
delta2.SampleStateDimension = 2;
delta_sample2= usample(delta2,1);
nyquist(delta_sample2)

delta3=ultidyn('delta3',[1 1], 'Type', 'GainBounded','Bound', 3);
delta3.SampleStateDimension = 2;
delta_sample3= usample(delta3,1);
nyquist(delta_sample3)


%Valori per FG
Ra=1;
Aa=2;
wb=2*pi*2  
s= tf('s')
K=(Ra*s+Aa*wb)/(s+wb)
K1=2
C= (K-1)/K
bode(C,'green',K,'red')
margin= 1/(K-1)
margin1= s*(1/s)
bode (margin,'blue',margin1, 'yellow')

Loop=C*(1+delta_sample)
nyquist(Loop)

%Spettro

Fs=1000;              % Sampling frequency                    
T = 1/Fs;             % Sampling period       
t = [0:0.001:10]; 

y=95*gaussmf(t,[0.4 7]);
y2=95*gaussmf(t, [0.4 1.78]);
y3=86*gaussmf(t, [0.38 3.42]);
y4=70*gaussmf(t,[0.32 2.63]);
signal= y+y2+y3+y4;
plot(t, signal)
d=length(t);
K= fft(signal);
P2 = abs(K/d);
P1 = P2(1:d/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(d/2))/d;
plot(f,P1)

% n = 2^nextpow2(d);
% 
% K=fft(signal,n);
% 
% f =Fs*(0:(n/2))/n;
% P = abs(K/n).^2;
% plot(f,P(1:n/2+1))
title('Single-Sided Amplitude Spectrum of signal(t)')
xlabel('f (Hz)')
ylabel('|P(f)|')



%tremore
wc=10*2*pi
Rt=0.05
FG2=(s^2+2*Rt*wc*s+wc^2)/(s^2+2*wc*s+wc^2);
bode(FG2)
C2=(FG2-1)/FG2
 

%controllore coppia
P=-2.97;
I=-22.3
D=-0.0193;
N=0;

PID= P+I/s+D*N/(1+N/s);
C=(PID-1)/PID



