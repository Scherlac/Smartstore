PORT=5101
REMOTE=192.168.12.143:5001

docker run -i --rm -p $PORT:5000 ubuntu << EOF
apt update
apt install -y socat
socat -v tcp-listen:5000,reuseaddr,fork,bind=0.0.0.0 tcp:$REMOTE
EOF
