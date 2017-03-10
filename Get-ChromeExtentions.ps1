#Extract Google Chrome extension name from the chrome website
$extensions = Import-Csv ".\extensions.csv" -Header extensions
$result = foreach ($extension in $extensions.extensions)
{
    #URL to Google extensions
    $url = "https://chrome.google.com/webstore/detail/$extension"
   
    #Try webreqest
    $extensioncheck = try { Invoke-WebRequest $url } catch { $_.Exception.Response }

    #Status check
    if ($extensioncheck.IsMutuallyAuthenticated -match "False")
    {
        "Google extension does not exists,$extension,$url"
    }
    else
    {
        #Invoke-WebRequest to get the title
        $siteinfo = ((Invoke-WebRequest $url).content | Select-string -Pattern '(?<=<title>).*(?= - Chrome Web Store</title>)' -AllMatches).Matches.Value
        #Create the list
        $siteinfo + "," + $extension + "," + $url
    }
}
#Output the file
$result | Sort-Object  | Out-File .\Out-extensions.csv
