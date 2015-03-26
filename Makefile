# Makefile for creating well structured debian and ubuntu package
# https://github.com/jinnko/etcd-packages
# vim:set ts=4 sw=4 sts=4 noexpandtab

NAME=etcd
VERSION=2.0.5
TARBALL=$(NAME)-v$(VERSION)-Linux-amd64.tar.gz
TARDIR=$(NAME)-v$(VERSION)-linux-amd64
DOWNLOAD=https://github.com/coreos/etcd/releases/download/v$(VERSION)/$(TARBALL)
DESCRIPTION=A highly-available key value store for shared configuration and service discovery

# Invoke this script with the ITERATION env var already set to provide your own
ITERATION ?= custom1

.PHONY: default
default: deb
package: deb

$(TARBALL):
	wget -nv --show-progress -c -O $(TARBALL) $(DOWNLOAD)

$(TARDIR): $(TARBALL)
	tar xzf $(TARBALL)

filetree: $(TARDIR)
	mkdir -p ROOT/usr/sbin
	mkdir -p ROOT/usr/bin
	mkdir -p ROOT/usr/share/doc/etcd/Documentation/{platforms,rfc}
	mkdir -p ROOT/etc
	install -Cv $(TARDIR)/etcd $(TARDIR)/etcd-migrate ROOT/usr/sbin
	install -Cv $(TARDIR)/etcdctl ROOT/usr/bin
	install -Cv -m 0644 $(TARDIR)/README.md $(TARDIR)/README-etcdctl.md ROOT/usr/share/doc/etcd
	install -Cv -m 0644 $(TARDIR)/Documentation/*.md ROOT/usr/share/doc/etcd/Documentation
	install -Cv -m 0644 $(TARDIR)/Documentation/*.png ROOT/usr/share/doc/etcd/Documentation
	install -Cv -m 0644 $(TARDIR)/Documentation/platforms/* ROOT/usr/share/doc/etcd/Documentation/platforms
	install -Cv -m 0644 $(TARDIR)/Documentation/rfc/* ROOT/usr/share/doc/etcd/Documentation/rfc
	install -Cv -m 0640 conf/etcd.conf ROOT/etc

etcd_$(VERSION)_amd64.deb: filetree
	fpm -s dir -t deb -C ROOT \
		--name $(NAME) \
		--version $(VERSION) \
		--iteration $(ITERATION) \
		--architecture amd64 \
		--provides etcd \
		--deb-default conf/etcd_default.conf \
		--deb-init conf/etcd.init \
		--config-files /etc/etcd.conf \
		--directories /var/lib/etcd \
		--url "https://github.com/coreos/etcd" \
		--description "$(DESCRIPTION)" \
		--deb-user root --deb-group root \
		--post-install debian/postinst \
		--pre-uninstall debian/prerm \
		.

etcd_$(VERSION)_amd64.rpm: $(TARDIR)
	cd $(TARDIR)/ && \
	fpm -s dir -t rpm -v $(VERSION) -n $(NAME) -a amd64 \
		--prefix=/usr/bin \
		--description "$(DESCRIPTION)" \
		--url "https://github.com/coreos/etcd" \
		etcd etcdctl && \
	mv *.rpm ..

.PHONY: clean
clean:
	rm -rf etcd* ROOT

.PHONY: deb
deb: $(NAME)_$(VERSION)_amd64.deb

.PHONY: rpm
rpm: $(NAME)_$(VERSION)_amd64.rpm
