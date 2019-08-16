classdef ExponentaNotifier < handle
    %EXPONENTANOTIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Updater
        Data
        GetDataCallback
        Offline = false
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
            if nargin > 0
                obj.GetDataCallback = cbfun;
            end
            Async(@(~)obj.getData, 2);
        end
        
        function getData(obj)
            %% Get notifications data
            furl = obj.Updater.ext.getrawurl(obj.DataPath);
            if ~obj.Offline
                try
                    txt = webread(furl);
                    obj.Data = struct2table(jsondecode(txt), 'AsArray', true);
                catch
                    obj.Offline = true;
                end
            end
            obj.getNotifications();
            if ~isempty(obj.GetDataCallback)
                obj.GetDataCallback(obj.Data);
            end
        end
        
        function setIcon(obj)
            %% Set shortcut icon
            if obj.Updater.ext.isfav(obj.NotifierName)
                favs = com.mathworks.mlwidgets.favoritecommands.FavoriteCommands.getInstance();
                c0 = favs.getCommandProperties(obj.NotifierName, obj.Name);
                c1 = favs.getCommandProperties(obj.NotifierName, obj.Name);
                if isempty(obj.Data) || all(obj.Data.read)
                    c1.setIconName(obj.IconDefault);
                else
                    c1.setIconName(obj.IconNotify);
                end
                favs.updateCommand(c0, c1);
            end
        end
        
        function N = getNotifications(obj)
            %% Get notifications
            if ~obj.Offline
                if ~isempty(obj.Data)
                    issaved = ispref(obj.Name, obj.Key);
                    if issaved
                        N = getpref(obj.Name, obj.Key);
                    else
                        N = [];
                    end
                    if isempty(N)
                        N = obj.Data;
                        N.read = false(height(obj.Data), 1);
                    else
                        N = innerjoin(obj.Data, N(:, {'code' 'read'}), 'Keys', 'code');
                    end
                else
                    N = [];
                end
            else
                N = getpref(obj.Name, obj.Key);
            end
            if ~isempty(N)
                obj.Data = N(N.duedate >= datetime('today'), :);
            end
            obj.Data = N;
            obj.saveNotifications();
            obj.setIcon();
        end
        
        function saveNotifications(obj)
            %% Save notifications
           setpref(obj.Name, obj.Key, obj.Data);
        end
        
        function markRead(obj, code, mark)
            %% Mark notification as read
            if ~isempty(obj.Data)
                cond = obj.Data.code == string(code);
                if nargin > 2
                    obj.Data.read(cond) = mark;
                else
                    state = obj.Data.read(cond);
                    obj.Data.read(cond) = ~state;
                end
                obj.saveNotifications();
                obj.setIcon();
            end
        end
        
        function num = getUnreadNum(obj)
            %% Get number of unread notifications
            if ~isempty(obj.Data)
                num = nnz(~obj.Data.read);
            else
                num = 0;
            end
        end
        
    end
end

