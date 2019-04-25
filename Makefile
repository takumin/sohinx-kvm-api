# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
AUTH_TOKEN   ?= unknown
DEPLOYDIR     = $(BUILDDIR)/deploy
DEPLOYUSER    = takumin
DEPLOYREPO    = sphinx-linux-kvm
DEPLOYBRANCH  = gh-pages
DEPLOYDATE   != date "+%Y/%m/%d %H:%M:%S"

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

livehtml:
	@sphinx-autobuild -b html $(ALLSPHINXOPTS) "$(SOURCEDIR)" "$(BUILDDIR)/html"

deploy:
	@if [ "$(AUTH_TOKEN)" = 'unknown' ]; then \
		echo 'Require AUTH_TOKEN Environment Variables'; \
		exit 1; \
	fi
	@if [ ! -d "$(DEPLOYDIR)" ]; then \
		git clone \
			--single-branch \
			-b "$(DEPLOYBRANCH)" \
			"https://$(DEPLOYUSER):$(AUTH_TOKEN)@github.com/$(DEPLOYUSER)/$(DEPLOYREPO).git" \
			"$(DEPLOYDIR)"; \
	fi
	@if [ -n "$(CIRRUS_CI)" ]; then \
		git -C "$(DEPLOYDIR)" config --local user.email "cirrus-ci@$(CIRRUS_BUILD_ID)"
		git -C "$(DEPLOYDIR)" config --local user.name "Cirrus CI"
	fi
	@git -C "$(DEPLOYDIR)" clean -xdf
	@git -C "$(DEPLOYDIR)" reset --hard HEAD
	@git -C "$(DEPLOYDIR)" fetch origin "$(DEPLOYBRANCH)"
	@git -C "$(DEPLOYDIR)" checkout "$(DEPLOYBRANCH)"
	@find "$(DEPLOYDIR)" -mindepth 1 -maxdepth 1 -type d -name '.git' -prune -o -type d -print0 | xargs -0 rm -rf
	@find "$(DEPLOYDIR)" -mindepth 1 -maxdepth 1 -type d -name '.git' -prune -o -type f -print0 | xargs -0 rm -rf
	@$(SPHINXBUILD) $(SPHINXOPTS) -d "$(BUILDDIR)/doctrees" "$(SOURCEDIR)" "$(DEPLOYDIR)"
	@git -C "$(DEPLOYDIR)" add -A
	@git -C "$(DEPLOYDIR)" commit -am "deploy $(DEPLOYDATE)"
	@git -C "$(DEPLOYDIR)" push origin "$(DEPLOYBRANCH)"
