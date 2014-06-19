COMPILE_FLAGS=-g -Wall -Werror -pthread -c -I/usr/include/libxml2
#COMPILE_FLAGS=-g -O2 -Wall -Werror -pthread -c -I/usr/include/libxml2
LINK_FLAGS=-ldl -lm -lmp3lame -logg -lpthread -lpython2.7 -lshout -lutil -lvorbis -lvorbisfile -lxml2
VERSION = 0.4.1-0umonkey2

build: ices man

install: build
	sudo install ices /usr/local/bin/ices
	sudo install doc/ices.1 /usr/share/man/man1/ices.1

package-ubuntu: build
	rm -rf packages/debian/usr
	mkdir -p packages/debian/usr/bin
	cp ices packages/debian/usr/bin/
	mkdir -p packages/debian/usr/share/man/man1
	cp doc/ices.1 packages/debian/usr/share/man/man1/
	gzip -9 packages/debian/usr/share/man/man1/ices.1
	mkdir -p packages/debian/usr/share/doc/ices/examples
	cp doc/ices.conf packages/debian/usr/share/doc/ices/examples/
	mkdir -p packages/debian/usr/share/doc/ices/html
	cp doc/icesmanual.html packages/debian/usr/share/doc/ices/html/
	cp debian/README.Debian packages/debian/usr/share/doc/ices/
	cp debian/changelog packages/debian/usr/share/doc/ices/changelog.Debian
	gzip -9 packages/debian/usr/share/doc/ices/changelog.Debian
	cp debian/copyright packages/debian/usr/share/doc/ices/
	fakeroot dpkg -b packages/debian ices_$(VERSION)-`uname -m`.deb

clean:
	rm -rf ices src/*.o src/*/*.o *.deb packages/debian/usr

ices: src/crossfade.o src/cue.o src/ices.o src/ices_config.o src/id3.o src/in_flac.o src/in_mp4.o src/in_vorbis.o src/log.o src/metadata.o src/mp3.o src/playlist/playlist.o src/playlist/pm_builtin.o src/playlist/pm_perl.o src/playlist/pm_python.o src/playlist/rand.o src/reencode.o src/replaygain.o src/setup.o src/signals.o src/stream.o src/util.o
	gcc -o $@ $^ ${LINK_FLAGS}

man:
	make -C doc -f Makefile.am srcdir=.

src/definitions.h: src/cue.h src/ices_config.h src/icestypes.h src/id3.h src/log.h src/mp3.h src/reencode.h src/setup.h src/signals.h src/stream.h src/util.h
src/cue.c: src/metadata.h
src/id3.c: src/metadata.h src/replaygain.h
src/in_flac.c: src/in_flac.h src/metadata.h src/replaygain.h
src/in_mp4.c: src/in_mp4.h src/metadata.h
src/in_vorbis.c: src/in_vorbis.h src/metadata.h src/replaygain.h
src/replaygain.c: src/replaygain.h
src/setup.c: src/metadata.h
src/stream.c: src/id3.h src/in_mp4.h src/in_vorbis.h src/metadata.h src/replaygain.h

%.o: %.c src/definitions.h
	gcc -o $@ ${COMPILE_FLAGS} $<

ubuntu-depends:
	sudo apt-get -y install build-essential fakeroot libshout3-dev python-dev libmp3lame-dev libxml2-dev debhelper
