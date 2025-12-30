% ---------------------------------------------------------
% LIVE DEMO: RFID Emergency Ward Simulation Engine
% ---------------------------------------------------------
clear; clc; close all;

% --- 1. SETUP PARAMETERS ---
wardW = 20; wardH = 15;
numPatients = 50;
rx = [5, 15, 10]; ry = [11.25, 11.25, 3.75]; % Reader positions

% Initialize Patient Positions (Random)
px = rand(1, numPatients) * wardW;
py = rand(1, numPatients) * wardH;

% --- 2. SETUP FIGURE ---
f = figure('Name', 'LIVE SIMULATION ENGINE', 'Color', [0.1 0.1 0.1], ...
    'Position', [100 100 1000 600]);

% Main Map Plot
subplot('Position', [0.05 0.1 0.60 0.85]);
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
title('LIVE TRACKING: 50 AGENTS', 'Color', 'w');

% Draw Zones
rectangle('Position', [0 7.5 10 7.5], 'EdgeColor', 'c', 'LineStyle', '--');
rectangle('Position', [10 7.5 10 7.5], 'EdgeColor', 'g', 'LineStyle', '--');
rectangle('Position', [0 0 10 7.5], 'EdgeColor', 'y', 'LineStyle', '--');
rectangle('Position', [10 0 10 7.5], 'EdgeColor', 'm', 'LineStyle', '--');

% Draw Static Readers
scatter(rx, ry, 200, 'p', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'r');

% Initialize Patient Plot Handles
hPatients = scatter(px, py, 50, 'filled', 'MarkerFaceColor', [0.2 0.6 1]);
hAlert = scatter(-10, -10, 100, 'r', 'filled'); % Hidden initially

% --- 3. LIVE ANIMATION LOOP ---
% Run for 500 frames (approx 30-60 seconds)
for t = 1:500
    % A. Move Patients (Random Walk)
    % Add small random movement (-0.2 to +0.2 meters)
    moveX = (rand(1, numPatients) - 0.5) * 0.4;
    moveY = (rand(1, numPatients) - 0.5) * 0.4;
    
    px = px + moveX;
    py = py + moveY;
    
    % Keep inside walls
    px = max(0, min(wardW, px));
    py = max(0, min(wardH, py));
    
    % Update Plot
    set(hPatients, 'XData', px, 'YData', py);
    
    % B. Simulate "Fall Event" (Randomly every ~50 frames)
    if mod(t, 50) == 0
        fall_id = randi(numPatients);
        set(hAlert, 'XData', px(fall_id), 'YData', py(fall_id));
        title(['ALERT: FALL DETECTED AT [' num2str(px(fall_id), '%.1f') ', ' num2str(py(fall_id), '%.1f') ']'], 'Color', 'r', 'FontSize', 14);
    elseif mod(t, 50) == 10
        % Reset Alert
        set(hAlert, 'XData', -10, 'YData', -10);
        title('SYSTEM STATUS: MONITORING...', 'Color', 'g', 'FontSize', 12);
    end
    
    % C. Update Live Stats (Fluctuate slightly)
    acc = 91 + (rand()-0.5)*2; % Fluctuate around 91-93%
    lat = 1.9 + (rand()-0.5)*0.2; % Fluctuate around 1.8-2.0s
    
    % Update Sidebar Text
    if exist('hText', 'var'), delete(hText); end
    stats_str = {
        '\bf LIVE METRICS', ...
        '-----------------', ...
        ['Frame: ' num2str(t)], ...
        ['Active Tags: ' num2str(numPatients)], ...
        '', ...
        ['Accuracy: \color{green}' num2str(acc, '%.1f') '%'], ...
        ['Latency:  \color{green}' num2str(lat, '%.2f') ' s'], ...
        ['CPU Load: \color{yellow}' num2str(randi([10,30])) '%']
    };
    hText = annotation('textbox', [0.7 0.4 0.25 0.3], 'String', stats_str, ...
        'Color', 'w', 'EdgeColor', 'w', 'BackgroundColor', [0.2 0.2 0.2], 'FontSize', 12);
    
    drawnow; % Render Frame
    pause(0.05); % Control speed
end