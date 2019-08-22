% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
instOld = contains(version, {'R2018' 'R2017' 'R2016' 'R2015'});
if instOld
    eval(webread('https://git.io/fjbyL')); % Install App Designer Pro Library
end
instURL = 'https://api.github.com/repos/ETMC-Exponenta/ExponentaToolbox/releases/latest';
[~, instName] = fileparts(fileparts(fileparts(instURL)));
instRes = webread(instURL);
fprintf('Downloading %s %s\n', instName, instRes.name);
websave(instRes.assets.name, instRes.assets.browser_download_url);
disp('Installing...')
v = version;
if instOld
    matlab.addons.install(instRes.assets.name);
    ext = ExponentaExtender;
    ext.doc;
    clear ext
else
    open(instRes.assets.name);
end
clear instURL instRes instName instOld
disp('Installation complete!')
% Post-install commands
% Add your post-install commands below