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

declare -r FACTORY_RESET_CONFIG_DIR=@factory_reset_config_dir@

reset_device_ext4() {
    local device=$1
    local label=$2
    local fs_opts=(${@:3})
    local opts=(-qF)
    local features=
    local tmp=
    local mt_point=
    local mt_opts=

    # not considering it an error if a device we were meant to wipe does not exist
    if ! [ -b "$device" ]; then
        return 0
    fi

    # can't have the device mounted while we reformat it
    # but we do want to save the mount opts if it is mounted
    local proc_dev proc_mnt proc_fs proc_opts proc_etc

    while read -r proc_dev proc_mnt proc_fs proc_opts proc_etc; do
        if [ "$device" != "$proc_dev" ]; then
            continue
        fi
        mt_point="$proc_mnt"
        mt_opts="$proc_opts"
        @WARN@ "Unmounting $device from $mt_point ($mt_opts)"
        umount -v "$device"
    done < /proc/mounts

    # try harder if it's still mounted
    if ismounted "$device"; then
        umount -v -f "$device"
    fi

    if ismounted "$device"; then
        @WARN@ "Could not unmount $device from $mt_point"
        return 1
    fi

    opts+=(-L "$label")
    if [ "$label" = "home" ]; then
        opts+=(-m 0)
    fi

    # use cached opts from FACTORY_RESET_CONFIG_DIR, alternatively read them
    # from the filesystem
    if [ ${#fs_opts[@]} -eq 0 ]; then
        read -r -a fs_opts < <(tune2fs -l "$device" | sed -n 's/^Filesystem features:\s*//p')
    fi

    # copy the important fs opts explicitly (currently just casefold):
    for tmp in "${features[@]}"; do
        if [ "$tmp" = "casefold" ]; then
            opts+=(-O casefold)
            break
        fi
    done

    @INFO@ "Making ext4 filesystem on device $device (options: ${opts[*]})"
    mkfs.ext4 "${opts[@]}" "$device"
    if [ -n "$mt_point" ]; then
        @WARN@ "Remounting fresh fs on $device at $mt_point ($mt_opts)"
        mount ${mt_opts:+-o} $mt_opts "$device" "$mt_point"
    fi
}

do_reset() {
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
    declare -a WAIT_PIDS=()
    declare -A RESET_DEV
    for cfg in $FACTORY_RESET_CONFIG_DIR/*.cfg; do
        [ -r $cfg ] || continue

        while read type instance dev opts; do
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
                    (reset_device_ext4 $dev "$name" "$opts" && rm -f "$cfg") &
                    RESET_PID=$!
                    WAIT_PIDS+=($RESET_PID)
                    RESET_DEV[$RESET_PID]="$dev $name"
                    ;;
                *)
                    @WARN@ "Unexpected SteamOS reset type $type ($instance, $dev)"
                    rm -f "$cfg"
                    ;;
            esac
        done < $cfg
    done

    while true; do
        wait -f -p WAITED_FOR -n
        rc=$?
        if [ $rc -eq 127 ]; then
            # nothing left to wait for.
            break;
        elif [ $rc -ne 0 ]; then
            @WARN@ "Reset of ${RESET_DEV[$WAITED_FOR]} failed, factory reset incomplete"
        else
            @INFO@ "Reset of ${RESET_DEV[$WAITED_FOR]} complete"
        fi
    done

    return 0
}

factory_reset() {
    local want_reset=0
    local cleanup_esp=0

    ########################################################################
    # mount /esp if it isn't mounted
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
    if [ -d $FACTORY_RESET_CONFIG_DIR ]; then
        for cfg in $FACTORY_RESET_CONFIG_DIR/*.cfg; do
            if [ -e "$cfg" ]; then
                @INFO@ "Factory reset request found in $FACTORY_RESET_CONFIG_DIR"
                want_reset=1
                break
            fi
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
    # partitions belonging to a dev slot don't get scrubbed, ever.
    # (production deck images should never have a dev slot out of the box):
    for cfg in $FACTORY_RESET_CONFIG_DIR/*.cfg; do
        case $cfg in
            */*-dev.cfg)
                @WARN@ "Ignoring reset for development partition $cfg"
                rm -v $cfg
                ;;
        esac
    done

    ########################################################################
    # do the actual reset (would be painful to get piping and async etc done
    # under ash so invoke a cut down copy of the old dracut script instead:
    if [ "$want_reset" -eq 1 ]; then
        do_reset
    fi

    ########################################################################
    # unmount /esp if we mounted it
    if [ "$cleanup_esp" -eq 1 ]; then
        @INFO@ "Unmounting /esp"
        umount /esp
    fi

    return 0
}
