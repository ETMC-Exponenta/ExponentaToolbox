function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
eval(webread('https://git.io/fjbyL')); % Install App Designer Pro Library
dev_on;
dev.test('', false);
% Post-install commands
cd('..');
ext = ExponentaExtender;
ext.doc;
% Add your post-install commands below