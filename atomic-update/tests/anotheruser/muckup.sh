# Add a second user so we can test ensure script doesn't remove it
#
# Use -M to not create user's home dir since we don't care if it really exists
useradd -d '/home/anotheruser' -M -s '/bin/bash' -c 'Not Deck' -p '$y$j9T$njojwB7rUw6K6qKcJaS3k1$KO8Iow/n1V.6glG28Qx9mIEjha73.MDH99FMwSa0aX3' anotheruser
