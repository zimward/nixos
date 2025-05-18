def genplay [start:int = 1] {
  ls -f | where name ends-with ".mkv" or  name ends-with ".avi" or name ends-with ".mp4" | skip ($start - 1) | get name | each {
      |it|
      $it | append "\n" | str join
    } | str join | save -f /tmp/playlist.m3u
    mpv /tmp/playlist.m3u
}

def dlvid [url:string] {
  yt-dlp --merge-output-format mkv $url
}

def auto-chroot [path:string, executable:string] {
  if (ls $path |length) != 0 {
  doas mount --rbind /dev $"($path)dev"
  doas mount --make-rslave $"($path)dev"
  doas mount --rbind /sys $"($path)sys"
  doas mount --make-rslave $"($path)dev"
  doas mount -t proc /proc $"($path)proc"
  doas mount --rbind /tmp $"($path)tmp"
  doas mount --bind /run $"($path)run"
  doas chroot $"($path)" $"($executable)"
  } else {
      echo "Invalid path" 
  }
}
