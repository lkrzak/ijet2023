% Model based on https://journals.sagepub.com/doi/epub/10.1155/2014/579271
% current model of a single transaction: each row is:
% [time (s) current (A)]
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

function [V, TR] = wmbus_transaction(mode, app_payload_length)
V = 3.3;
switch mode
    case 'S1'
        TR =  wmbus_transaction_s1(app_payload_length);
    case 'T1'
        TR =  wmbus_transaction_t1(app_payload_length);
    case 'T2'
        TR =  wmbus_transaction_t2(app_payload_length);
    case 'C1'
        TR =  wmbus_transaction_c1(app_payload_length);
    otherwise
        error('not supported WM-bus mode')
end
end


function TR = wmbus_transaction_s1(app_payload_length)
bitrate_up = 16384; % kbps
preamble_sync_length  = 576 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length / 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    0 0.055;  % transmission
    t_tx 0 % end of transaction
    ];
end


function TR = wmbus_transaction_t1(app_payload_length)
bitrate_up = 66666; % kbps
preamble_sync_length  = 48 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length / 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    0 0.055;  % transmission
    t_tx 0 % end of transaction
    ];
end


function TR = wmbus_transaction_t2(app_payload_length)
bitrate_up = 66666; %bps
bitrate_down = 16384 %bps

preamble_sync_length  = 48 + 2; %bits
frame_length = preamble_sync_length + (app_payload_length * 8);

% ack length from (https://oms-group.org/fileadmin/files/download4all/specification/Vol2/4.1.2/OMS-Spec_Vol2_AnnexN_B042.pdf)
ack_length = 30 * 8; %bits 

t_tx = frame_length / bitrate_up; %seconds
t_guard = 0.04; 
t_rx_ack = 2* t_guard  + (ack_length / bitrate_down); %seconds

t_switch = 0.005; %seconds

TR = [
    0 0.055;  % transmission
    t_tx 0 % tx to rx switch time
    t_tx + t_switch 20;  % reception
    t_tx + t_switch + t_rx_ack 0 % end of transaction
    ];
end

function TR = wmbus_transaction_c1(app_payload_length)
bitrate_up = 100000; % kbps
preamble_sync_length  = 32 + 32; %bits
frame_length = preamble_sync_length + (app_payload_length / 8);
t_tx = frame_length / bitrate_up; %seconds
TR = [
    0 0.055;  % transmission
    t_tx 0 % end of transaction
    ];
end

