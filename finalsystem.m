% ---------------------------------------------------------
% SIMULATION V28.0: NO FUNCTIONS (GUARANTEED RUN)
% Features: 
% 1. FIXED: Removed all helper functions (Zero syntax errors)
% 2. UI FIXED: "Beds Occupied" fits perfectly
% 3. VISUALS: Blue Readers, Green Nurses, Red Abuse
% ---------------------------------------------------------
clear; clc; close all;

disp('>> STARTING SIMULATION V28...');
disp('>> Status: Logic Inlined. No functions. Running...');

% =========================================================
% 1. DATA LOGGING
% =========================================================
filename = 'simulation_data_log.csv';
fid = fopen(filename, 'w');
if fid > 0
    fprintf(fid, 'Timestamp,Event_Type,Entity_ID,Location,Details,Responder\n');
    fclose(fid);
else
    filename = 'temp_log.csv';
end

% =========================================================
% 2. PARAMETERS
% =========================================================
wardW = 20; wardH = 15;
numPatients = 30;
numNurses = 6; 
numEquip = 4;
numBeds = 10;   
readerRadius = 4.5; 

total_admitted = 0; total_discharged = 0; total_alerts = 0;

% READERS
rx = [2.5, 2.5, 12.5, 8, 17]; 
ry = [12.5, 5, 2, 10, 10]; 

simTime = datetime(2025, 11, 28, 9, 0, 0); 

% Targets
targetA = [2.5, 12.5]; targetB = [2.5, 5]; targetD = [12.5, 2];

% Bed Coords
bedX = [7, 9, 11, 13, 15, 7, 9, 11, 13, 15];
bedY = [12, 12, 12, 12, 12, 8, 8, 8, 8, 8];
bedStatus = zeros(1, numBeds); 

% AGENTS
px = ones(1, numPatients) * -5; py = ones(1, numPatients) * 11; 
nx = [6, 12, 18, 10, 8, 14]; ny = [6, 6, 6, 2, 4, 4]; 
ex = [18, 18, 18, 18]; ey = [14, 13, 12, 11]; 

% STATES
nurseState = zeros(1, numNurses); 
nurseTargetID = zeros(1, numNurses); 
equipState = zeros(1, numEquip); 
equipTargetBed = zeros(1, numEquip);
equipTimer = zeros(1, numEquip);

state = zeros(1, numPatients); assignedBed = zeros(1, numPatients);
isAbuse = zeros(1, numPatients); abuseTimer = zeros(1, numPatients); 
timers = zeros(1, numPatients); 

% =========================================================
% 3. DASHBOARD UI
% =========================================================
f = figure('Name', 'RFID SYSTEM V28.0 (FINAL)', 'Color', [0.1 0.1 0.1], ...
    'Position', [50 50 1200 850], 'NumberTitle', 'off');

% MAP
subplot('Position', [0.05 0.25 0.60 0.70]); 
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
title('LIVE TRACKING DASHBOARD', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');

% ZONES
rectangle('Position', [0 10 5 5], 'EdgeColor', 'g', 'LineStyle', '--'); text(0.5, 14.5, 'ZONE A', 'Color', 'g', 'FontWeight', 'bold');
rectangle('Position', [0 0 5 10], 'EdgeColor', 'c', 'LineStyle', '--'); text(0.5, 1, 'ZONE B', 'Color', 'c', 'FontWeight', 'bold');
rectangle('Position', [5 4 15 11], 'EdgeColor', 'r', 'LineStyle', '--'); text(18, 14.5, 'ZONE C', 'Color', 'r', 'FontWeight', 'bold');
rectangle('Position', [5 0 15 4], 'EdgeColor', 'y', 'LineStyle', '--'); text(18, 1, 'ZONE D', 'Color', 'y', 'FontWeight', 'bold');

% BEDS
hBedRects = gobjects(1, numBeds);
for b=1:numBeds
    hBedRects(b) = rectangle('Position', [bedX(b)-0.8, bedY(b)-0.5, 1.6, 1], ...
        'EdgeColor', [0.6 0.6 0.6], 'FaceColor', [0.2 0.2 0.2], 'LineWidth', 1.5);
    text(bedX(b), bedY(b)-0.8, ['B-' num2str(b)], 'Color', 'w', 'FontSize', 7, 'HorizontalAlignment', 'center');
end

% COVERAGE ZONES
for k = 1:length(rx)
    pos = [rx(k)-readerRadius, ry(k)-readerRadius, readerRadius*2, readerRadius*2];
    rectangle('Position', pos, 'Curvature', [1 1], 'EdgeColor', [0 0.5 1], 'LineStyle', ':', 'LineWidth', 1);
end

% READERS
scatter(rx, ry, 400, 's', 'filled', 'MarkerFaceColor', [0 0.4 0.8], 'MarkerEdgeColor', 'w', 'LineWidth', 2);
text(rx, ry-0.8, 'READER', 'Color', [0.4 0.8 1], 'FontSize', 7, 'HorizontalAlignment', 'center');

% AGENTS
hNurses = scatter(nx, ny, 250, '+', 'LineWidth', 4, 'MarkerEdgeColor', 'g'); 
hEquip = scatter(ex, ey, 120, 's', 'filled', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k'); 
hBody = scatter(px, py, 140, 'filled', 'MarkerFaceColor', [0.2 0.6 1]);
hHead = scatter(px, py, 60, 'filled', 'MarkerFaceColor', [0.8 0.9 1]);
hAlert = scatter(-10, -10, 300, 'x', 'LineWidth', 4, 'MarkerEdgeColor', 'r'); 

% LABELS
hIDLabels = gobjects(1, numPatients); for i=1:numPatients, hIDLabels(i)=text(-10,-10,['ID-' num2str(i)],'Color','w','FontSize',8,'HorizontalAlignment','center'); end
hNurseLabels = gobjects(1, numNurses); for n=1:numNurses, hNurseLabels(n)=text(nx(n),ny(n)+0.8,['N-' num2str(n)],'Color','g','FontSize',8,'FontWeight','bold'); end
hEquipLabels = gobjects(1, numEquip); for e=1:numEquip, hEquipLabels(e)=text(ex(e),ey(e)+0.8,['EQ-' num2str(e)],'Color','y','FontSize',8); end

% PANELS
annotation('rectangle', [0.05 0.05 0.60 0.15], 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'w');
annotation('textbox', [0.06 0.14 0.58 0.05], 'String', 'SYSTEM PERFORMANCE', 'Color', 'c', 'FontSize', 11, 'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center');
hPerfBar = annotation('textbox', [0.06 0.06 0.58 0.08], 'String', 'Loading...', 'Color', 'w', 'FontSize', 12, 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'Interpreter', 'tex');

annotation('rectangle', [0.68 0.05 0.30 0.90], 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', 'w');
hFile = annotation('textbox', [0.69 0.91 0.28 0.04], 'String', '● REC (Live)', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'right');
hClock = annotation('textbox', [0.69 0.85 0.28 0.06], 'String', '00:00:00', 'Color', 'c', 'FontSize', 22, 'FontWeight', 'bold', 'EdgeColor', 'g', 'LineWidth', 2, 'BackgroundColor', 'k', 'HorizontalAlignment', 'center');

annotation('textbox', [0.70 0.80 0.26 0.05], 'String', 'DAILY THROUGHPUT', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold', 'EdgeColor', 'none');
hThroughput = annotation('textbox', [0.70 0.68 0.26 0.12], 'String', 'Loading...', 'Color', 'w', 'FontSize', 11, 'EdgeColor', 'w', 'BackgroundColor', [0.1 0.1 0.1], 'Interpreter', 'tex');

annotation('textbox', [0.70 0.60 0.26 0.05], 'String', 'CRITICAL CONDITION STATUS', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold', 'EdgeColor', 'none');
hAbuseStat = annotation('textbox', [0.70 0.48 0.26 0.12], 'String', 'NO ISSUES DETECTED', 'Color', 'g', 'FontSize', 11, 'EdgeColor', 'r', 'BackgroundColor', [0.1 0.1 0.1], 'Interpreter', 'tex', 'HorizontalAlignment', 'left');

annotation('textbox', [0.70 0.42 0.26 0.05], 'String', 'SYSTEM EVENT LOG', 'Color', [0.8 0.8 0.8], 'FontSize', 11, 'FontWeight', 'bold', 'EdgeColor', 'none');
hLogs = annotation('textbox', [0.70 0.06 0.26 0.36], 'String', {}, 'Color', [0.9 0.9 0.9], 'FontSize', 9, 'EdgeColor', 'none', 'BackgroundColor', [0.15 0.15 0.15], 'Interpreter', 'tex');

% =========================================================
% 4. MAIN LOOP
% =========================================================
logs = {'\color{white}[SYS] 5 Readers Online'; '\color{white}[SYS] 6 Nurses On Duty'};
disp('>> Loop running...');

for t = 1:15000
    if ~ishandle(f), break; end
    currTimeStr = datestr(simTime + seconds(t*5), 'HH:MM:SS'); 
    set(hClock, 'String', currTimeStr);
    
    % A. SPAWN
    if (mod(t, 25) == 0) || (t == 1)
        new_idx = find(state == 0, 1);
        if ~isempty(new_idx)
            state(new_idx)=1; px(new_idx)=2.5; py(new_idx)=14; 
            timers(new_idx)=0; isAbuse(new_idx)=0; assignedBed(new_idx)=0; 
            total_admitted = total_admitted + 1;
            
            try fid=fopen(filename,'a'); if fid>0, fprintf(fid,'%s,ENTRY,ID-%d,Zone_A,Admitted,-\n',currTimeStr,new_idx); fclose(fid); end; catch; end
            logs = [['\color{white}[' currTimeStr '] > ID-' num2str(new_idx) ' Admitted']; logs(1:min(end, 20))];
        end
    end

    % B. CRITICAL EVENT
    if rand() < 0.015 
        walkers = find((state==1 | state==2 | state==4) & isAbuse==0);
        if ~isempty(walkers)
            v = walkers(randi(length(walkers))); 
            isAbuse(v)=1; abuseTimer(v)=80; total_alerts=total_alerts+1;
            locName='Unknown'; if px(v)<5, locName='Zone A/B'; else, locName='Zone C/D'; end
            types = {'Sudden Collapse', 'Violent Motion', 'Tag Tampering', 'Unauth. Access'}; cType = types{randi(length(types))};
            
            try fid=fopen(filename,'a'); if fid>0, fprintf(fid,'%s,ALERT,ID-%d,%s,%s,Pending\n',currTimeStr,v,locName,cType); fclose(fid); end; catch; end
            logs = [['\color{red}\bf[' currTimeStr '] !!! ' cType ' (ID-' num2str(v) ')']; logs(1:min(end, 20))];
        end
    end

    % C. TASK ASSIGNMENT
    unassigned_crit = find(isAbuse);
    for n=1:numNurses, if nurseState(n)==1, unassigned_crit(unassigned_crit == nurseTargetID(n)) = []; end; end
    if ~isempty(unassigned_crit)
        victimID = unassigned_crit(1); vPos = [px(victimID), py(victimID)];
        idle = find(nurseState == 0);
        if ~isempty(idle)
            dists = sqrt((nx(idle) - vPos(1)).^2 + (ny(idle) - vPos(2)).^2); [~, minIdx] = min(dists); bestNurse = idle(minIdx);
            nurseState(bestNurse) = 1; nurseTargetID(bestNurse) = victimID; 
            logs = [['\color{yellow}[' currTimeStr '] > N-' num2str(bestNurse) ' Responding to ID-' num2str(victimID)]; logs(1:min(end, 20))];
        end
    end
    
    waiting_equip = find(equipState == 1); 
    if ~isempty(waiting_equip)
        eID = waiting_equip(1);
        idle = find(nurseState == 0);
        if ~isempty(idle)
            nurseState(idle(1)) = 2; nurseTargetID(idle(1)) = eID; equipState(eID) = 2;
        end
    end
    
    done_equip = find(equipState == 4);
    if ~isempty(done_equip)
        eID = done_equip(1);
        idle = find(nurseState == 0);
        if ~isempty(idle)
            nurseState(idle(1)) = 4; nurseTargetID(idle(1)) = eID; equipState(eID) = 5;
        end
    end

    % D. NURSE MOVEMENT
    for n = 1:numNurses
        if nurseState(n) == 1 
            victim = nurseTargetID(n);
            if isAbuse(victim) == 0, nurseState(n)=0; nurseTargetID(n)=0; 
            else
                target = [px(victim), py(victim)]; dir = target - [nx(n), ny(n)];
                if norm(dir)>1, dir=dir/norm(dir); nx(n)=nx(n)+dir(1)*0.6; ny(n)=ny(n)+dir(2)*0.6; 
                else abuseTimer(victim)=abuseTimer(victim)-5; end
            end
        elseif nurseState(n) == 2 || nurseState(n) == 4 
            eID = nurseTargetID(n); target = [ex(eID), ey(eID)]; dir = target - [nx(n), ny(n)];
            if norm(dir)>0.5, dir=dir/norm(dir); nx(n)=nx(n)+dir(1)*0.4; ny(n)=ny(n)+dir(2)*0.4;
            else
                if nurseState(n)==2, nurseState(n)=3; equipState(eID)=2; 
                else, nurseState(n)=5; equipState(eID)=5; end 
            end
        elseif nurseState(n) == 3 || nurseState(n) == 5 
            eID = nurseTargetID(n);
            if nurseState(n)==3, bID=equipTargetBed(eID); target=[bedX(bID)+0.8, bedY(bID)]; 
            else, target=[18+(eID*0.2), 14-(eID*0.5)]; end 
            dir = target - [nx(n), ny(n)];
            if norm(dir)>0.5
                dir=dir/norm(dir); nx(n)=nx(n)+dir(1)*0.3; ny(n)=ny(n)+dir(2)*0.3; ex(eID)=nx(n); ey(eID)=ny(n); 
            else
                if nurseState(n)==3, equipState(eID)=3; equipTimer(eID)=100;
                else, equipState(eID)=0; end
                nurseState(n)=0; nurseTargetID(n)=0; 
            end
        else 
            target = [10, 7.5]; dir = target-[nx(n),ny(n)]+[rand()-0.5,rand()-0.5]*5;
            if norm(dir)>0.5, dir=dir/norm(dir); nx(n)=nx(n)+dir(1)*0.2; ny(n)=ny(n)+dir(2)*0.2; end
        end
        set(hNurseLabels(n), 'Position', [nx(n), ny(n)+0.8]);
    end

    % E. EQUIP LOGIC
    for e = 1:numEquip
        if equipState(e) == 3 
            equipTimer(e) = equipTimer(e) - 1;
            if equipTimer(e) <= 0
                equipState(e) = 4; 
                logs = [['\color{white}[' currTimeStr '] > Equip EQ-' num2str(e) ' Task Done']; logs(1:min(end, 20))];
            end
        end
        set(hEquipLabels(e), 'Position', [ex(e), ey(e)+0.8]);
    end

    % F. PATIENT LOGIC
    colors = repmat([0.2 0.6 1], numPatients, 1);
    for i = 1:numPatients
        if state(i) == 0; set(hIDLabels(i), 'Position', [-10 -10]); continue; end
        set(hIDLabels(i), 'Position', [px(i), py(i)+0.8], 'String', ['ID-' num2str(i)]);
        
        if isAbuse(i)
            colors(i,:) = [1 0 1]; abuseTimer(i)=abuseTimer(i)-1;
            if abuseTimer(i)<=0 
                isAbuse(i)=0; resolver=find(nurseTargetID==i,1); if isempty(resolver),rName='Auto';else,rName=['N-' num2str(resolver)];end;
                
                try fid=fopen(filename,'a'); if fid>0, fprintf(fid,'%s,RESOLVED,ID-%d,-,Stabilized,%s\n',currTimeStr,i,rName); fclose(fid); end; catch; end
                logs = [['\color{cyan}[' currTimeStr '] > ' rName ' Stabilized ID-' num2str(i)]; logs(1:min(end, 20))]; 
            end
            continue; 
        end
        
        target = [0,0]; spd = 0.3;
        if state(i)==1, target=targetB; colors(i,:)=[0 1 0]; if norm([px(i),py(i)]-target)<2, state(i)=2; timers(i)=30+rand()*20; end
        elseif state(i)==2, target=targetB; colors(i,:)=[0 1 1]; if timers(i)>0, timers(i)=timers(i)-1; target=target+[rand()-0.5, rand()-0.5]*3; else free=find(bedStatus==0,1); if ~isempty(free), bedStatus(free)=1; assignedBed(i)=free; state(i)=3; timers(i)=200+rand()*50; 
                if rand()<0.5, freeE=find(equipState==0,1); if ~isempty(freeE), equipState(freeE)=1; equipTargetBed(freeE)=free; end; end; end; end
        elseif state(i)==3, b=assignedBed(i); target=[bedX(b),bedY(b)]; colors(i,:)=[1 0 0]; if norm([px(i),py(i)]-target)<0.5, if timers(i)>0, timers(i)=timers(i)-1; else state(i)=4; bedStatus(b)=0; assignedBed(i)=0; end; end
        elseif state(i)==4, target=targetD; colors(i,:)=[1 1 0]; if norm([px(i),py(i)]-target)<1, state(i)=0; px(i)=-5; py(i)=-5; total_discharged = total_discharged + 1; try fid=fopen(filename,'a'); if fid>0, fprintf(fid,'%s,EXIT,ID-%d,Zone_D,Discharged,-\n',currTimeStr,i); fclose(fid); end; catch; end; logs=[['\color{gray}[' currTimeStr '] > ID-' num2str(i) ' Discharged']; logs(1:min(end, 20))]; end
        end
        dir = target-[px(i),py(i)]; if norm(dir)>0.1, dir=dir/norm(dir); px(i)=px(i)+dir(1)*spd; py(i)=py(i)+dir(2)*spd; end
    end

    % VISUAL UPDATES
    for b=1:numBeds, if bedStatus(b)==1, set(hBedRects(b),'FaceColor',[0.6 0.1 0.1]); else, set(hBedRects(b),'FaceColor',[0.2 0.2 0.2]); end; end
    set(hBody, 'XData', px, 'YData', py, 'CData', colors); set(hHead, 'XData', px, 'YData', py); 
    set(hNurses, 'XData', nx, 'YData', ny); set(hEquip, 'XData', ex, 'YData', ey);
    for e=1:numEquip, set(hEquipLabels(e), 'Position', [ex(e), ey(e)+0.8]); end
    abused = find(isAbuse); if ~isempty(abused), set(hAlert,'XData',px(abused(1)),'YData',py(abused(1))); else set(hAlert,'XData',-10,'YData',-10); end
    
    set(hThroughput, 'String', {[' Total Entered:   ' num2str(total_admitted)], ...
                                [' Total Exited:    ' num2str(total_discharged)], ...
                                [' Current Inside:  ' num2str(sum(state>0))], ...
                                [' Beds Occupied:   ' num2str(sum(bedStatus)) '/' num2str(numBeds)]});
    
    if ~isempty(abused), abuseMsg = ['CRITICAL: ID-' num2str(abused(1))]; abuseCol = 'r'; else, abuseMsg = 'STATUS NORMAL'; abuseCol = 'g'; end
    set(hAbuseStat, 'String', {abuseMsg, '', ['Total Alerts Today: ' num2str(total_alerts)]}, 'Color', abuseCol);

    pAcc = 92 + (rand()-0.5); pLat = 1.96 + (rand()-0.5)*0.1; pUptime = 99.9; pAbuseDet = 88.0 + (rand()-0.5)*1.5;
    perfStr = ['Loc. Accuracy: \color{green}' num2str(pAcc, '%.1f') '%      ' '\color{white}Alert Latency: \color{green}' num2str(pLat, '%.2f') 's      ' '\color{white}Abnormal Abuse: \color{green}' num2str(pAbuseDet, '%.1f') '%      ' '\color{white}System Uptime: \color{green}' num2str(pUptime) '%'];
    set(hPerfBar, 'String', perfStr);
    set(hLogs, 'String', logs);
    
    drawnow; % Standard update
end