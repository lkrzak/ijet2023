close all 
clear all

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

figure;
hold on
for len = 1: 12
    for variant = 1: size(variants)
        [x, y, z] = variants{variant}(len)
        plot_transaction(y)
    end
end