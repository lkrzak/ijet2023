function [V, TR] = actislink_transaction(mode, app_payload_length)
V = 3.3;

phy_overhead = 19; % there are 19 bytes of overhead in each packet
ack_length = 20; % length of the ACK packet
current_tx = 55; % mA
current_rx = 20; % mA
current_idle = 5; % mA

switch mode
    case '02'
        bitrate_up = 50000;
        bitrate_down = 19200;        
    case '13'
        bitrate_up = 1200;
        bitrate_down = 9600;
    case '47'
        bitrate_up = 19200;
        bitrate_down = 19200;
    case '58'
        bitrate_up = 9600;
        bitrate_down = 9600;
    case '69'
        bitrate_up = 500;
        bitrate_down = 500;
    otherwise
        error('not supported Actislink mode: %s', mode)
end

% packet transmission time [ms]
Ttx = ((phy_overhead + app_payload_length)*8)*1000/bitrate_up;
% ack transmission time [ms]
Tack = (ack_length*8)*1000/bitrate_down;

% total receive window time [ms]
Trxwindow = (32*8)*1000/bitrate_down;
% active part of the receive window if there is no ACK [ms]
Trxnoack = (8*8)*1000/bitrate_down;
% active part of the receive window if there is an ACK [ms]
Trxack = (24*8)*1000/bitrate_down;

TR = [
    5                   current_idle;   % (1) wake up
    Ttx                 current_tx;     % (2) transmission
    5                   current_idle;   % (3) tx-rx time
    Trxnoack            current_rx;     % (4) 1st receive window (no ACK)
    Trxwindow-Trxnoack  current_idle;   % (5) wait 2nd window
    Trxack              current_rx;     % (6) 1st receive window (got ACK)
    5                   current_idle;   % (7) turn off sequence
    ];

end

