function Batch-Set-DefaultFieldValue(){
  <#
    .SYNOPSIS
    This method is a batching support for Set-DefaultFieldValue.

    .DESCRIPTION
    This method exposes the batching functionality over an explicit collection, or recursively from a root path.The following methods are supported:

    -Pathwise: provide a collection of paths like -paths @("path1","path2","pathN") with -src and dest, and each dest value will be defaulted to src's value if no value is present

    -Recursive: (NOTE: EXTREMELY VOLATILE) This will take the $rootPath and recurse every single child whose layout inherits General Page in the same way as pathwise. This can effect massive change on a site.

    .PARAMETER paths
    A collection of paths that will be have their specific values defaulted.

    .PARAMETER rootPath
    A source path from which all children of type General Page will be recursed.

    .PARAMETER src
    The source object the default value will be sampled from

    .PARAMETER dest
    The destination object that will be defaulted

    .PARAMETER verbose
    Exposes errors that are hidden otherwise
  #>
  [cmdletbinding()]
  param(
    [parameter()]
    [string[]]$searchPaths,
    [parameter()]
    [string]$rootPath,
    [parameter(Mandatory=$true)]
    [string]$src,
    [parameter(Mandatory=$true)]
    [string]$dest
  )
  ##### subroutines
  $errorActionPreference = "stop"
  function runPath($path){
    if($verbose){
      Set-DefaultFieldValue -path $path -src $src -dest $dest -verbose $verbose;
    }
    else{Set-DefaultFieldValue -path $path -src $src -dest $dest}
  }
  function processPaths(){
    Write-Progress -id 1 -activity "Processing Paths...";
    for($i = 0; $i -lt $searchPaths.length; $i++){
      $path =$searchPaths[$i];
      Write-Progress -id 1 -activity "Processing Paths" -current "Executing $path" -status "Working..." -percent ($i/$searchPaths.length*100);
      Write-Warning "Modifying $path";
      runPath $path; start-sleep 1
    }
    Write-Progress -id 1 -activity "Processing Paths..." -completed;
  }
  #####dialogs
  function confirmRecursiveUpdate($workingSet){
    if($workingSet.length -eq 0){Write-Warning "No items were found, exiting."; return $false;}
    $confirm = "";
    $length = $workingSet.length;
    while ($confirm -notmatch "^y|^n|^Y|^N|^l|^L"){
      $confirm = read-host "This operation will effect ? Y = Continue, N = cancel, L = List Items"
    }
    switch -wildcard($confirm.ToLower()){
      "y*"{ Write-Host "Executing changes..."; return $true;}
      "n*"{ Write-host "Cancelling..."; return $false;}
      "l*"{ return "list";}
    }
  }

  function confirm($msg){
    $confirm = "";
    $length = $workingSet.length;
    while ($confirm -notmatch "^y|^n|^Y|^N|^l|^L"){
      $confirm = read-host "$msg (Y/N)";
    }
    switch -wildcard($confirm.ToLower()){
      "y*"{ return $true;}
      "n*"{ return $false;}
    }
  }

  #####Execution routines
  if($searchPaths){
    processPaths;
  }
  if($rootPath){
    $confirm = "";
    try{
      Write-Progress -id 1 -activity "Calculating Objects to Modify...";
      Start-Transaction;
      if(test-path $rootPath)
      {
        $searchPaths = @(get-childitem $rootPath -r| %{$_.FullName}) #| ?{ $_.TemplateName -eq "Generic Page" };
        $confirm = confirmRecursiveUpdate $searchPaths;
        if($confirm -eq $true){
          processPaths;
        }
        elseif($confirm -eq "list"){ $searchPaths | ft -a -prop Name;
          $run = confirm "Do you wish to continue?";
          if($run){
            processPaths;
          }
        }
      }
      else{ Write-Error "$rootPath is not a valid location, please check the directory and try again.";}
    }
    catch{
      $msg = $_.Exception.Message;
      Write-Error "An error occured during processing: $msg";
      if($verbose){ $_.Exception }
      Undo-Transaction
    }
    finally{
      Write-Host "Path processing Completed.";
    }
  }

}

function Set-DefaultFieldValue(){
  <#
    .SYNOPSIS
    This method allows a user to set a default value on a field based on another value one time.

    .DESCRIPTION
    This method provides the ability for the user to sample a fields value, and assign a default value from another field if that value is in the default state. This method does not perform type inference or guarantee coercion from one type to another, the functionality will default to sitecore's root implementation for this functionality.

    .PARAMETER path
    The explicit path to the page that houses the field to be modified

    .PARAMETER src
    The source object the default value will be sampled from

    .PARAMETER dest
    The destination object that will be defaulted

    .PARAMETER verbose
    Exposes errors that are hidden otherwise
  #>
  [cmdletbinding()]
  param(
  	[parameter(Mandatory=$true)]
  	[string]$path,
  	[parameter(Mandatory=$true)]
  	[string]$src,
    [parameter(Mandatory=$true)]
    [string]$dest,
    [parameter()]
    [switch]$useTransaction
  )
  $errorActionPreference = "stop"
  #private static const
  $defaultCases = @(""," ",[System.Environment]::NewLine);
  Try{
    $item = get-item $path; #retrieve the src object
  }
  Catch{
    Write-Error "$path was not found, please check the location and try again";
    if($verbose){ $_.Exception.Message; }
    return;
  }
  try{
    $destVal= $item[$dest];#get destination value, terminating condition if null
    $srcVal = $item[$src];#get srcval, terminating condition if null
    if(!$defaultCases.Contains($destVal)){#ensure destination is not an empty string (default value)
        Write-Host "Setting $path::$dest to $srcVal";
        if($useTransaction){Set-ItemProperty -path $path -Name $dest -Value $item[$src]; -useTransaction}
        else{Set-ItemProperty -path $path -Name $dest -Value $item[$src];}#Write the source value to the destination object
     }
     else{ Write-Warning "$dest already contains data, skipping...`n data: $destVal" }
   }catch{
    Write-Error "An error occurred while setting $path, please verify the data on sitecore and run again";
    if($verbose){$msg;
       $_.Exception; }
    return;
   }
}
