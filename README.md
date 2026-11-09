# overlay2-initramfs

`overlay2-initramfs` — сценарий для Debian `initramfs-tools`, который монтирует live-систему с корнем на OverlayFS. Нижний слой берётся из файла образа, смонтированного только для чтения; верхний слой используется для сохранения изменений.

Поддерживаются режимы хранения изменений в RAM (`tmpfs`), на отдельном разделе (`storage`) или в loop-файле (`loop`). Для persistence доступны тома LUKS, включая вынесенные, а так-же зашифрованные (в `aes-256-ctr`) заголовки.

## Параметры загрузки

Параметры передаются через командную строку ядра. Сценарий включается только при наличии `boot=overlay2`. UUID устройств можно узнать командой `blkid`.

| Параметр | Описание |
| --- | --- |
| `boot=overlay2` | Включает сценарий загрузки. |
| `storage-uuid=` | UUID носителя с образом системы. |
| `overlay-loop=` | Путь к файлу образа относительно основного носителя. Поддерживаются `squashfs`, `btrfs` и `iso9660`. |
| `persistence-src=` | Режим writable-слоя: `ram`, `storage` или `loop`. |
| `persistence-ram-size=` | Размер tmpfs для режима `ram`; значение по умолчанию — `50%`. |
| `persistence-storage-uuid=` | UUID раздела для режима `storage`. |
| `persistence-loop=` | Путь к loop-файлу persistence относительно основного носителя. |
| `persistence-storage-path=` | Каталог на persistence-носителе для директорий `rw` и `work`. |
| `tmp-storage-uuid=` | UUID дополнительного носителя с ключом и/или вынесенным заголовком LUKS. |
| `persistence-header=` | Имя файла вынесенного заголовка на дополнительном носителе. |
| `persistence-key-file=` | Имя файла ключа LUKS на дополнительном носителе. |
| `ssl-keys-file=` | Имя файла с OpenSSL-ключом и IV для обработки заголовка. |

Пример параметров для режима RAM:

```text
boot=overlay2 storage-uuid=1234-5678 overlay-loop=debian.squashfs persistence-src=ram persistence-ram-size=50%
```

Для `storage` и `loop` требуется настроить соответствующий носитель или файл persistence. При использовании LUKS доступны следующие режимы:
| Сценарий | параметры загрузки (пример) | Описание |
| --- | --- | --- |
| Обычный режим с вводом пароля | `persistene-loop=persistence.luks` | Параметр `persistence-loop` указывает на файл-образ |
| Обычный режим с поддержкой ключей | `persistene-loop=persistence.luks`, `persistene-key-file=kyes.luks`, `tmp-storage-uuid=1234-5678`. | Параметр `tmp-storage-uuid` нужен для указания доверенного носителя с ключом шифрования |
| Режим отдельного заголовка | `persistene-loop=persistence.luks`, `persistene-key-file=kyes.luks`, `tmp-storage-uuid=1234-5678`, `persistence-header=header_file` | Ключ шифрования (см. выше) как и заголовк лежат на доверенном носителе |
| Режим отдельного заголовка, зашифрованного в *aes-256-ctr* | `persistene-loop=persistence.luks`, `persistene-key-file=kyes.luks`, `tmp-storage-uuid=1234-5678`, `persistence-header=header_file`, `ssl-keys-file=ssl.txt` | Файл с ключами SSL так-же хранится на доверенном носителе |

## Точки останова
| Название | Описание |
| --- | --- |
| `persistence-ram` | После монтирования persistence в RAM |
| `persistence-storage` | После монтирования persistence раздела |
| `persistence-loop` | После монтирования persistence файла |
| `do-storage` | До монтирования основного устройства |
| `after-storage` | После монтирования основного устройства |
| `do-overlay` | До монтирования OverlayFS |
| `after-overlay` | После монтирования основного устройства |

## Требования и зависимости

### Исполняемые файлы
> `openssl`, `cryptsetup`, `askpass`

### Модули
> `overlay`, `loop`, `dm-mod`, `dm-crypt`, `af_alg`, `algif_skcipher`, `algif_hash`, `crypto_user`, `aes_generic`, `aesni-intel`, `xts`, `sha256`, `sha512`, `squashfs`, `ext2`, `ext3`, `ext4`, `f2fs`, `vfat`, `exfat`, `ntfs3`, `xfs`, `jffs2`, `nls_cp437`, `nls_ascii`, `nls_utf8`, `nls_cp866`

## Сборка и установка

### Сборка Debian-пакета

На Debian/Ubuntu установите инструменты сборки и выполните:

```bash
sudo apt update
sudo apt install initramfs-tools build-essential debhelper dpkg-dev
make deb
```

Пакет `.deb` и сопутствующие файлы сборки будут помещены в `.build/`.

Установить готовый пакет:

```bash
sudo apt install ./overlay2-initramfs_*.deb
```

После установки пакет обновляет initramfs, если доступна команда `update-initramfs`.

### Ручная установка

Из корня репозитория выполните:

```bash
sudo make update
```

Команда устанавливает файлы сценария в `initramfs-tools` и обновляет initramfs.

## Состав проекта

- `scripts/init-top/parse-overlay2` — читает параметры загрузки из `/proc/cmdline`.
- `scripts/overlay2` — монтирует образ и настраивает persistence и OverlayFS.
- `hooks/overlay2` — добавляет необходимые утилиты и модули в initramfs.
- `debian/` — метаданные и сценарии Debian-пакета.
- `Makefile` — ручная установка, удаление, обновление initramfs и сборка пакета.

Лицензия: GPL-3.0-or-later (см. `debian/copyright`).