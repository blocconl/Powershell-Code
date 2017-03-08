#Extract Google Chrome extension name from the chrome website
$extensions = Import-Csv ".\extensions.csv" -Header extensions
$result = foreach ($extension in $extensions.extensions)
{
    #URL to Google extensions
    $url = "https://chrome.google.com/webstore/detail/$extension"
    #Invoke-WebRequest to get the title
    $siteinfo = ((Invoke-WebRequest $url).content | Select-string -Pattern '(?<=<title>).*(?= - Chrome Web Store</title>)' -AllMatches).Matches.Value
    #Create the list
    $siteinfo + "," + $extension + "," + $url
}
$result | Sort-Object
