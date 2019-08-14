function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
dev = ExponentaDev;
dev.test('', false);
% Post-install commands
cd('..');
ext = ExponentaExtender;
ext.doc;
% Add your post-install commands below