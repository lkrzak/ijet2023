%based on Nordic semiconductor NB-IoT power profiler
%(https://devzone.nordicsemi.com/power/w/opp/3/online-power-profiler-for-lte)

function [V, TR, ULB, DLB] = nbiot_transaction(mode, app_payload_length)
V = 3.7;

tx_power = 10;% dBm
sensitivity = -108;%dBm (nRF9160)
ULB=tx_power - sensitivity;
DLB=ULB;
TR = nbiot_transaction_psm(app_payload_length);
end


function [TR] = nbiot_transaction_psm(app_payload_length)

bitrate = 13e3; %bps - average achievable uplink rate https://www-file.huawei.com/-/media/CORPORATE/PDF/News/NB-IoT-Smart-Gas-Solution-EN.pdf?la=en
t_tx = 950 + (8*app_payload_length) / bitrate;
TR = [
    74.46 16.709    %network sync
    483 6.093 %sim sync
    149.743  36.294 %RRC setup
    931.115 36.294% TAU
    t_tx 35.307 % data upload
    527.939 17.523 %RRC release
    ];
end