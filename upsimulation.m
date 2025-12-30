% ---------------------------------------------------------
% RFID-Based Web Simulation - Data-Driven Dashboard
% Data Source: Simulation Logs (Run ID 1-20)
% ---------------------------------------------------------

clear; clc; close all;

% --- 1. IMPORT FILE DATA (20 Runs) ---
% RunID | Accuracy(%) | Falls | Detected | Latency(s) | Uptime(%)
runData = [
    1,  92.0, 3, 3, 1.85, 99.3;
    2,  90.0, 2, 2, 2.10, 100.0;
    3,  94.0, 4, 3, 1.95, 100.0;
    4,  92.0, 2, 2, 2.05, 98.3;
    5,  88.0, 3, 2, 2.20, 100.0;
    6,  96.0, 1, 1, 1.75, 100.0;
    7,  90.0, 3, 3, 2.00, 99.7;
    8,  92.0, 5, 4, 2.15, 100.0;
    9,  94.0, 2, 2, 1.90, 100.0;
    10, 86.0, 4, 3, 2.25, 98.0;
    11, 92.0, 3, 3, 1.98, 100.0;
    12, 94.0, 2, 2, 1.88, 100.0;
    13, 90.0, 3, 2, 2.12, 99.0;
    14, 92.0, 4, 4, 2.04, 100.0;
    15, 96.0, 2, 2, 1.80, 100.0;
    16, 88.0, 5, 4, 2.30, 98.7;
    17, 92.0, 3, 3, 1.95, 100.0;
    18, 94.0, 2, 1, 2.05, 100.0;
    19, 90.0, 4, 4, 2.18, 99.3;
    20, 92.0, 3, 3, 1.92, 100.0;
];

% Calculate Averages (Matches the "AVG" row in your file)
avg_accuracy = mean(runData(:,2)); % 91.70%
avg_latency  = mean(runData(:,5)); % 2.02s
avg_uptime   = mean(runData(:,6)); % 99.60%
% Fall Detection Acc = Total Detected / Total Falls
total_falls    = sum(runData(:,3));
total_detected = sum(runData(:,4));
avg_fall_acc   = (total_detected / total_falls) * 100; % 88.30%

% --- 2. SETUP VISUALIZATION PARAMETERS ---
wardW = 20; wardH = 15;
numPatients = 50;
numReaders = 3;

% Select a specific run to visualize (e.g., Run #1)
currentRunID = 1; 
run_falls = runData(currentRunID, 3); 

% --- 3. CREATE DASHBOARD FIGURE ---
f = figure('Name', 'RFID Simulation Control Center', 'NumberTitle', 'off', ...
    'Color', [0.15 0.15 0.15], 'Position', [100 100 1200 700]);

% --- 4. DRAW VIRTUAL WARD (Main Plot) ---
subplot('Position', [0.05 0.1 0.65 0.8]); 
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
title(['Real-Time Tracking: Simulation Run #' num2str(currentRunID)], 'Color', 'w', 'FontSize', 14);
xlabel('Ward Length (m)'); ylabel('Ward Width (m)');

% Draw Zones
rectangle('Position', [0 7.5 10 7.5], 'EdgeColor', 'c', 'LineStyle', '--'); text(1, 14, 'ZONE A', 'Color', 'c');
rectangle('Position', [10 7.5 10 7.5], 'EdgeColor', 'g', 'LineStyle', '--'); text(11, 14, 'ZONE B', 'Color', 'g');
rectangle('Position', [0 0 10 7.5], 'EdgeColor', 'y', 'LineStyle', '--'); text(1, 6.5, 'ZONE C', 'Color', 'y');
rectangle('Position', [10 0 10 7.5], 'EdgeColor', 'm', 'LineStyle', '--'); text(11, 6.5, 'ZONE D', 'Color', 'm');

% Plot Readers
rx = [5, 15, 10]; ry = [11.25, 11.25, 3.75];
hReaders = scatter(rx, ry, 300, 'p', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'r', 'LineWidth', 1.5);

% Plot Patients
rng(currentRunID * 10); % Seed changes with Run ID for variety
px = rand(1, numPatients) * wardW;
py = rand(1, numPatients) * wardH;
hPatients = scatter(px, py, 60, 'filled', 'MarkerFaceColor', [0.2 0.6 1], 'MarkerEdgeColor', 'w');

% Plot Fall Events based on Current Run Data
for i = 1:run_falls
    % Pick random patient to simulate fall
    fall_x = px(i); fall_y = py(i);
    scatter(fall_x, fall_y, 150, 'r', 'LineWidth', 2);
    text(fall_x+0.5, fall_y, 'FALL DETECTED', 'Color', 'r', 'FontSize', 8, 'FontWeight', 'bold');
end

legend([hReaders, hPatients], 'RFID Readers', 'Active Tags', 'Location', 'southoutside', 'TextColor', 'w', 'Color', [0.2 0.2 0.2]);

% --- 5. CREATE "LIVE DATA" SIDEBAR (Right Panel) ---
annotation('rectangle', [0.72 0.1 0.25 0.8], 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'w');

% Metrics Strings (Formatted from File Data)
str_acc    = sprintf('%.1f%%', avg_accuracy);   % 91.7%
str_lat    = sprintf('%.2f s', avg_latency);    % 2.02 s
str_falls  = sprintf('%.1f%%', avg_fall_acc);   % 88.3%
str_uptime = sprintf('%.1f%%', avg_uptime);     % 99.6%

stats_text = {
    '\bf AGGREGATE METRICS (N=20)', ...
    '---------------------------------', ...
    ['Total Runs: ', '20'], ...
    ['Total Patients: ', '1000'], ... % 50 * 20
    '', ...
    '\bf SYSTEM PERFORMANCE (AVG)', ...
    '---------------------------------', ...
    ['Loc. Accuracy:    ', '\color{green}', str_acc], ...
    ['Alert Latency:    ', '\color{green}', str_lat], ...
    ['Fall Detection:   ', '\color{yellow}', str_falls], ...
    ['System Uptime:    ', '\color{green}', str_uptime], ...
    '', ...
    '\bf LIVE RUN STATUS', ...
    '---------------------------------', ...
    ['Current Run ID:  ', num2str(currentRunID)], ...
    ['Active Falls:    ', num2str(run_falls)], ...
    ['System Status:   ', '\color{green}ONLINE'] ...
};

annotation('textbox', [0.73 0.15 0.23 0.65], 'String', stats_text, ...
    'Color', 'w', 'FontSize', 11, 'EdgeColor', 'none', 'Interpreter', 'tex');

hold off;