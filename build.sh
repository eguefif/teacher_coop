#!/bin/sh

set -e

MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.gen.release --docker
MIX_ENV=prod mix release

TIMESTAMP=$(date +%Y%m%d%H%M%S)
IMAGE="eguefif/teacher_coop:$TIMESTAMP"

docker build -t "$IMAGE" .
docker push "$IMAGE"

echo "Built $IMAGE"

