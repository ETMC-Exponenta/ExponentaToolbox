% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
instURL = 'https://api.github.com/repos/ETMC-Exponenta/ExponentaToolbox/releases/latest';
[~, instName] = fileparts(fileparts(fileparts(instURL)));
instRes = webread(instURL);
fprintf('Downloading %s %s\n', instName, instRes.name);
websave(instRes.assets.name, instRes.assets.browser_download_url);
disp('Installing...')
v = version;
if contains(v, {'R2018' 'R2017' 'R2016' 'R2015'})
    installAppDesignerPro();
    matlab.addons.install(instRes.assets.name);
else
    open(instRes.assets.name);
end
clear instURL instRes instName
disp('Installation complete!')
% Post-install commands
% Add your post-install commands below

function installAppDesignerPro()
eval(webread('https://git.io/fjbyL')); % Install App Designer Pro Library
end