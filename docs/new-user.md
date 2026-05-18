apk update
(doas already exists, dont need to apk add doas)
- but you do if you did the alpine minimal script

go to /etc/doas.d/wheel.conf
    - and change `nopass` to `persist`

`adduser <username>`

`addgroup <username> wheel`

switch user - `doas -su <username>`
    - enter current user password

chown root:root /etc/doas.conf
chmod 644 /etc/doas.conf

# Do the same for your doas.d directory if you are using it
chown -R root:root /etc/doas.d
chmod 755 /etc/doas.d
chmod 644 /etc/doas.d/*