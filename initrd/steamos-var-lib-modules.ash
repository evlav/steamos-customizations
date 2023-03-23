# Initialize /var in case of first boot
#
# /var is empty on first boot or after a factory reset. A 'usual' way of
# initializing is to use systemd-tmpfiles, and indeed it's how it's done.
# However it doesn't run early enough to initialize /var/lib/modules in time.
#
# For the record, SteamOS has a custom layout for kernel modules things,
# due to the requirement to have DKMS working with a read-only rootfs,
# so we end up having kernel module things in /var rather than /usr.
# The kernel modules must be available super early at boot, earlier than
# what systemd-tmpfiles provides out of the box.
#
# So systemd-tmpfiles won't work for us. I thought about using it from the
# initrd instead, and using the `--root=/sysroot` option, but that doesn't
# really work either, see <https://github.com/systemd/systemd/issues/12467>.
#
# So, let's do the job manually here.

initialize_var_lib_modules() {

    # Create /var/lib/modules from factory

    local moddir="var/lib/modules"
    local orig="$NEWROOT@datadir@/factory/$moddir"
    local dest="$NEWROOT/$moddir"

    @INFO@ "Checking modules source and destination ($orig; $dest)"
    [ -e "$dest" ] && return 0
    [ -d "$orig" ] || return 0

    @INFO@ "Creating module directory '$dest'"
    mkdir -p "$(dirname "$dest")"

    # purge any half copied content or leftovers
    rm -rf "$dest".new

    @INFO@ "Copying $orig to $dest.new"
    if cp -a "$orig" "$dest.new"; then
        @INFO@ "Copy successful, installing to $dest"
        mv "$dest.new" "$dest"
        return 0
    fi

    @WARN@ "Could not install kernel modules to $dest, system may need rescue"
    return 1
}
