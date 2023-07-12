# Mount the etc overlay for steamos atomic
#
# Mount the /etc overlay now (that is, in the initrd), which is needed for
# systemd to successfully commit a generated machine-id on the very first
# boot, and to find this existing machine-id on subsequent boots.
#
# Since the overlay is defined in `/etc/fstab`, one could try to add the
# option `x-initrd.mount`, and let things happen automatically, right?
#
# Well, no, for two reasons. One is that we need to make sure that the
# various directories used for the overlay (upper and work dir) exist,
# which is not the case for a first boot scenario.
#
# Another reason is that, even though systemd-fstab-generator is smart enough
# to prefix the mountpoints found in fstab with `/sysroot`, I don't think
# it's smart enough to do the same with the overlay options `upperdir=`,
# `workdir=` and so on.
#
# For these reasons, we do the job manually here.


setup_etc_overlay() {
    local lowerdir="$NEWROOT/etc"
    local upperdir="$NEWROOT/var/lib/overlays/etc/upper"
    local workdir="$NEWROOT/var/lib/overlays/etc/work"

    # upper dir contains persistent data, create it only if it doesn't exist
    @INFO@ "Preparing /etc overlay"
    if [ ! -d "$upperdir" ]; then
        @INFO@ "Creating overlay upper directory '$upperdir'"
        rm -fr "$upperdir"
        mkdir -p "$upperdir"
    fi

    # work dir must exist and be empty
    @INFO@ "Clearing overlay work directory $workdir"
    rm -fr "$workdir"
    mkdir -p "$workdir"

    # Mount the /etc overlay
    @INFO@ "Mounting overlay $upperdir on $lowerdir ($workdir)"
    mount -v \
        -t overlay \
        -o "lowerdir=$lowerdir,upperdir=$upperdir,workdir=$workdir" \
        overlay \
        "$lowerdir" 2>&1 | vinfo

    if ismounted "$lowerdir"; then
        return
    fi

    @WARN@ "Mounting $upperdir failed: Compile the kernel with CONFIG_OVERLAY_FS!"
    @WARN@ "*** Dropping you to a shell; the system will continue"
    @WARN@ "*** when you leave the shell."
    emergency_shell
}
