close all
clear all

idle_current = 0.01; %mA
available_charge = 1000; %mAh
payload_length = 1:13;%bytes
transaction_interval = 3.6e6;%ms


variants = {
    @(len) sigfox_transaction('unidirectional', len)
    @(len) sigfox_transaction('bidirectional', len)
    @(len) wmbus_transaction('S1', len)
    @(len) wmbus_transaction('S2', len)
    @(len) wmbus_transaction('T1', len)
    @(len) wmbus_transaction('T2', len)
    @(len) wmbus_transaction('C1', len)
    @(len) lora_transaction(0, len)
    @(len) lora_transaction(1, len)
    @(len) lora_transaction(2, len)
    @(len) lora_transaction(3, len)
    @(len) lora_transaction(4, len)
    @(len) lora_transaction(5, len)
    @(len) lora_transaction(6, len)
    };

transaction_charge = zeros(length(variants), length(payload_length)); %mAh
transaction_duration = zeros(length(variants), length(payload_length)); % ms

for len = 1 : length(payload_length)
    for variant = 1: size(variants)
        [voltage, tr] = variants{variant}(payload_length(len));
        transaction_charge(variant, len) = sum(prod(tr, 2)) / (3.6e6);
        transaction_duration(variant, len) = sum(tr(:,1));
    end
end


charge_per_interval = zeros(length(variants), length(payload_length)); % mAh

for len = 1 : length(payload_length)
    for variant = 1: size(variants)
        idle_duration = transaction_interval-transaction_duration(variant, len);
        idle_charge = idle_duration * idle_current / 3.6e6;

        charge_per_interval(variant, len) = idle_charge + transaction_charge(variant, len);
    end
end

max_intervals = ceil(max(available_charge ./ charge_per_interval, [],"all"));

figure;

t = linspace(0, max_intervals);
for len = 1 : length(payload_length)
    for variant = 1: size(variants)
        hold on;
        y = available_charge - t * charge_per_interval(variant, len);
        plot(t, y);
    end
end


