SteamOS Customizations
======================

You everyday commands:

    # build it all
    make DESTDIR=tmp install
 
    # have a look at the result
    tree tmp

Expected Make variables (for packagers):
- `DESTDIR`: Staging installation directory.
- `NVIDIA_MODULE_NAME`: the name of the nvidia module (eg. `nvidia` for
  ArchLinux style distributions, `nvidia-current` for Debian style
  distributions).



Structure
---------

Every directory is more or less like a lightweight package. It comes with its
own `Makefile` and its own `.gitignore` file.

Everything that doesn't really belong to a particular feature, or is too small
to deserve its own sub-directory, ends up in the directory `misc`.



Background
----------

This package was created by merging two git repositories:
- steamos-packages
- steamos-partitions

All the git history was lost in the process. So if you're after some details,
you might want to refert to the git logs of those git repos.

