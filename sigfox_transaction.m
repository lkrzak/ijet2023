function [V, TR] = sigfox_transaction(mode, app_payload_length)
if app_payload_length <= 0 || app_payload_length > 12
    warning('invalid payload length for a single frame')
    V = NaN;
    TR = [NaN, NaN];
    return
end

V = 3.3;
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
    510 1.2 % cool down
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
    495 1.2 % cool down
    ];
end