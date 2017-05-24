Function Import-WindowsErrorCode{
[cmdletbinding()]
Param()

    Begin{
        $SystemErrorURLs = @(
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681382(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681388(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681383(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681385(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681386(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681387(v=vs.85).aspx"
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681389(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681390(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681391(v=vs.85).aspx",
                         "https://msdn.microsoft.com/en-us/library/windows/desktop/ms681384(v=vs.85).aspx"
                        )
        $InternetErrorURL = "https://msdn.microsoft.com/en-us/library/windows/desktop/aa385465(v=vs.85).aspx"

        $ExtractedString_SystemErrorURLs = $ExtractedString_InternetErrorURL = $Output = @()
    }
    Process{

        $ExtractedString_SystemErrorURLs = Foreach($URL in $SystemErrorURLs){
            $Content = ((Invoke-WebRequest -uri $URL).allelements|?{$_.id -eq "mainsection"}).outertext
            (($Content -split "FORMAT_MESSAGE_FROM_SYSTEM flag.")[1] -split "Suggestions?")[0].trim()   
        }
        
        $Content_interneterrors =  ((Invoke-WebRequest -uri "https://msdn.microsoft.com/en-us/library/windows/desktop/aa385465(v=vs.85).aspx").allelements|?{$_.id -eq "mainsection"}).outerText
        $ExtractedString_InternetErrorURL = (($Content_interneterrors -split "The following errors are specific to the WinINet functions.")[1] -split "ERROR_INVALID_HANDLE")[0].trim()

        Write-Verbose "Creating temporary files and fetching the Content to parse"
        #This is aa single line String
        $ExtractedString_SystemErrorURLs + $ExtractedString_InternetErrorURL |Out-File C:\Temp\TempData.txt
        
        #Saving it in the file and then fetching the data using get content converts it to array of strings separated by EOL
        $Result = (Get-Content C:\Temp\TempData.txt).trim()
        
        #Parsing the exit codes and description
        $Output = for($i =0 ; $i -le ($Result.count-1) ;){
            $ErrorString = ($Result[$i]).ToString()
            $i=$i+1
            $Exitcode = ($Result[$i]).trim().split(" ")[0]
            $hex = "0x$("{0:X0}" -f [int] $Exitcode)"
            $j=$i=$i+1
            
            While($Result[$i] -notlike "" -and $Result[$i] -notlike "ERROR_*" -and $Result[$i] -notlike "WAIT_*" -and $Result[$i] -notlike "ERROR_SETCOUNT_ON_BAD_LB*" -and $Result[$i] -notlike "RPC_*" -and $Result[$i] -notlike "EPT_*" -and $Result[$i] -notlike "SCHED_*" -and $Result[$i] -notlike "FRS_*" -and $Result[$i] -notlike "DNS_*" -and $Result[$i] -notlike "WSASERVICE_*" -and $Result[$i] -notlike "WSATYPE_*" -and $Result[$i] -notlike "WSA_*" -and $Result[$i] -notlike "WSATRY_*" -and $Result[$i] -notlike "WSAHOST_*" -and $Result[$i] -notlike "WSANO_*" -and $Result[$i] -notlike "WARNING_*" -and $Result[$i] -notlike "APPMODEL_*"){
                $i = $i+1
            }

            $str=''
            $Description = $Result[$j..($i-1)] | %{$str="$str$_";$str}

            If($Description -like $Result[$j-2]){
                $Description = $Result[$j]
                $i=$i+1
            }

            '' | select @{n='ErrorString';e={$ErrorString}}, @{n='ExitCode';e={[int]$Exitcode}}, @{n='Hex Value';e={$Hex}}, @{n='Description';e={$Description}} 
        } 

		Write-Verbose "All Exit code information has been extracted successfully"
		Write-Verbose "Sorting Information according to ExitCode numbers"

        $Output = $Output| ?{$_.ErrorString -ne 'ERROR_INTERNET_*'} |sort ExitCode

    }
    End{
        $Output 
    }  
}


Function Get-WindowsErrorCode{
[Alias("ErrorCode")]
[cmdletbinding()]
Param(
        [Parameter(ValueFromPipeline = $true)][String]$ExitCode,
        [String]$LocalJSONFilePath = "$PSScriptRoot\ErrorCodes.JSON",
        [String]$GithubJSONUrl = 'https://gist.githubusercontent.com/PrateekKumarSingh/72e5deda930831f0bb41a3518d2464e1/raw/ce98cc4120066b53ae738abf7d38668980cbaafd/WindowsErrorCode.JSON',
        [Switch]$Online
)

    Begin{
        Try{
            if ($Online){
                $JSON = (Invoke-WebRequest -Uri $GithubJSONUrl).content | ConvertFrom-Json
            }
            Else{
                if (!(Test-Path $LocalJSONFilePath)){
                    Import-WindowsErrorCode | ConvertTo-Json | Out-File $LocalJSONFilePath
                }
                $JSON = Get-Content $LocalJSONFilePath -Raw |ConvertFrom-Json
            }
   
        }
        Catch{
            "Something went wrong! please try running the script again."
        }
    }

    Process{
        Foreach($Item in $ExitCode){
            If($Item){
                $result = net helpmsg $ExitCode 2>&1
                if (!$result.WriteErrorStream.Count){
                    [PSCustomObject]@{
                        ErrorString=''
                        ExitCode = $ExitCode
                        'Hex Value' = '0x{0:X}' -f $ExitCode
                        Description = $result -join ' '
                    }
                }
                else{
			        $JSON.PSObject.BaseObject | Where{$_.exitCode -eq $ExitCode}
                }
	        }
            else{
                $JSON.PSObject.BaseObject 
                break;
            }
        }

    }

    End{
    }

}

Export-ModuleMember -Function Get-WindowsErrorCode -Alias ErrorCode
