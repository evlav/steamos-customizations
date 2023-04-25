downcase() {
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

steamos_generate_partsets() {
    local dev=$1

    @INFO@ "Mounting $dev on /mnt"

    mkdir -p /mnt
    mount -o ro "$dev" /mnt 2>&1 | vinfo
    if ! ismounted /mnt; then
        @WARN@ "Mounting $dev failed"
        emergency_shell
    fi

    for partset in /mnt/@partsets_reldir@/*; do
        [ -e "$partset" ] || continue
        @INFO@ "Generating udev rules from $partset"
        @libexecdir@/steamos/steamos-partsets-generator "$partset"
    done
    umount /mnt

    udevadm control --reload-rules
    udevadm trigger --settle
}

steamos_setup_partsets() {
    local efi_dev

    @INFO@ "Scanning for EFI partition"

    if [ -z "$1" ]; then
        @WARN@ "EFI partition not found"
        emergency_shell
    fi

    efi_dev=$(expand_dev "$1")

    @INFO@ "Waiting for $efi_dev"
    @WAIT_FOR_DEV@ "$efi_dev"

    steamos_generate_partsets "$efi_dev"
}
