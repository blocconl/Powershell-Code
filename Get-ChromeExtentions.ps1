#Extract Google Chrome extentions from the website
$extentions = Import-Csv ".\extentions.csv" -Header extentions
$result = foreach ($extention in $extentions.extentions)
{
    #URL to Google Extentions
    $url = "https://chrome.google.com/webstore/detail/$extention"
    #Invoke-WebRequest to get the title
    $siteinfo = ((Invoke-WebRequest $url).content | Select-string -Pattern '(?<=<title>).*(?= - Chrome Web Store</title>)' -AllMatches).Matches.Value
    #Create the list
    $siteinfo + "," + $extention + "," + $url
}
$result | Sort-Object
