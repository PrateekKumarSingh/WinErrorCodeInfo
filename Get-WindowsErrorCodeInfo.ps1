Function Get-WindowsErrorCodeInfo
{
[cmdletbinding()]
Param(
        [Parameter(ValueFromPipeline = $true)][String]$ExitCode,
        [String]$LocalJSONFilePath,
        [String]$GithubJSONUrl = "https://gist.githubusercontent.com/PrateekKumarSingh/72e5deda930831f0bb41a3518d2464e1/raw/ce98cc4120066b53ae738abf7d38668980cbaafd/WindowsErrorCode.JSON"
)

Begin
{
    Try
    {

        If($LocalJSONFilePath)
        {
            $JSON = Get-Content .\ErrorCodes.json -Raw |ConvertFrom-Json
        }
        ElseIf($GithubJSONUrl)
        {
            $JSON = (Invoke-WebRequest -Uri $GithubJSONUrl).content | ConvertFrom-Json
        }
    }
    Catch
    {
        "Something went wrong! please try running the script again."
    }
}

Process
{
    Foreach($Item in $ExitCode)
    {
        If($Item)
	    {
			$JSON.PSObject.BaseObject | Where{$_.exitCode -eq $ExitCode}
	    }
        else
        {
            $JSON.PSObject.BaseObject 
            break;
        }
    }

}

End
{}

}
