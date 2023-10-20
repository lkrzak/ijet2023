% current model of a single transaction: each row is:
% [time (ms) current (mA)]
%
% Example = [
%   0.1 20;   % 20mA during 0.1ms
%   2.5 30;   % 30mA during 2.5ms
% ];
%
function [V, TR] = wmbus_transaction(mode, appPayloadLen, hasAck)
    V = 3.3;
    TR = [
      0.1 20; % wake up
      25 30;  % transmission
      5  20;  % reception
     ];
end
