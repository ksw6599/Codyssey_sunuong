#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
repo_dir=$PWD

# Linux 파일 권한은 WSL 내부 파일 시스템에서 검증한다.
practice_dir=$(mktemp -d)
trap 'rm -r -- "$practice_dir"' EXIT

set -x
uname -sr
cat /etc/os-release
bash --version | sed -n '1p'
git --version
cd "$practice_dir"
pwd
mkdir practice
cd practice
printf '%s\n' 'E1-1 terminal practice' > notes.txt
touch .hidden empty.txt
ls -la
cat notes.txt
cp -v notes.txt copy.txt
mv -v copy.txt renamed.txt
rm -v renamed.txt
wc -c empty.txt
mkdir shared
chmod 600 notes.txt
chmod 700 shared
stat -c '%a %A %n' notes.txt shared
chmod 644 notes.txt
chmod 755 shared
stat -c '%a %A %n' notes.txt shared
cd "$repo_dir"

docker --version
docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Driver={{.Driver}}'
docker run --rm hello-world
docker pull ubuntu:24.04
docker run -dit --name e11-ubuntu ubuntu:24.04 bash
docker exec e11-ubuntu bash -c 'ls /; echo exec-finished'
docker inspect -f '{{.State.Status}}' e11-ubuntu
docker stop e11-ubuntu
docker ps -a --filter name=e11-ubuntu
docker rm e11-ubuntu
docker run -di --name e11-attach ubuntu:24.04 bash
printf '%s\n' 'echo attached-to-main-shell' 'exit 0' | docker attach e11-attach
docker wait e11-attach
docker inspect -f '{{.State.Status}}' e11-attach
docker rm e11-attach

docker build -t e11-workbench:1.0 .
docker images
docker run -d --name e11-web -p 127.0.0.1:8781:80 e11-workbench:1.0
docker run -d --name e11-web-second -p 127.0.0.1:8782:80 e11-workbench:1.0
for port in 8781 8782; do
    curl -fsS --retry 6 --retry-all-errors -D - "http://127.0.0.1:$port/" |
        sed -n '1p; /NGINX 응답 정상/p'
done
docker ps --filter name=e11-web
docker logs --tail 5 e11-web
docker stats --no-stream e11-web e11-web-second
docker stop e11-web-second
docker ps -a --filter name=e11-web-second
docker rm e11-web-second

mkdir "$practice_dir/bind"
printf '%s\n' 'host version 1' > "$practice_dir/bind/index.html"
docker run -d --name e11-bind -p 127.0.0.1:8782:80 \
    --mount "type=bind,source=$practice_dir/bind,target=/usr/share/nginx/html,readonly" \
    e11-workbench:1.0
before=$(curl -fsS --retry 6 --retry-all-errors http://127.0.0.1:8782/)
printf '%s\n' "$before"
test "$before" = 'host version 1'
printf '%s\n' 'host version 2' > "$practice_dir/bind/index.html"
after=$(curl -fsS http://127.0.0.1:8782/)
printf '%s\n' "$after"
test "$after" = 'host version 2'
docker stop e11-bind
docker rm e11-bind

volume=$(docker volume create)
docker run --name e11-volume-writer -v "$volume:/data" ubuntu:24.04 \
    bash -c 'echo e11-volume-record > /data/check.txt; cat /data/check.txt'
docker rm e11-volume-writer
persisted=$(docker run --rm -v "$volume:/data:ro" ubuntu:24.04 cat /data/check.txt)
printf '%s\n' "$persisted"
test "$persisted" = 'e11-volume-record'
docker volume rm "$volume"
set +x
printf '%s\n' 'All checks passed. Web server: http://127.0.0.1:8781/'
