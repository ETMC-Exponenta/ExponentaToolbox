function update(upd, varargin)
u = AppDesignerProUpdater();
u.update();
if nargin < 1
    upd = ExponentaUpdater();
end
upd.update(varargin{:});