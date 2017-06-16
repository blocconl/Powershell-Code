<#
.Synopsis
   Get the applied Google Chrome extensions out of a GPO
.DESCRIPTION
   This script gets all the applied Google Chrome extensions from a GPO. Please use google chrome extensions GPO.
.EXAMPLE
   Get-ChromeExtentions -GPO {Choose the right policy}
#>
function Get-ChromeExtentions
{
    [CmdletBinding()]
    Param()
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'GPO'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = (get-gpo -all).displayname
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }
    
    Begin
    {
        # Bind the parameter to a friendly variable
        $GPOname = $PsBoundParameters[$ParameterName]

        # Get the extensions out of the GPO
        $Extensions = (Get-GPOReport -Name $GPOname -ReportType Xml | Select-String -Pattern '(?<=<q1:Data>)[a-z]{32}' -AllMatches).Matches.Value
        
        # Check if it is not empty
        if ($Extensions -eq $null)
        {
            Write-Host "No extensions found!" -BackgroundColor Red
            Exit
        }
    
    }
    
    Process
    {
        #Create table
        $ExtensionTable = foreach ($Extension in $Extensions)
        {
            # URL to Google extensions
            $Url = "https://chrome.google.com/webstore/detail/$Extension"
   
            # Try webreqest
            $ExtensionCheck = try { Invoke-WebRequest $Url } catch { $_.Exception.Response }
            
            # Status check
                
            if ($ExtensionCheck.IsMutuallyAuthenticated -match "False")
            {
                $SiteInfo = "Google extension does not exists"
            }
               
            else
            {
                # Invoke-WebRequest to get the title
                $SiteInfo = ((Invoke-WebRequest $Url).content | Select-string -Pattern '(?<=<title>).*(?= - Chrome Web Store</title>)' -AllMatches).Matches.Value
            }

            #Defined properties for the New-Object
            $Properties = [Ordered]@{
                        "ExtentionName" = $SiteInfo
                        "ExtentionCode" = $Extensions
                        "URL" = $Url
            }
            #Create new object
            New-Object -TypeName PSCustomObject -Property $Properties
        }
    }

    End
    {
        # Export the file
        $ExtensionTable | Export-Csv .\Chrome-Extensions.csv -NoTypeInformation
    }
}

