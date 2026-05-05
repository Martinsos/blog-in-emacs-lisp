SHELL := /bin/bash

.PHONY: build-inc build-clean serve publish
.DEFAULT_GOAL := build-inc

# Incremental build: changed/new files in src/ will be updated/added in dist/, but none deleted.
# Fast and practical for development, but contents in dist/ might not be 100% correct after some
# time due to deleted files being left around and possible drift from the file timestamps cache.
# Implementation details:
#   Relies on org-publish's file timestamp cache to know which files to generate and which to skip,
#   while assuming that no external actors are changing contents of dist/.
build-inc:
	@emacs -Q --script build/blog-build.el \
          2>&1 | sed -E \
	  	-e $$'s/^Skipping .*$$/\e[90m&\e[0m/' \
	  	-e $$'s/^Publishing/\e[1;32m&\e[0m/' \
	  	-e $$'s/\\b([Ee]rror|[Ww]arning|[Ff]ailed)\\b/\e[1;31m&\e[0m/g'
	@date +"%Y-%m-%d %H:%M:%S.%3N" > .last_build_info

# Clean build: whole dist/ will be deleted first and then rebuilt.
# Slower than incremental build, but guarantees correct build.
# Implementation details:
#   Calling build-inc with FORCE is important step as it deletes org-publish's file timestamps cache,
#   otherwise org-publish would think dist/ still looks as it was before deleting it.
build-clean:
	rm -rf dist/
	ORG_PUBLISH_FORCE=1 $(MAKE) build-inc

# Serves content of dist/ via local web server, with live reload.
# Implementation details:
#   Using .last_build_info as a trigger for reloading the browser minimizes number of files that
#   need to be watched + is robust to files being deleted on rebuild before being written again.
serve:
	npx browser-sync start --server dist --files ".last_build_info" --port 8080

# Published dist/ dir to Cloudflare.
# Implementation details:
#   wrangler is Cloudflare's CLI. We have to select `release` branch even though we don't use it in
#   our repo because that is how Cloudflare works, it ties deployment envs to a specific git branch
#   name (and we want to push to production env here).
publish:
	@echo "Publishing dist/ to Cloudflare (project: todo-my-blog-project-name)!"
	@echo "Note: if you haven't yet, you will probably want to run 'make build-clean' first and check all is ok."
	@read -p "Type 'y' to continue: " -n 1 -r; echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
	  npx wrangler pages deploy ./dist --project-name todo-my-blog-project-name --branch=release; \
	fi
