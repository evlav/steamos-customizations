# Perform a factory reset
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> X <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# NOTE: This is never a complete nuke-the-site-from-orbit reset
# a) we boot from /esp, so we can't really fix it as we
#    have nothing to fix it _from_
# b) likewise we don't reset the root fses as we haven't got a source
#    for a vanilla rootfs image
#
# The recovery tool/reset tool _does_ have vanilla data sources for those,
# so it is able to reset them.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> X <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

reset_device_ext4() {
    local device=$1
    local label=$2
    local casefold=$3
    local noreserved=$4

    # not considering it an error if a device we were meant to wipe does not exist
    if ! [ -b "$device" ]; then
        return 0
    fi

    [ "$casefold" -eq 1 ] && fmt_case="-O casefold"
    [ "$noreserved" -eq 1 ] && fmt_nores="-m 0"

    @INFO@ "Making ext4 filesystem on device $device"
    @INFO@ "Options: with casefold: $casefold, w/o res blocks: $noreserved"
    # shellcheck disable=SC2086 # do not quote these optional arguments
    mkfs.ext4 -qF -L "$label" $fmt_case $fmt_nores "$device"
}

do_reset() {
    local wait_pids

    @INFO@ "A factory reset has been requested."

    # Make sure we bail out if the reset fails at any stage
    # we do this to make sure the reset will be re-attempted
    # or resumed if it does not complete here (possibly because
    # the user got bored and leaned on the power button)

    # There is a small chance of a reset loop occurring if the reset cannot
    # complete for fundamental reasons (unable to format filesystem and so
    # forth) BUT
    #
    # a) the device is probably hosed anyway if this happens
    #
    # b) we care more (for now) about doing a genuine reset to stop
    #    leaking private data / things worth actual €£$¥ to the next owner
    #    than we do about [hopefully] unlikely reset loops

    # We want to reset each filesystem in parallel _but_ we must wait for
    # them to finish as we have to release all fds before the pivot to the
    # real sysroot happens:
    # NOTE: the rootfs would need to be reset _before_ the EFI fs if we were
    # handling it, as its fs uuid must be known for the EFI reset - but since
    # we're not touching it everything is parallelisable:

    for cfg in "@factory_reset_config_dir@"/*.cfg; do
        [ -r "$cfg" ] || continue

        # shellcheck disable=SC2094 # yes, the read/rm is perfectly safe
        while read -r type instance dev casefold noreserved; do
            @INFO@ "Processing manifest file $cfg (async)"
            name="${instance##*/}"
            case $type in
                EFI)
                    @INFO@ "Reset of efi partition ($instance, $dev) is obsolete, ignoring"
                    rm -f "$cfg"
                    ;;
                VAR|HOME)
                    # these are slow so we want them done in parallel and async
                    # BUT we need to wait until they're all done before proceeding
                    @INFO@ "Formatting data partition $dev ($instance)"
                    (
                        if reset_device_ext4 "$dev" "$name" "$casefold" "$noreserved"; then
                            rm -f "$cfg"
                            @INFO@ "Reset of $dev ($instance) complete"
                        else
                            @WARN@ "Reset of $dev ($instance) failed, factory reset incomplete"
                        fi
                    ) &
                    wait_pids="$wait_pids $!"
                    ;;
                *)
                    @WARN@ "Unexpected SteamOS reset type $type ($instance, $dev)"
                    rm -f "$cfg"
                    ;;
            esac
        done < "$cfg"
    done

    if [ -n "$wait_pids" ]; then
        @INFO@ "Waiting for $wait_pids"
        # shellcheck disable=SC2086 # a space separated list
        wait $wait_pids
        @INFO@ "Formatting complete"
    fi
}

factory_reset() {
    local want_reset=0
    local cleanup_esp=0

    ########################################################################
    # mount /esp if it isn't mounted, the reset config is located in there
    if [ ! -d /esp/efi ]; then
        local dev="@udev_symlinks_absdir@/all/esp"
        @INFO@ "Checking ESP partition $dev"
        if ! ismounted "$dev"; then
            @INFO@ "Mounting $dev at /esp"
            mkdir -p /esp
            mount "$dev" /esp
            cleanup_esp=1
        fi
    fi

    ########################################################################
    # if reset config exists, we want a reset:
    if [ -d "@factory_reset_config_dir@" ]; then
        for cfg in "@factory_reset_config_dir@"/*.cfg; do
            [ -r "$cfg" ] || continue

            @INFO@ "Factory reset request found in @factory_reset_config_dir@"
            want_reset=1
            break
        done
    fi

    ########################################################################
    # if we don't already have a reset config then check to see if
    # the bootloader asked us to generate one:
    if [ "$want_reset" -eq 0 ]; then
        want_reset=$1
        if [ "$want_reset" -ne 0 ]; then
            steamos-factory-reset-config
        fi
    fi

    ########################################################################
    # perform the actual reset operations
    if [ "$want_reset" -eq 1 ]; then
        do_reset
    fi

    ########################################################################
    # unmount /esp if we mounted it
    if [ "$cleanup_esp" -eq 1 ]; then
        @INFO@ "Unmounting /esp"
        umount /esp
    fi
}
