function startup()
%% Check notifications when MATLAB starts
try
    s = ExponentaStorage('type', 'pref', 'auto', 1);
    if s.get('AutoCheckUpdate', [], true)
        exponenta.internal.checkupdate(s.ext);
    end
    if s.get('AutoLoadNotifications', [], true)
        exponenta.internal.Notifier([], true, s.ext);
    end
end