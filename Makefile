DESTDIR ?=
PREFIX = /usr/share/initramfs-tools
BUILD_DIR = .build

.PHONY: all install uninstall update deb clean

all:

install:
	install -D -m 0755 hooks/overlay2 $(DESTDIR)$(PREFIX)/hooks/overlay2
	install -D -m 0755 scripts/init-top/parse-overlay2 $(DESTDIR)$(PREFIX)/scripts/init-top/parse-overlay2
	install -D -m 0644 scripts/overlay2 $(DESTDIR)$(PREFIX)/scripts/overlay2

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/hooks/overlay2
	rm -f $(DESTDIR)$(PREFIX)/scripts/init-top/parse-overlay2
	rm -f $(DESTDIR)$(PREFIX)/scripts/overlay2

	update-initramfs -u

update: install
	update-initramfs -u

deb:
	dpkg-buildpackage -us -uc -b
	mkdir -p $(BUILD_DIR)
	mv -f ../overlay2-initramfs_*.deb ../overlay2-initramfs_*.buildinfo ../overlay2-initramfs_*.changes $(BUILD_DIR)/

git:
	git add .
	git commit
	git push origin main

clean:
	rm -rf $(BUILD_DIR) debian/.debhelper debian/overlay2-initramfs debian/files debian/*.substvars debian/debhelper-build-stamp
