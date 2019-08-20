function rusdoc(url)
%% Open russian version of documentation
if nargin < 1
    b = com.mathworks.mlservices.MLHelpServices.getHelpBrowser;
    if ~isempty(b)
        url = b.getCurrentLocation;
    else
        url = '';
    end
end
url = extractAfter(char(url), '/help/');
if startsWith(url, 'templates/3pdoc.html')
    url = '';
end
web("https://docs.exponenta.ru/" + url, '-browser');