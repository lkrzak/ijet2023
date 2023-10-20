function plot_transaction(tr)
durations = [0; tr(:, 1)];
current = [tr(:,2); 0];

t = cumsum(durations)
stairs(t, current,'-o')

xlabel('time [s]')
ylabel('current [mA]')
end
