useradd -u 1000 -c "Steam Deck User" -s "/bin/bash" deck
usermod -p '' deck
usermod -a -G wheel deck
