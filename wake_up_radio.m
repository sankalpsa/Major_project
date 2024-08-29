% Author: Sankalp B Chandavarkar
% Date: 26-07-2024

clc;
batteryValues = [12, 30, 15, 9, 6];

% Get the max values and sorted values
[MAX, ~] = get_max(batteryValues);

function [maxValues, sortedValues] = get_max(batteryValues)
    sortedValues = sort(batteryValues, 'descend');
    maxValues = sortedValues(1:3);
end

function Utime = update_time()
    Utime = round(rand(1), 1);
end

function correctedValues = correction(batteryValues)
    for i=1:length(batteryValues)
        if batteryValues(i) < 0
            batteryValues(i) = 0;
        else
            continue;
        end
    end
    correctedValues = batteryValues;
end

global k t history update time;
k = 1;
t = 0;
history = [];
update = [];
time = [];

function [updatedValues, history, time] = battery_reduction(MAX, batteryValues)
    global k t history update time;
    
    j = find(MAX(1) == batteryValues);
    Uptime = t + update_time();
    
    while batteryValues(j) >= MAX(2) && any(batteryValues,"all")
        if t == Uptime
            history(k, :) = batteryValues;
            batteryValues(j) = max(0,batteryValues(j) - 0.3);
            
            for i = 1:length(batteryValues)
                if i ~= j
                    batteryValues(i) = max(batteryValues(i) - 0.1, 0);

                end
            end
            
            update = correction(batteryValues);
            time(k, 1) = t + 0.1;
            t = time(k, 1);
            k = k + 1;

            Uptime = t + update_time();
            disp("New update time");
            disp(Uptime);
        else
            history(k, :) = batteryValues;
            
            for i = 1:length(batteryValues)
                batteryValues(i) = max(batteryValues(i) - 0.1, 0);

            end
            
            update = correction(batteryValues);
            time(k, 1) = t + 0.1;
            t = time(k, 1);
            k = k + 1;
        end
        % if all(batteryValues)
        %     break;
        % end
        
    end
    
    updatedValues = update;
end

while any(batteryValues > 0)
    [MAX, ~] = get_max(batteryValues);
    [update, history, time] = battery_reduction(MAX, batteryValues);
    batteryValues = update;
end

% Plot the battery levels
plot_battery_levels(time, history);

function plot_battery_levels(time, history)
    figure;
    hold on;
    
    for i = 1:size(history, 2)
        plot(time, history(:, i), 'LineWidth', 1.5);
    end
    
    xlabel('Time');
    ylabel('Battery Level');
    title('Battery Level Over Time');
    legend('Node 1', 'Node 2', 'Node 3', 'Node 4', 'Node 5');
    grid on;
end
