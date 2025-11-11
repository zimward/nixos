def genplay [start:int = 1] {
  ls -f | where name ends-with ".mkv" or  name ends-with ".avi" or name ends-with ".mp4" | skip ($start - 1) | get name | each {
      |it|
      $it | append "\n" | str join
    } | str join | save -f /tmp/playlist.m3u
    mpv --vo=gpu-next /tmp/playlist.m3u
}

def dlvid [url:string] {
  yt-dlp --merge-output-format mkv $url
}

def auto-chroot [path:string, executable:string] {
  if (ls $path |length) != 0 {
  sudo mount --rbind /dev $"($path)dev"
  sudo mount --make-rslave $"($path)dev"
  sudo mount --rbind /sys $"($path)sys"
  sudo mount --make-rslave $"($path)dev"
  sudo mount -t proc /proc $"($path)proc"
  sudo mount --rbind /tmp $"($path)tmp"
  sudo mount --bind /run $"($path)run"
  sudo chroot $"($path)" $"($executable)"
  } else {
      echo "Invalid path" 
  }
}
