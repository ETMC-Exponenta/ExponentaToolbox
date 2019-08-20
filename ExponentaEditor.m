classdef ExponentaEditor < handle
    %EXPONENTAEDITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Root
        FileName = 'data/notifications.json'
        Data
    end
    
    methods
        function obj = ExponentaEditor()
            %% Constructor
            obj.Root = fileparts(mfilename('fullpath'));
            obj.load();
        end
        
        function data = load(obj)
            %% Read data
            data = obj.json_read(fullfile(obj.Root, obj.FileName), true);
            data.duedate = datetime(data.duedate);
            data = ExponentaNotifier.fixActions(data);
            obj.Data = data;
        end
        
        function save(obj)
            %% Write data
            obj.json_write(fullfile(obj.Root, obj.FileName), obj.Data, true);
        end
        
        function code = genCode(~)
            %% Generate new code
            code = datestr(datetime, 'yymmddHHMMss');
        end
        
        function data = json_read(~, fname, asTable)
            %% Read data from .json file
            if nargin < 3
                asTable = true;
            end
            data = loadjson(fname, 'SimplifyCell', 1, 'ParseLogical', 1, 'Encoding', 'UTF-8');
            if asTable && ~(isstruct(data) && isscalar(data))
                data = struct2table(data, 'AsArray', true);
            end
        end
        
        function json_write(~, fname, data, asArray)
            %% Write data to .json file
            if nargin < 4
                asArray = true;
            end
            if istable(data)
                data = reshape(table2struct(data), 1, []);
            end
            if asArray
                data = arrayfun(@(x) {x}, data);
            end
            savejson('', data, 'FileName', fname, 'ParseLogical', 1, 'Encoding', 'UTF-8');
        end
        
        function check_jsonlab(~)
            %% Check jsonlab in installed
            w1 = which('loadjson');
            w2 = which('savejson');
            if isempty(w1) || isempty(w2)
                error('Install <a href="https://github.com/fangq/jsonlab">jsonlab</a> first');
            end
        end
        
    end
end

