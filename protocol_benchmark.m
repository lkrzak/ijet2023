close all
clear all


idle_current = 0.01; %mA
available_charge = 1000; %mAh
payload_length = 1:13;%bytes
transaction_interval = 3.6e6;%ms

min_len = 1;
max_len = 16;

actislink_modes = ["02" "13", "47", "58", "69"]';
actislink_tab = generate_variants("Actislink", actislink_modes, min_len, max_len, @actislink_transaction);

lora_modes = ["DR0", "DR1", "DR2", "DR3", "DR4", "DR5", "DR6"]';
lora_tab = generate_variants("LoRa", lora_modes, min_len, max_len, @lora_transaction);

sigfox_modes = ["unidirectional", "bidirectional"]';
sigfox_tab = generate_variants("Sigfox", sigfox_modes, min_len, max_len, @sigfox_transaction);

wmbus_modes = ["S1", "S2", "T1", "T2", "C1"]';
wmbus_tab = generate_variants("WM-BUS", wmbus_modes, min_len, max_len, @wmbus_transaction);


nbiot_tab = generate_variants("NB-IoT", "PSM", min_len, max_len, @nbiot_transatction);

input = vertcat(actislink_tab , lora_tab, sigfox_tab, wmbus_tab, nbiot_tab);

% result = table('Size', [height(variants) 3], 'VariableTypes', {'double', 'double', 'double'}, );


transaction_charge = zeros(height(input), 1);
transaction_duration = zeros(height(input), 1);

for v = 1: height(input)
    entry = input(v, :);
    [voltage, tr] = entry.Callback{1}(entry.Mode, entry.Payload);
    transaction_charge(v) = sum(prod(tr, 2)) / (3.6e6);
    transaction_duration(v) = sum(tr(:,1));
end


charge_per_interval = zeros(height(input), 1); % mAh

for v = 1: height(input)
    idle_duration = transaction_interval-transaction_duration(v);
    idle_charge = idle_duration * idle_current / 3.6e6;
    charge_per_interval(v) = idle_charge + transaction_charge(v);
end

max_intervals = ceil(max(available_charge ./ charge_per_interval, [],"all"));

figure;

t = linspace(0, max_intervals);
for v = 1: height(input)
    hold on;
    y = available_charge - t * charge_per_interval(v);
    entry = input(v,:);
    plot(t, y,'DisplayName',strcat(entry.Protocol, ' mode:' ,entry.Mode, "@", num2str(entry.Payload)));
end

function[tab] = generate_variants(name, modes, min_length, max_length, fn)
length_variants = max_length - min_length + 1;
mode_variants = length(modes);
lengths = repmat([min_length : max_length]', mode_variants, 1);
modes = repmat(modes, length_variants, 1);
count = mode_variants * length_variants;
names = repmat(name, count, 1);

callbacks = repmat({fn}, count, 1);

tab = table(names, modes, lengths, callbacks, 'VariableNames', ["Protocol", "Mode", "Payload", "Callback"]);
end



