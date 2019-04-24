# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
DEPLOYURI     = git@github.com:takumin/sphinx-linux-kvm.git
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

$(BUILDDIR)/deploy:
	@git clone -b "$(DEPLOYBRANCH)" "$(DEPLOYURI)" "$(BUILDDIR)/deploy"

deploy: $(BUILDDIR)/deploy
	@$(SPHINXBUILD) $(SPHINXOPTS) "$(SOURCEDIR)" "$(BUILDDIR)/deploy"
	@git -C "$(BUILDDIR)/deploy" add -A
	@git -C "$(BUILDDIR)/deploy" commit -am "deploy $(DEPLOYDATE)"
	@git -C "$(BUILDDIR)/deploy" push
