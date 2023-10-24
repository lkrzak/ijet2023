function plot_transaction(tr, varargin )
durations = [0; tr(:, 1)];
current = [tr(:,2); 0];
t = cumsum(durations);
if (nargin > 1)
    stairs(t, current, varargin{1:nargin-1})
else
    stairs(t, current)
xlabel('time [ms]')
ylabel('current [mA]')
end
