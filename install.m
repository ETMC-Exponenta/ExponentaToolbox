function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
if contains(version, {'R2018' 'R2017' 'R2016' 'R2015'})
    eval(webread('https://git.io/fjbyL')); % Install App Designer Pro Library
end
dev = ExponentaDev;
dev.test('', false);
% Post-install commands
cd('..');
ext = ExponentaExtender;
ext.doc;
% Add your post-install commands below