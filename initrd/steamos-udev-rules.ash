downcase () {
    echo -n "$@" | tr '[:upper:]' '[:lower:]'
}

expand_dev() {
    local dev

    case "$1" in
    LABEL=*)
        dev="/dev/disk/by-label/${1#LABEL=}"
        ;;
    UUID=*)
        dev="${1#UUID=}"
        dev="/dev/disk/by-uuid/$(downcase "$dev")"
        ;;
    PARTUUID=*)
        dev="${1#PARTUUID=}"
        dev="/dev/disk/by-partuuid/$(downcase "$dev")"
        ;;
    PARTLABEL=*)
        dev="/dev/disk/by-partlabel/${1#PARTLABEL=}"
        ;;
    *)
        dev="$1"
        ;;
    esac

    echo "$dev"
}

udev_rules() {
    local partset="${1##*/}"

    # ignore the "other" partitions, so they don't know up in dolphin
    local udisks
    [ "$partset" = "other" ] && udisks=1 || udisks=0

    while read -r name partuuid; do
        cat <<EOF
ENV{ID_PART_ENTRY_SCHEME}=="gpt", ENV{ID_PART_ENTRY_UUID}=="$partuuid", SYMLINK+="@udev_symlinks_reldir@/$partset/$name", ENV{UDISKS_IGNORE}="$udisks"
EOF
    done < "$1"
}

steamos_generate_partsets () {
    local dev=$1

    @INFO@ "Mounting $dev on /mnt"

    mkdir -p /mnt
    trap "if ismounted /mnt; then umount /mnt; fi" 0

    mount -o ro "$dev" /mnt 2>&1 | vinfo
    if ! ismounted /mnt; then
        @WARN@ "Mounting $dev failed"
        return 1
    fi

    mkdir -p /run/udev/rules.d
    for partset in /mnt/@partsets_reldir@/*; do
        [ -e "$partset" ] || continue
        @INFO@ "Generating udev rules from $partset"

        # must be after 60-persistent-storage.rules
        udev_rules "$partset" > "/run/udev/rules.d/90-steamos-partsets-${partset##*/}.rules"
    done
    umount /mnt

    # These must be separate for mkinitcpio or you will likely get a deadlock
    # This does not affect dracut initrds. We do not know why.
    udevadm control --reload-rules
    udevadm trigger
    udevadm settle
}

steamos_setup_partsets() {
    local efi_dev

    @INFO@ "Scanning for EFI partition"

    if [ -z "$1" ]; then
        @WARN@ "EFI partition not found"
        return 1
    fi

    efi_dev=$(expand_dev "$1")

    @INFO@ "Waiting for $efi_dev"
    @WAIT_FOR_DEV@ "$efi_dev"

    steamos_generate_partsets "$efi_dev"
}
