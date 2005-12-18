# ###########################################################################
# Makefile: make the binary and the source package
# ###########################################################################
# Copyright (C) Felix KŸhne, 2005
# $Id$
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
# ###########################################################################

PD_VERSION = 1.0b1

all:
	@echo "--> As you want, please stand by..."
	@echo "--> Compiling all projects..."
	@echo ""
	@$(MAKE) PhotoDwarf

PhotoDwarf:
	@echo "--> Compiling PhotoDwarf..."
	@echo ""
	@xcodebuild -project PhotoDwarf.xcodeproj -configuration Deployment

clean:
	@echo "--> Cleaning all targets of all projects..."
	@echo ""
	@xcodebuild clean

dist:
	@echo "--> Packaging all projects..."
	@echo ""
	@$(MAKE) PhotoDwarf-dist-src
	@$(MAKE) PhotoDwarf-dist-bin

PhotoDwarf-dist-src:
	@echo "--> Packaging PhotoDwarf's source..."
	@echo ""
	@if test -d tmp; then \
		@echo "Error: please remove ./tmp, it is in the way" ; \
		exit 1 ; \
	fi
	mkdir tmp
	tar cf - COPYING English.lproj German.lproj Info.plist \
		MainController.* Makefile PhotoDwarf.xcodeproj/project.pbxproj \
		PolVersionInfo.bkp README SPADropImageView.* main.m extras \
		| (cd tmp; tar xf -)
	(cd tmp; tar cf - .) | bzip2 -c > PhotoDwarf-$(PD_VERSION).src.tar.bz2
	rm -rf tmp

PhotoDwarf-dist-bin:
	@echo "--> Packaging the current PhotoDwarf binary plus some docs..."
	@echo ""
	@if test -e "tmp"; then \
	  @echo "Error: please remove ./tmp, it is in the way"; \
	  false; \
	else \
	  @echo "OK."; mkdir -p "tmp"; \
	fi
	cp -R "build/Deployment/PhotoDwarf.app" "tmp/PhotoDwarf.app"
	cp README COPYING tmp/
	extras/macosx-dmg "PhotoDwarf-${PD_VERSION}" tmp
	rm -Rf tmp
