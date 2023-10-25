% This function returns:
% V - nominal voltage in Volts
% CCP - current consumption profile (see below)
% ULB - link budget for uplink in dB
% DLB - link budget for downlink in dB
%
% CCP is the current consumption profile of a single transaction
% It is a matrix, where each row has 2 columns:
% time (ms) current (mA)
%
% ExampleCCP = [
%   0.1 20;   % consumed 20mA during 0.1ms
%   2.5 30;   % consumed 30mA during 2.5ms
% ];
%
% -- Sigfox specific --
% The data is based on:
% Gomez, Carles & Veras, Juan & Vidal Ferré, Rafael & Casals Ibáñez, 
% Lluis & Paradells, Josep. (2019). 
% A Sigfox Energy Consumption Model. Sensors. 19. 681. 10.3390/s19030681. 
%
function [V, TR, ULB, DLB] = sigfox_transaction(mode, app_payload_length)
if app_payload_length <= 0 || app_payload_length > 12
    warning('invalid payload length for a single frame')
    V = NaN;
    TR = [NaN, NaN];
    return
end

V = 3.3;
ULB = 132 + 14.5;
DLB = 126 + 23;

switch mode
    case 'unidirectional'
        TR = sigfox_transaction_unidirectional(app_payload_length);
    case 'bidirectional'
        TR = sigfox_transaction_bidirectional(app_payload_length);
    otherwise
        error('not supported sigfox mode')
end
end

function TR = sigfox_transaction_unidirectional(app_payload_length)
bitrate_up = 100; % bps

frame_overhead = 14 * 8; %bits minimal frame size, excluding payload
frame_length = frame_overhead + (app_payload_length * 8);%bits
t_tx = frame_length / bitrate_up * 1e3; %ms
TR = [
    287 10.4;  % wake up
    t_tx 27.2 % tx
    486 1.2 % wait for next transmission
    t_tx 27.2 % tx replica 1
    486 1.2 % wait for next transmission
    t_tx 27.2 % tx replica 2
    5    1.2 % switch off
    ];
end


function TR = sigfox_transaction_bidirectional(app_payload_length)
bitrate_up = 100; % bps
%bitrate_down = 600; %bps

frame_overhead = 14 * 8; %bits minimal frame size, excluding payload
frame_length = frame_overhead + (app_payload_length * 8);%bits
t_tx = frame_length / bitrate_up * 1e3; %ms
TR = [
    287 10.4;  % wake up
    t_tx 27.2 % tx
    493 1.2 % % wait for next transmission
    t_tx 27.2 % tx replica 1
    493 1.2 % % wait for next transmission
    t_tx 27.2 % tx replica 2
    16493 1.3 % wait for packet propagation
    12690 18.5 % avg active reception window (0.387-25s)
    1430 1.2 % wait for confirmation tx
    1850 27 % confirmation tx
    5    1.2 % switch off
    ];
end