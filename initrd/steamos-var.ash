mount_var() {
    @INFO@ "Mounting /dev/@udev_symlinks_reldir@/self/var"
    mount "/dev/@udev_symlinks_reldir@/self/var" "$NEWROOT/var" 2>&1 | vinfo
    if ismounted "$NEWROOT/var"; then
        return 0
    fi

    @WARN@ "Mounting /dev/@udev_symlinks_reldir@/self/var failed! Fallback using tmpfs!"
    mount -t tmpfs -o size=512m tmpfs "$NEWROOT/var" 2>&1 | vinfo
    if ismounted "$NEWROOT/var"; then
        return 0
    fi

    @WARN@ "Mounting /dev/@udev_symlinks_reldir@/self/var failed! Compile the kernel with CONFIG_TMPFS!"
    @WARN@ "*** Dropping you to a shell; the system will continue"
    @WARN@ "*** when you leave the shell."
    emergency_shell
}
