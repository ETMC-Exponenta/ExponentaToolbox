classdef ExponentaNotifier < handle
    %EXPONENTANOTIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Updater
        Data
        NotifierName = 'Exponenta App'
        IconDefault = 'icon-my-etmc-exponenta.png'
        IconNotify = 'icon-my-etmc-exponenta-mod-notification.png'
    end
    
    methods
        function obj = ExponentaNotifier()
            %% Constructor
            obj.Updater = ExponentaUpdater();
            if obj.Updater.isonline()
                Async(@(~)obj.getData, 2);
            end
        end
        
        function getData(obj)
            %% Get notifications data
            furl = obj.Updater.ext.getrawurl('data/alerts.json');
            txt = webread(furl);
            obj.Data = struct2table(jsondecode(txt), 'AsArray', true);
            if ~isempty(obj.Data)
                obj.Data = obj.Data(obj.Data.duedate >= datetime('today'), :);
            end
            obj.setIcon();
        end
        
        function setIcon(obj)
            %% Set shortcut icon
            if obj.Updater.ext.isfav('Exponenta App')
                favs = com.mathworks.mlwidgets.favoritecommands.FavoriteCommands.getInstance();
                c0 = favs.getCommandProperties(obj.NotifierName, obj.Updater.ext.name);
                c1 = favs.getCommandProperties(obj.NotifierName, obj.Updater.ext.name);
                if isempty(obj.Data)
                    c1.setIconName(obj.IconDefault);
                else
                    c1.setIconName(obj.IconNotify);
                end
                favs.updateCommand(c0, c1);
            end
        end
        
    end
end

