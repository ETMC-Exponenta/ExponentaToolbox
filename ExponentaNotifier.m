classdef ExponentaNotifier < handle
    %EXPONENTANOTIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Updater
        Data
        DataRecievedFcn
        Offline = false
        DownloadTimeout = 10
        DataPath = 'data/notifications.json'
        Key = 'Notifications'
        NotifierName = 'Exponenta App'
        IconDefault = 'icon-my-etmc-exponenta.png'
        IconNotify = 'icon-my-etmc-exponenta-mod-notification.png'
    end
    
    methods
        function obj = ExponentaNotifier(cbfun)
            %% Constructor
            obj.Updater = ExponentaUpdater();
            obj.Name = obj.Updater.ext.name;
            obj.Offline = ~obj.Updater.isonline();
            obj.Data = obj.readNotifications();
            if nargin > 0
                obj.DataRecievedFcn = cbfun;
            end
            obj.updateNotifications();
            Async(@(~)obj.downloadNotifications, obj.DownloadTimeout);
        end
        
        function downloadNotifications(obj)
            %% Get notifications data
            furl = obj.Updater.ext.getrawurl(obj.DataPath);
            data = [];
            if ~obj.Offline
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
                            datatemp = outerjoin(data, data0, 'Keys', 'code', 'type', 'left');
                            data.checked = any(datatemp{:, {'checked_data' 'checked_data0'}}, 2);
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
            N = obj.Data;
            if ~isempty(N)
                obj.Data = N(N.duedate >= datetime('today'), :);
                obj.saveNotifications();
            end
            if ~isempty(obj.DataRecievedFcn)
                obj.DataRecievedFcn(obj.Data);
            end
        end
        
        function N = readNotifications(obj)
            %% Read saved notifications
            if ispref(obj.Name, obj.Key)
                N = getpref(obj.Name, obj.Key);
            else
                N = [];
            end
        end
        
        function saveNotifications(obj)
            %% Save notifications
           setpref(obj.Name, obj.Key, obj.Data);
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
                favs = com.mathworks.mlwidgets.favoritecommands.FavoriteCommands.getInstance();
                c0 = favs.getCommandProperties(obj.NotifierName, obj.Name);
                c1 = favs.getCommandProperties(obj.NotifierName, obj.Name);
                if isempty(obj.Data) || all(obj.Data.checked)
                    c1.setIconName(obj.IconDefault);
                else
                    c1.setIconName(obj.IconNotify);
                end
                favs.updateCommand(c0, c1);
            end
        end
        
    end
end

