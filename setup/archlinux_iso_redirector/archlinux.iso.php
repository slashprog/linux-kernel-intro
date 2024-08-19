<?php
  $arch_release_regex = '/(?<=<a href="https:\/\/mirror\.rackspace\.com\/archlinux\/iso\/).+?(?=\/")/';
  $contents = file_get_contents("https://archlinux.org/download/");
  if (preg_match($arch_release_regex, $contents, $matches)) {
    #print_r($matches);
    $release = $matches[0];
    # echo $release;
    $arch_iso_mirror = "https://mirror.rackspace.com/archlinux/iso/$release/archlinux-$release-x86_64.iso";
    header("Location: $arch_iso_mirror");
    echo $arch_iso_mirror;
    
  } else {
    echo "Sorry! Failed to locate ArchLinux release information. Seems like the web-page layout has changed causing failure of regex based pattern search.";
  }
?>
