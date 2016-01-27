function filesEqual {
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$left,
        
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$right
    )
    
    $leftBuffer = New-Object byte[] 100;
    $rightBuffer = New-Object byte[] 100;
    
    $leftStream = [System.IO.File]::OpenRead($left.FullName)
    $rightStream = [System.IO.File]::OpenRead($right.FullName)

    While($true){
        $leftRead = $leftStream.Read($leftBuffer,0,$leftBuffer.Length)
        $rightRead = $rightStream.Read($rightBuffer,0,$rightBuffer.Length)
        if($leftRead -eq 0 -and $rightRead -eq 0) { #read both files to the end
            return $true
        }
        if($leftRead -ne $rightRead) { # files not equal in size - shouldn't happen
            Write-Warning "Files  $($left.FullName) and $($right.FullName) have different sizes"
            return $false
        }
        $leftEnumerator = $leftBuffer.GetEnumerator()
        $rightEnumerator = $rightBuffer.GetEnumerator()
        While($leftEnumerator.MoveNext() -and $rightEnumerator.MoveNext()){
            if($leftEnumerator.Current -ne $rightEnumerator.Current){
                return $false
            }
        }
    }
}

function Find-DuplicateFiles {
    Param([System.IO.DirectoryInfo]$Directory = ".")
    $sizes = @{}
    [System.Collections.ArrayList]$return = @()
    [array]$files = Get-ChildItem -Recurse $Directory | Where-Object {$_ -is [System.IO.FileInfo]}
    $files | ForEach-Object{
        if(!$sizes.ContainsKey($_.Length)){ $sizes[$_.Length] = @() }
        $sizes[$_.Length] += $_
    }
    
    foreach($files in  $sizes.Values){
        for($i = 0; $i -lt $files.Count; $i++){
            for($j = $i + 1; $j -lt $files.Count; $j++){
                Write-Debug "Comparing $($files[$i].FullName) and $($files[$j].FullName)"
                if( filesEqual $files[$i] $files[$j] ){ 
                    $return.Add(@($files[$i],$files[$j])) | Out-Null
                }
            }
        }
    }

    return $return
}