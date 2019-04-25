#!/bin/bash

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"

    # Keep track of where Travis put us.
    # We are on a detached head, and we need to be able to go back to it.
    local build_head=$(git rev-parse HEAD)

    # Fetch all the remote branches. Travis clones with `--depth`, which
    # implies `--single-branch`, so we need to overwrite remote.origin.fetch to
    # do that.
    git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch
    # optionally, we can also fetch the tags
    git fetch --tags

    # create the tacking branches
    for branch in $(git branch -r|grep -v HEAD) ; do
        git checkout -qf ${branch#origin/}
    done

    # finally, go back to where we were at the beginning
    git checkout ${build_head}
}


make_pr() {
    git checkout .
    git checkout -$TAVIS_BRANCH
    git status
    diff=$(git diff HEAD~1 -- test)
    [ -z "$diff" ] && echo "Test file is empty." || hub pull-request -m "test"
}

setup_git
make_pr
