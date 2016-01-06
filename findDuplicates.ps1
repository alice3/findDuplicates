function findDuplicateFiles {
    Param([System.IO.DirectoryInfo]$Directory = ".")
    [array]$files = Get-ChildItem -Recurse $Directory | Where-Object {$_ -is [System.IO.FileInfo]} 
    [System.Collections.ArrayList]$return = @()

    for($i = 0; $i -lt $files.Count; $i++){
        for($j = $i + 1; $j -lt $files.Count; $j++){
            Write-Debug "Comparing $($files[$i].FullName) and $($files[$j].FullName)"
            if( -not (Compare-Object (Get-Content $files[$i].FullName) (Get-Content $files[$j].FullName))) {
                $return.Add(@($files[$i],$files[$j])) | Out-Null
            }
        }
    }
    return $return
}