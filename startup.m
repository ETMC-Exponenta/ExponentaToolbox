function startup()
%% Check notifications when MATLAB starts
try
    ExponentaNotifier();
    exponenta.internal.checkupdate();
end