#TraderDaddy Credentials
$TD_cred = Get-Credential -Message "TraderDaddy login"

#Login settings for the api page
$TD_login_api = Invoke-WebRequest https://www.traderdaddy.com/api/dashboard -SessionVariable tdapidsh
$TD_login_api.Forms[0].Fields.email = $TD_cred.UserName
$TD_login_api.Forms[0].Fields.password = $TD_cred.GetNetworkCredential().Password

#Login settings for the dashboard page
$TD_login_dsh = Invoke-WebRequest https://www.traderdaddy.com/dashboard -SessionVariable tddsh
$TD_login_dsh.Forms[0].Fields.email = $TD_cred.UserName
$TD_login_dsh.Forms[0].Fields.password = $TD_cred.GetNetworkCredential().Password

#get the content
$TD_Api = Invoke-WebRequest $TD_login_api.Forms[0].Action -WebSession $tdapidsh -Body $TD_login_api -Method Post
$TD_dashboard = Invoke-WebRequest $TD_login_dsh.Forms[0].Action -WebSession $tddsh -Body $TD_login_dsh -Method Post

#get the value's from the webpage
$TD_Totalprofit = ($TD_Api.Content | Select-string -Pattern '(?<=total_profit":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_AvgPercent = ($TD_Api.Content | Select-string -Pattern '(?<=avg_percent":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_TotalVolume = ($TD_Api.Content | Select-string -Pattern '(?<=total_volume":")(\d+[.]\d+)' -AllMatches).Matches.Value
$TD_AccountValue = (($TD_dashboard | Select-string '(<div class="inner">\s+\S+\s+)(\d+[.]\d+)' -AllMatches).Matches.Value | Select-string '(\d+[.]\d+)' -AllMatches).Matches.Value
$BL3P_EuroBTC = ((Invoke-WebRequest -Uri https://bl3p.eu/nl/api).content | Select-String -Pattern '(?<=€<\/span><span class="value">)(\d+[.]\d+[,]\d+)' -AllMatches).Matches.Value

#Set the properties for the table
$Properties = [Ordered]@{
  "AccountValue" = $TD_AccountValue
  "AvgPercent" = $TD_AvgPercent
  "TotalProfit" = $TD_Totalprofit
  "TotalVolume" = $TD_TotalVolume
  "BTC-EUR(BL3P)" = $BL3P_EuroBTC
  "Date" = Get-Date  
}
#Create the table
$list = New-Object -TypeName PSCustomObject -Property $Properties
$list