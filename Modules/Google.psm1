function google(){
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true,Position=0)]
		[String]$ctx,
		[Parameter(Mandatory=$false)]
		[switch]$recurse,
		[Parameter(Mandatory=$false)]
		[switch]$r,
		[Parameter(Mandatory=$false,Position=1)]
		[String]$filetype = "*",
		[Parameter(Mandatory=$false)]
		[String]$exclude = "none"
	)
	$qft = "*";
	$exc = $exclude -ne "none";
	if($exc){$exSet = $exclude.split(",");}
	if($filetype -ne $qft){ $qft = $qft + ".$filetype"; }
	function reduceSet($c,$ctx){
		$c | ?{ !$_.GetType().Name.ToLower().Contains("Directory") } | sls
	}
	function getExset($arr){$arr|%{"*.$_"};}
	function query($ctx,$ft){
		Write-Host "Searching current directory for *.$filetype files containing $ctx";
		get-childitem $ft | sls $ctx
	}
	function queryRecursive($ctx,$ft){
		Write-Host "Searching children for *.$filetype files containing $ctx";
		get-childitem $ft -r | sls $ctx
	}
	function queryExclude($ctx,$ex,$ft){
		$exSet = getExset $ex;
		Write-Host "Searching current directory for *.$filetype files containing $ctx, excluding filetypes: $exSet";
		get-childitem $ft -exclude $exSet | sls $ctx;
	}
	function queryExcludeRecursive($ctx,$ex,$ft){
                 $exSet = getExset $ex;
		 Write-Host "Searching children for *.$filetype files containing $ctx, excluding filetypes: $exSet";
                 get-childitem $ft -exclude $exSet -r | sls $ctx;
	}
	if($exc){ if($r -or $recurse){ queryExcludeRecursive $ctx $exSet $qft; return; }else{ queryExclude $ctx $exSet $qft; return; } }
	if($r -or $recurse){queryRecursive $ctx $qft;}
	else{query $ctx $qft;}
 }
