close all
clear all

addpath('labelpoints')



sleep_current = 0.003; %mA
available_charge = 1000; %mAh
payload_length = 16; %bytes


i = 1;

% item(i).protocol = 'WMBus';
% item(i).mode = 'S1';
% i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'S2';
item(i).pos = "N";
i = i + 1;
% item(i).protocol = 'WMBus';
% item(i).mode = 'T1';
% i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'T2';
item(i).pos = "NE";
i = i + 1;
% item(i).protocol = 'WMBus';
% item(i).mode = 'C1';
% i = i + 1;

item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR0';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR1';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR2';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR3';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR4';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR5';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR6';
item(i).pos = "SE";
i = i + 1;

% item(i).protocol = 'Sigfox';
% item(i).mode = 'unidirectional';
% i = i + 1;
item(i).protocol = 'Sigfox';
item(i).mode = 'bidirectional';
item(i).pos = "SW";
i = i + 1;

item(i).protocol = 'Actislink';
item(i).mode = '02';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '13';
item(i).pos = "NW";
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '47';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '58';
item(i).pos = "SE";
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '69';
item(i).pos = "NW";
i = i + 1;
item(i).protocol = 'NB-IoT';
item(i).mode = 'psm';
item(i).pos = "NE";
i = i + 1;


for i = 1:length(item)
    item(i).name = strcat(item(i).protocol, ":", item(i).mode);
    if strcmp(item(i).protocol, 'WMBus')
        [v, item(i).transaction item(i).uplink_budget item(i).downlink_budget] = wmbus_transaction(item(i).mode, payload_length);
        item(i).color = 'xb';
    end
    if strcmp(item(i).protocol, 'LoRaWAN')
        [v, item(i).transaction item(i).uplink_budget item(i).downlink_budget] = lora_transaction(item(i).mode, payload_length);
        item(i).color = 'or';
    end
    if strcmp(item(i).protocol, 'Sigfox')
        [v, item(i).transaction item(i).uplink_budget item(i).downlink_budget] = sigfox_transaction(item(i).mode, 12);
        item(i).color = '^m';
    end     
    if strcmp(item(i).protocol, 'Actislink')
        [v, item(i).transaction item(i).uplink_budget item(i).downlink_budget] = actislink_transaction(item(i).mode, payload_length, 1);
        item(i).color = 'og';
    end  
    if strcmp(item(i).protocol, 'NB-IoT')
        [v, item(i).transaction item(i).uplink_budget item(i).downlink_budget] = nbiot_transaction(item(i).mode, payload_length);
        item(i).color = 'vc';
    end     
    item(i).totalCharge = sum(prod(item(i).transaction, 2)) / (3.6e3); %uAh
end


T = struct2table(item); % convert the struct array to a table
sortedT = sortrows(T, 'totalCharge'); % sort the table by 'DOB'
item = table2struct(sortedT); % change it back to struct array if necessary


labels = {};
for i = 1:length(item)
    labels{i} = item(i).name;
end





f = figure;
f.Position = [0 0 800 800];
barh([item.totalCharge], 'BarWidth', 0.5);
axis = gca;
c = struct2cell(item);
axis.YTickLabels = labels;
axis.YTick=1:length(item)
axis.YAxis.TickLength = [0 0];
axis.YDir = 'reverse';
xlabel('Charge consumed in a single transaction [\muAh]');
ylabel('Protocol and mode');
xlim([0 30]);
hold on;
for i = 1:length(item) - 1
   
    text(item(i).totalCharge+0.5,i, num2str(item(i).totalCharge, '%.2f'));
end
annotation('textarrow', [.95 .95], [.20 .13], 'String',item(end).totalCharge);
box off;



f = figure;
hold on;
for i = 1:length(item)
    hold on;

     plot(item(i).uplink_budget,item(i).totalCharge,item(i).color);
     labelpoints(item(i).uplink_budget,item(i).totalCharge,strcat("  ", labels{i}," "),item(i).pos, 0, 1)
 

end
axis = gca;
axis.YScale ="log";
xlabel('Uplink budget [dB]');
ylabel('Charge per transaction [\muAh]');
xlim([110 160]);
ylim([0.01, 2e2])

f = figure;
for i = 1:length(item)
    plot_transaction(item(i).transaction);
    hold on;
end
axis = gca;
axis.XScale ="log";

f = figure;
plot_transaction(item(4).transaction, 'b');
xlabel('Time [ms]');
ylabel('Consumed current [mA]');
%annotation('textarrow', [0.3,0.234], [0.2905,0.3238], 'String','IDLE');
text(3, 16, 'TX');
text(50, 4, 'RX');
f.Position = [0 0 500 250];
saveas(f,'tr_wmbus.png')

f = figure;
plot_transaction(item(14).transaction, 'b');
xlabel('Time [ms]');
ylabel('Consumed current [mA]');
f.Position = [0 0 500 250];
text(500, 5, 'TX');
text(1700, 5, 'SLEEP');
text(2800, 5, 'RX');
saveas(f,'tr_lorawan.png')

f = figure;
plot_transaction(item(16).transaction, 'b');
xlabel('Time [ms]');
ylabel('Consumed current [mA]');
f.Position = [0 0 500 250];
text(300,  24, 'TX');
text(2900, 24, 'TX');
text(5500, 24, 'TX');
text(15000, 10, 'WAIT');
text(29000, 10, 'RX');
text(38200, 24, 'TX');
saveas(f,'tr_sigfox.png')

