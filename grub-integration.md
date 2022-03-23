Grub Integration
================

SteamOS uses grub as its stage 2 bootloader (the details of the entire
boot process are documented elsewhere - see the final section of this
file).

Here we will document how we use grub in SteamOS and where the configuration
and so forth for grub is driven from.

Components
---------------

Note that these scripts also do other things. We are concerned here only
with how they interact with grub:

 * misc/bin/steamos-clone
   * clone a SteamOS partset to another disk
   * steamos-chroot :: grub/libexec/steamos-grub-mkimage (as grub-mkimage)
   * steamos-chroot :: grub/bin/update-grub
   
 * misc/bin/steamos-finalize-install
   * different mode (obsolete?) if /boot is a mount point
   * grub/libexec/steamos-grub-mkimage (as grub-mkimage)
   * grub/bin/update-grub
   
 * grub/systemd/steamos-install-grub.service
   * If either grub.cfg or grubx64.efi are missing from /efi
     * grub/libexec/steamos-grub-install (invoked as as /usr/bin/grub-install)
     * grub/bin/update-grub

 * grub/bin/update-grub
   * EXTERNAL DEPENDENCY /usr/share/grub/grub-mkconfig_lib
   * grub-mkconfig
     * write to /boot if /boot is rw
       * prepare\_grub\_to\_access\_device → stub grub config on /efi
     * write to /efi  if /boot is ro

 * grub/libexec/steamos-grub-mkearlyconfig
   * create a stub config for the default location to point to the real config

 * grub/libexec/steamos-grub-install
   * EXTERNAL DEPENDENCY /usr/lib/grub-install
     * targets /efi
     * omits the nvram bootloader variable
     * uses steamos-grub-mkimage as grub-mkimage

 * grub/libexec/steamos-grub-mkimage
   * calls steamos-grub-mkearlyconfig
   * EXTERNAL DEPENDENCY /usr/lib/grub-mkimage
   * writes grub image to /efi by default

