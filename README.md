# WinErrorCodeInfo
Import Windows Error code and filter matching error code to get the information


Get-ErrorCodeInfo 112 -Verbose

Get-ErrorCodeInfo 112 -LocalJSONFilePath .\ErrorCodes.json -Verbose

Get-ErrorCodeInfo 0 -Online
