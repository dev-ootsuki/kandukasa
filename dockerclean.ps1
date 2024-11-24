# https://docs.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.1
# when powershell not execute
# open "Powershell" by administrator
# input console "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned"
# enter.

# stop all container
$runlist = docker ps -a
foreach($container in $runlist){
  if($container -match "([a-zA-Z0-9_/\-\.]+)(\s+)(`".+`")(\s+)"){
    docker stop $Matches.1
  }
}

docker image prune -af
docker network prune -f
docker builder prune -af
docker system prune -af
docker volume prune -af

# for linux
# docker volume rm $(docker volume ls -qf dangling=true)
$imagelist = docker images -a
# remove images non caches
foreach($img in $imagelist){
  if($img -match "([a-zA-Z0-9_/\-\.]+)(\s+)([a-zA-Z0-9_/\-\.]+)(\s+)([a-f0-9]+?)(\s+)([0-9A-Za-z\s]{1,8}\s?[a-z]{3,7}\sago)(\s+)([0-9A-Z\.])"){
    $target = $Matches.1 + ":" + $Matches.3
    docker rmi -f $target
    Write-Host $target
  }
}

# remove at unuse repository:<none>, tag:<none>
$imagelist = docker images -a
foreach($img in $imagelist){
  if($img -match "(<none>)(\s+)(<none>)(\s+)(?<hash>[a-f0-9]+?)(\s+)(.+)"){
    docker rmi -f $Matches.hash
  }
}

# remove volume all
$volumelist = docker volume ls
foreach($volume in $volumelist){
  if($volume -match "(?<driver>[a-zA-Z0-9_/\-\.]+?)(\s+)(?<vname>.+)"){
    docker volume rm $Matches.vname
  }
}