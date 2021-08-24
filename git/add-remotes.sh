#!/bin/bash
# purpose: add all remotes for repo
# author: Jeff Reeves

# define repository's stub for the URL
REPO_STUB='substruct-server'

# create the repo directory on bridges
ssh git@bridges "mkdir /git/substruct-server.git && cd /git/substruct-server.git && git config --global init.defaultBranch main && git init --bare && sed -i 's/master/main/' /git/rpi4-custom-os.git/HEAD"

# add bridges to git remote list
git remote add bridges git@bridges:/git/substruct-server.git

# add gitlab to git remote list
git remote add gitlab git@gitlab.com:JeffReeves/substruct-server.git

# add github to git remote list
git remote add github git@github.com:JeffReeves/substruct-server.git

# update origin to bridges
git remote set-url origin git@bridges:/git/substruct-server.git

# view all remotes
git remote -v

# open settings for gitlab and github in browser
#explorer.exe "https://gitlab.com/JeffReeves/substruct-server/-/settings/repository"
#explorer.exe "https://gitlab.com/JeffReeves/substruct-server/-/branches"
#explorer.exe "https://github.com/JeffReeves/substruct-server/settings/branches"
#explorer.exe "https://github.com/JeffReeves/substruct-server/branches"

