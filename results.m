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
    if strcmp(item(i).protocol, 'Actislink')
        [v, item(i).transaction] = actislink_transaction(item(i).mode, payload_length);
    end
    item(i).totalCharge = sum(prod(item(i).transaction, 2)) / (3.6e3); %uAh
end

figure;
barh([item.totalCharge]);
axis = gca;
c = struct2cell(item);
axis.YTickLabels = c(3,1,:);
axis.YAxis.TickLength = [0 0];
xlabel('Charge consumed in single transaction [\muAh]');
ylabel('Protocol and mode');

for i = 1:size(item, 2)
    text(item(i).totalCharge+0.1,i, num2str(item(i).totalCharge, '%.3f'));
end
box off