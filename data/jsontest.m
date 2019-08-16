T = cell2table(cell(0, 3), 'VariableNames', {'code' 'message' 'duedate'});
T = [T; {datestr(datetime, 'yymmddHHMMss'), char("fdsfds"+newline+"gggg"), datetime}];
json_write(1, 'notifications.json', T, true)


function data = json_read(~, fname, asTable)
%% Read data from .json file
if nargin < 3
    asTable = true;
end
data = loadjson(fname, 'Encoding', 'UTF-8');
if asTable && ~(isstruct(data) && isscalar(data))
    data = struct2table(vertcat(data{:}), 'AsArray', true);
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