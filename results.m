close all
clear all

sleep_current = 0.010; %mA
available_charge = 1000; %mAh
payload_length = 16; %bytes


i = 1;

item(i).protocol = 'WMBus';
item(i).mode = 'S1';
i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'S2';
i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'T1';
i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'T2';
i = i + 1;
item(i).protocol = 'WMBus';
item(i).mode = 'C1';
i = i + 1;

item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR0';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR1';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR2';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR3';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR4';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR5';
i = i + 1;
item(i).protocol = 'LoRaWAN';
item(i).mode = 'DR6';
i = i + 1;

item(i).protocol = 'Sigfox';
item(i).mode = 'unidirectional';
i = i + 1;
item(i).protocol = 'Sigfox';
item(i).mode = 'bidirectional';
i = i + 1;

item(i).protocol = 'Actislink';
item(i).mode = '02';
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '13';
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '47';
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '58';
i = i + 1;
item(i).protocol = 'Actislink';
item(i).mode = '69';
i = i + 1;


for i = 1:size(item, 2)
    item(i).name = strcat(item(i).protocol, ":", item(i).mode);
    if strcmp(item(i).protocol, 'WMBus')
        [v, item(i).transaction] = wmbus_transaction(item(i).mode, payload_length);
    end
    if strcmp(item(i).protocol, 'LoRaWAN')
        [v, item(i).transaction] = lora_transaction(item(i).mode, payload_length);
    end
    if strcmp(item(i).protocol, 'Sigfox')
        [v, item(i).transaction] = sigfox_transaction(item(i).mode, 12);
    end     
    if strcmp(item(i).protocol, 'Actislink')
        [v, item(i).transaction] = actislink_transaction(item(i).mode, payload_length);
    end    
    item(i).totalCharge = sum(prod(item(i).transaction, 2)) / (3.6e3); %uAh
end

f = figure;
f.Position = [0 0 700 600];
barh([item.totalCharge], 'BarWidth', 0.5);
axis = gca;
c = struct2cell(item);
axis.YTickLabels = c(3,1,:);
axis.YTick=1:size(item, 2);
axis.YAxis.TickLength = [0 0];
axis.YDir = 'reverse';
xlabel('Charge consumed in single transaction [\muAh]');
ylabel('Protocol and mode');
xlim([0 150]);
for i = 1:size(item, 2)
    text(item(i).totalCharge+0.5,i, num2str(item(i).totalCharge, '%.2f'));
end
box off