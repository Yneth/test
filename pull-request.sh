#!/bin/bash

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

make_pr() {
    git checkout .
    git checkout $TAVIS_BRANCH
    git status
    diff=$(git diff HEAD~1 -- test)
    [ -z "$diff" ] && echo "Test file is empty." || hub pull-request -m "test"
}

setup_git
make_pr
