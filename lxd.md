LXD segédlet
============

# Terminológia

- image: képfájl
- konténer: futó képfájl, egy image-ből több konténer is készíthető
- profile: konfiguráció egy konténerhez


# LXD/LXC

## Listázás

 - konténer:

    `lxc list`

 - helyi image:

     `lxc image list`

 - távoli (ezek ált. opredszerek):

     `lxc image list iamges:`

## Új konténer

 - képfájlból:

     `lxc launch <szerver>:<kép> <konténernév> [-p <profil>]`

 - másolva:

     `lxc copy <konténer> <új konténer>`

## Indítás/leállítás

`lxc start <konténer> 
lxc stop <konténer>`

## Futtatás konténerben

 - hagyományosan:

     `lxc exec <konténer> -- <parancs>`

 - konzol kérése:

     `lxc console <konténer>`

## Fájlok átvitele hosztra

 - fájlokhoz:

     `lxc file pull <konténer>/<hely> <hely a hoszton>`

 - mappákhoz:

     `lxc file pull -r <konténer>/<hely> <hely a hoszton>`

## Fájlok átvitele hosztról

 - fájlokhoz:

     `lxc file push <hely a hoszton> <konténer>/<hely>`

 - mappákhoz:

     `lxc file push -r <hely a hoszton> <konténer>/<hely>`

## Törlések

 - konténer:

     `lxc delete <konténer>`

 - image:

     `lxc image delete <image>`

## Profilok

 - lekérdezés:

     `lxc profile show <profil>`

 - létrehozás:

     `lxc profile create <profil>`

 - hozzárendelése konténerhez:

     `lxc profile add <konténer> <profil>`

 - lecsatolás konténerről:

     `lxc profile remobe <konténer> <profil>`

 - változtatás editorban:

     `lxc profile edit <profil>`

 - egy kulcs érték megváltoztatása:

     `lxc profile set <profil> <kulcs>=<érték>`

 - profil részei:
     - `config:` konfigurációs kulcs-érték párok, bővebben (itt)[https://linuxcontainers.org/lxd/docs/master/instances#keyvalue-configuration]
     - `description:` profil leírása (üres is lehet akár)
     - `devices:` a profilhoz kapcsolódó eszközök, bővebben (itt)[https://linuxcontainers.org/lxd/docs/master/instances#device-types]
     - `name:` a profil neve
     - `used_by:` mely konténerek használják a profilt, üresen kell hagyni

## Konténerek konfigurálása (profilok nélkül)

 - lekérdezés:

     `lxc config show <profile> -e`

 - változtatás editorban:

     `lxc config edit <konténer>`

 - egy kulcs érték megváltoztatása:

     `lxc config set <konténer> <kulcs>=<érték>`
