#!/bin/bash

build_head=""

setup_git_config() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

setup_git_branches() {
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
    for branch in $(git branch -r|grep -v HEAD) ; do
        git checkout -qf ${branch#origin/}
    done
}

make_pr() {
    echo "check if current build is a pull request build"
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
        echo "this build is already a pull request one"
        exit 0
    fi

    echo "check if current branch is master"
    if [ "$TRAVIS_BRANCH" == "master" ]; then
        echo "skipping pull request from master to master"
        exit 0
    fi

    echo "checkout target branch"
    git checkout -f $TRAVIS_BRANCH

    diff=$(git diff HEAD~1 -- test)
    if [ -z "$diff" ]; then
        echo "test file was not changed" 
    else 
        echo "test file was updated, making pull request" 
        hub pull-request -m "test"
    fi
}

checkout_build() {
    echo "checking out build head"
    git checkout -qf ${build_head}
}

setup_git_config
setup_git_branches
make_pr
checkout_build
