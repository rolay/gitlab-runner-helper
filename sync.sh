#!/usr/bin/env sh

set -e

git tag > local.list
#tags=$(glab release list -R gitlab-org/gitlab-runner | tail -n +3 | awk '{ print $1 }' | grep -vf local.list)
tags="v14.9.2"

archs="x86_64 arm64"

for tag in $tags
do
  for arch in $archs
  do
    arch_target=$arch
    if [ $arch_target = "x86_64" ]; then
      arch_target="amd64"
    fi
    skopeo copy --dest-creds="$:$GITHUB_TOKEN" \
      docker://registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:alpine3.15-$arch-$tag \
      docker://ghcr.io/rolay/gitlab-runner-helper:alpine3.15-$arch_target-$tag
  done
  
  manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ghcr.io/rolay/gitlab-runner-helper:alpine3.15-ARCH-$tag \
    --target ghcr.io/rolay/gitlab-runner-helper:$tag
  gh release create $tag --generate-notes
done