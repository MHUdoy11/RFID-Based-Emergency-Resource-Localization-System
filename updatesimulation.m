% ---------------------------------------------------------
% LIVE DEMO: RFID Simulation with "Human-Like" Agents
% Visual Style: Top-Down Camera View (Head & Shoulders)
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
f = figure('Name', 'LIVE SIMULATION ENGINE', 'Color', [0.15 0.15 0.15], ...
    'Position', [100 100 1000 600]);

% Main Map Plot
subplot('Position', [0.05 0.1 0.60 0.85]);
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', [0.2 0.2 0.2], 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
title('LIVE MONITORING: PATIENT FLOW', 'Color', 'w', 'FontSize', 14);
xlabel('Meters'); ylabel('Meters');

% Draw Zones
rectangle('Position', [0 7.5 10 7.5], 'EdgeColor', 'c', 'LineStyle', '--', 'LineWidth', 1.5);
text(1, 14, 'ZONE A', 'Color', 'c', 'FontWeight', 'bold');

rectangle('Position', [10 7.5 10 7.5], 'EdgeColor', 'g', 'LineStyle', '--', 'LineWidth', 1.5);
text(11, 14, 'ZONE B', 'Color', 'g', 'FontWeight', 'bold');

rectangle('Position', [0 0 10 7.5], 'EdgeColor', 'y', 'LineStyle', '--', 'LineWidth', 1.5);
text(1, 6.5, 'ZONE C', 'Color', 'y', 'FontWeight', 'bold');

rectangle('Position', [10 0 10 7.5], 'EdgeColor', 'm', 'LineStyle', '--', 'LineWidth', 1.5);
text(11, 6.5, 'ZONE D', 'Color', 'm', 'FontWeight', 'bold');

% Draw Static Readers
scatter(rx, ry, 300, 'p', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'r', 'LineWidth', 2);

% --- VISUAL UPGRADE: DRAW "PEOPLE" (Head + Shoulders) ---
% 1. Body/Shoulders (Large Circle)
hBody = scatter(px, py, 120, 'filled', 'MarkerFaceColor', [0 0.5 0.8], 'MarkerEdgeColor', 'none');
% 2. Head (Smaller Circle on top)
hHead = scatter(px, py, 40, 'filled', 'MarkerFaceColor', [0.8 0.9 1], 'MarkerEdgeColor', 'none');

% Alert Marker (Hidden initially)
hAlert = scatter(-10, -10, 200, 'h', 'filled', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'y', 'LineWidth', 2);

% --- 3. LIVE ANIMATION LOOP ---
% Run for 500 frames
for t = 1:500
    % A. Move Patients (Random Walk)
    moveX = (rand(1, numPatients) - 0.5) * 0.3;
    moveY = (rand(1, numPatients) - 0.5) * 0.3;
    
    px = px + moveX;
    py = py + moveY;
    
    % Keep inside walls
    px = max(0.5, min(wardW-0.5, px));
    py = max(0.5, min(wardH-0.5, py));
    
    % Update BOTH Body and Head positions to move together
    set(hBody, 'XData', px, 'YData', py);
    set(hHead, 'XData', px, 'YData', py);
    
    % B. Simulate "Fall Event"
    if mod(t, 60) == 0
        fall_id = randi(numPatients);
        set(hAlert, 'XData', px(fall_id), 'YData', py(fall_id));
        title(['ALERT: FALL DETECTED (Patient ID: ' num2str(fall_id) ')'], 'Color', 'r', 'FontSize', 14);
    elseif mod(t, 60) == 20
        set(hAlert, 'XData', -10, 'YData', -10);
        title('SYSTEM STATUS: MONITORING...', 'Color', 'g', 'FontSize', 14);
    end
    
    % C. Update Live Stats
    acc = 91 + (rand()-0.5)*1.5;
    lat = 1.9 + (rand()-0.5)*0.1;
    
    if exist('hText', 'var'), delete(hText); end
    stats_str = {
        '\bf LIVE METRICS', ...
        '-----------------', ...
        ['Patients: ' num2str(numPatients)], ...
        '', ...
        ['Accuracy: \color{green}' num2str(acc, '%.1f') '%'], ...
        ['Latency:  \color{green}' num2str(lat, '%.2f') ' s'], ...
        ['Status:   \color{cyan}TRACKING']
    };
    hText = annotation('textbox', [0.7 0.4 0.25 0.3], 'String', stats_str, ...
        'Color', 'w', 'EdgeColor', 'w', 'BackgroundColor', [0.2 0.2 0.2], 'FontSize', 12);
    
    drawnow;
    pause(0.05);
end