current=`pwd`
reprepro=$current/reprepro
cd apt
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb bookworm $current/deb/bookworm/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb trixie $current/deb/trixie/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb forky $current/deb/forky/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb sid $current/deb/sid/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb jammy $current/deb/jammy/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb noble $current/deb/noble/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb questing $current/deb/questing/*deb
reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedeb resolute $current/deb/resolute/*deb

for DIST in bookworm trixie forky sid jammy noble questing resolute; do
    DSC_FILES=$(ls $current/src/*~${DIST}.dsc 2>/dev/null)
    if [ -n "$DSC_FILES" ]; then
        for DSC in $DSC_FILES; do
            reprepro --dbdir $reprepro/db --confdir $reprepro/conf -C main includedsc $DIST $DSC
        done
    fi
done

cd dists/bookworm
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/forky
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/trixie
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/sid
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/jammy
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/noble
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/questing
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd dists/resolute
cat Release | gpg -s --default-key EA0F721D231FDD3A0A17B9AC7808B4DD62C41256 -abs > Release.gpg
cd -
cd $current
