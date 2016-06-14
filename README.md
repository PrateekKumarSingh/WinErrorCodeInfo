# WinErrorCodeInfo
Import Windows Error code and filter matching error code to get the information


Get-ErrorCodeInfo 112 -Verbose

Get-ErrorCodeInfo 112 -LocalJSONFilePath .\ErrorCodes.json -Verbose

Get-ErrorCodeInfo 0 -GithubJSONUrl "https://gist.githubusercontent.com/PrateekKumarSingh/ce9a1dda082d52a9c6e1378cb9da0d08/raw/c73ff89d5002da1ebf6f6ba11728252b337dc9ed/MSI_ExitCodes.json"
