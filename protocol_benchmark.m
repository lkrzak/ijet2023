close all 
clear all

idle_current = 0.01; %mA
available_charge = 1000; %mAh
payload_length = 1:20;

%transaction_interval 

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

transaction_charge = zeros(length(variants), length(payload_length));
transaction_duration = zeros(length(variants), length(payload_length));

for len = payload_length
    for variant = 1: size(variants)
        [voltage, tr] = variants{variant}(len);
        transaction_charge(variant, len) = sum(prod(tr, 2)) / (3.6e6)
        transaction_duration = sum(tr(:,1))
        
        %plot_transaction(transitions)
    end
end