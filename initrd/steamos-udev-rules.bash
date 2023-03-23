# Create udev rules for steamos partitions

expand_dev() {
    local dev

    case "$1" in
    LABEL=*)
        dev="/dev/disk/by-label/${1#LABEL=}"
        ;;
    UUID=*)
        dev="${1#UUID=}"
        dev="/dev/disk/by-uuid/${dev,,}"
        ;;
    PARTUUID=*)
        dev="${1#PARTUUID=}"
        dev="/dev/disk/by-partuuid/${dev,,}"
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

# Main

@INFO@ "Setting up SteamOS udev rules"

EFI=$(getarg 'rd.steamos.efi=')
if [ -z "$EFI" ]; then
    EFI=$(getarg 'steamos.efi=')
fi
if [ -z "$EFI" ]; then
    @WARN@ "No second loader found!"
    @WARN@ "Creates the by-partsets symlinks manually and exit."
    @WARN@ "*** Dropping you to a shell; the system will continue"
    @WARN@ "*** when you leave the shell."
    emergency_shell
fi

efidev="$(expand_dev "$EFI")"

@INFO@ "Waiting for device ${efidev}"
@WAIT_FOR_DEV@ "${efidev}"

@INFO@ "Mounting ${EFI##*=} with -o ro"
mount -o ro "${efidev}" /mnt 2>&1 | vinfo

trap "if ismounted /mnt; then umount /mnt; fi" 0
if ! ismounted /mnt; then
    @WARN@ "Mounting $efidev failed!"
    @WARN@ "*** Dropping you to a shell; the system will continue"
    @WARN@ "*** when you leave the shell."
    emergency_shell
fi

for partset in /mnt/@partsets_reldir@/*; do
    [ -e "$partset" ] || continue
    @libexecdir@/steamos/steamos-partsets-generator "$partset"
done

udevadm control --reload-rules && udevadm trigger --settle
