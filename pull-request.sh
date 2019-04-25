#!/bin/bash

build_head=""

echo "$TRAVIS_BRANCH"

setup_git_config() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

checkout_branch() {
    # Keep track of where Travis put us.
    # We are on a detached head, and we need to be able to go back to it.
    build_head=$(git rev-parse HEAD)

    # Fetch all the remote branches. Travis clones with `--depth`, which
    # implies `--single-branch`, so we need to overwrite remote.origin.fetch to
    # do that.
    git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch
    # optionally, we can also fetch the tags
    git fetch --tags

    # create the tacking branches
    git checkout -qf $TRAVIS_BRANCH
}

make_pr() {
    git checkout -$TAVIS_BRANCH
    diff=$(git diff HEAD~1 -- test)
    [ -z "$diff" ] && echo "Test file is empty." || hub pull-request -m "test"
    
    # finally, go back to where we were at the beginning
    git checkout ${build_head}
}

checkout_build() {
    git checkout -qf ${build_head}
}

setup_git_config
checkout_branch
make_pr
checkout_build
