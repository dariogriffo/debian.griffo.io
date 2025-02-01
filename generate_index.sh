current=`pwd`
reprepro=$current/reprepro
cd apt
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb bookworm $current/deb/bookworm/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb trixie $current/deb/trixie/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb sid $current/deb/sid/*deb
cd dists/bookworm
cat Release | gpg -s --default-key 3B9335DF576D3D58059C6AA50B56A1A69762E9FF -abs > Release.gpg
cd -
cd dists/trixie
cat Release | gpg -s --default-key 3B9335DF576D3D58059C6AA50B56A1A69762E9FF -abs > Release.gpg
cd -
cd dists/sid
cat Release | gpg -s --default-key 3B9335DF576D3D58059C6AA50B56A1A69762E9FF -abs > Release.gpg
cd -
cd ..


