
function Get-IPGeolocation {

    param (
        [Parameter( Mandatory = $true)]
        [string]$ip
    )

    $resource = "http://api.ipstack.com/$($ipaddress)?access_key=c9574effa0947ca42c10bafa9542a28d"

    $geoip = Invoke-RestMethod -Method Get -URI $resource

    return $geoip

}
