doc:
	doxygen

clean:
	rm -rf html

upload:
	cd html ; \
	scp -pr * $(USER)@hangul.kldp.net:/var/lib/gforge/chroot/home/groups/hangul/htdocs
