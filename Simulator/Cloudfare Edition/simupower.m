% ---------------------- LEGEND ----------------------
%               [i] APP COMPONENTS
%               [ii] UI CREATION
%               [iii] APP DATA INITIALIZATION
%               [iv] VISIBILITY UPDATE
%               [v] DYNAMIC LIST BOX
%               [vi] SIMULATION
%               [vii] CLEAR FUNCTION
%               [viii] APP CON/DEL
% ---------------------- LEGEND ----------------------

% ---------------------- DETAILS ----------------------
% THIS CODE HAS BEEN ASSISTED BY MATGPT [https://www.mathworks.com/matlabcentral/fileexchange/126665-matgpt] (CHATGPT); 
% THE WHOLE CODE HAS BEEN DEBUGGED WITH CHATGPT;
% INITIAL FUNCTIONALITIES THAT AREN'T LABELED ARE HUMAN-MADE;
% IF IT HAS * OR [ASSISTED BY MATGPT] IT IS MADE WITH CHATGPT
% DATA OF THE APPLICATIONS AND WATTAGE FROM:
% [i] https://www.sunstar.com.ph/davao/davao-light-power-rate-up-in-july-2025 
% [ii] https://solarswitch.ph/guide-to-average-power-ratings-of-appliances-in-the-philippines/
% ---------------------- DETAILS ----------------------

%% I. ---------------------- APP COMPONENTS ----------------------
classdef simupower < matlab.apps.AppBase
    
    
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        SimulationPanel                matlab.ui.container.Panel
        EstimatedBillPhp000Label       matlab.ui.control.Label
        NumberofApplicationsDropDown   matlab.ui.control.DropDown
        NumberofApplicationsLabel      matlab.ui.control.Label
        DataInputsPanel                matlab.ui.container.Panel
        ConsumptionFieldArray          % NUMERIC EDIT FIELD (ARRAY)
        ConsumptionLabelArray          % LABELS FOR FIELD
        CalculateButton                matlab.ui.control.Button
        ClearButton                    matlab.ui.control.Button
        ApplianceListListBox           matlab.ui.control.ListBox
        ApplianceListListBoxLabel      matlab.ui.control.Label
        TimeFrameDropDown              matlab.ui.control.DropDown
        TimeFrameLabel                 matlab.ui.control.Label
    end

    % INTERNAL APP DATA
    properties (Access = private)
        ElecRate = 8.7772 % Php per kWh
        ApplianceData
        LastBreakdownLabels
        LastImageHandles
        LastWireHandles
        MaxDevices = 5
    end


    %% II. ---------------------- UI CREATION ----------------------
    methods (Access = private)
        function createComponents(app)
            % MAIN FIGURE 
            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Position = [100 100 920 660];
            app.UIFigure.Name = 'SimuPower';
            app.UIFigure.Color = [0.02 0.06 0.02]; % DARK GREEN BASE

            % COLORS
            panelBG      = [0.03 0.10 0.03];
            controlBG    = [0.04 0.12 0.04];
            controlText  = [0.88 0.96 0.88];
            neonAccent   = [0.12 1.0 0.5];

            % SIMULATION PANEL
            app.SimulationPanel = uipanel(app.UIFigure);
            app.SimulationPanel.Title = 'Simulation';
            app.SimulationPanel.Position = [30 90 560 520];
            app.SimulationPanel.BackgroundColor = panelBG;
            app.SimulationPanel.FontSize = 15;
            app.SimulationPanel.FontWeight = 'bold';
            app.SimulationPanel.ForegroundColor = neonAccent;

            % ESTIMATED BILL LABEL
            app.EstimatedBillPhp000Label = uilabel(app.SimulationPanel);
            app.EstimatedBillPhp000Label.Text = 'Estimated Bill: Php 0.00';
            app.EstimatedBillPhp000Label.Position = [18 470 520 26];
            app.EstimatedBillPhp000Label.FontSize = 14;
            app.EstimatedBillPhp000Label.FontWeight = 'bold';
            app.EstimatedBillPhp000Label.FontColor = neonAccent;

            % DATA INPUT PANEL
            app.DataInputsPanel = uipanel(app.UIFigure);
            app.DataInputsPanel.Title = 'Data Inputs';
            app.DataInputsPanel.Position = [610 90 280 520];
            app.DataInputsPanel.BackgroundColor = panelBG;
            app.DataInputsPanel.FontSize = 14;
            app.DataInputsPanel.FontWeight = 'bold';
            app.DataInputsPanel.ForegroundColor = neonAccent;

            % TOP INPUT/CONTROLS
            app.NumberofApplicationsLabel = uilabel(app.UIFigure);
            app.NumberofApplicationsLabel.Text = 'Number of Application(s)';
            app.NumberofApplicationsLabel.Position = [40 610 220 22];
            app.NumberofApplicationsLabel.FontColor = neonAccent;
            app.NumberofApplicationsLabel.FontSize = 13;

            app.NumberofApplicationsDropDown = uidropdown(app.UIFigure);
            app.NumberofApplicationsDropDown.Items = {'1','2','3','4','5'};
            app.NumberofApplicationsDropDown.Value = '1';
            app.NumberofApplicationsDropDown.Position = [270 610 100 28];
            app.NumberofApplicationsDropDown.BackgroundColor = controlBG;
            app.NumberofApplicationsDropDown.FontColor = controlText;
            app.NumberofApplicationsDropDown.FontSize = 12;
            app.NumberofApplicationsDropDown.ValueChangedFcn = @(src,evt) updateVisibleConsumptionFields(app);

            app.TimeFrameLabel = uilabel(app.UIFigure);
            app.TimeFrameLabel.Text = 'Time Frame';
            app.TimeFrameLabel.Position = [390 610 80 22];
            app.TimeFrameLabel.FontColor = neonAccent;
            app.TimeFrameLabel.FontSize = 13;

            app.TimeFrameDropDown = uidropdown(app.UIFigure);
            app.TimeFrameDropDown.Items = {'Daily','Weekly','Monthly'};
            app.TimeFrameDropDown.Value = 'Monthly';
            app.TimeFrameDropDown.Position = [470 610 120 28];
            app.TimeFrameDropDown.BackgroundColor = controlBG;
            app.TimeFrameDropDown.FontColor = controlText;
            app.TimeFrameDropDown.FontSize = 12;

            % APPLIANCE LISTS
            app.ApplianceListListBoxLabel = uilabel(app.DataInputsPanel);
            app.ApplianceListListBoxLabel.Text = 'Appliance List';
            app.ApplianceListListBoxLabel.Position = [18 470 120 22];
            app.ApplianceListListBoxLabel.FontColor = neonAccent;
            app.ApplianceListListBoxLabel.FontSize = 13;

            app.ApplianceListListBox = uilistbox(app.DataInputsPanel);
            app.ApplianceListListBox.Position = [18 330 244 130];
            app.ApplianceListListBox.Multiselect = 'on';
            app.ApplianceListListBox.BackgroundColor = controlBG;
            app.ApplianceListListBox.FontColor = controlText;
            app.ApplianceListListBox.FontSize = 12;
            app.ApplianceListListBox.ValueChangedFcn = @(src,evt) onListChanged(app, src);

            % CONSUMPTION FIELD (MAX OF 5) [ASSISTED BY MATGPT]
            app.ConsumptionLabelArray = gobjects(app.MaxDevices,1);
            app.ConsumptionFieldArray = gobjects(app.MaxDevices,1);
            baseY = 290;
            spacing = 38;
            for i = 1:app.MaxDevices
                lbl = uilabel(app.DataInputsPanel);
                lbl.Position = [18, baseY - (i-1)*spacing, 180, 20];
                lbl.Text = sprintf('Consumption [Device %d]', i);
                lbl.FontColor = controlText;
                lbl.FontSize = 12;
                lbl.Visible = 'off';

                fld = uieditfield(app.DataInputsPanel, 'numeric');
                fld.Position = [200, baseY - (i-1)*spacing, 62, 24];
                fld.Value = 1;
                fld.Limits = [1 24];
                fld.RoundFractionalValues = true;
                fld.BackgroundColor = controlBG;
                fld.FontColor = controlText;
                fld.FontSize = 12;
                fld.Visible = 'off';

                app.ConsumptionLabelArray(i) = lbl;
                app.ConsumptionFieldArray(i) = fld;
            end

            % BUTTONS
            app.CalculateButton = uibutton(app.DataInputsPanel, 'push');
            app.CalculateButton.Position = [28 18 110 36];
            app.CalculateButton.Text = 'Calculate';
            app.CalculateButton.FontSize = 13;
            app.CalculateButton.FontWeight = 'bold';
            app.CalculateButton.BackgroundColor = [0.06 0.16 0.06];
            app.CalculateButton.FontColor = neonAccent;
            app.CalculateButton.ButtonPushedFcn = @(btn,evt) updateSimulation(app);

            app.ClearButton = uibutton(app.DataInputsPanel, 'push');
            app.ClearButton.Position = [152 18 110 36];
            app.ClearButton.Text = 'Clear';
            app.ClearButton.FontSize = 13;
            app.ClearButton.FontWeight = 'bold';
            app.ClearButton.BackgroundColor = [0.06 0.16 0.06];
            app.ClearButton.FontColor = neonAccent;
            app.ClearButton.ButtonPushedFcn = @(btn,evt) clearInputs(app);

            % SHOW FIGURE
            app.UIFigure.Visible = 'on';

            % INITIALIZE DATA AND FIELDS
            initApplianceData(app);
            updateVisibleConsumptionFields(app);
        end

     %% III. ---------------------- APP DATA INITIALIZATION ----------------------
        function initApplianceData(app)
            app.ApplianceData = struct( 'Refrigerator',175, 'Freezer',175, 'ElectricOven',3000, ...
                'Microwave',900, 'Dishwasher',1800, 'Toaster',1150, ...
                'ElectricKettle',1250, 'CoffeeMaker',900, 'Blender',650, ...
                'ElectricStoveBurner',2000, 'WashingMachine',750, ...
                'ClothesDryer',3400, 'Iron',1400, 'HairDryer',1450, ...
                'VacuumCleaner',1200, 'Television',225, 'Computer',450, ...
                'Laptop',50, 'AirConditioner',2500, 'SpaceHeater',1125, ...
                'CeilingFan',120, 'LEDLightBulb',10, 'IncandescentBulb',80, ...
                'ClothesDryerGas',350, 'SteamIron',1600, 'ClothesSteamer',1500, ...
                'SewingMachine',90, 'HandheldFabricSteamer',1000 ...
                );

            app.ApplianceListListBox.Items = fieldnames(app.ApplianceData);
            app.ApplianceListListBox.Value = {};
            app.LastBreakdownLabels = gobjects(0);
            app.LastImageHandles = gobjects(0);
            app.LastWireHandles = gobjects(0);
        end

     %% IV. ---------------------- VISIBILITY UPDATE ----------------------
        function updateVisibleConsumptionFields(app)
            n = str2double(app.NumberofApplicationsDropDown.Value);
            n = max(1, min(app.MaxDevices, n)); % CLAMPS BETWEEN 1 AND MAX VALUE
            for i = 1:app.MaxDevices
                visible = i <= n;
                app.ConsumptionLabelArray(i).Visible = visible;
                app.ConsumptionFieldArray(i).Visible = visible;
            end
            % IF DEVICE SELECTED MORE THAN ALLOWED DEVICES
            sel = app.ApplianceListListBox.Value;
            if numel(sel) > n
                sel = sel(1:n);
                app.ApplianceListListBox.Value = sel;
                uialert(app.UIFigure, sprintf('Only %d device(s) allowed.', n), 'Selection Limit');
            end
            onListChanged(app, app.ApplianceListListBox);
        end

        %% V. ---------------------- DYNAMIC LIST-BOX ---------------------- [ASSISTED BY MATGPT]
        function onListChanged(app, src)
            selected = src.Value;
            maxAllowed = str2double(app.NumberofApplicationsDropDown.Value);
            if numel(selected) > maxAllowed
                selected = selected(1:maxAllowed);
                src.Value = selected;
                uialert(app.UIFigure, sprintf('Only %d device(s) allowed.', maxAllowed), 'Selection Limit');
            end
            for i = 1:app.MaxDevices
                if i <= numel(selected)
                    app.ConsumptionLabelArray(i).Text = sprintf('%s (hrs/day):', selected{i});
                else
                    app.ConsumptionLabelArray(i).Text = sprintf('Consumption [Device %d]', i);
                    app.ConsumptionFieldArray(i).Value = 1;
                end
            end
        end

%% VI. ---------------------- SIMULATION ---------------------- [ASSISTED BY MATGPT + CLOUDFLARE AI]
function updateSimulation(app)
    % CLEARS PREVIOUS VISUALS
    try
        delete([app.LastBreakdownLabels; app.LastImageHandles; app.LastWireHandles]);
    catch
    end
    app.LastBreakdownLabels = gobjects(0);
    app.LastImageHandles = gobjects(0);
    app.LastWireHandles = gobjects(0);

    % VALIDATES SELECTION
    selected = app.ApplianceListListBox.Value;
    n = str2double(app.NumberofApplicationsDropDown.Value);
    selected = selected(1:min(n, numel(selected)));
    if isempty(selected)
        uialert(app.UIFigure, 'Please select at least one appliance.', 'Error');
        return;
    end

    % DETERMINES TIME FRAME
    switch app.TimeFrameDropDown.Value
        case 'Daily', days = 1;
        case 'Weekly', days = 7;
        case 'Monthly', days = 30;
        otherwise, days = 30;
    end

    % COMPUTES COST
    totalCost = 0;
    for i = 1:numel(selected)
        name = selected{i};
        hours = app.ConsumptionFieldArray(i).Value;
        watt = app.ApplianceData.(name);
        totalCost = totalCost + (watt * hours / 1000 * days * app.ElecRate);
    end

    % ALWAYS UPDATE COST LABEL FIRST
    app.EstimatedBillPhp000Label.Text = sprintf('Estimated Bill (%s): Php %.2f', ...
        app.TimeFrameDropDown.Value, totalCost);

    % BUILD AI IMAGE PROMPT
    applianceStr = strjoin(selected, ', ');
    desc = sprintf(['Simple flat illustration of %s connected to a power outlet. ', ...
    'Soft pastel colors, glowing cables, white background, no text.'], ...
    applianceStr);

    % --- CLOUDFLARE TEXT-TO-IMAGE GENERATION (SAFE TO FAIL) ---
    try
        import matlab.net.http.*

        % INSERT INFO HERE
        accountId = 'XXXX'; % Cloudflare Account ID
        apiKey = 'ZZZZ';   % Cloudflare API token with "Workers AI: Edit" permission

        % Cloudflare Workers AI Endpoint (text-to-image model)
        url = ['https://api.cloudflare.com/client/v4/accounts/' accountId ...
               '/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0'];

        headers = [ ...
            HeaderField('Authorization', ['Bearer ' apiKey]), ...
            HeaderField('Content-Type', 'application/json') ...
        ];

        % JSON BODY FOR TXT-IMG
        body = struct( ...
            'prompt', desc, ...
            'num_steps', 20, ...
            'guidance', 7.5 ...
        );

        % SEND REQUEST TO CLOUDFARE
        msg = RequestMessage('post', headers, MessageBody(body));
        resp = msg.send(url);

        disp('--- Cloudflare response status ---');
        disp(resp.StatusCode);

        % HANDLE FOR 200: 0K RESPONSE
        if resp.StatusCode ~= 200
            rawText = char(resp.Body.string);
            uialert(app.UIFigure, sprintf('AI visual generation failed.\n\nHTTP %d:\n\n%s\n\nSimulation calculations are still complete.', ...
                double(resp.StatusCode), rawText), 'AI Error');
            return;
        end

        % IMAGE/JSON DETECTION
        contentType = resp.getFields('Content-Type');
        if ~isempty(contentType) && contains(lower(contentType.Value), 'image/png')
            % UINT8 MATRIX RETURNED
            disp('Cloudflare returned direct PNG data — decoding...');
            try
                imgData = resp.Body.Data;

                % NUM ARRAY? TREAT RGB IMG
                if isnumeric(imgData) && ndims(imgData) == 3
                    img = imgData;
                elseif isstruct(imgData) && isfield(imgData, 'data')
                    img = uint8(imgData.data);
                else
                    error('Unexpected image data type: %s', class(imgData));
                end

                % DISPLAY IN PANEL
                delete(findall(app.SimulationPanel, 'Type', 'uiimage'));
                uiimage(app.SimulationPanel, ...
                    'ImageSource', img, ...
                    'Position', [40 40 480 420], ...
                    'ScaleMethod', 'fit');

                disp('✅ AI visual displayed successfully.');
                return;

            catch IMGERR
                disp('Image display error:');
                disp(IMGERR.message);
                uialert(app.UIFigure, ...
                    'AI visual generation returned image data but could not be displayed. Simulation calculations are still complete.', ...
                    'AI Error');
                return;
            end
        end


        % INTERPRET JSON/HTML
        try
            rawText = char(resp.Body.string);
        catch
            rawText = '';
        end

        if isempty(rawText)
            uialert(app.UIFigure, 'AI visual generation returned an empty body. Simulation calculations are still complete.', 'AI Error');
            return;
        end

        % HTML DETECTION
        if rawText(1) == '<'
            disp('DEBUG: Cloudflare returned HTML (likely an error page).');
            disp(rawText(1:min(end,2000)));
            uialert(app.UIFigure, ...
                ['AI visual generation failed (server returned HTML). ' ...
                 'Check your Cloudflare account, token, and endpoint. See Command Window for raw response. ' ...
                 'Simulation calculations are still complete.'], ...
                'AI Error');
            return;
        end

        % JSON DECODING
        try
            data = jsondecode(rawText);
        catch JDERR
            disp('JSON decode error:');
            disp(JDERR.message);
            disp('Raw response:');
            disp(rawText(1:min(end,2000)));
            uialert(app.UIFigure, sprintf('AI visual generation failed.\n\nInvalid JSON response.\n\nSimulation calculations are still complete.'), 'AI Error');
            return;
        end

        % STRUCT PARSE JSON // EXTRACT IMG
        imgBase64 = '';
        if isstruct(data)
            if isfield(data, 'result')
                r = data.result;
                if ischar(r) || isstring(r)
                    imgBase64 = char(r);
                elseif isstruct(r)
                    if isfield(r, 'image_base64')
                        imgBase64 = r.image_base64;
                    elseif isfield(r, 'image')
                        imgBase64 = r.image;
                    elseif isfield(r, 'output') && isstruct(r.output) && isfield(r.output, 'image_base64')
                        imgBase64 = r.output.image_base64;
                    end
                elseif iscell(r) && ~isempty(r)
                    if isstruct(r{1}) && isfield(r{1}, 'image')
                        imgBase64 = r{1}.image;
                    elseif isstruct(r{1}) && isfield(r{1}, 'image_base64')
                        imgBase64 = r{1}.image_base64;
                    end
                end
            elseif isfield(data, 'output') && isstruct(data.output) && isfield(data.output, 'image_base64')
                imgBase64 = data.output.image_base64;
            end
        end

        if isempty(imgBase64)
            disp('DEBUG: Could not find an image field in parsed JSON:');
            disp(data);
            uialert(app.UIFigure, ['AI visual generation failed: Cloudflare returned JSON but no recognized image field. ' ...
                'Check the Command Window for the JSON response. Simulation calculations are still complete.'], 'AI Error');
            return;
        end

        % DECODE AND DISPLAY IMG
        try
            imgBytes = matlab.net.base64decode(imgBase64);
            tempFile = [tempname, '.png'];
            fid = fopen(tempFile,'wb'); fwrite(fid,imgBytes,'uint8'); fclose(fid);
            img = imread(tempFile);
            delete(findall(app.SimulationPanel,'Type','uiimage'));
            uiimage(app.SimulationPanel,'ImageSource',img,'Position',[40 40 480 420],'ScaleMethod','fit');
        catch IMGERR
            disp('Image decoding/display error:');
            disp(IMGERR.message);
            uialert(app.UIFigure, 'AI visual generation returned image data but decoding failed. Simulation calculations are still complete.', 'AI Error');
        end

    catch ME
        msg = ME.message;
        warning('%s', msg);
        if contains(lower(msg), 'quota') || contains(lower(msg), 'limit')
            uialert(app.UIFigure, ...
                ['Your Cloudflare AI usage limit or quota may have been reached. ' ...
                 'Simulation calculations are still complete.'], ...
                'Billing Limit Reached');
        else
            uialert(app.UIFigure, sprintf( ...
                'AI visual generation failed.\n\n%s\n\nSimulation calculations are still complete.', msg), ...
                'AI Error');
        end
    end
end

        %% VII. ---------------------- CLEAR FUNCTION ----------------------
        function clearInputs(app)
            % CLEAR SELECTION AND CONSUMPTION FIELDS
            app.ApplianceListListBox.Value = {};
            for i = 1:app.MaxDevices
                app.ConsumptionLabelArray(i).Text = sprintf('Consumption [Device %d]', i);
                app.ConsumptionFieldArray(i).Value = 1;
                app.ConsumptionLabelArray(i).Visible = 'off';
                app.ConsumptionFieldArray(i).Visible = 'off';
            end

            % REMOVE CHILDREN EXCEPT IN ESTIMATED BILL
            children = allchild(app.SimulationPanel);
            for k = 1:numel(children)
                h = children(k);
                if h ~= app.EstimatedBillPhp000Label
                    try
                        delete(h);
                    catch
                        % IGNORE IF DELETION FAILS
                    end
                end
            end

            % RESET STORED HANDLES
            app.LastBreakdownLabels = gobjects(0);
            app.LastImageHandles = gobjects(0);
            app.LastWireHandles = gobjects(0);

            % RESET ESTIMATED BILL
            app.EstimatedBillPhp000Label.Text = 'Estimated Bill: Php 0.00';
        end
    end

    %% VIII. ---------------------- APP CON/DEL ----------------------
    methods (Access = public)
        function app = simupower
            
            % CONSTRUCT APP
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            % DELETE UIFIGURE WHEN APP IS DELETED
            try
                delete(app.UIFigure)
            catch
            end
        end
    end
end
