#TraderDaddy Credentials
$TD_Cred = Get-Credential -Message "TraderDaddy login"

#Login settings for the api page
$TD_Login_Api = Invoke-WebRequest https://www.traderdaddy.com/api/dashboard -SessionVariable tdapidsh
$TD_Login_Api.Forms[0].Fields.email = $TD_Cred.UserName
$TD_Login_Api.Forms[0].Fields.password = $TD_Cred.GetNetworkCredential().Password

#Login settings for the dashboard page
$TD_Login_Dsh = Invoke-WebRequest https://www.traderdaddy.com/dashboard -SessionVariable tddsh
$TD_Login_Dsh.Forms[0].Fields.email = $TD_Cred.UserName
$TD_Login_Dsh.Forms[0].Fields.password = $TD_Cred.GetNetworkCredential().Password
    
#get the content
$TD_Api = Invoke-WebRequest $TD_Login_Api.Forms[0].Action -WebSession $tdapidsh -Body $TD_Login_Api -Method Post
$TD_Dashboard = Invoke-WebRequest $TD_Login_Dsh.Forms[0].Action -WebSession $tddsh -Body $TD_Login_Dsh -Method Post

#get the value's from the webpage
$TD_TotalProfit = ($TD_Api.Content | Select-String -Pattern '(?<=total_profit":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_AvgPercent = ($TD_Api.Content | Select-String -Pattern '(?<=avg_percent":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_TotalVolume = ($TD_Api.Content | Select-String -Pattern '(?<=total_volume":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_AccountValue = (($TD_Dashboard | Select-String '(<div class="inner">\s+\S+\s+)(\d+[.]\d+)' -AllMatches).Matches.Value | Select-String '(\d+[.]\d+)' -AllMatches).Matches.Value
$BL3P_EuroBTC = ((Invoke-WebRequest -Uri https://bl3p.eu/nl/api).content | Select-String -Pattern '(?<=€<\/span><span class="value">)(\d+[.]\d+[,]\d+)' -AllMatches).Matches.Value

#Set the properties for the table
$Properties = [Ordered]@{

            "AccountValue" = $TD_AccountValue
            "AvgPercent" = $TD_AvgPercent
            "TotalProfit" = $TD_TotalProfit
            "TotalVolume" = $TD_TotalVolume
            "BTC-EUR(BL3P)" = $BL3P_EuroBTC
            "Date" = Get-Date
}

#Create the table
$List = New-Object -TypeName PSCustomObject -Property $Properties
$List