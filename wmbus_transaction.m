% Model based on https://journals.sagepub.com/doi/epub/10.1155/2014/579271
% current model of a single transaction: each row is:
% [time (ms) current (mA)]
%
% Example = [
%   0.1 20;   % 20mA during 0.1ms
%   2.5 30;   % 30mA during 2.5ms
% ];
%
% using modes covered by:
% (C1, T1) https://pim.zenner.com/wp-content/uploads/documents/data_sheets/water_meter/WWZ/EN/DB_WWZ_Minomess_L868_wMB_EN.pdf
% T1 (https://www.piigab.com/en/download/hydrodigit-s1-datablad/?wpdmdl=60199&refresh=6532648712ac01697801351)
% S1, T1 (https://www.arigo-software.de/en/shop/domestic-flush-mbus-water-meter.html)
% T1, T2 (https://api.apator.com/uploads/oferta/woda-i-cieplo/systemy/radiowy/at-wmbus--16-2-apt-o3a-1-2/at-wmbus-16-2-catalogue.pdf)
% S1?, C1? (https://hit.sbt.siemens.com/RWD/app.aspx?RC=HQEU&lang=en&MODULE=Catalog&ACTION=ShowProduct&KEY=S55560-F121)
% Current and sensitivity data based on STM32WLE5C datasheet
function [V, TR, ULB, DLB] = wmbus_transaction(mode, app_payload_length)
if app_payload_length <= 0 || app_payload_length >=255
    warning('impossible wmbus payload length for single frame')
    V = NaN;
    TR = [NaN, NaN];
    return
end

V = 3.3;
tx_power = 10; % dBm
switch mode
    case 'S1'
        TR =  wmbus_transaction_s1(app_payload_length);
        sensitivity = -108; 
    case 'S2'
        TR =  wmbus_transaction_s2(app_payload_length);
        sensitivity = -108;     
    case 'T1'
        TR =  wmbus_transaction_t1(app_payload_length);
        sensitivity = -103; 
    case 'T2'
        TR =  wmbus_transaction_t2(app_payload_length);
        sensitivity = -103; 
    case 'C1'
        TR =  wmbus_transaction_c1(app_payload_length);
        sensitivity = -110; 
    otherwise
        error('not supported WM-bus mode')
end
TR = TR * 1000;
ULB = tx_power - sensitivity;
DLB = ULB;

end


function TR = wmbus_transaction_s1(app_payload_length)
bitrate_up = 16384; % bps
current_tx = 0.0175; %A
preamble_sync_length  = 576 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    t_tx current_tx;  % transmission
    ];
end


function TR = wmbus_transaction_s2(app_payload_length)
bitrate_up = 16384; %bps
bitrate_down = 16384; %bps

current_tx = 0.0175; %A
current_rx = 0.0055; %A

preamble_sync_length  = 48 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);

% ack length from (https://oms-group.org/fileadmin/files/download4all/specification/Vol2/4.1.2/OMS-Spec_Vol2_AnnexN_B042.pdf)
ack_length = preamble_sync_length + 30 * 8; %bits

t_tx = frame_length / bitrate_up; %seconds
t_guard = 0.03;
t_rx_ack = 2* t_guard  + (ack_length / bitrate_down); %seconds

t_switch = 0.001; %seconds

TR = [
    t_tx current_tx;  % transmission
    t_switch 0 % tx to rx switch time
    t_rx_ack current_rx;  % reception
    ];
end


function TR = wmbus_transaction_t1(app_payload_length)
bitrate_up = 66666; % bps

current_tx = 0.0175; %A

preamble_sync_length  = 48 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    t_tx current_tx;  % transmission
    ];
end


function TR = wmbus_transaction_t2(app_payload_length)
bitrate_up = 66666; %bps
bitrate_down = 16384; %bps

current_tx = 0.0175; %A
current_rx = 0.0055; %A

preamble_sync_length  = 48 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);

% ack length from (https://oms-group.org/fileadmin/files/download4all/specification/Vol2/4.1.2/OMS-Spec_Vol2_AnnexN_B042.pdf)
ack_length = preamble_sync_length + 30 * 8; %bits

t_tx = frame_length / bitrate_up; %seconds
t_guard = 0.03;
t_rx_ack = 2* t_guard  + (ack_length / bitrate_down); %seconds

t_switch = 0.001; %seconds

TR = [
    t_tx current_tx;  % transmission
    t_switch 0 % tx to rx switch time
    t_rx_ack current_rx;  % reception
    ];
end

function TR = wmbus_transaction_c1(app_payload_length)
bitrate_up = 100000; % bps

current_tx = 0.0175; %A

preamble_sync_length  = 32 + 32; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    t_tx current_tx;  % transmission
    ];
end

