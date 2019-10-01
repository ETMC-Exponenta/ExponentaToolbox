classdef Notifier < handle
    %EXPONENTANOTIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Updater % ExponentaUpdater
        Storage % ExponentaStorage
        UISnackbars
        DataRecievedFcn
        Offline = false
        DownloadTimeout = 3
        DataPath = 'data/notifications.json'
        Key = 'Notifications'
        NotifierName = 'Exponenta App'
        NotifierIconDefault = 'icon-my-etmc-exponenta.png'
        NotifierIcon = 'icon-my-etmc-exponenta-mod-notification.png'
    end
    
    methods
        function obj = Notifier(cbfun, synch, ext)
            %% Constructor
            obj.Updater = ExponentaUpdater(ext);
            obj.Storage = exponenta.internal.Storage('ext', ext,...
                'type', 'pref', 'auto', true);
            obj.Offline = ~obj.Updater.isonline();
            obj.Data = obj.readNotifications();
            if nargin > 0 && ~isempty(cbfun)
                obj.DataRecievedFcn = cbfun;
            end
            obj.updateNotifications();
            if nargin > 1 && synch
                obj.Updater.run_task(@(~,~)obj.downloadNotifications, obj.DownloadTimeout);
            end
        end
        
        function showNotifications(obj, parent, checkfcn)
            %% Show notifications in app
            data = obj.Data;
            if ~isempty(data)
                notifications = cell(height(data), 1);
                for i = 1 : height(data)
                    notifications{i} = obj.showNotification(parent, data(i, :), checkfcn);
                end
                if ~isempty(obj.UISnackbars)
                    for i = 1 : length(obj.UISnackbars)
                        delete(obj.UISnackbars(i));
                    end
                end
                obj.UISnackbars = flipud(vertcat(notifications{:}));
                pos = get(vertcat(obj.UISnackbars.Root), {'Position'});
                pos = uialign(vertcat(pos{:}), parent, 'center', 'top', true, [0 -15], 'VertDist', 5);
                set(obj.UISnackbars, {'Position'}, num2cell(pos, 2));
                arrayfun(@(s)s.redraw(), obj.UISnackbars);
            end
        end
        
        function downloadNotifications(obj)
            %% Get notifications data
            furl = obj.Updater.ext.getrawurl(obj.DataPath);
            data = [];
            if ~obj.Offline && obj.Updater.isonline()
                try
                    txt = webread(furl);
                    data = struct2table(jsondecode(txt), 'AsArray', true);
                catch
                    obj.Offline = true;
                end
            end
            if ~obj.Offline
                if isempty(data)
                    data = [];
                else
                    if ~isempty(obj.Data)
                        try
                            data0 = obj.Data(:, {'code' 'checked'});
                            [datatemp, ia] = outerjoin(data, data0, 'Keys', 'code', 'type', 'left');
                            checked = any(datatemp{:, {'checked_data' 'checked_data0'}}, 2);
                            [~, ia] = sort(ia);
                            data.checked = checked(ia);
                        end
                    end
                end
                obj.Data = data;
                obj.updateNotifications();
                obj.setIcon();
            end
        end
        
        function updateNotifications(obj)
            %% Update notifications to actual date
            if ~isempty(obj.Data)
                N = obj.fixActions(obj.Data);
                obj.Data = N(N.duedate >= datetime('today'), :);
                obj.saveNotifications();
            end
            if ~isempty(obj.DataRecievedFcn)
                obj.DataRecievedFcn(obj);
            end
        end
        
        function N = readNotifications(obj)
            %% Read saved notifications
            N = obj.Storage.get(obj.Key);
        end
        
        function saveNotifications(obj)
            %% Save notifications
           obj.Storage.set(obj.Key, obj.Data);
        end
        
        function markChecked(obj, code, mark)
            %% Mark notification as checked
            if ~isempty(obj.Data)
                cond = obj.Data.code == string(code);
                if nargin > 2
                    obj.Data.checked(cond) = mark;
                else
                    state = obj.Data.checked(cond);
                    obj.Data.checked(cond) = ~state;
                end
                obj.saveNotifications();
                obj.setIcon();
            end
        end
        
        function num = getUnreadNum(obj)
            %% Get number of unread notifications
            if ~isempty(obj.Data)
                num = nnz(~obj.Data.checked);
            else
                num = 0;
            end
        end
        
        function setIcon(obj)
            %% Set shortcut icon
            if obj.Updater.ext.isfav(obj.NotifierName)
                name = obj.Updater.ext.name;
                favs = com.mathworks.mlwidgets.favoritecommands.FavoriteCommands.getInstance();
                if ismethod(favs, 'getCommandProperties')
                    c0 = favs.getCommandProperties(obj.NotifierName, name);
                    c1 = favs.getCommandProperties(obj.NotifierName, name);
                    if isempty(obj.Data) || all(obj.Data.checked)
                        c1.setIconName(obj.NotifierIconDefault);
                    else
                        c1.setIconName(obj.NotifierIcon);
                    end
                    favs.updateCommand(c0, c1);
                end
            end
        end
        
    end
    
    methods (Static)
        
        function n = showNotification(parent, data, checkfcn)
            %% Show notification
            actions = data.actions{1};
            if ~isempty(actions)
                for i = 1 : size(actions, 1)
                    actions{i, 2} = str2func(actions{i, 2});
                end
            end
            n = uisnackbar(parent, data.message{1}, 'Type', 'checkable',...
                'Checked', data.checked(1), 'Animation', 'none', 'Theme', data.theme{1},...
                'Time', inf, 'MinWidth', 375, 'UserData', data.code{1},...
                'MainActionFcn', checkfcn, 'Actions', actions);
        end
        
        function data = fixActions(data)
            %% Fix actions cell array
            actions = data.actions;
            if size(actions, 2) > 1
                actions = mat2cell(actions, ones(1, size(actions, 1)), 2);
            end
            isca = cellfun(@(x) ~isempty(x) && iscell(x) && iscell(x{1}), actions);
            if any(isca)
                actions(isca) = cellfun(@(x)vertcat(x{:}), actions(isca), 'UniformOutput', false);
            end
            iscv = cellfun(@(x) ~isempty(x) && iscell(x) && size(x, 2) == 1, actions);
            if any(iscv)
                actions(iscv) = cellfun(@(x)reshape(x, 2, [])', actions(iscv), 'UniformOutput', false);
            end
            data.actions = actions;
        end
        
    end
end

