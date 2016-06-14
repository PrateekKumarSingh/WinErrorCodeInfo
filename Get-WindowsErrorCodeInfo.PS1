Function Get-WindowsErrorCodeInfo
{
[cmdletbinding()]
Param(
        [Parameter(ValueFromPipeline = $true)][String]$ExitCode,
        [String]$LocalJSONFilePath,
        [String]$GithubJSONUrl = "https://gist.githubusercontent.com/PrateekKumarSingh/72e5deda930831f0bb41a3518d2464e1/raw/ce98cc4120066b53ae738abf7d38668980cbaafd/WindowsErrorCode.JSON"
)

Begin{}

Process
{
    Try
    {

        If($LocalJSONFilePath)
        {
            $JSON = Get-Content .\ErrorCodes.json -Raw |ConvertFrom-Json
			
			If($ExitCode)
			{
				$JSON.PSObject.BaseObject | Where{$_.exitCode -eq $ExitCode}
			}
			Else
			{
				$JSON.PSObject.BaseObject 
			}
        }
        ElseIf($GithubJSONUrl)
        {
            $JSON = (Invoke-WebRequest -Uri $GithubJSONUrl).content | ConvertFrom-Json
			
			If($ExitCode)
			{
				$JSON.PSObject.BaseObject | Where{$_.exitCode -eq $ExitCode}
			}
			Else
			{
				$JSON.PSObject.BaseObject
			}
        }
    }
    Catch
    {
        "Something went wrong! please try running the command again."
    }
}

End
{}

}
