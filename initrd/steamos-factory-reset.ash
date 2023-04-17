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

FACTORY_RESET_CONFIG_DIR=@factory_reset_config_dir@

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
        INITRD_FACTORY_RESET=1
        export INITRD_FACTORY_RESET
        @INFO@ "Calling @libexecdir@/steamos/steamos-initrd-do-reset"
        @libexecdir@/steamos/steamos-initrd-do-reset | \
            while read sidr; do @INFO@ "$sidr"; done
    fi

    ########################################################################
    # unmount /esp if we mounted it
    if [ "$cleanup_esp" -eq 1 ]; then
        @INFO@ "Unmounting /esp"
        umount /esp
    fi

    return 0
}
