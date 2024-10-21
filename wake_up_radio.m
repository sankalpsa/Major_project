clc;
clear;

% Ask the user for the number of nodes (maximum of 10)
nodeCount = input('Enter the number of nodes (maximum 10): ');
while nodeCount > 10 || nodeCount < 1
    nodeCount = input('Invalid entry. Please enter a number between 1 and 10: ');
end

% Initialize nodeValues array
nodeValues = zeros(1, nodeCount);

% Ask the user to input the battery values for each node (between 1 and 100)
for i = 1:nodeCount
    batteryValue = input(sprintf('Enter the battery value for node %d (between 1 and 100): ', i));
    while batteryValue < 1 || batteryValue > 100
        batteryValue = input(sprintf('Invalid entry. Please enter a value between 1 and 100 for node %d: ', i));
    end
    nodeValues(i) = batteryValue;
end

% Define thresholds and tolerances
threshold = 1e-10;
tolerance = 1e-9;

hello = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]; % Predefined wake-up intervals
currentTime = 0;
uptime = currentTime + hello(randi([1, length(hello)])); % Initial uptime scheduling
hysteresis = 0.5; % Hysteresis for leader node selection

% Multi-hop parameters
communicationRange = 2; % Simulating limited range
maxHops = 2; % Maximum number of hops allowed in multi-hop communication

% Initial leader selection (node with the highest battery level)
leaderIndex = find(nodeValues == max(nodeValues), 1);

% Create figure for battery visualization (2D bars)
figure(1);
barHandle = bar(nodeValues); % Create 2D bar graph
set(gca, 'YLim', [0 100]); % Adjust battery levels to the range of 0 to 100
title('Battery Levels of Nodes');
xlabel('Node');
ylabel('Battery Level');
grid on;

% Create figure for live plot of battery over time
figure(2);
hold on;
colors = lines(nodeCount);
hPlot = gobjects(1, nodeCount); % Initialize array to store plot handles

for i = 1:nodeCount
    hPlot(i) = plot(currentTime, nodeValues(i), 'Color', colors(i, :), 'LineWidth', 2);
end

xlabel('Time (seconds)');
ylabel('Node Battery Levels');
title('Live Node Values Over Time');
legend(arrayfun(@(x) sprintf('Node %d', x), 1:nodeCount, 'UniformOutput', false));
grid on;

% Choose random round for leader to transmit to sink
transmitToSinkRound = randi([5, 10]); % Leader will transmit to sink randomly after 5-10 rounds

% Loop until all node values are zero
roundCount = 0; % Counter to keep track of rounds
while any(nodeValues > 0)
    if currentTime >= (uptime - tolerance) % Data collection round
        interactionMatrix = rand(nodeCount, nodeCount) - 0.5; % Simulating data exchange
        interactionEffect = sum(interactionMatrix .* nodeValues', 2) * 0.01;

        % Leader node consumes more energy during data collection
        leaderConsumption = 0.5; % Higher energy consumption for the leader
        nodeValues(leaderIndex) = max(nodeValues(leaderIndex) - leaderConsumption + interactionEffect(leaderIndex), 0);

        % Non-Leader Nodes
        for i = 1:nodeCount
            if i ~= leaderIndex
                % Non-leader nodes consume less energy
                if abs(i - leaderIndex) > communicationRange
                    nonLeaderConsumption = 0.15; % Multi-hop cost (higher but still lower than the leader)
                else
                    nonLeaderConsumption = 0.1; % Direct communication cost
                end
                nodeValues(i) = max(nodeValues(i) - nonLeaderConsumption + interactionEffect(i), 0);
            end
        end

        % Every 5 rounds, all nodes transmit to the leader node
        roundCount = roundCount + 1;
        if mod(roundCount, 5) == 0
            for i = 1:nodeCount
                if i ~= leaderIndex && nodeValues(i) > 0
                    fprintf('Node %d is transmitting data to Leader Node %d.\n', i, leaderIndex);
                end
            end
        end

        % Leader transmits data to sink during randomly chosen round
        if roundCount == transmitToSinkRound
            fprintf('Leader Node %d is transmitting data to Sink Node.\n', leaderIndex);

            % Remove the arrow drawing
            % Add an arrow pointing out from the leader node in the bar graph
            % figure(1);
            % x = leaderIndex; % Position of leader node in the bar graph
            % annotation('arrow', [0.5 0.75], [0.5 0.8], 'Color', 'blue', 'LineWidth', 2); % Sample arrow parameters
            % text(x, 100, 'Data to Sink', 'FontSize', 12, 'Color', 'blue');

            % Reset random round for next transmission to sink
            transmitToSinkRound = roundCount + randi([5, 10]);
        end

        uptime = currentTime + hello(randi([1, length(hello)])); % Reschedule next uptime
    else
        % Simulate random battery drainage for idle nodes
        for i = 1:nodeCount
            interactionEffect = (rand - 0.5) * 0.01;
            if i ~= leaderIndex
                nodeValues(i) = max(nodeValues(i) - 0.02 + interactionEffect, 0); % Idle drain for non-leaders
            else
                nodeValues(leaderIndex) = max(nodeValues(leaderIndex) - 0.05 + interactionEffect, 0); % Higher idle drain for leader
            end
        end
    end

    % Update the 2D bar graph with new battery levels
    figure(1);
    barHandle.YData = nodeValues;  % Update bar values

    % Dynamically color each bar based on battery level
    for i = 1:nodeCount
        if nodeValues(i) > 60
            barHandle.FaceColor = 'flat';
            barHandle.CData(i, :) = [0, 1, 0];  % Green for high battery
        elseif nodeValues(i) > 30
            barHandle.FaceColor = 'flat';
            barHandle.CData(i, :) = [1, 1, 0];  % Yellow for medium battery
        else
            barHandle.FaceColor = 'flat';
            barHandle.CData(i, :) = [1, 0, 0];  % Red for low battery
        end
    end
    drawnow;

    % Update the live 2D plot
    figure(2);
    for i = 1:nodeCount
        set(hPlot(i), 'XData', [get(hPlot(i), 'XData') currentTime], ...
                      'YData', [get(hPlot(i), 'YData') nodeValues(i)]);
    end
    drawnow;

    % Fault tolerance: Identify new leader if current leader has too low battery
    secondMaxNodeValue = max(nodeValues(nodeValues ~= max(nodeValues))); % Find the second-highest battery value
    if nodeValues(leaderIndex) < secondMaxNodeValue % Leader re-election logic
        fprintf('Leader node %d has low battery. Selecting a new leader.\n', leaderIndex);
        nodeValues(leaderIndex) = max(nodeValues(leaderIndex) - 0.1, 0); % Adjust leader depletion
        potentialLeaderIndex = find(nodeValues == max(nodeValues), 1);

        if nodeValues(potentialLeaderIndex) > 0 % Ensure the potential leader is still alive
            leaderIndex = potentialLeaderIndex;
            fprintf('New leader selected: Node %d\n', leaderIndex);
        else
            disp('No viable leader remaining. Network failure possible.');
            break; % If no leader can be selected, the network collapses
        end
    end

    % Display current status
    fprintf('Time: %.1f, Leader: Node %d, Node Values: [%s]\n', currentTime, leaderIndex, num2str(nodeValues));

    currentTime = currentTime + 0.1; % Increment time
    pause(0.1); % Small delay to simulate real-time behavior
end

disp('All nodes have reached zero or the network has collapsed.');
