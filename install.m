function install
% Generated with Toolbox Extender https://github.com/ETMC-Exponenta/ToolboxExtender
eval(webread('https://git.io/fjbyL')); % Install App Designer Pro Library
open('ExponentaToolbox.prj');
dev_on
dev.test('', false);
% Post-install commands
close(currentProject)
cd('..');
exponenta.doc;
% Add your post-install commands below