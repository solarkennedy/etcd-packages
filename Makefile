VERSION=0.3.0

wget: etcd-v$(VERSION)-Linux-amd64.tar.gz

etcd-v$(VERSION)-Linux-amd64.tar.gz:
	wget -c -O etcd-v$(VERSION)-Linux-amd64.tar.gz https://github.com/coreos/etcd/releases/download/v$(VERSION)/etcd-v$(VERSION)-Linux-amd64.tar.gz

etcd-v$(VERSION)-Linux-amd64/etcd: wget
	tar xzf etcd-v$(VERSION)-Linux-amd64.tar.gz

etcd_v$(VERSION)_amd64.deb: etcd-v$(VERSION)-Linux-amd64/etcd
	cd etcd-v$(VERSION)-linux-amd64/ && \
	fpm -s dir -t deb -v $(VERSION) -n etcd -a amd64 \
	--prefix=/usr/bin/ \
	--url "https://github.com/coreos/etcd" \
	--deb-user root --deb-group root \
	etcd etcdctl && \
	mv *.deb ..

deb: etcd_v$(VERSION)_amd64.deb

clean:
	rm -rf etcd*

.PHONY: deb
