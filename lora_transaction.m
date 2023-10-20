% This function returns:
% V - nominal voltage in Volts
% TR - transaction current (see below)
% Q - total charge consumed by transaction in mAh
%
% TR: current model of a single transaction
% It is a matrix, where each row has 2 columns:
% time (ms) current (mA)
%
% ExampleTR = [
%   0.1 20;   % 20mA during 0.1ms
%   2.5 30;   % 30mA during 2.5ms
% ];
%
% LoRaWAN:
% Data rates for EU863-870 band channels.
% DR  Modulation    SF  BW      Bitrate
% 0	  LoRa          12	125 kHz	250
% 1	  LoRa	        11	125 kHz	440
% 2	  LoRa	        10	125 kHz	980
% 3	  LoRa	        9	125 kHz	1760
% 4	  LoRa	        8	125 kHz	3125
% 5	  LoRa	        7	125 kHz	5470
% 6	  LoRa	        7	250 kHz	11000
%
% Assumed PHY packet format
% | preamble | PHDR    | PHDR_CRC | PHY payload  | CRC    |
% | 8 bytes  | 2 bytes | 4 bytes  | variable     | 2 bytes|
%
% Assumed MAC+FRM packet format
% | MHDR     | FHDR    | Fport  | FRM payload | MIC     |
% | 1 byte   | 7 bytes | 1 byte | variable    | 4 bytes |
%
% Assumed coding rate: 4/5
%
function [V, TR, Q] = lora_transaction(dr, frmPayloadLen)

CR = 1; % assume coding rate of 4/5

% based on LoRaWAN regional requirements for EU868:
switch dr
    case 0
        SF = 12;
        DE = 1;
        BW = 125000;
        Trx1w = 262.14;
        Tw2w = 33.02;
    case 1
        SF = 11;
        DE = 1;
        BW = 125000;
        Trx1w = 131.07;
        Tw2w = 16.64;
    case 2
        SF = 10;
        BW = 125000;
        DE = 0;
        Trx1w = 98.30;
        Tw2w = 8.45;
    case 3
        SF = 9;
        BW = 125000;
        DE = 0;
        Trx1w = 49.15;
        Tw2w = 4.35;
    case 4
        SF = 8;
        BW = 125000;
        DE = 0;
        Trx1w = 24.58;
        Tw2w = 2.30;
    case 5
        SF = 7;
        BW = 125000;
        DE = 0;
        Trx1w = 12.29;
        Tw2w = 1.28;
    case 6
        SF = 7;
        BW = 125000;
        DE = 0;
        Trx1w = 6.14;
        Tw2w = 0.64;
end

% based on SX1272/3/6/7/8: LoRa Modem DesignerDs Guide AN1200.13:
Tsym = (2^SF)/BW;             % symbol time in [s]
Tpreamble = (8 + 4.25)*Tsym;  % preamble time in [s]

tp = 8*frmPayloadLen - 4 *SF + 28 + 16;
tp = tp / (4*(SF - 2*DE));
tp = ceil(tp);
tp = tp * (CR+4);
Np = 8+max(tp,0);             % number of symbols (excluding preamble)
Ttx = (Tpreamble + (Np*Tsym))*1000; % total transmission time in [s]

% assume voltage
V = 3.3;

% based on
% Casals, L.; Mir, B.; Vidal, R.; Gomez, C. 
% Modeling the Energy Performance of LoRaWAN. 
% Sensors 2017, 17, 2364. https://doi.org/10.3390/s17102364
TR = [
    168.2   22.1;   % (1) wake up
    83.8    13.3;   % (2) radio preparation
    Ttx     83.0;   % (3) transmission
    983.3   27.0;   % (4) wait 1st window
    Trx1w   38.1;   % (5) 1st receive window
    Tw2w    27.1;   % (6) wait 2nd window
    33      35.0;   % (7) 2nd receive window
    147.4   13.2;   % (8) radio off
    268     21.0;   % (9) postprocessing
    38.6    13.3;   % (10) turn off sequence
    ];

% calculate charge
Q = sum(prod(TR, 2)) / (3.6e6)
%Q = Q / (1000*3600);

end

