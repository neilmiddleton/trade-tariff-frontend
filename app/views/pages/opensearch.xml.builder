xml.instruct!
xml.OpenSearchDescription(xmlns: 'http://a9.com/-/spec/opensearch/1.1/', 'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/') do
  xml.ShortName('Trade Tariff')
  xml.InputEncoding('UTF-8')
  xml.Description('Trade Tariff: look up commodity codes, duty and VAT rates')
  xml.Url(type: 'text/html', method: 'get', template: CGI::unescape(perform_search_url(q: '{searchTerms}')))
  xml.Url(type: 'application/atom+xml', method: 'get', template: CGI::unescape(perform_search_url(q: '{searchTerms}', format: :atom)))
  xml.Url(type: 'application/x-suggestions+json', method: 'get', template: CGI::unescape(perform_search_url(q: '{searchTerms}', format: :json)))
  xml.Url(type: 'application/json', rel: 'suggestions', method: 'get', template: CGI::unescape(perform_search_url(q: '{searchTerms}', format: :json)))
end
