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

       %% VI. ---------------------- SIMULATION ---------------------- [ASSISTED BY MATGPT]
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
                uialert(app.UIFigure,'Please select at least one appliance.','Error');
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
            desc = sprintf(['Generate a clean schematic illustration showing %s connected ', ...
                'to a central power outlet using soft glowing lines. Minimal pastel colors, ', ...
                'flat design, white background, no text. Educational infographic look.'], ...
                applianceStr);
        
            % --- DEEPAI IMAGE GENERATION (SAFE TO FAIL) ---
            try
                % DEEPAI endpoint 
                url = 'https://api.deepai.org/api/text2img';
                apiKey = 'API-HERE';  % replace with your DeepAI key from https://deepai.org/dashboard
        
                options = weboptions( ...
                    'HeaderFields', {'api-key', apiKey}, ...
                    'Timeout', 60 ...
                );
        
                response = webwrite(url, 'text', desc, options);
        
                % VERIFY RESPONSE STRUCTURE
                if ~isfield(response, 'output_url')
                    error('DeepAI did not return a valid image URL.');
                end
        
                % READ THE GENERATED IMAGE
                img = imread(response.output_url);
        
                % DISPLAY IMAGE IN UI
                delete(findall(app.SimulationPanel,'Type','uiimage'));
                uiimage(app.SimulationPanel, ...
                    'ImageSource', img, ...
                    'Position',[40 40 480 420], ...
                    'ScaleMethod','fit');
        
            catch ME
                msg = ME.message;
                warning('%s', msg);
                if contains(lower(msg),'quota') || contains(lower(msg),'limit')
                    uialert(app.UIFigure, ...
                        ['Your DeepAI usage limit or quota may have been reached. ' ...
                         'Simulation calculations are still complete.'], ...
                        'Billing Limit Reached');
                else
                    uialert(app.UIFigure, sprintf('AI visual generation failed.\n\n%s\n', msg), 'AI Error');
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
