# imports
Import-Module BurntToast

New-BTAppId "Twitch PowerNotifications"

# load config file
$config = ([xml] (Get-Content .\config.xml)).config

# iterate over all channels
foreach($channel in $config.channels.channel) {
    $stream_endpoint = "https://api.twitch.tv/helix/streams?user_login=$($channel)"
    $user_endpoint = 'https://api.twitch.tv/helix/users?id='
    $headers = @{
        'Client-ID' = "$($config.clientID)"
    }
    
    $response = Invoke-RestMethod -Uri $stream_endpoint -Method Get -Headers $headers
    if ($response.data) {
        $stream = $response.data
        $response = Invoke-RestMethod -Uri "$($user_endpoint)$($stream.user_id)" -Method Get -Headers $headers
        $user = $response.data
        
        $hero = New-BTImage -Source ($stream.thumbnail_url -replace "{width}", "360" -replace "{height}", "180") -HeroImage
        $title = New-BTText -Content $stream.user_name
        $subtitle = New-BTText -Content $stream.title -Style Subtitle
        $logo = New-BTImage -Source $user.profile_image_url -AppLogoOverride -Crop Circle
    
        $binding = New-BTBinding -HeroImage $hero -Children $title, $subtitle -AppLogoOverride $logo
        $visual = New-BTVisual -BindingGeneric $binding
        $content = New-BTContent -Visual $visual -ActivationType Protocol -Launch "https://www.twitch.tv/$($user.display_name)"
    
        # send notification
        Submit-BTNotification -Content $content -UniqueIdentifier "twitch-notification-$($channel)" -AppId "Twitch PowerNotifications"
    }
}